# RemoteBox and VirtualBox preferences
use strict;
use warnings;
use Glib ('TRUE','FALSE');
our %gui;
our %prefs = (RDPCLIENT           => ($^O =~ m/MSWin/) ? 'mstsc.exe /w:%X /h:%Y /v:%h:%p' # Built into Windows
                                                       : 'xfreerdp /size:%Xx%Y /bpp:32 +clipboard /sound /t:"%n - RemoteBox" /v:%h:%p /d: /p: /cert:ignore',
              VNCCLIENT           => 'vncviewer -Shared -AcceptClipboard -SetPrimary -SendClipboard -SendPrimary -RemoteResize -DesktopSize %Xx%Y  %h:%p',
              ADDADDITIONS        => 1,
              RDPAUTOOPEN         => 1,
              GUESTLISTEXPAND     => 1,
              AUTOSORTGUESTLIST   => 1,
              EXTENDEDDETAILS     => 0,
              SSLVERIFY           => 0,
              DEFRDPPORTS         => '3389-4389',
              DEFVNCPORTS         => '5900-5999',
              AUTOHINTDISP        => 0,
              AUTOHINTDISPX       => 1280,
              AUTOHINTDISPY       => 1024,
              AUTOHINTDISPD       => 32,
              STOPTYPE            => 'INSTANT',
              EXPANDDETGEN        => 1,
              EXPANDDETSYS        => 1,
              EXPANDDETDISP       => 1,
              EXPANDDETSTOR       => 1,
              EXPANDDETAUDIO      => 1,
              EXPANDDETNET        => 1,
              EXPANDDETIO         => 1,
              EXPANDDETUSB        => 1,
              EXPANDDETSHARE      => 1,
              EXPANDDETRUN        => 1,
              EXPANDDETDESC       => 1,
              NOEXTPACKWARNDIALOG => 0,
              NOVERSIONWARNDIALOG => 0,
              AUTOCONNPROF        => '');

# Import the current remotebox preferences
sub rbprefs_get {
    $gui{PREFSDIR} = Glib::get_user_config_dir();
    $gui{CONFIGFILE} = "$gui{PREFSDIR}/remotebox.conf";
    $gui{PROFILESFILE} = "$gui{PREFSDIR}/remotebox-profiles.conf";
    $gui{THUMBDIR} = "$gui{PREFSDIR}/remoteboxthumbs";

    if (open(PREFS, '<', $gui{CONFIGFILE})) {
        my @contents = <PREFS>;
        chomp(@contents);
        close(PREFS);
        foreach (@contents) {
            if ($_ =~ m/^URL=(.*)$/) { $prefs{URL}{$1} = 'URL'; }
            elsif ($_ =~ m/^USER=(.*)$/) { $prefs{USER}{$1} = 'USER'; }
            elsif ($_ =~ m/^(.*?)=(.*)$/) { $prefs{$1} = $2; }
        }
    }
    else { $prefs{URL}{qq[http://localhost:18083]} = 'URL'; } #Add a default URL

    $gui{d}{Main}{checkbuttonDetails}->set_active($prefs{EXTENDEDDETAILS});

    # Load in the connection profiles
    if (open(PROFILES, '<', $gui{PROFILESFILE})) {
        my @contents = <PROFILES>;
        chomp(@contents);
        close(PROFILES);
        foreach (sort(@contents)) {
            my ($pname, $url, $username, $password, $key) = split("\a", $_);
            my @pass = split(' ', $password);
            $password = pack("C*", @pass);
            $password = xor_pass($password, $key);
            addrow_profile(undef, $pname, $url, $username, $password);
        }
    }
}

# Save the current remotebox preferences
sub rbprefs_save {
    mkdir($gui{PREFSDIR}, 0755) unless (-e $gui{PREFSDIR});

    if (open(PREFS, '>', $gui{CONFIGFILE})) {
        foreach my $key (sort(keys %prefs)) {
            if ($key eq 'URL') {
                foreach (keys %{$prefs{URL}}) { print PREFS "URL=$_\n"; }
            }
            elsif ($key eq 'USER') {
                foreach (keys %{$prefs{USER}}) { print PREFS "USER=$_\n"; }
            }
            else { print PREFS "$key=$prefs{$key}\n"; }
        }
        close(PREFS);
    }
    else { warn "Unable to save preferences: $gui{CONFIGFILE}\n"; }
}

# Saves the profiles. DO NOT call this from rbprefs_save otherwise there will be
# a race condition which will empty the profiles file.
sub rbprofiles_save {
    # As this file might contain passwords, we'll create it 0600, but only if it's the first time we're creating it.
    my $newprofilesfile = (-e $gui{PROFILESFILE}) ? 0 : 1;

    # Save the connection profiles
    if (open(PROFILES, '>', $gui{PROFILESFILE})) {
        chmod(0600, $gui{PROFILESFILE}) if ($newprofilesfile);
        my $iter = $gui{d}{Connect}{lstoreProfile}->get_iter_first();

        while(defined($iter) and $gui{d}{Connect}{lstoreProfile}->iter_is_valid($iter)) {
            print(PROFILES $gui{d}{Connect}{lstoreProfile}->get_value($iter, 0) . "\a" .
                           $gui{d}{Connect}{lstoreProfile}->get_value($iter, 1) . "\a" .
                           $gui{d}{Connect}{lstoreProfile}->get_value($iter, 2) . "\a");
            my $password = $gui{d}{Connect}{lstoreProfile}->get_value($iter, 3);
            my $key = random_key(length($password));
            $password = xor_pass($password, $key);
            my @ordpass = unpack("C*", $password);
            $password = join(' ', @ordpass);
            print PROFILES "$password\a$key\n";
            $gui{d}{Connect}{lstoreProfile}->iter_next($iter); # The iter is now modified directly
        }

        close(PROFILES);
    }
}

# Save RemoteBox's window position for restoration later
sub save_window_pos {
    if (defined($ENV{GDK_BACKEND}) and $ENV{GDK_BACKEND} =~ m/broadway/i) {
        # There's probably a nicer way to check for this, but...
        # We don't save the window position because the browser settings will be very
        # different to the desktop settings.
    }
    else {
        my ($win) = @_;
        my ($w, $h) = $win->get_size();
        my ($x, $y) = $win->get_position();
        $prefs{"WINPOS_windowMain"} = "$w:$h:$x:$y";
    }

    rbprefs_save();
}

# Restore RemoteBox's window position to the last save position
sub restore_window_pos {
    my ($win) = @_;

    if (defined($ENV{GDK_BACKEND}) and $ENV{GDK_BACKEND} =~ m/broadway/i) {
        # There's probably a nicer way to check for this, but...
        # We don't restore the window position because the browser settings will be very
        # different to the desktop settings.
        $win->maximize();
    }
    else {
        if ($prefs{"WINPOS_windowMain"}) {
            my ($w, $h, $x, $y) = split ':', $prefs{"WINPOS_windowMain"};
            $win->move($x, $y);
            $win->resize($w, $h);
        }
    }
}

sub show_dialog_editnat {
    my $natref = getsel_list_vbprefsnat();
    $gui{d}{NAT}{entryName}->set_text($$natref{Name});
    $gui{d}{NAT}{entryCIDR}->set_text(INATNetwork_getNetwork($$natref{INATNetwork}));
    $gui{d}{NAT}{checkDHCP}->set_active(bl(INATNetwork_getNeedDhcpServer($$natref{INATNetwork})));
     $gui{d}{NAT}{checkIPv6}->set_active(bl(INATNetwork_getIPv6Enabled($$natref{INATNetwork})));
    $gui{d}{NAT}{checkRoute}->set_active(bl(INATNetwork_getAdvertiseDefaultIPv6RouteEnabled($$natref{INATNetwork})));
    fill_list_pf4($$natref{INATNetwork});
    fill_list_pf6($$natref{INATNetwork});

    do {
        $gui{d}{NAT}{dialog}->show_all;
        my $response = $gui{d}{NAT}{dialog}->run();

        if ($response eq 'ok') {
            # Other entries do not require validation
            if (!$gui{d}{NAT}{entryName}->get_text()) { show_err_msg('invalidname', 0); }
            elsif (!valid_cidr($gui{d}{NAT}{entryCIDR}->get_text())) { show_err_msg('invalidipv4cidr', 0, '(Network CIDR)'); }
            else {
                $gui{d}{NAT}{dialog}->hide;
                INATNetwork_setNetworkName($$natref{INATNetwork}, $gui{d}{NAT}{entryName}->get_text());
                INATNetwork_setNetwork($$natref{INATNetwork}, $gui{d}{NAT}{entryCIDR}->get_text());
                INATNetwork_setNeedDhcpServer($$natref{INATNetwork}, int($gui{d}{NAT}{checkDHCP}->get_active()));
                INATNetwork_setIPv6Enabled($$natref{INATNetwork}, int( $gui{d}{NAT}{checkIPv6}->get_active()));
                INATNetwork_setAdvertiseDefaultIPv6RouteEnabled($$natref{INATNetwork}, int($gui{d}{NAT}{checkRoute}->get_active()));
                fill_list_vbprefsnat();
            }
        }
        else { $gui{d}{NAT}{dialog}->hide; }

    } until (!$gui{d}{NAT}{dialog}->get_visible());
}

# Show dialog for adding an IPv4 port forwarding rule
sub show_dialog_pf4 {
    my ($widget, $mode) = @_;
    my $oldname;

    if ($mode eq 'EDIT') {
        my $rule = getsel_list_pf4();
        $oldname = $$rule{Name};
        $gui{d}{PFRule4}{entryName}->set_text($$rule{Name});
        combobox_set_active_text($gui{d}{PFRule4}{cboxProtocol}, $$rule{Protocol}, 1);
        $gui{d}{PFRule4}{entryHostIP}->set_text($$rule{HostIP});
        $gui{d}{PFRule4}{sbHostPort}->set_value($$rule{HostPort});
        $gui{d}{PFRule4}{entryGuestIP}->set_text($$rule{GuestIP});
        $gui{d}{PFRule4}{sbGuestPort}->set_value($$rule{GuestPort});
    }
    else { $gui{d}{PFRule4}{entryName}->set_text('Rule ' . int(rand(999999))); }

    do {
        $gui{d}{PFRule4}{dialog}->show_all;
        my $response = $gui{d}{PFRule4}{dialog}->run();

        if ($response eq 'ok') {
            # No validation needed for other entries
            if (!$gui{d}{PFRule4}{entryName}->get_text()) { show_err_msg('invalidname', 0); }
            elsif (!valid_ipv4($gui{d}{PFRule4}{entryHostIP}->get_text())) { show_err_msg('invalidipv4address', 0, '(Host IP)'); }
            elsif (!valid_ipv4($gui{d}{PFRule4}{entryGuestIP}->get_text())) { show_err_msg('invalidipv4address', 0, '(Guest IP)'); }
            else {
                $gui{d}{PFRule4}{dialog}->hide;
                my $natref = getsel_list_vbprefsnat();
                # We can't actually edit an existing rule, so it's deleted and recreated.
                INATNetwork_removePortForwardRule($$natref{INATNetwork}, 0, $oldname) if ($mode eq 'EDIT');
                INATNetwork_addPortForwardRule($$natref{INATNetwork}, 0,
                                               $gui{d}{PFRule4}{entryName}->get_text(),
                                               getsel_combo($gui{d}{PFRule4}{cboxProtocol}, 1),
                                               $gui{d}{PFRule4}{entryHostIP}->get_text(),
                                               int($gui{d}{PFRule4}{adjHostPort}->get_value()),
                                               $gui{d}{PFRule4}{entryGuestIP}->get_text(),
                                               int($gui{d}{PFRule4}{adjGuestPort}->get_value()));
                fill_list_pf4($$natref{INATNetwork});
            }
        }
        else { $gui{d}{PFRule4}{dialog}->hide; }

    } until (!$gui{d}{PFRule4}{dialog}->get_visible());
}

# Show dialog for adding an IPv6 port forwarding rule
sub show_dialog_pf6 {
    my ($widget, $mode) = @_;
    my $oldname;

    if ($mode eq 'EDIT') {
        my $rule = getsel_list_pf6();
        $oldname = $$rule{Name};
        $gui{d}{PFRule6}{entryName}->set_text($$rule{Name});
        combobox_set_active_text($gui{d}{PFRule6}{cboxProtocol}, $$rule{Protocol}, 1);
        $gui{d}{PFRule6}{entryHostIP}->set_text($$rule{HostIP});
        $gui{d}{PFRule6}{sbHostPort}->set_value($$rule{HostPort});
        $gui{d}{PFRule6}{entryGuestIP}->set_text($$rule{GuestIP});
        $gui{d}{PFRule6}{sbGuestPort}->set_value($$rule{GuestPort});
    }
    else { $gui{d}{PFRule6}{entryName}->set_text('Rule ' . int(rand(999999))); }

    do {
        $gui{d}{PFRule6}{dialog}->show_all;
        my $response = $gui{d}{PFRule6}{dialog}->run();

        if ($response eq 'ok') {
            # No validation needed for other entries
            if (!$gui{d}{PFRule6}{entryName}->get_text()) { show_err_msg('invalidname', 0, '(Portforwarding rule name)'); }
            elsif (!valid_ipv6($gui{d}{PFRule6}{entryHostIP}->get_text())) { show_err_msg('invalidipv6address', 0, '(Host IP)'); }
            elsif (!valid_ipv6($gui{d}{PFRule6}{entryGuestIP}->get_text())) { show_err_msg('invalidipv6address', 0, '(Guest IP)'); }
            else {
                $gui{d}{PFRule6}{dialog}->hide;
                my $natref = getsel_list_vbprefsnat();
                # We can't actually edit an existing rule, so it's deleted and recreated.
                INATNetwork_removePortForwardRule($$natref{INATNetwork}, 1, $oldname) if ($mode eq 'EDIT');
                INATNetwork_addPortForwardRule($$natref{INATNetwork}, 1,
                                               $gui{d}{PFRule6}{entryName}->get_text(),
                                               getsel_combo($gui{d}{PFRule6}{cboxProtocol}, 1),
                                               $gui{d}{PFRule6}{entryHostIP}->get_text(),
                                               int($gui{d}{PFRule6}{adjHostPort}->get_value()),
                                               $gui{d}{PFRule6}{entryGuestIP}->get_text(),
                                               int($gui{d}{PFRule6}{adjGuestPort}->get_value()));
                fill_list_pf6($$natref{INATNetwork});
            }
        }
        else { $gui{d}{PFRule6}{dialog}->hide; }

    } until (!$gui{d}{PFRule6}{dialog}->get_visible());
}

# Removes an IPv4 port forwarding rule to the selected NAT Network
sub remove_pf_rule4 {
    my $ruleref = getsel_list_pf4();
    INATNetwork_removePortForwardRule($$ruleref{INATNetwork}, 0, $$ruleref{Name});
    fill_list_pf4($$ruleref{INATNetwork});
}

# Removes an IPv6 port forwarding rule to the selected NAT Network
sub remove_pf_rule6 {
    my $ruleref = getsel_list_pf6();
    INATNetwork_removePortForwardRule($$ruleref{INATNetwork}, 1, $$ruleref{Name});
    fill_list_pf6($$ruleref{INATNetwork});
}

# Shows the RemoteBox preferences dialog
sub show_dialog_prefs {
    $gui{d}{Prefs}{entryRDP}->set_text($prefs{RDPCLIENT});
    $gui{d}{Prefs}{entryVNC}->set_text($prefs{VNCCLIENT});
    $gui{d}{Prefs}{checkOpenDisplay}->set_active($prefs{RDPAUTOOPEN});
    $gui{d}{Prefs}{checkAdditions}->set_active($prefs{ADDADDITIONS});
    $gui{d}{Prefs}{checkSortGuest}->set_active($prefs{AUTOSORTGUESTLIST});
    $gui{d}{Prefs}{checkNoExtPackWarn}->set_active($prefs{NOEXTPACKWARNDIALOG});
    $gui{d}{Prefs}{checkNoVersionWarn}->set_active($prefs{NOVERSIONWARNDIALOG});
    $gui{d}{Prefs}{checkAutoHint}->set_active($prefs{AUTOHINTDISP});
    $gui{d}{Prefs}{sbWidth}->set_value($prefs{AUTOHINTDISPX});
    $gui{d}{Prefs}{sbHeight}->set_value($prefs{AUTOHINTDISPY});

    if ($prefs{AUTOHINTDISPD} == 8) { $gui{d}{Prefs}{cboxDepth}->set_active(0); }
    elsif ($prefs{AUTOHINTDISPD} == 16) { $gui{d}{Prefs}{cboxDepth}->set_active(1); }
    else { $gui{d}{Prefs}{cboxDepth}->set_active(2); }

    if ($prefs{STOPTYPE} eq 'ACPI') { $gui{d}{Prefs}{cboxStop}->set_active(1); }
    elsif ($prefs{STOPTYPE} eq 'STATE')  { $gui{d}{Prefs}{cboxStop}->set_active(2); }
    else { $gui{d}{Prefs}{cboxStop}->set_active(0); }

    $gui{d}{Prefs}{dialog}->show_all();
    my $response = $gui{d}{Prefs}{dialog}->run();
    $gui{d}{Prefs}{dialog}->hide();

    if ($response eq 'ok') {
        $prefs{RDPCLIENT} = $gui{d}{Prefs}{entryRDP}->get_text();
        $prefs{VNCCLIENT} = $gui{d}{Prefs}{entryVNC}->get_text();
        $prefs{RDPAUTOOPEN} = int($gui{d}{Prefs}{checkOpenDisplay}->get_active());
        $prefs{ADDADDITIONS} = int($gui{d}{Prefs}{checkAdditions}->get_active());
        $prefs{AUTOSORTGUESTLIST} = int($gui{d}{Prefs}{checkSortGuest}->get_active());
        $prefs{NOEXTPACKWARNDIALOG} = int($gui{d}{Prefs}{checkNoExtPackWarn}->get_active());
        $prefs{NOVERSIONWARNDIALOG} = int($gui{d}{Prefs}{checkNoVersionWarn}->get_active());
        $prefs{STOPTYPE} = getsel_combo($gui{d}{Prefs}{cboxStop}, 1);
        $prefs{AUTOHINTDISP} = int($gui{d}{Prefs}{checkAutoHint}->get_active());
        $prefs{AUTOHINTDISPX} = int($gui{d}{Prefs}{sbWidth}->get_value());
        $prefs{AUTOHINTDISPY} = int($gui{d}{Prefs}{sbHeight}->get_value());
        $prefs{AUTOHINTDISPD} = getsel_combo($gui{d}{Prefs}{cboxDepth}, 1);
        rbprefs_save();
    }
}

# Shows the VirtualBox preferences dialog
sub show_dialog_vbprefs {
    my $vhost = vhost();
    $gui{d}{VBPrefs}{entryMachineFolder}->set_text($$vhost{machinedir});
    $gui{d}{VBPrefs}{entryDatabaseFolder}->set_text($$vhost{autostartdb});
    $gui{d}{VBPrefs}{entryVRDPLib}->set_text($$vhost{vrdelib});
    $gui{d}{VBPrefs}{checkExclusive}->set_active(bl($$vhost{hwexclusive}));
    $gui{d}{VBPrefs}{dialog}->show_all();
    my $response = $gui{d}{VBPrefs}{dialog}->run();
    $gui{d}{VBPrefs}{dialog}->hide();

    if ($response eq 'ok') {
        my $machinedir = $gui{d}{VBPrefs}{entryMachineFolder}->get_text();
        my $autostartdir = $gui{d}{VBPrefs}{entryDatabaseFolder}->get_text();
        my $vrdelib = $gui{d}{VBPrefs}{entryVRDPLib}->get_text();
        $vrdelib =~ s/\.dll$//i;
        $vrdelib =~ s/\.so$//i;
        ISystemProperties_setDefaultMachineFolder($$vhost{ISystemProperties}, $machinedir) if ($machinedir ne $$vhost{machinedir});
        ISystemProperties_setVRDEAuthLibrary($$vhost{ISystemProperties}, $vrdelib) if ($vrdelib ne $$vhost{vrdelib});
        ISystemProperties_setAutostartDatabasePath($$vhost{ISystemProperties}, $autostartdir) if ($autostartdir ne $$vhost{autostartdb});
        if ($gui{d}{VBPrefs}{checkExclusive}->get_active()) { IPlatformProperties_setExclusiveHwVirt($$vhost{IPlatformProperties}, 'true'); }
        else { IPlatformProperties_setExclusiveHwVirt($$vhost{IPlatformProperties}, 'false'); }
        clr_vhost(); # VB Prefs changes can potentially alter vhost values, so clear them to be repopulated
    }
}

# Shows the RDPVNCInfo dialog
sub show_dialog_rdpvncinfo {
    fill_list_rdpvncinfo();
    $gui{d}{RDPVNCInfo}{dialog}->show_all();
    $gui{d}{RDPVNCInfo}{dialog}->run();
    $gui{d}{RDPVNCInfo}{dialog}->hide();
}

# Shows the Host Network Manager dialog
sub show_dialog_hostnetman {
    fill_list_vbprefshon();
    fill_list_vbprefsnat();
    $gui{d}{HostNetMan}{dialog}->show_all();
    $gui{d}{HostNetMan}{dialog}->run();
    $gui{d}{HostNetMan}{dialog}->hide();
}

# Shows the dialog for managing connection profiles
sub show_dialog_profiles {
    $gui{d}{Profile}{dialog}->show_all();
    $gui{d}{Profile}{dialog}->run();
    $gui{d}{Profile}{dialog}->hide();
    rbprofiles_save();
}

sub show_dialog_edithon {
    my $ifref = getsel_list_vbprefshon();
    my @DHCPServers = IVirtualBox_getDHCPServers($gui{websn});
    my $IDHCPServer;

    # Check if it has a DCHP server associated with it
    foreach my $server (@DHCPServers) {
        if ("HostInterfaceNetworking-$$ifref{Name}" eq IDHCPServer_getNetworkName($server)) {
            $IDHCPServer = $server;
            last;
        }
    }

    $gui{d}{HON}{checkEnableDHCP}->signal_connect('toggled' => \&vbprefs_hon_dhcp_toggle, $IDHCPServer);
    $gui{d}{HON}{entryIPV4Addr}->set_text(IHostNetworkInterface_getIPAddress($$ifref{IHostNetworkInterface}));
    $gui{d}{HON}{entryIPV4Netmask}->set_text(IHostNetworkInterface_getNetworkMask($$ifref{IHostNetworkInterface}));
    $gui{d}{HON}{entryIPV6Addr}->set_text(IHostNetworkInterface_getIPV6Address($$ifref{IHostNetworkInterface}));
    $gui{d}{HON}{entryIPV6Netmask}->set_text(IHostNetworkInterface_getIPV6NetworkMaskPrefixLength($$ifref{IHostNetworkInterface}));
    $gui{d}{HON}{gridDHCP}->set_sensitive($gui{d}{HON}{checkEnableDHCP}->get_active());

    if (!$IDHCPServer or !bl(IDHCPServer_getEnabled($IDHCPServer))) { $gui{d}{HON}{checkEnableDHCP}->set_active(0); }
    else { $gui{d}{HON}{checkEnableDHCP}->set_active(1); }

    do {
        $gui{d}{HON}{dialog}->show_all();
        my $response = $gui{d}{HON}{dialog}->run();

        if ($response eq 'ok') {
            # Validate everything BEFORE closing the dialog
            my $valid = TRUE;
            my $active = $gui{d}{HON}{checkEnableDHCP}->get_active();
            my $ipv6addr = $gui{d}{HON}{entryIPV6Addr}->get_text();

            if (!valid_ipv4($gui{d}{HON}{entryIPV4Addr}->get_text())) {
                $valid = FALSE;
                show_err_msg('invalidipv4address', 0, '(Adapter IPv4 Address)');
            }
            elsif (!valid_ipv4($gui{d}{HON}{entryIPV4Netmask}->get_text())) {
                $valid = FALSE;
                show_err_msg('invalidipv4netmask', 0, '(Adapter IPv4 Netmask)');
            }
            elsif ($ipv6addr and !valid_ipv6($ipv6addr)) {
                $valid = FALSE;
                show_err_msg('invalidipv6address', 0, '(Adapter IPv6 Address)');
            }

            if ($active) {
                if (!valid_ipv4($gui{d}{HON}{entryServerAddr}->get_text())) {
                    $valid = FALSE;
                    show_err_msg('invalidipv4address', 0, '(DHCP Server Address)');
                }
                elsif (!valid_ipv4($gui{d}{HON}{entryServerNetmask}->get_text())) {
                    $valid = FALSE;
                    show_err_msg('invalidipv4netmask', 0, '(DHCP Server Netmask)');
                }
                elsif (!valid_ipv4($gui{d}{HON}{entryLowerBound}->get_text())) {
                    $valid = FALSE;
                    show_err_msg('invalidipv4address', 0, '(DHCP Server Lower Address Bound)');
                }
                elsif (!valid_ipv4($gui{d}{HON}{entryUpperBound}->get_text())) {
                    $valid = FALSE;
                    show_err_msg('invalidipv4address', 0, '(DHCP Server Upper Address Bound)');
                }
            }

            if ($valid == TRUE) {
                $gui{d}{HON}{dialog}->hide();

                if ($active) {
                    # When a HON is created, there's no guarantee a DHCP server is associated with it. So here we create one
                    # If one doesn't exist,
                    $IDHCPServer = IVirtualBox_createDHCPServer($gui{websn}, "HostInterfaceNetworking-$$ifref{Name}") if (!$IDHCPServer);
                    IDHCPServer_setEnabled($IDHCPServer, $active);
                    IDHCPServer_setConfiguration($IDHCPServer, $gui{d}{HON}{entryServerAddr}->get_text(),
                                                               $gui{d}{HON}{entryServerNetmask}->get_text(),
                                                               $gui{d}{HON}{entryLowerBound}->get_text(),
                                                               $gui{d}{HON}{entryUpperBound}->get_text());
                }

                IHostNetworkInterface_enableStaticIPConfig($$ifref{IHostNetworkInterface}, $gui{d}{HON}{entryIPV4Addr}->get_text() , $gui{d}{HON}{entryIPV4Netmask}->get_text());
                IHostNetworkInterface_enableStaticIPConfigV6($$ifref{IHostNetworkInterface}, $ipv6addr, $gui{d}{HON}{entryIPV6Netmask}->get_text()) if ($ipv6addr);
                fill_list_vbprefshon();
            }
        }
        else { $gui{d}{HON}{dialog}->hide(); }

    } until (!$gui{d}{HON}{dialog}->get_visible());
}

sub vbprefs_reset {
    my ($widget) = @_;
    my $ISystemProperties = IVirtualBox_getSystemProperties($gui{websn});

    if ($widget eq $gui{d}{VBPrefs}{buttonMachineReset}) {
        ISystemProperties_setDefaultMachineFolder($ISystemProperties, '');
        $gui{d}{VBPrefs}{entryMachineFolder}->set_text(ISystemProperties_getDefaultMachineFolder($ISystemProperties));
    }
    elsif ($widget eq $gui{d}{VBPrefs}{buttonVRDPLibReset}) {
        ISystemProperties_setVRDEAuthLibrary($ISystemProperties, '');
        $gui{d}{VBPrefs}{entryVRDPLib}->set_text(ISystemProperties_getVRDEAuthLibrary($ISystemProperties));
    }
}

sub vbprefs_createhon {
    my $IHost = IVirtualBox_getHost($gui{websn});
    my ($hostinterface, $IProgress) = IHost_createHostOnlyNetworkInterface($IHost);
    show_progress_window($IProgress, 'Adding host only network', $gui{pb}{ProgressNetwork});
    fill_list_vbprefshon();
}

sub vbprefs_createnat {
    IVirtualBox_createNATNetwork($gui{websn}, 'NatNetwork ' . int(rand(999999)));
    fill_list_vbprefsnat();
}

sub vbprefs_removehon {
    my $ifref = getsel_list_vbprefshon();
    my @DHCPServers = IVirtualBox_getDHCPServers($gui{websn});

    # Check if it has a DCHP server associated with it
    foreach my $server (@DHCPServers) {
        if ("HostInterfaceNetworking-$$ifref{Name}" eq IDHCPServer_getNetworkName($server)) {
            IVirtualBox_removeDHCPServer($gui{websn}, $server);
            last;
        }
    }

    my $IHost = IVirtualBox_getHost($gui{websn});
    my $IProgress = IHost_removeHostOnlyNetworkInterface($IHost, $$ifref{Uuid});
    show_progress_window($IProgress, 'Removing host only network', $gui{pb}{ProgressNetwork});
    fill_list_vbprefshon();
}

sub vbprefs_removenat {
    my $natref = getsel_list_vbprefsnat();
    IVirtualBox_removeNATNetwork($gui{websn}, $$natref{INATNetwork});
    fill_list_vbprefsnat();
}

# Can't use getsel_list_vbprefsnat in here due to the way the signals are propagated
sub vbprefs_togglenat {
    my ($widget, $path_str) = @_;
    my $iter = $gui{d}{HostNetMan}{lstoreNAT}->get_iter(Gtk3::TreePath->new_from_string($path_str));
    my $val = $gui{d}{HostNetMan}{lstoreNAT}->get($iter, 0);
    my $INATNetwork = $gui{d}{HostNetMan}{lstoreNAT}->get($iter, 2);
    INATNetwork_setEnabled($INATNetwork, !$val);
    fill_list_vbprefsnat();
}

sub rbprefs_sslverify {
    my $active = $gui{d}{Connect}{checkSSL}->get_active();
    $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = $active;
    $prefs{SSLVERIFY} = $active;
    rbprefs_save();
}

sub vbprefs_hon_dhcp_toggle {
    my ($widget, $IDHCPServer) = @_;
    my $active = $widget->get_active();
    $gui{d}{HON}{gridDHCP}->set_sensitive($active); # Ghost/Unghost other widgets based on dhcp enabled

    if ($active) {
        if (!$IDHCPServer) {
            # There's no existing DHCP server associated with this network, so pre-fill reasonable details
            my $ip4 = $gui{d}{HON}{entryIPV4Addr}->get_text();
            my $nm = $gui{d}{HON}{entryIPV4Netmask}->get_text();
            $gui{d}{HON}{entryServerNetmask}->set_text($nm);
            $gui{d}{HON}{entryServerAddr}->set_text(ip4_add($ip4, 1));
            $gui{d}{HON}{entryLowerBound}->set_text(ip4_add($ip4, 2));
            $gui{d}{HON}{entryUpperBound}->set_text(ip4_highest($ip4, $nm));
        }
        else {
            # There's an existing DHCP server.
            $gui{d}{HON}{entryServerAddr}->set_text(IDHCPServer_getIPAddress($IDHCPServer));
            $gui{d}{HON}{entryServerNetmask}->set_text(IDHCPServer_getNetworkMask($IDHCPServer));
            $gui{d}{HON}{entryLowerBound}->set_text(IDHCPServer_getLowerIP($IDHCPServer));
            $gui{d}{HON}{entryUpperBound}->set_text(IDHCPServer_getUpperIP($IDHCPServer));
        }
    }
    else {
        # Not active so blank the fields
        $gui{d}{HON}{entryServerAddr}->set_text('');
        $gui{d}{HON}{entryServerNetmask}->set_text('');
        $gui{d}{HON}{entryLowerBound}->set_text('');
        $gui{d}{HON}{entryUpperBound}->set_text('');
    }
}

# Shows the preset RDP options for selection
sub show_rdppreset_menu {
    my ($widget, $event) = @_; #$event->time
    $gui{menu}{RDPPreset}->popup(undef, undef, undef, undef, 0, $event->time) if ($event->button == 1);
    return 0;
}

# Shows the preset VNC options for selection
sub show_vncpreset_menu {
    my ($widget, $event) = @_; #$event->time
    $gui{menu}{VNCPreset}->popup(undef, undef, undef, undef, 0, $event->time) if ($event->button == 1);
    return 0;
}

# Updates the RDP widget with the selected preset
sub set_rdppreset {
    my ($widget, $command) = @_;
    $gui{d}{Prefs}{entryRDP}->set_text($command);
}

# Updates the VNC entry widget with the selected preset
sub set_vncpreset {
    my ($widget, $command) = @_;
    $gui{d}{Prefs}{entryVNC}->set_text($command);
}

1;
