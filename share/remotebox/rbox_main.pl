# Main Entry for RemoteBox
use strict;
use warnings;
use Gtk3;

our (%gui, %prefs, $endpoint, $fault);
my %cmdopts=();
$endpoint = 'http://localhost:18083';
$fault = sub{}; # Do nothing with faults until connected
rbprefs_get(); # Retrieve and set preferences
restore_window_pos($gui{d}{Main}{win});
addrow_msg_log("Welcome to $gui{appname} $gui{appver}");
getopts("H:u:p:h", \%cmdopts);
# Set Disconnected State
sens_unselected();
sens_connect(0);
clr_list_guest();
clr_vhost(); # Clear vhost so values are not retained on subsequent connections

if($cmdopts{h}) {
    print STDERR <<USAGE;
Usage:
    $0 [-h]
    $0 [-H <host>] [-u <user>] [-p <pass>]

    -h        : Help
    -H <host> : Automatically connect to this virtualbox host
    -u <user> : Connect using this username. If omitted an empty username is assumed. Only useful with -H
    -p <pass> : Connect using this password. If omitted an empty password is assumed. Only useful with -H
USAGE
    exit 0;
}
elsif ($cmdopts{H}) { show_dialog_connect('CMDAUTO'); } # Command line parameter based login
elsif ($prefs{AUTOCONNPROF}) { show_dialog_connect('PROFAUTO'); } # Profile based automatic login
$0 = 'RemoteBox VirtualBox Client';
$gui{d}{Main}{win}->show_all();
Gtk3->main;

sub quit_remotebox {
    save_window_pos($gui{d}{Main}{win}); # Also saves the main preferences
    virtualbox_logoff();
    Gtk3->main_quit;
}

# Attempts to logon or fails with a dialog
sub virtualbox_logon {
    my ($url, $user, $password) = @_;
    virtualbox_logoff(); # Ensure we disconnect from an existing connection
    $endpoint = $url;
    $fault = \&vboxlogonerror;
    $gui{websn} = IWebsessionManager_logon($user, $password);

    # Register timer events and run them immediately if needed.
    if ($gui{websn}) {
        $fault = \&vboxerror; # Install the fault capture
        $gui{servermem} = Glib::Timeout->add(30000, \&update_server_membar);
        update_server_membar();
        return 1;
    }

}

# Logoff and perform various necessary cleanups
sub virtualbox_logoff {
    my ($closewin) = @_;
    $fault = sub{}; # Disable fault capture. Protection against infinite loops

    # Remove timers
    Glib::Source->remove($gui{servermem}) if ($gui{servermem});

    # Force close any open windows - usually because we've hit a fault. This will cause them to
    # execute their cancel operations
    if ($closewin) {
        foreach my $win (Gtk3::Window->list_toplevels()) {
            next if ($win eq $gui{d}{Main}{win});
            $win->hide;
        }
    }

    if ($gui{websn}) {
        # Clean up resources. Not sure if this is truly needed but SDK recommends it
        my @IMachine = IVirtualBox_getMachines();
        foreach my $machine (@IMachine) { IManagedObjectRef_release($machine); }
        IWebsessionManager_logoff($gui{websn});
        $gui{websn} = undef;
    }

    # Return GUI to a disconnected state
    sens_unselected();
    sens_connect(0);
    clr_list_guest();
    clr_vhost(); # Clear vhost so values are not retained on subsequent connections
}

# Fill in the fields when a profile is selected
sub select_profile {
    my $liststore = $gui{d}{Connect}{cboxProfile}->get_model();
    my $iter = $gui{d}{Connect}{cboxProfile}->get_active_iter();
    my @profile = $liststore->get($iter) if (defined($iter) and $liststore->iter_is_valid($iter));

    if (@profile) {
        $gui{d}{Connect}{entryURL}->set_text($profile[1]);
        $gui{d}{Connect}{entryUser}->set_text($profile[2]);
        $gui{d}{Connect}{entryPass}->set_text($profile[3]);
    }
}

# Shows the connection dialog. Automatic logins take place here to ensure they
# follow the same path as a manual login. Be careful with the use of vhost in
# this sub
sub show_dialog_connect {
    my ($widget) = @_;
    my $response = 'cancel';
    $gui{d}{Connect}{checkSSL}->set_active($prefs{SSLVERIFY});

    if ($widget eq 'CMDAUTO') {
        $gui{d}{Connect}{entryURL}->set_text($cmdopts{H});
        $gui{d}{Connect}{entryUser}->set_text($cmdopts{u}) if ($cmdopts{u});
        $gui{d}{Connect}{entryPass}->set_text($cmdopts{p}) if ($cmdopts{p});
        $response = 'ok';
        addrow_msg_log("Starting automatic login (command line) to $cmdopts{H}");
    }
    elsif ($widget eq 'PROFAUTO') {
        my $iter = $gui{d}{Connect}{lstoreProfile}->get_iter_first();

        while(defined($iter) and $gui{d}{Connect}{lstoreProfile}->iter_is_valid($iter)) {
            my @profile = $gui{d}{Connect}{lstoreProfile}->get($iter);
            if ($profile[0] eq $prefs{AUTOCONNPROF}) {
                $gui{d}{Connect}{entryURL}->set_text($profile[1]);
                $gui{d}{Connect}{entryUser}->set_text($profile[2]);
                $gui{d}{Connect}{entryPass}->set_text($profile[3]);
                $response = 'ok';
                addrow_msg_log("Starting automatic login (profile) to $profile[1]");
                last;
            }

            $gui{d}{Connect}{lstoreProfile}->iter_next($iter); # Iter is modifed directly
        }
    }
    else { # Normal GUI login
        $gui{d}{Connect}{cboxProfile}->set_active(-1); # We don't want a current active
        $gui{d}{Connect}{dialog}->show_all();
        $response = $gui{d}{Connect}{dialog}->run();
        $gui{d}{Connect}{dialog}->hide();
    }

    $gui{d}{Connect}{dialog}->get_display->flush;

    if ($response eq 'ok') {
        my $url = strim($gui{d}{Connect}{entryURL}->get_text());
        my $user = strim($gui{d}{Connect}{entryUser}->get_text());
        $url = $endpoint if (!$url);
        $url =~ s/(\/)+$//g; # Remove all trailing
        $url = "http://$url" if ($url !~ m/^.+:\/\//);
        $url = "$url:18083" if ($url !~ m/:\d+$/);
        $prefs{URL}{$url} = 'URL' if ($url);
        $prefs{USER}{$user} = 'USER' if ($user);

        # If we got a successful logon
        if (virtualbox_logon($url, $user, $gui{d}{Connect}{entryPass}->get_text())) {
            my $ver = IVirtualBox_getVersion($gui{websn});

            if (!$ver) {
                # FIXME
                show_err_msg('connect', 0, "asasasasasas ($url)");
                virtualbox_logoff();
            }
            else {
                addrow_msg_log("Logged into $endpoint", "Running VirtualBox $ver");
                show_err_msg('vboxver', $prefs{NOVERSIONWARNDIALOG}, "Detected VirtualBox Version: $ver") if ($ver !~ m/^7.2/);
                my $vhost = vhost();

                if ($$vhost{vrdeextpack} =~ m/Built-in-VBoxVRDP/i) { $gui{d}{Main}{buttonDisplay}->set_label('_Guest Display (RDP)'); }
                elsif ($$vhost{vrdeextpack} =~ m/vnc/i) {
                    $gui{d}{Main}{buttonDisplay}->set_label('_Guest Display (VNC)');
                    addrow_msg_log('Warning: The Oracle VirtualBox Extension Pack is not installed.', '* This pack is only available for Linux, Windows, Solaris and MacOS ', '* Features which require this extension pack will be non-functional or unavailable');
                }
                else {
                    $gui{d}{Main}{buttonDisplay}->set_label('Guest Display Unavailable');
                    show_err_msg('noextensions', $prefs{NOEXTPACKWARNDIALOG});
                }

                if ($prefs{ADDADDITIONS}) {
                    if ($$vhost{additionsiso}) {
                        my ($vol, $dir, $file) = rsplitpath($$vhost{additionsiso});
                        my $IMedium = register_medium(undef, {type => 'DVD', mode => 'ReadOnly', basedir => $vol . $dir, file => $file});
                        addrow_msg_log('Warning: Could not automatically register the guest additions ISO with the VMM') if (!defined($IMedium));
                    }
                }

                fill_list_guest();
                sens_connect(1);
            }
        }
    }
}

# Display a progress window for tasks which can take a long time
sub show_progress_window {
    my ($IProgress, $msg, $decal) = @_;
    my $resultcode = 0;
    my $timer = 0;
    $decal ? $gui{d}{Progress}{img}->set_from_pixbuf($decal) : $gui{d}{Progress}{img}->set_from_pixbuf($gui{pb}{ProgressSettings});
    $gui{d}{Progress}{dialog}->set_title($msg);
    $gui{d}{Progress}{label}->set_text('Please Wait...'); # Reset text so its not cached from a previous call
    $gui{d}{Progress}{bar}->set_text(''); # Reset text so its not cached from a previous call
    $gui{d}{Progress}{bar}->set_fraction(0); # Reset fraction back to 0
    (IProgress_getCancelable($IProgress) eq 'true') ? $gui{d}{Progress}{buttonCancel}->show() : $gui{d}{Progress}{buttonCancel}->hide();
    Gtk3::main_iteration while Gtk3::events_pending;

    $timer = Glib::Timeout->add(1000,
        sub {
            $gui{d}{Progress}{buttonCancel}->hide() if (IProgress_getCancelable($IProgress) eq 'false'); # Sometimes cancellable earlier but not later on
            my $percent = IProgress_getPercent($IProgress);
            my $secsremaining = IProgress_getTimeRemaining($IProgress);
            $gui{d}{Progress}{label}->set_text(IProgress_getOperationDescription($IProgress));
            if (IProgress_getCompleted($IProgress) eq 'true') {
                Glib::Source->remove($timer);
                $timer = 0;
                $gui{d}{Progress}{bar}->set_fraction(1.00);
                $gui{d}{Progress}{bar}->set_text('100%');
                $resultcode = IProgress_getResultCode($IProgress);
                $gui{d}{Progress}{dialog}->response('ok');
                return 0;
            }
            else {

                $gui{d}{Progress}{bar}->set_fraction($percent * 0.01);
                if ($percent > 10 and $secsremaining > 0) {
                    my $humantime = secs_to_humantime($secsremaining);
                    $gui{d}{Progress}{bar}->set_text("$percent% (About $humantime remaining)");
                }
                else { $gui{d}{Progress}{bar}->set_text("$percent%"); }
                return 1;
            }
        });

    my $response = $gui{d}{Progress}{dialog}->run();
    $gui{d}{Progress}{dialog}->hide();
    Glib::Source->remove($timer) if ($timer);
    IProgress_cancel($IProgress) if ($response ne 'ok');
    Gtk3::main_iteration while Gtk3::events_pending;
    return $resultcode;
}

# Shows the about dialog
sub show_dialog_about {
    $gui{d}{About}{dialog}->run;
    $gui{d}{About}{dialog}->hide;
}

# Shows the custom video hint dialog
sub show_dialog_videohint {
    $gui{d}{CustomVideo}{sbVideoW}->set_value($prefs{AUTOHINTDISPX});
    $gui{d}{CustomVideo}{sbVideoH}->set_value($prefs{AUTOHINTDISPY});
    $gui{d}{CustomVideo}{dialog}->show_all();
    my $response = $gui{d}{CustomVideo}{dialog}->run();
    $gui{d}{CustomVideo}{dialog}->hide();

    if ($response eq 'ok') { return [$gui{d}{CustomVideo}{sbVideoW}->get_value_as_int(), $gui{d}{CustomVideo}{sbVideoH}->get_value_as_int(), getsel_combo($gui{d}{CustomVideo}{cboxVideoDepth}, 1)] }
    else { return [0,0,0]; }
}

# Shows a dialog with basic information about the VirtualBox server
sub show_dialog_serverinfo {
    fill_list_serverinfo();
    $gui{d}{ServerInfo}{dialog}->show_all();
    $gui{d}{ServerInfo}{dialog}->run();
    $gui{d}{ServerInfo}{dialog}->hide();
}

# Displays a dialog with the contents of the logs for a specific guest
sub show_dialog_log {
    my $gref = getsel_list_guest();
    fill_list_log($$gref{IMachine});
    $gui{d}{GuestLog}{dialog}->set_title("$$gref{Name} Guest Logs");
    $gui{d}{GuestLog}{dialog}->show_all();
    $gui{d}{GuestLog}{dialog}->run();
    $gui{d}{GuestLog}{dialog}->hide();
}

sub refresh_guest_logs {
    my $gref = getsel_list_guest();
    fill_list_log($$gref{IMachine});
}

# Saves a guest log to a text file.
sub guest_log_save {
    my $gref = getsel_list_guest();
    my $lognum = $gui{d}{GuestLog}{notebookLog}->get_current_page(); # We choose the log number by the page number
    $gui{d}{LogFileChooser}{dialog}->set_current_name("$$gref{Name}_log$lognum" . '.txt');
    $gui{d}{LogFileChooser}{dialog}->set_current_folder(Glib::get_home_dir());
    my $response = $gui{d}{LogFileChooser}{dialog}->run();
    $gui{d}{LogFileChooser}{dialog}->hide();
    my $filename = $gui{d}{LogFileChooser}{dialog}->get_filename();

    if ($response eq 'ok' and $filename) {
        if (open(my $guest_log_fh, '>', $filename)) {
            my $iter = $gui{d}{GuestLog}{'lstoreLog' . $lognum}->get_iter_first();

            while (defined($iter) and $gui{d}{GuestLog}{'lstoreLog' . $lognum}->iter_is_valid($iter)) {
                print $guest_log_fh $gui{d}{GuestLog}{'lstoreLog' . $lognum}->get($iter, 1) . "\n";
                $gui{d}{GuestLog}{'lstoreLog' . $lognum}->iter_next($iter);
            }

            close($guest_log_fh);
            addrow_msg_log("Guest log $lognum for $$gref{Name}, saved to $filename");
        }
        else { show_err_msg('guestlogsave', 0, "\nFile: $filename\nError: $!"); }
    }
}

# Save the contents of the message log into a file
sub save_msg_log {
    $gui{d}{LogFileChooser}{dialog}->set_current_name('remotebox-message-log.txt');
    $gui{d}{LogFileChooser}{dialog}->set_current_folder(Glib::get_home_dir());
    my $response = $gui{d}{LogFileChooser}{dialog}->run();
    $gui{d}{LogFileChooser}{dialog}->hide();
    my $filename = $gui{d}{LogFileChooser}{dialog}->get_filename();

    if($response eq 'ok' and $filename){
        if (open(my $msg_log_fh, '>', $filename)) {
            my $iter = $gui{d}{Main}{lstoreMsgLog}->get_iter_first();

            while (defined($iter) and $gui{d}{Main}{lstoreMsgLog}->iter_is_valid($iter)) {
                print $msg_log_fh $gui{d}{Main}{lstoreMsgLog}->get($iter, 0) . "\n";
                $gui{d}{Main}{lstoreMsgLog}->iter_next($iter);
            }

            close($msg_log_fh);
            addrow_msg_log("Saved the message log to: $filename");
        }
        else { show_err_msg('msglogsave', 0, "\nFile: $filename\nError: $!"); }
    }
}

# Show the export appliance dialog
sub show_dialog_exportappl {
    my $gref = getsel_list_guest();
    my $vhost = vhost();
    my $fname = rcatdir($$vhost{machinedir}, $$gref{Name});
    $gui{d}{ExportAppl}{entryFile}->set_text($fname);
    $gui{d}{ExportAppl}{entryName}->set_text($$gref{Name});
    $gui{d}{ExportAppl}{tbDescription}->set_text(IMachine_getDescription($$gref{IMachine}));

    # Determine if any media are USB attached as they are not supported by Appliances and
    # whether any media encrypted
    my @IMediumAttachment = IMachine_getMediumAttachments($$gref{IMachine});
    my %used_key_ids; # Key IDs can only be asked for once, we keep a used list here

    foreach my $attach (@IMediumAttachment) {
        my $IStorageController = IMachine_getStorageControllerByName($$gref{IMachine}, $$attach{controller});

        if (IStorageController_getBus($IStorageController) eq 'USB') {
            show_err_msg('exportapplusb', 0);
            return;
        }

        next if (!$$attach{medium}); # Empty DVD drive etc

        if (imedium_has_property($$attach{medium}, 'CRYPT/KeyStore')) {
            my $keyid = IMedium_getProperty($$attach{medium}, 'CRYPT/KeyId');
            if (!$used_key_ids{$keyid}) {
                my $passwd = show_dialog_decpasswd($$attach{medium}, $keyid);
                if ($passwd) { $used_key_ids{$keyid} = $passwd; }
                else { return; }
            }
        }
    }

    do {
        my $response = $gui{d}{ExportAppl}{dialog}->run();

        if ($response eq 'ok') {
            if (!$gui{d}{ExportAppl}{entryFile}->get_text()) { show_err_msg('invalidfile', 0); }
            elsif (!$gui{d}{ExportAppl}{entryName}->get_text()) { show_err_msg('invalidname', 0); }
            else {
                $gui{d}{ExportAppl}{dialog}->hide;
                my $location = $gui{d}{ExportAppl}{entryFile}->get_text() . getsel_combo($gui{d}{ExportAppl}{cboxFormat}, 2);
                my $IAppliance = IVirtualBox_createAppliance($gui{websn});
                foreach my $key (keys(%used_key_ids)) { IAppliance_addPasswords($IAppliance, $key, $used_key_ids{$key}); }
                my $IVirtualSystemDescription = IMachine_exportTo($$gref{IMachine}, $IAppliance, $location);
                IVirtualSystemDescription_addDescription($IVirtualSystemDescription, 'Name', $gui{d}{ExportAppl}{entryName}->get_text(), '');
                IVirtualSystemDescription_addDescription($IVirtualSystemDescription, 'Product', $gui{d}{ExportAppl}{entryProduct}->get_text(), '');
                IVirtualSystemDescription_addDescription($IVirtualSystemDescription, 'ProductUrl', $gui{d}{ExportAppl}{entryProductURL}->get_text(), '');
                IVirtualSystemDescription_addDescription($IVirtualSystemDescription, 'Vendor', $gui{d}{ExportAppl}{entryVendor}->get_text(), '');
                IVirtualSystemDescription_addDescription($IVirtualSystemDescription, 'VendorUrl', $gui{d}{ExportAppl}{entryVendorURL}->get_text(), '');
                IVirtualSystemDescription_addDescription($IVirtualSystemDescription, 'Version', $gui{d}{ExportAppl}{entryVersion}->get_text(), '');
                my ($iter_s, $iter_e) = ($gui{d}{ExportAppl}{tbDescription}->get_start_iter(), $gui{d}{ExportAppl}{tbDescription}->get_end_iter());
                IVirtualSystemDescription_addDescription($IVirtualSystemDescription, 'Description', $gui{d}{ExportAppl}{tbDescription}->get_text($iter_s, $iter_e, 0), '');
                ($iter_s, $iter_e) = ($gui{d}{ExportAppl}{tbLicense}->get_start_iter(), $gui{d}{ExportAppl}{tbLicense}->get_end_iter());
                IVirtualSystemDescription_addDescription($IVirtualSystemDescription, 'License', $gui{d}{ExportAppl}{tbLicense}->get_text($iter_s, $iter_e, 0), '');
                # The export options array is not at the end of the function so we have to make it a fixed size. In this case 3 elements.
                # We also cannot pass a null option, so choose something harmless and duplicate (CreateManifest). Messy but no way around it...
                my @exportopts = ('CreateManifest', 'CreateManifest', 'CreateManifest');
                $exportopts[1] = 'ExportDVDImages' if ($gui{d}{ExportAppl}{checkISO}->get_active() == 1);
                $exportopts[2] = 'StripAllNonNATMACs' if ($gui{d}{ExportAppl}{cboxMAC}->get_active() == 1);
                $exportopts[2] = 'StripAllMACs' if ($gui{d}{ExportAppl}{cboxMAC}->get_active() == 2);
                my $IProgress = IAppliance_write($IAppliance, getsel_combo($gui{d}{ExportAppl}{cboxFormat}, 1), @exportopts, $location);
                if ($IProgress) { show_progress_window($IProgress, "Exporting Appliance $$gref{Name}", $gui{pb}{ProgressExport}); }
                addrow_msg_log("Exported $$gref{Name} as an appliance to $location");
            }
        }
        else { $gui{d}{ExportAppl}{dialog}->hide; }

    } until (!$gui{d}{ExportAppl}{dialog}->get_visible());
}

sub show_dialog_snap_details {
    my $snapref = getsel_list_snapshots();

    if ($$snapref{ISnapshot}) { # This is needed in case a user double clicks on "Current State" which is not a real snapshot
        $gui{d}{Snapshot}{Name}->set_text(ISnapshot_getName($$snapref{ISnapshot}));
        $gui{d}{Snapshot}{tbDescription}->set_text(ISnapshot_getDescription($$snapref{ISnapshot}));
        my $response = $gui{d}{Snapshot}{dialog}->run;
        $gui{d}{Snapshot}{dialog}->hide;

        if ($response eq 'ok') {
            my ($iter_s, $iter_e) = ($gui{d}{Snapshot}{tbDescription}->get_start_iter(), $gui{d}{Snapshot}{tbDescription}->get_end_iter());
            ISnapshot_setDescription($$snapref{ISnapshot}, $gui{d}{Snapshot}{tbDescription}->get_text($iter_s, $iter_e, 0));
            ISnapshot_setName($$snapref{ISnapshot}, $gui{d}{Snapshot}{Name}->get_text());
            fill_list_guest();
        }
    }
}

sub show_dialog_snapshot {
    $gui{d}{Snapshot}{Name}->set_text('Snapshot');
    $gui{d}{Snapshot}{tbDescription}->set_text('');
    my $response = $gui{d}{Snapshot}{dialog}->run();
    $gui{d}{Snapshot}{dialog}->hide();

    if ($response eq 'ok') {
        my ($iter_s, $iter_e) = ($gui{d}{Snapshot}{tbDescription}->get_start_iter(), $gui{d}{Snapshot}{tbDescription}->get_end_iter());
        take_snapshot($gui{d}{Snapshot}{Name}->get_text(), $gui{d}{Snapshot}{tbDescription}->get_text($iter_s, $iter_e, 0));
    }
}

# Discards the saved execution state for a guest
sub discard_saved_state {
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});
    IMachine_discardSavedState($$sref{IMachine}, 'true');
    addrow_msg_log("Discarded saved execution state of $$gref{Name}");
    fill_list_guest();
    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Performs a reset of the guest
sub reset_guest {
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} eq 'Shared') {
        IConsole_reset(ISession_getConsole($$sref{ISession}));
        addrow_msg_log("Reset signal sent to $$gref{Name}");
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Stops the guest
sub stop_guest {
    if ($prefs{STOPTYPE} eq 'ACPI') { stop_guest_acpi(); }
    elsif ($prefs{STOPTYPE} eq 'STATE') { stop_guest_savestate(); }
    else { stop_guest_poweroff(); }
}

# Stops a guest by issuing a hard poweroff
sub stop_guest_poweroff {
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} eq 'Shared') {
        my $IConsole = ISession_getConsole($$sref{ISession});

        if (my $IProgress = IConsole_powerDown($IConsole)) { # Not cancellable
            show_progress_window($IProgress, "Powering off $$gref{Name}", $gui{pb}{ProgressPowerOff});
            addrow_msg_log("Power off signal sent to $$gref{Name}");
            fill_list_guest();
        }
        else { addrow_msg_log("Warning: Power off signal could not be sent to $$gref{Name}"); }
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Tries to stop a guest by sending the ACPI shutdown signal
sub stop_guest_acpi {
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} eq 'Shared') {
        IConsole_powerButton(ISession_getConsole($$sref{ISession}));
        addrow_msg_log("ACPI shutdown signal sent to $$gref{Name}", "* Shutdown is not guaranteed as it depends on the OS and its configuration");
        fill_list_guest();
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Stops a guest and save it's execution state
sub stop_guest_savestate {
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} eq 'Shared') {
        if (my $IProgress = IMachine_saveState($$sref{IMachine})) { # Not cancellable
            show_progress_window($IProgress, "Saving execution state of $$gref{Name}", $gui{pb}{ProgressStateSave});
            addrow_msg_log("Execution state of $$gref{Name} saved");
            fill_list_guest();
        }
        else { addrow_msg_log("Warning: Execution state of $$gref{Name} could not be saved"); }
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Pauses the execution of the guest
sub pause_guest {
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} eq 'Shared') {
        IConsole_pause(ISession_getConsole($$sref{ISession}));
        addrow_msg_log("Paused the execution of $$gref{Name}");
        fill_list_guest();
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Resumes the execution state for a guest that has one saved
sub resume_guest {
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} eq 'Shared') {
        IConsole_resume(ISession_getConsole($$sref{ISession}));
        addrow_msg_log("Resumed the execution state of $$gref{Name}");
        fill_list_guest();
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Starts a guest
sub start_guest {
    my $gref = getsel_list_guest();
    my $ISession = IWebsessionManager_getSessionObject($gui{websn});
    return if (ISession_getState($ISession) ne 'Unlocked');

    # VB 6.1.0 seems to insist the environmentChanges options cannot be empty (probably a bug). Set a dummy one
    my $IProgress = IMachine_launchVMProcess($$gref{IMachine}, $ISession, 'headless', 'DUMMY=DUMMY');
    my $started = 0;

    if ($IProgress) { # Is Cancellable
        my $resultcode = show_progress_window($IProgress, "Starting guest $$gref{Name}", $gui{pb}{ProgressStart});

        if (IProgress_getCanceled($IProgress) eq 'true') { addrow_msg_log("Starting guest $$gref{Name} cancelled"); }
        elsif ($resultcode != 0) {
            my $IVirtualBoxErrorInfo = IProgress_getErrorInfo($IProgress);
            show_err_msg('startguest', 0, "Guest: $$gref{Name}\nCode: $resultcode\nError:\n" . IVirtualBoxErrorInfo_getText($IVirtualBoxErrorInfo));
        }
        else {
            $started = 1;
            addrow_msg_log("Start signal sent to $$gref{Name}");
            my @IMediumAttachment = IMachine_getMediumAttachments($$gref{IMachine});
            my %used_key_ids; # Key IDs can only be asked for once, we keep a used list here

            foreach my $attach (@IMediumAttachment) { # Determine if we have anything encrypted and prompt for password
                next if ($$attach{type} ne 'HardDisk');

                if (imedium_has_property($$attach{medium}, 'CRYPT/KeyStore')) {
                    my $keyid = IMedium_getProperty($$attach{medium}, 'CRYPT/KeyId');

                    if (!$used_key_ids{$keyid}) {
                        my $passwd = show_dialog_decpasswd($$attach{medium}, $keyid);

                        if ($passwd) {
                            my $gref = getsel_list_guest();
                            my $sref = get_session($$gref{IMachine});

                            if ($$sref{Lock} eq 'Shared') {
                                my $IConsole = ISession_getConsole($$sref{ISession});
                                IConsole_addEncryptionPassword($IConsole, $keyid, $passwd, 0);
                            }

                            ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
                            $used_key_ids{$keyid} = $passwd;
                        }
                        else {
                            $started = 0;
                            stop_guest_poweroff();
                        }
                    }
                }
            }
        }
    }
    else { show_err_msg('sessionopen', 0, " ($$gref{Name})"); }

    ISession_unlockMachine($ISession) if (ISession_getState($ISession) ne 'Unlocked');
    open_remote_display() if ($prefs{RDPAUTOOPEN} and $started);
    fill_list_guest() if ($started);
}

# Removes a guest, optionally deleting associated files
sub remove_guest {
    my $gref = getsel_list_guest();
    $gui{d}{RemoveGuest}{dialog}->show_all();
    my $response = $gui{d}{RemoveGuest}{dialog}->run();
    $gui{d}{RemoveGuest}{dialog}->hide;

    if ($response eq '1') { # Remove Only
        IMachine_unregister($$gref{IMachine}, 'DetachAllReturnNone');
        unlink("$gui{THUMBDIR}/$$gref{Uuid}.png") if (-e "$gui{THUMBDIR}/$$gref{Uuid}.png"); # Remove screenshot icon
        addrow_msg_log("Removed $$gref{Name} from the VirtualBox registry");
        fill_list_guest();
    }
    elsif ($response eq '2') { # Delete all
        my @IMedium = IMachine_unregister($$gref{IMachine}, 'DetachAllReturnHardDisksOnly');

        foreach my $medium (@IMedium) { # Is cancellable
            my $IProgress = IMachine_deleteConfig($$gref{IMachine}, $medium);
            show_progress_window($IProgress, 'Deleting hard disk image', $gui{pb}{ProgressMediaDelete});
            if (IProgress_getCanceled($IProgress) eq 'true') { addrow_msg_log('Cancelled hard disk deletion'); }
        }

        unlink("$gui{THUMBDIR}/$$gref{Uuid}.png") if (-e "$gui{THUMBDIR}/$$gref{Uuid}.png"); # Remove screenshot icon
        addrow_msg_log("Removed and deleted $$gref{Name} from the VirtualBox registry");
        fill_list_guest();
    }
}

# Restores a guest to a snapshot state
sub restore_snapshot {
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Type} eq 'WriteLock') { # Not cancellable
        my $snapref = getsel_list_snapshots();
        my $IProgress = IMachine_restoreSnapshot($$sref{IMachine}, $$snapref{ISnapshot});
        show_progress_window($IProgress, 'Restoring snapshot', $gui{pb}{ProgressSnapshotRestore});
        addrow_msg_log("Restored snapshot of $$gref{Name}");
    }
    else { show_err_msg('restorefail', 0, " ($$gref{Name})"); }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
    fill_list_guest(); # This also refreshes the snapshot list
}

# Deletes a guest snapshot
sub delete_snapshot {
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} ne 'None') {
        my $snapref = getsel_list_snapshots();

        if (ISnapshot_getChildrenCount($$snapref{ISnapshot}) > 1) { show_err_msg('snapdelchild', 0, " ($$gref{Name})"); }
        else { # Not cancellable
            my $snapuuid = ISnapshot_getId($$snapref{ISnapshot});
            my $IProgress = IMachine_deleteSnapshot($$sref{IMachine}, $snapuuid);
            show_progress_window($IProgress, 'Deleting snapshot', $gui{pb}{ProgressSnapshotDiscard}) if ($IProgress);
            addrow_msg_log("Deleted snapshot of $$gref{Name}");
        }
    }
    else { show_err_msg('snapdelete', 0, " ($$gref{Name})"); }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
    fill_list_guest(); # This also refreshes the snapshot list
}

# Takes a snapshot of a guest
sub take_snapshot {
    my ($name, $description) = @_;
    $name = 'Snapshot' if (!$name);
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} ne 'None') { # Not cancellable
        my ($snapid, $IProgress) = IMachine_takeSnapshot($$sref{IMachine}, $name, $description, 'true');
        show_progress_window($IProgress, 'Taking snapshot', $gui{pb}{ProgressSnapshotCreate}) if ($IProgress);
        addrow_msg_log("Created snapshot of $$gref{Name} called $name");
    }
    else { show_err_msg('snapshotfail', 0, " ($$gref{Name})"); }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
    fill_list_guest(); # This also refreshes the snapshot list
}

# Attempts to open the remote display by calling the RDP/VNC client
sub open_remote_display {
    my $vhost = vhost();
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} eq 'Shared') {
        my $IConsole = ISession_getConsole($$sref{ISession});
        my $IVRDEServer = IMachine_getVRDEServer($$gref{IMachine});
        my $bindaddress = strim(IVRDEServer_getVRDEProperty($IVRDEServer, 'TCP/Address'));
        my $IVRDEServerInfo = IConsole_getVRDEServerInfo($IConsole);

        for (1..5) { # Wait up to 5 seconds for the VRDE server to start
            last if ($$IVRDEServerInfo{port} != -1);
            addrow_msg_log("Waiting on RDP/VNC service to be available for $$gref{Name}");
            $IVRDEServerInfo = IConsole_getVRDEServerInfo($IConsole);
            sleep 1;
        }

        if ($$IVRDEServerInfo{port} > 0) {
            if ($prefs{AUTOHINTDISP}) {
                IDisplay_setVideoModeHint(IConsole_getDisplay($IConsole), 0, 1, 0, 0, 0, $prefs{AUTOHINTDISPX}, $prefs{AUTOHINTDISPY}, $prefs{AUTOHINTDISPD});
                addrow_msg_log("Sent video hint ($prefs{AUTOHINTDISPX}x$prefs{AUTOHINTDISPY}:$prefs{AUTOHINTDISPD}) to $$gref{Name}");
            }

            my $dst = $bindaddress ? $bindaddress : $endpoint; # If there's a specific bind address for the guest use that
            my $dispcmd = ($$vhost{vrdeextpack} =~ m/vnc/i) ? $prefs{VNCCLIENT} : $prefs{RDPCLIENT};
            my ($user, $pass) = ($gui{d}{Connect}{entryUser}->get_text(), $gui{d}{Connect}{entryPass}->get_text());
            $dst =~ s/^.*:\/\///;
            $dst =~ s/:\d+$//;
            $dispcmd =~ s/%h/$dst/g;
            $dispcmd =~ s/%p/$$IVRDEServerInfo{port}/g;
            $dispcmd =~ s/%n/$$gref{Name}/g;
            $dispcmd =~ s/%o/$$gref{Os}/g;
            $dispcmd =~ s/%U/$user/g;
            $dispcmd =~ s/%P/$pass/g;
            $dispcmd =~ s/%X/$prefs{AUTOHINTDISPX}/g;
            $dispcmd =~ s/%Y/$prefs{AUTOHINTDISPY}/g;
            $dispcmd =~ s/%D/$prefs{AUTOHINTDISPD}/g;
            addrow_msg_log("Request sent to open the display of $$gref{Name} at address $dst:$$IVRDEServerInfo{port}", $dispcmd);
            # The client must run in the background or the GUI blocks until it exits.
            # On Windows, system(1, ...) starts a process without waiting for it.
            ($^O =~ m/MSWin/) ? system(1, $dispcmd) : system("$dispcmd &");
        }
        else { show_err_msg('remotedisplay', 0, " ($$gref{Name})"); }
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Displays a popup machine menu on the guest list when the right mouse button is pressed
sub show_rmb_menu {
    my ($widget, $event) = @_;

    # Check if it's the RMB otherwise do nothing
    if ($event->button == 3) {
        # This code is needed because if the user just presses the RMB, then GTK has not updated the
        # location of the cursor until AFTER this routine is complete meaning we will be referencing the
        # wrong VM. We need to force a cursor update first.
        my ($path, $col) = $gui{d}{Main}{treeviewGuest}->get_path_at_pos(int($event->x), int($event->y));
        if ($path) {
            $gui{d}{Main}{treeviewGuest}->grab_focus();
            $gui{d}{Main}{treeviewGuest}->set_cursor($path, undef, 0);
        }

        $gui{menu}{Devices}->popup(undef, undef, undef, undef, 0, $event->time);
        return 1;
    }

    return 0;
}

# Called when parent DVD menu is highlighted. Cheaper than calling each time main menu is opened
sub fill_menu_optical {
    my $vhost = vhost();
    my $menu = gui_new_menu();
    $gui{mi}{DVD}->set_submenu($menu);
    my $itema = gui_new_menu_item_no_mnemonic('Add Optical Disc Image', 'cd_add_16px.png', $menu);
    $itema->signal_connect('activate' => \&show_remote_filechooser, {title => 'Choose Disc Image', entrywidget => '', mode => 'file', filter => '^.*\.iso$', callback => \&devices_menu_add_optical_disc});
    my $itemb = gui_new_menu_item_no_mnemonic('Eject Optical Disc', 'cd_clear_16px.png', $menu);
    $itemb->signal_connect('activate' => \&insert_removable_disk_first_drive, {IMedium => '', type => 'DVD'});
    $menu->append(Gtk3::SeparatorMenuItem->new());

    if ($$vhost{dvd}) {
        my $added;

        foreach my $pdvd (@{$$vhost{dvd}}) {
            $added = 1;
            my $item = gui_new_menu_item_no_mnemonic('<Server Drive> ' . IMedium_getLocation($pdvd), 'cd_16px.png', $menu);
            $item->signal_connect('activate' => \&insert_removable_disk_first_drive, {IMedium => $pdvd, type => 'DVD'});
        }

        $menu->append(Gtk3::SeparatorMenuItem->new()) if ($added); # Only add separator if a host drive was added
    }

    my $IMediumRef = get_all_media('DVD');

    foreach (sort { lc($$IMediumRef{$a}) cmp lc($$IMediumRef{$b}) } (keys %$IMediumRef)) {
        my $item = gui_new_menu_item_no_mnemonic($$IMediumRef{$_}, 'cd_16px.png', $menu);
        $item->signal_connect('activate' => \&insert_removable_disk_first_drive, {IMedium => $_, type => 'DVD'});
    }
}

# Called when parent USB menu is highlighted. Cheaper than calling each time machine menu is opened
sub fill_menu_usb {
    my %connected;
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} eq 'Shared') {
        my $usbmenu =  gui_new_menu();
        $gui{mi}{USB}->set_submenu($usbmenu);
        my @IHostUSBDevices = IHost_getUSBDevices(IVirtualBox_getHost($gui{websn}));
        my @USBDevices = IConsole_getUSBDevices(ISession_getConsole($$sref{ISession}));

        foreach my $IUSBDevice (@USBDevices) { $connected{IUSBDevice_getId($IUSBDevice)} = 1; }

        foreach my $usb (@IHostUSBDevices) {
            my $label = usb_make_label(IUSBDevice_getManufacturer($usb),
                                        IUSBDevice_getProduct($usb),
                                        sprintf('%04x', IUSBDevice_getRevision($usb)));

            my $item = gui_new_check_menu_item($label, $usbmenu);
            my $usbid = IUSBDevice_getId($usb);
            $item->set_active(1) if $connected{$usbid};
            $item->signal_connect(activate => \&mount_usb_online, [$usbid, $label]);
        }
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Fills the menu with the number of hot pluggable CPUs
sub fill_menu_cpu {
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} eq 'Shared') {
        my $cpumenu = gui_new_menu();
        $gui{mi}{HotPlugCPU}->set_submenu($cpumenu);
        my $cpucount = IMachine_getCPUCount($$sref{IMachine});

        # CPU 0 is special - it can never be detached.
        my $item = gui_new_check_menu_item('vCPU 0', $cpumenu);
        $item->set_active(1);
        $item->set_sensitive(0);
        $item->set_tooltip_text('vCPU 0 is never hot pluggable');

        foreach my $cpunum (1..($cpucount - 1)) {
            my $item = gui_new_check_menu_item("vCPU $cpunum", $cpumenu);
            $item->set_active(1) if (bl(IMachine_getCPUStatus($$sref{IMachine}, $cpunum)));
            $item->signal_connect(activate => \&mount_cpu_online, $cpunum);
        }
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Attaches or detaches a processor whilst the guest is online
sub mount_cpu_online {
    my ($widget, $cpunum) = @_;
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} eq 'Shared') {
        if ($widget->get_active()) {
            IMachine_hotPlugCPU($$sref{IMachine}, $cpunum);
            addrow_msg_log("Hot plugging vCPU $cpunum for $$gref{Name}.");
        }
        else {
            IMachine_hotUnplugCPU($$sref{IMachine}, $cpunum);
            addrow_msg_log("Hot Unplugging  vCPU $cpunum for $$gref{Name}.");
        }

        IMachine_saveSettings($$sref{IMachine});
    }
    else { addrow_msg_log("Error: Could not change the status of CPU $cpunum for $$gref{Name}."); }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Attaches or detaches a USB device whilst the guest is online
sub mount_usb_online {
    my ($widget, $dataref) = @_;
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} eq 'Shared') {
        my $IConsole = ISession_getConsole($$sref{ISession});

        if ($widget->get_active()) {
            IConsole_attachUSBDevice($IConsole, $$dataref[0]);
            addrow_msg_log("Attached USB device '$$dataref[1]' to $$gref{Name}.");
        }
        else {
            IConsole_detachUSBDevice($IConsole, $$dataref[0]);
            addrow_msg_log("Detached USB device '$$dataref[1]' from $$gref{Name}.");
        }

        IMachine_saveSettings($$sref{IMachine});
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Dynamically fills the floppy menu of the devices menu
sub fill_menu_floppy {
    my $gref = getsel_list_guest();
    my $vhost = vhost();
    my $menu = gui_new_menu();
    my $itema = gui_new_menu_item_no_mnemonic('Add Floppy Disk Image', 'fd_add_16px.png', $menu);
    $itema->signal_connect('activate' => \&show_remote_filechooser, {title => 'Choose Floppy Image', entrywidget => '', mode => 'file', filter => '^.*\.img$', callback => \&devices_menu_add_floppy_disk});
    my $itemb = gui_new_menu_item_no_mnemonic('New Floppy Disk Image', 'fd_create_16px.png', $menu);
    $itemb->signal_connect('activate' => \&show_dialog_create_floppy, {IMachine => $$gref{IMachine}, filename => rcatfile($$vhost{machinedir}, 'Floppy-' . int(rand(999999))), callback => \&insert_removable_disk_first_drive});
    my $itemc = gui_new_menu_item_no_mnemonic('Eject Floppy Disk', 'fd_clear_16px.png', $menu);
    $itemc->signal_connect('activate' => \&insert_removable_disk_first_drive, {IMedium => '', type => 'Floppy'});
    $menu->append(Gtk3::SeparatorMenuItem->new());

    if ($$vhost{floppy}) {
        my $added;

        foreach my $pfloppy (@{$$vhost{floppy}}) {
            $added = 1;
            my $item = gui_new_menu_item_no_mnemonic('<Server Drive> ' . IMedium_getLocation($pfloppy), 'fd_16px.png', $menu);
            $item->signal_connect('activate' => \&insert_removable_disk_first_drive, {IMedium => $pfloppy, type => 'Floppy'});
        }

        $menu->append(Gtk3::SeparatorMenuItem->new()) if ($added); # Only add separator if a host drive was added
    }

    my $IMediumRef = get_all_media('Floppy');

    foreach (sort { lc($$IMediumRef{$a}) cmp lc($$IMediumRef{$b}) } (keys %$IMediumRef)) {
        my $item = gui_new_menu_item_no_mnemonic($$IMediumRef{$_}, 'fd_16px.png', $menu);
        $item->signal_connect('activate' => \&insert_removable_disk_first_drive, {IMedium => $_, type => 'Floppy'});
    }

    $gui{mi}{Floppy}->set_submenu($menu);
}

# Called from the devices menu
sub devices_menu_add_floppy_disk {
    my ($basedir, $file) = @_;
    my $IMedium = register_medium(undef, {type => 'Floppy', mode => 'ReadWrite', basedir => $basedir, file => $file});
    insert_removable_disk_first_drive(undef, {IMedium => $IMedium, type => 'Floppy'}) if ($IMedium);
}

# Called from the devices menu
sub devices_menu_add_optical_disc {
    my ($basedir, $file) = @_;
    my $IMedium = register_medium(undef, {type => 'DVD', mode => 'ReadOnly', basedir => $basedir, file => $file});
    insert_removable_disk_first_drive(undef, {IMedium => $IMedium, type => 'DVD'}) if ($IMedium);
}

# Inserts a removable in the first drive found
sub insert_removable_disk_first_drive {
    my ($widget, $medium) = @_;
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});
    my @IMediumAttachment = IMachine_getMediumAttachments($$sref{IMachine});
    my $found = 0;

    foreach my $attach (@IMediumAttachment) {
        next if ($$attach{type} ne $$medium{type});
        IMachine_mountMedium($$sref{IMachine}, $$attach{controller}, $$attach{port}, $$attach{device}, $$medium{IMedium}, 0);
        onsel_list_guest() if ($gui{d}{Main}{treeviewGuest}->get_selection->get_selected());
        $found = 1;
        addrow_msg_log("Changed $$medium{type} medium for $$gref{Name}");
        last;
    }

    show_err_msg('nodrive', 0) if ($$medium{type} eq 'DVD' and !$found);
    show_err_msg('nofloppydrive', 0) if ($$medium{type} eq 'Floppy' and !$found);
    IMachine_saveSettings($$sref{IMachine});
    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

sub keyboard_CAD {
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} eq 'Shared') {
        my $IKeyboard = IConsole_getKeyboard(ISession_getConsole($$sref{ISession}));
        IKeyboard_putCAD($IKeyboard);
        addrow_msg_log("Keyboard sequence Ctrl-Alt-Delete sent to $$gref{Name}");
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Attempts to release any pressed keys if the host and the guest become out of sync
sub keyboard_releasekeys {
    my ($widget) = @_;
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{IMachine}) {
        my $IKeyboard = IConsole_getKeyboard(ISession_getConsole($$sref{ISession}));
        IKeyboard_releaseKeys($IKeyboard);
        addrow_msg_log("Keyboard release keys signal to $$gref{Name}");
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Sends a sequence of keyboard scan codes depending on the option chosen
sub keyboard_send {
    my ($widget, $scancodes) = @_;
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{IMachine}) {
        my $IKeyboard = IConsole_getKeyboard(ISession_getConsole($$sref{ISession}));
        IKeyboard_putScancode($IKeyboard, $_) foreach (@{$$scancodes{codes}});
        addrow_msg_log("Keyboard sequence $$scancodes{desc} sent to $$gref{Name}");
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Updates the video memory requirement when choosing a custom video hint
sub update_vidmeminfo {
    my $w = $gui{d}{CustomVideo}{sbVideoW}->get_value_as_int();
    my $h = $gui{d}{CustomVideo}{sbVideoH}->get_value_as_int();
    my $d = getsel_combo($gui{d}{CustomVideo}{cboxVideoDepth}, 1);
    $gui{d}{CustomVideo}{labelVideoInfo}->set_text('This resolution requires a minimum of ' . vram_needed($w, $h, $d) . 'MB of video memory');
}

# Sends a video mode hint to the guest
sub send_video_hint {
    my ($widget, $res) = @_;
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($widget eq $gui{mi}{SetVideoCustom}) { $res = show_dialog_videohint(); }

    # This checks if the custom res window got cancels as the resolution will be 0
    if ($$res[0] > 0) {
        if ($$sref{IMachine}) {
            my $IConsole = ISession_getConsole($$sref{ISession});
            IDisplay_setVideoModeHint(IConsole_getDisplay($IConsole), 0, 1, 0, 0, 0, $$res[0], $$res[1], $$res[2], 1);
            addrow_msg_log("Video hint ($$res[0]x$$res[1]:$$res[2]) sent to $$gref{Name}");
        }
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Return a hash reference with name as key. Useful for sorting
sub get_all_media {
    my ($type) = @_;
    my @IMedium;
    my %media;

    if ($type eq 'DVD') { @IMedium = IVirtualBox_getDVDImages($gui{websn}); }
    elsif ($type eq 'Floppy') { @IMedium = IVirtualBox_getFloppyImages($gui{websn}); }
    else { @IMedium = IVirtualBox_getHardDisks($gui{websn}); }

    $media{$_} = IMedium_getName($_) foreach (@IMedium);
    return \%media;
}

# Return an appropriate session
sub get_session {
    my ($IMachine) = @_;
    my $ISession = IWebsessionManager_getSessionObject($gui{websn});
    my %state = (Lock     => 'None',
                 Type     => 'None',
                 IMachine => 0,
                 ISession => 0);

    if (IMachine_getSessionState($IMachine)  eq 'Unlocked') {
        IMachine_lockMachine($IMachine, $ISession, 'VM');
        $state{Lock} = 'VM';
        $state{Type} = ISession_getType($ISession);
        $state{IMachine} = ISession_getMachine($ISession);
        $state{ISession} = $ISession;
    }
    elsif (IMachine_getSessionState($IMachine)  eq 'Locked') {
        # Theoretically we shouldn't return a writelock here because it should have already been locked
        IMachine_lockMachine($IMachine, $ISession, 'Shared');
        $state{Lock} = 'Shared';
        $state{Type} = ISession_getType($ISession);
        $state{IMachine} = ISession_getMachine($ISession);
        $state{ISession} = $ISession;
    }

    return \%state;
}

# Encrypts a hard disk image. *MUST* only be given hard disk images
sub encrypt_disk {
    my ($IMedium, $currentpasswd, $cipher, $newpasswd, $passwdid) = @_;
    my $name = IMedium_getName($IMedium);
    my @mids = IMedium_getMachineIds($IMedium);

    # Not allowed to have children
    if (IMedium_getChildren($IMedium)) {
        addrow_msg_log("Warning: The Medium $name cannot be encrypted because it has child media");
        return 1;
    }

    if (scalar(@mids) > 1) {
        addrow_msg_log("Warning: The Medium $name cannot be encrypted because it is attached to more than one guest");
        return 1;
    }

    my $IProgress = IMedium_changeEncryption($IMedium, $currentpasswd, $cipher, $newpasswd, $passwdid);
    addrow_msg_log("Enrypting the disk image $name with $cipher");
    show_progress_window($IProgress, "Encrypting Disk Image $name");
    return 0;
}

# Returns whether the IMedium object has a particular property.
# Uses getProperties to avoid VirtualBox from issuing an error when
# other methods would.
sub imedium_has_property {
    my ($IMedium, $property) = @_;
    my @properties = IMedium_getProperties($IMedium, undef); # Note, SDK states second parameter is ignored
    my %props = map { $_ => 1 } @properties; # convert to hash
    return (exists($props{$property}));
}

# Set sensitivity based on connection state
sub sens_connect {
    my ($state) = @_;
    $gui{mi}{New}->set_sensitive($state);
    $gui{mi}{Add}->set_sensitive($state);
    $gui{mi}{ImportAppl}->set_sensitive($state);
    $gui{mi}{VMM}->set_sensitive($state);
    $gui{mi}{HostNetMan}->set_sensitive($state);
    $gui{mi}{ServerInfo}->set_sensitive($state);
    $gui{mi}{VBPrefs}->set_sensitive($state);
    $gui{d}{Main}{buttonNew}->set_sensitive($state);
    $gui{d}{Main}{buttonRefresh}->set_sensitive($state);
    $gui{d}{Main}{barMem}->show();
}

# Sets the sensitivity when no guest is selected
sub sens_unselected {
    $gui{mi}{ExportAppl}->set_sensitive(0);
    $gui{mi}{Action}->set_sensitive(0);
    $gui{mi}{Start}->set_sensitive(0);
    $gui{mi}{Stop}->set_sensitive(0);
    $gui{mi}{Pause}->set_sensitive(0);
    $gui{mi}{Resume}->set_sensitive(0);
    $gui{mi}{Settings}->set_sensitive(0);
    $gui{mi}{Clone}->set_sensitive(0);
    $gui{mi}{SetGroup}->set_sensitive(0);
    $gui{mi}{Ungroup}->set_sensitive(0);
    $gui{mi}{Discard}->set_sensitive(0);
    $gui{mi}{Reset}->set_sensitive(0);
    $gui{mi}{Remove}->set_sensitive(0);
    $gui{mi}{Keyboard}->set_sensitive(0);
    $gui{mi}{Display}->set_sensitive(0);
    $gui{mi}{HotPlugCPU}->set_sensitive(0);
    $gui{mi}{DVD}->set_sensitive(0);
    $gui{mi}{Floppy}->set_sensitive(0);
    $gui{mi}{USB}->set_sensitive(0);
    $gui{mi}{Screenshot}->set_sensitive(0);
    $gui{mi}{Logs}->set_sensitive(0);
    $gui{d}{Main}{buttonStart}->set_sensitive(0);
    $gui{d}{Main}{buttonStop}->set_sensitive(0);
    $gui{d}{Main}{buttonSettings}->set_sensitive(0);
    $gui{d}{Main}{buttonDisplay}->set_sensitive(0);
    $gui{d}{Main}{buttonCAD}->set_sensitive(0);
    $gui{d}{Main}{buttonDiscard}->set_sensitive(0);
    $gui{d}{Main}{buttonReset}->set_sensitive(0);
    $gui{d}{Main}{buttonRefreshSnap}->set_sensitive(0);
    $gui{d}{Main}{buttonCloneSnap}->set_sensitive(0);
    $gui{d}{Main}{buttonTakeSnap}->set_sensitive(0);
}

# Resets the guest icon back to the default
sub reset_icon {
    my $gref = getsel_list_guest();
    unlink("$gui{THUMBDIR}/$$gref{Uuid}.png") if (-e "$gui{THUMBDIR}/$$gref{Uuid}.png");
    fill_list_guest();
}

# Takes a PNG screenshot of the guest
sub screenshot {
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});
    $gui{d}{ScreenShotFileChooser}{dialog}->set_current_name("$$gref{Name}_screenshot.png");
    $gui{d}{ScreenShotFileChooser}{dialog}->set_current_folder(Glib::get_home_dir());
    my $response = $gui{d}{ScreenShotFileChooser}{dialog}->run();
    $gui{d}{ScreenShotFileChooser}{dialog}->hide();
    my $filename = $gui{d}{ScreenShotFileChooser}{dialog}->get_filename();

    if ($response eq 'ok' and $filename) {
        if ($$sref{Lock} eq 'Shared') {
            my $IConsole = ISession_getConsole($$sref{ISession});
            my $IDisplay = IConsole_getDisplay($IConsole);
            my ($w, $h, $d, $ox, $oy) = IDisplay_getScreenResolution($IDisplay, 0);
            if (my $rawscreenshot = IDisplay_takeScreenShotToArray($IDisplay, 0, $w, $h, 'PNG')) {
                my $screenshot = decode_base64($rawscreenshot);
                if (open(SHOT, '>', $filename)) {
                    binmode SHOT; # Not normally needed for UNIX, but more portable
                    print SHOT $screenshot;
                    close(SHOT);
                    addrow_msg_log("Saved screenshot of $$gref{Name} as $filename.");
                }
                else { addrow_msg_log("Warning: Failed to save screenshot of $$gref{Name} as $filename"); }
            }
            else { show_err_msg('noscreenshot', 0); }
        }
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Sets the guest icon to a screenshot of the guest
sub screenshot_to_icon {
    my ($widget) = @_;
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} eq 'Shared') {
        my $IConsole = ISession_getConsole($$sref{ISession});
        my $IDisplay = IConsole_getDisplay($IConsole);

        if (my $rawicon = IDisplay_takeScreenShotToArray($IDisplay, 0, 32, 32, 'PNG')) {
            mkdir($gui{THUMBDIR}, 0755) unless (-e $gui{THUMBDIR});
            my $icon = decode_base64($rawicon);
            if (open(ICON, '>', "$gui{THUMBDIR}/$$gref{Uuid}.png")) {
                binmode ICON; # Not normally needed for UNIX, but more portable
                print ICON $icon;
                close(ICON);
                addrow_msg_log("Set screenshot as icon for $$gref{Name}");
                fill_list_guest();
            }
            else { addrow_msg_log("Warning: Could not save the icon for $$gref{Name}"); }
        }
        else { show_err_msg('noscreenshot', 0); }
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

sub group_list_expand {
    $gui{d}{Main}{treeviewGuest}->expand_all();
    $prefs{GUESTLISTEXPAND}=1;
    rbprefs_save();
}

sub group_list_collapse {
    $gui{d}{Main}{treeviewGuest}->collapse_all();
    $prefs{GUESTLISTEXPAND}=0;
    rbprefs_save();
}

# Shows the dialog for importing an appliance
sub show_dialog_importappl {
    my $vhost = vhost();
    $gui{d}{ImportAppl}{entryAppl}->set_text(rcatfile($$vhost{machinedir}, 'appliance.ova'));

    do {
        $gui{d}{ImportAppl}{dialog}->show_all();
        my $response = $gui{d}{ImportAppl}{dialog}->run();

        if ($response eq 'ok') {
            my @importopts;
            push (@importopts, 'ImportToVDI') if ($gui{d}{ImportAppl}{checkConvert}->get_active() == 1);
            push (@importopts, 'KeepAllMACs') if ($gui{d}{ImportAppl}{cboxMAC}->get_active() == 0);
            push (@importopts, 'KeepNATMACs') if ($gui{d}{ImportAppl}{cboxMAC}->get_active() == 1);

            if (!$gui{d}{ImportAppl}{entryAppl}->get_text()) { show_err_msg('invalidfile', 0); }
            else {
                $gui{d}{ImportAppl}{dialog}->hide();
                my $appliancefile = $gui{d}{ImportAppl}{entryAppl}->get_text();
                addrow_msg_log("Importing appliance from $appliancefile");
                my $IAppliance = IVirtualBox_createAppliance($gui{websn});
                my $IProgress = IAppliance_read($IAppliance, $appliancefile);

                if ($IProgress) {
                    show_progress_window($IProgress, 'Reading Appliance', $gui{pb}{ProgressReadAppl});
                    IAppliance_interpret($IAppliance);
                    my $warnings = IAppliance_getWarnings($IAppliance);
                    addrow_msg_log("Import warnings: $warnings") if ($warnings);
                    $IProgress = IAppliance_importMachines($IAppliance, @importopts);

                    if ($IProgress) {
                        show_progress_window($IProgress, 'Importing Appliance', $gui{pb}{ProgressImport});
                        my @appluuid = IAppliance_getMachines($IAppliance);
                        foreach my $id (@appluuid) {
                            makesel_list_guest($id); # Make the current selection the new appliance
                            addrow_msg_log("Imported new appliance from $appliancefile");
                            fill_list_guest(); # Repopulate the guest list so it appears and is selected
                            show_dialog_edit(); # Edit any settings
                        }
                    }
                    else { show_err_msg('applimport', 0, "\nAppliance: $appliancefile"); }
                }
                else { show_err_msg('applimport', 0, "\nAppliance: $appliancefile"); }
            }
        }
        else { $gui{d}{ImportAppl}{dialog}->hide; }

    } until (!$gui{d}{ImportAppl}{dialog}->get_visible());
}

# Displays the dialog for entering a decryption password
sub show_dialog_decpasswd {
    my ($IMedium, $keyid) = @_;
    my $passwd;
    $gui{d}{DecPassword}{labelKeyID}->set_text($keyid);
    $gui{d}{DecPassword}{labelDisk}->set_text(IMedium_getName($IMedium));
    $gui{d}{DecPassword}{dialog}->show_all();
    my $response = $gui{d}{DecPassword}{dialog}->run();
    $gui{d}{DecPassword}{dialog}->hide();
    if ($response eq 'ok') { $passwd = $gui{d}{DecPassword}{entryPass}->get_text(); }
    return $passwd;
}

# Displays the dialog for setting a guests group
sub show_dialog_group {
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} ne 'None') {
        my ($group) = IMachine_getGroups($$sref{IMachine}, ('/')); # Only interested in first group entry
        $gui{d}{SetGroup}{entryGroup}->set_text($group);
        $gui{d}{SetGroup}{dialog}->show_all();
        my $response = $gui{d}{SetGroup}{dialog}->run();
        $gui{d}{SetGroup}{dialog}->hide();

        if ($response eq 'ok') {
            $group = $gui{d}{SetGroup}{entryGroup}->get_text();
            $group =~ s/\/+$//; # Remove any trailing slashes
            $group = "/$group" if ($group !~ m/^\//);
            IMachine_setGroups($$sref{IMachine}, ($group));
            IMachine_saveSettings($$sref{IMachine});
            addrow_msg_log("Set group membership for $$gref{Name} to $group");
            fill_list_guest();
        }
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Clears the group for a VM
sub clear_group {
    my $gref = getsel_list_guest();
    my $sref = get_session($$gref{IMachine});

    if ($$sref{Lock} ne 'None') {
        IMachine_setGroups($$sref{IMachine}, ('/'));
        IMachine_saveSettings($$sref{IMachine});
        addrow_msg_log("Ungrouped $$gref{Name}");
        fill_list_guest();
    }

    ISession_unlockMachine($$sref{ISession}) if (ISession_getState($$sref{ISession}) eq 'Locked');
}

# Update the server memory progress bar - also called from a timer
sub update_server_membar {
    if ($gui{websn}) {
        my $vhost = vhost();
        my $memavail = IHost_getMemoryAvailable($$vhost{IHost});
        my $memused = ($$vhost{memsize} - $memavail);
        $gui{d}{Main}{barMem}->set_text("Server Memory ($$vhost{memsize} MB): $memused MB Used / $memavail MB Free");
        $gui{d}{Main}{barMem}->set_fraction(($memused / $$vhost{memsize}));
    }

    return 1; # Return 1 to stop the timer from being removed
}

# Display extended details when a guest is selected
sub extended_details {
    $prefs{EXTENDEDDETAILS} = $gui{d}{Main}{checkbuttonDetails}->get_active();
    onsel_list_guest() if ($gui{d}{Main}{treeviewGuest}->get_selection->get_selected());
}

sub set_connection_prof_inactive {
    $gui{d}{Connect}{cboxProfile}->set_active(-1);
}

1;
