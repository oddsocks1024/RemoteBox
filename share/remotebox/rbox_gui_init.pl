# General GUI related functions and structures
use strict;
use warnings;
use Gtk3;
use Glib ('TRUE','FALSE');
use Regexp::Common qw /net/;
use utf8;

our ($sharedir, $endpoint);
our %gui = (appname         => 'RemoteBox',
            appver          => 'v3.7',
            websn           => undef);
our %signal = ();
our (%prefs);
# Guest Status
$gui{pb}{Aborted} = gui_new_pixbuf_from_file('gueststatus/Aborted.png');
$gui{pb}{DeletingSnapshot} = gui_new_pixbuf_from_file('gueststatus/Misc.png');
$gui{pb}{DeletingSnapshotOnline} = gui_new_pixbuf_from_file('gueststatus/Misc.png');
$gui{pb}{DeletingSnapshotPaused} = gui_new_pixbuf_from_file('gueststatus/Misc.png');
$gui{pb}{Discarding} = gui_new_pixbuf_from_file('gueststatus/Discarding.png');
$gui{pb}{Error} = gui_new_pixbuf_from_file('gueststatus/Error.png');
$gui{pb}{FaultTolerantSyncing} = gui_new_pixbuf_from_file('gueststatus/Misc.png');
$gui{pb}{FirstOnline} = gui_new_pixbuf_from_file('gueststatus/Running.png');
$gui{pb}{FirstTransient} = gui_new_pixbuf_from_file('gueststatus/Running.png');
$gui{pb}{LastOnline} = gui_new_pixbuf_from_file('gueststatus/Running.png');
$gui{pb}{LastTransient} = gui_new_pixbuf_from_file('gueststatus/Running.png');
$gui{pb}{LiveSnapshotting} = gui_new_pixbuf_from_file('gueststatus/Misc.png');
$gui{pb}{OnlineSnapshotting} = gui_new_pixbuf_from_file('gueststatus/Misc.png');
$gui{pb}{Paused} = gui_new_pixbuf_from_file('gueststatus/Paused.png');
$gui{pb}{PoweredOff} = gui_new_pixbuf_from_file('gueststatus/PoweredOff.png');
$gui{pb}{Restoring} = gui_new_pixbuf_from_file('gueststatus/Restoring.png');
$gui{pb}{RestoringSnapshot} = gui_new_pixbuf_from_file('gueststatus/Restoring.png');
$gui{pb}{Running} = gui_new_pixbuf_from_file('gueststatus/Running.png');
$gui{pb}{Saved} = gui_new_pixbuf_from_file('gueststatus/Saved.png');
$gui{pb}{Saving} = gui_new_pixbuf_from_file('gueststatus/Saving.png');
$gui{pb}{SettingUp} = gui_new_pixbuf_from_file('gueststatus/Running.png');
$gui{pb}{Snapshotting} = gui_new_pixbuf_from_file('gueststatus/Misc.png');
$gui{pb}{Starting} = gui_new_pixbuf_from_file('gueststatus/Running.png');
$gui{pb}{Stopping} = gui_new_pixbuf_from_file('gueststatus/Misc.png');
$gui{pb}{Stuck} = gui_new_pixbuf_from_file('gueststatus/Stuck.png');
$gui{pb}{Teleported} = gui_new_pixbuf_from_file('gueststatus/PoweredOff.png');
$gui{pb}{Teleporting} = gui_new_pixbuf_from_file('gueststatus/Misc.png');
$gui{pb}{TeleportingIn} = gui_new_pixbuf_from_file('gueststatus/Misc.png');
$gui{pb}{TeleportingPausedVM} = gui_new_pixbuf_from_file('gueststatus/Paused.png');
# Storage Icons
$gui{pb}{Network} = gui_new_pixbuf_from_file('nw_16px.png');
$gui{pb}{HardDisk} = gui_new_pixbuf_from_file('hd_16px.png');
$gui{pb}{DVD} = gui_new_pixbuf_from_file('cd_16px.png');
$gui{pb}{Floppy} = gui_new_pixbuf_from_file('fd_16px.png');
$gui{pb}{ctr}{IDE} = gui_new_pixbuf_from_file('ide_16px.png');
$gui{pb}{ctr}{SATA} = gui_new_pixbuf_from_file('sata_16px.png');
$gui{pb}{ctr}{SAS} = $gui{pb}{ctr}{SATA};
$gui{pb}{ctr}{SCSI} = gui_new_pixbuf_from_file('scsi_16px.png');
$gui{pb}{ctr}{Floppy} = gui_new_pixbuf_from_file('floppy_16px.png');
$gui{pb}{ctr}{USB} = gui_new_pixbuf_from_file('usb_16px.png');
$gui{pb}{ctr}{PCIe} = gui_new_pixbuf_from_file('nvme_16px.png');
$gui{pb}{ctr}{VirtioSCSI} = gui_new_pixbuf_from_file('virtio_scsi_16px.png');
# Snapshot icons
$gui{pb}{SnapshotOffline} = gui_new_pixbuf_from_file('snapshot_offline_16px.png');
$gui{pb}{SnapshotOnline} = gui_new_pixbuf_from_file('snapshot_online_16px.png');
$gui{pb}{SnapshotCurrent} = gui_new_pixbuf_from_file('machine_16px.png');
# OS Icons
$gui{pb}{OtherOS} = gui_new_pixbuf_from_file('os/Other.png');
$gui{pb}{OtherOS64} = gui_new_pixbuf_from_file('os/Other_64.png');
# Other Icons
$gui{pb}{VMGroup} = gui_new_pixbuf_from_file('vm_group_16px.png');
$gui{pb}{DirIcon} = gui_new_pixbuf_from_file('sf_16px.png');
$gui{pb}{FileIcon} = gui_new_pixbuf_from_file('vm_open_filemanager_16px.png');
$gui{pb}{ParentIcon} = gui_new_pixbuf_from_file('sf_parent_16px.png');
# Details Icons
$gui{pb}{CatGen} = gui_new_pixbuf_from_file('machine_16px.png');
$gui{pb}{CatSys} = gui_new_pixbuf_from_file('chipset_16px.png');
$gui{pb}{CatDisp} = gui_new_pixbuf_from_file('vrdp_16px.png');
$gui{pb}{CatStor} = gui_new_pixbuf_from_file('hd_16px.png');
$gui{pb}{CatAudio} = gui_new_pixbuf_from_file('sound_16px.png');
$gui{pb}{CatNet} = gui_new_pixbuf_from_file('nw_16px.png');
$gui{pb}{CatIO} = gui_new_pixbuf_from_file('serial_port_16px.png');
$gui{pb}{CatUSB} = gui_new_pixbuf_from_file('usb_16px.png');
$gui{pb}{CatShare} = gui_new_pixbuf_from_file('sf_16px.png');
$gui{pb}{CatDesc} = gui_new_pixbuf_from_file('description_16px.png');
# Progress Decals
$gui{pb}{ProgressClone} = gui_new_pixbuf_from_file('progress_clone_90px.png');
$gui{pb}{ProgressRefresh} = gui_new_pixbuf_from_file('progress_refresh_90px.png');
$gui{pb}{ProgressDelete} = gui_new_pixbuf_from_file('progress_delete_90px.png');
$gui{pb}{ProgressExport} = gui_new_pixbuf_from_file('progress_export_90px.png');
$gui{pb}{ProgressImport} = gui_new_pixbuf_from_file('progress_import_90px.png');
$gui{pb}{ProgressInstallGA} = gui_new_pixbuf_from_file('progress_install_guest_additions_90px.png');
$gui{pb}{ProgressMediaCreate} = gui_new_pixbuf_from_file('progress_media_create_90px.png');
$gui{pb}{ProgressMediaDelete} = gui_new_pixbuf_from_file('progress_media_delete_90px.png');
$gui{pb}{ProgressMediaMove} = gui_new_pixbuf_from_file('progress_media_move_90px.png');
$gui{pb}{ProgressMediaResize} = gui_new_pixbuf_from_file('progress_media_resize_90px.png');
$gui{pb}{ProgressNetwork} = gui_new_pixbuf_from_file('progress_network_interface_90px.png');
$gui{pb}{ProgressPowerOff} = gui_new_pixbuf_from_file('progress_poweroff_90px.png');
$gui{pb}{ProgressReadAppl} = gui_new_pixbuf_from_file('progress_reading_appliance_90px.png');
$gui{pb}{ProgressSettings} = gui_new_pixbuf_from_file('progress_settings_90px.png');
$gui{pb}{ProgressSnapshotCreate} = gui_new_pixbuf_from_file('progress_snapshot_create_90px.png');
$gui{pb}{ProgressSnapshotDiscard} = gui_new_pixbuf_from_file('progress_snapshot_discard_90px.png');
$gui{pb}{ProgressSnapshotRestore} = gui_new_pixbuf_from_file('progress_snapshot_restore_90px.png');
$gui{pb}{ProgressStart} = gui_new_pixbuf_from_file('progress_start_90px.png');
$gui{pb}{ProgressRestore} = gui_new_pixbuf_from_file('progress_state_restore_90px.png');
$gui{pb}{ProgressStateSave} = gui_new_pixbuf_from_file('progress_state_save_90px.png');

# Build the AboutDialog
sub build_dialogAbout {
    $gui{d}{About}{dialog} = Gtk3::AboutDialog->new();
    $gui{d}{About}{dialog}->set_icon(gui_new_pixbuf_from_file('remotebox.png'));
    $gui{d}{About}{dialog}->set_program_name($gui{appname});
    $gui{d}{About}{dialog}->set_version($gui{appver});
    $gui{d}{About}{dialog}->set_comments("RemoteBox is a client for managing VirtualBox and its guests over the network.\nFor use with VirtualBox 7.2.x");
    $gui{d}{About}{dialog}->set_copyright("RemoteBox (ex. artwork) Copyright © 2010-2027 Ian Chapman\nRemoteBox is not affiliated with Oracle.\nAll trademarks belong to their respective owners.\n\nIf you like RemoteBox or have found it useful, please consider donating.");
    $gui{d}{About}{dialog}->set_documenters(['Ian Chapman <packages@amiga-hardware.com>']);
    $gui{d}{About}{dialog}->set_artists(['Icons are included which originate from the VirtualBox Open Source Edition, released under the GPL']);
    $gui{d}{About}{dialog}->set_authors(['Ian Chapman <packages@amiga-hardware.com>']);
    $gui{d}{About}{dialog}->set_license_type('GTK_LICENSE_GPL_2_0');
    $gui{d}{About}{dialog}->set_logo(gui_new_pixbuf_from_file('remotebox-about.png'));
    $gui{d}{About}{dialog}->set_website('http://remotebox.knobgoblin.org.uk');
    $gui{d}{About}{dialog}->set_website_label('Donate or visit the RemoteBox site');
    $gui{d}{About}{dialog}->set_transient_for($gui{d}{Main}{win});
    $gui{d}{About}{dialog}->signal_connect('hide' => \&transwin_sens_on, $gui{d}{Main}{win});
    $gui{d}{About}{dialog}->signal_connect('show' => \&transwin_sens_off, $gui{d}{Main}{win});
}

# Build Warning MessageDialog
sub build_messageDialogsAll {
    # Try to support OS with older perl-gtk3 installs
    # Will miss some info or look more janky but RemoteBox will run
    my $newgtk = Gtk3::MessageDialog->can('new_with_markup');
    # General warning dialog
    $gui{d}{Warning}{dialog} = $newgtk ? Gtk3::MessageDialog->new_with_markup($gui{d}{Main}{win}, 'GTK_DIALOG_MODAL', 'GTK_MESSAGE_WARNING', 'GTK_BUTTONS_OK', '<b><big>Warning Message Dialog</big></b>') :
                                         Gtk3::MessageDialog->new($gui{d}{Main}{win}, 'GTK_DIALOG_MODAL', 'GTK_MESSAGE_WARNING', 'GTK_BUTTONS_OK', 'Warning Message Dialog');
    $gui{d}{Warning}{dialog}->signal_connect('hide' => \&transwin_sens_on, $gui{d}{Warning}{dialog});
    $gui{d}{Warning}{dialog}->signal_connect('show' => \&transwin_sens_off, $gui{d}{Warning}{dialog});
    $gui{d}{Warning}{dialog}->set_deletable(FALSE);
    $gui{d}{Warning}{dialog}->set_icon(gui_new_pixbuf_from_file('remotebox.png'));
    # General error dialog
    $gui{d}{Error}{dialog} = $newgtk ? Gtk3::MessageDialog->new_with_markup($gui{d}{Main}{win}, 'GTK_DIALOG_MODAL', 'GTK_MESSAGE_ERROR', 'GTK_BUTTONS_OK', '<b><big>Error Message Dialog</big></b>') :
                                       Gtk3::MessageDialog->new($gui{d}{Main}{win}, 'GTK_DIALOG_MODAL', 'GTK_MESSAGE_ERROR', 'GTK_BUTTONS_OK', 'Error Message Dialog');
    $gui{d}{Error}{dialog}->signal_connect('hide' => \&transwin_sens_on, $gui{d}{Error}{dialog});
    $gui{d}{Error}{dialog}->signal_connect('show' => \&transwin_sens_off, $gui{d}{Error}{dialog});
    $gui{d}{Error}{dialog}->set_deletable(FALSE);
    $gui{d}{Error}{dialog}->set_icon(gui_new_pixbuf_from_file('remotebox.png'));
    # The Remove selected guest dialog
    $gui{d}{RemoveGuest}{dialog} = $newgtk ? Gtk3::MessageDialog->new_with_markup($gui{d}{Main}{win}, 'GTK_DIALOG_MODAL', 'GTK_MESSAGE_WARNING', 'GTK_BUTTONS_NONE', '<b><big>Remove the selected guest?</big></b>') :
                                             Gtk3::MessageDialog->new($gui{d}{Main}{win}, 'GTK_DIALOG_MODAL', 'GTK_MESSAGE_WARNING', 'GTK_BUTTONS_NONE', 'Remove the selected guest?');
    $newgtk ? $gui{d}{RemoveGuest}{dialog}->format_secondary_text('Choose whether to remove the guest and delete the associated files or only remove it from VirtualBox. Deleting all files is a permanent and irreversible operation. Removing will allow you to add the guest again at a later date') : print("format_secondary_text() support missing\n") ;
    $gui{d}{RemoveGuest}{dialog}->set_deletable(FALSE);
    $gui{d}{RemoveGuest}{dialog}->set_default_response('cancel');
    $gui{d}{RemoveGuest}{dialog}->add_button('Cancel', 'cancel');
    $gui{d}{RemoveGuest}{dialog}->signal_connect('hide' => \&transwin_sens_on, $gui{d}{RemoveGuest}{dialog});
    $gui{d}{RemoveGuest}{dialog}->signal_connect('show' => \&transwin_sens_off, $gui{d}{RemoveGuest}{dialog});
    $gui{d}{RemoveGuest}{dialog}->set_icon(gui_new_pixbuf_from_file('remotebox.png'));
    my $removebutton = $gui{d}{RemoveGuest}{dialog}->add_button('Remove Only', 1);
    $removebutton->set_always_show_image(TRUE);
    $removebutton->set_image(gui_new_img_from_file('dialog_remove_only_16px.png'));
    $removebutton->set_image_position('GTK_POS_LEFT');
    my $deletebutton = $gui{d}{RemoveGuest}{dialog}->add_button('Delete All Files', 2);
    $deletebutton->set_always_show_image(TRUE);
    $deletebutton->set_image(gui_new_img_from_file('dialog_delete_all_files_16px.png'));
    $deletebutton->set_image_position('GTK_POS_LEFT');
    # The Remove HD dialog
    $gui{d}{RemoveHD}{dialog} = $newgtk ? Gtk3::MessageDialog->new_with_markup($gui{d}{Main}{win}, 'GTK_DIALOG_MODAL', 'GTK_MESSAGE_WARNING', 'GTK_BUTTONS_NONE', '<b><big>Remove or Delete Hard Disk Image?</big></b>') :
                                          Gtk3::MessageDialog->new($gui{d}{Main}{win}, 'GTK_DIALOG_MODAL', 'GTK_MESSAGE_WARNING', 'GTK_BUTTONS_NONE', 'Remove or Delete Hard Disk Image?');
    $newgtk ? $gui{d}{RemoveHD}{dialog}->format_secondary_text("Deleting the hard disk image will permanently remove it from the host's file system. It will no longer be available in VirtualBox and all data on the disk image will be destroyed.\nRemoving will make the hard disk image unavailable to VirtualBox, however it may be added again at a later date.") : print ("format_secondary_text() support missing\n");
    $gui{d}{RemoveHD}{dialog}->set_deletable(FALSE);
    $gui{d}{RemoveHD}{dialog}->set_default_response('cancel');
    $gui{d}{RemoveHD}{dialog}->add_button('Cancel', 'cancel');
    $gui{d}{RemoveHD}{dialog}->signal_connect('hide' => \&transwin_sens_on, $gui{d}{RemoveHD}{dialog});
    $gui{d}{RemoveHD}{dialog}->signal_connect('show' => \&transwin_sens_off, $gui{d}{RemoveHD}{dialog});
    $gui{d}{RemoveHD}{dialog}->set_icon(gui_new_pixbuf_from_file('remotebox.png'));
    my $removehdbutton = $gui{d}{RemoveHD}{dialog}->add_button('Remove Only', 2);
    $removehdbutton->set_always_show_image(TRUE);
    $removehdbutton->set_image(gui_new_img_from_file('dialog_remove_only_16px.png'));
    $removehdbutton->set_image_position('GTK_POS_LEFT');
    my $deletehdbutton = $gui{d}{RemoveHD}{dialog}->add_button('Delete', 1);
    $deletehdbutton->set_always_show_image(TRUE);
    $deletehdbutton->set_image(gui_new_img_from_file('hd_remove_16px.png'));
    $deletehdbutton->set_image_position('GTK_POS_LEFT');
    # InvalidObject Reference Dialog
    $gui{d}{InvalidObj}{dialog} = $newgtk ? Gtk3::MessageDialog->new_with_markup($gui{d}{Main}{win}, 'GTK_DIALOG_MODAL', 'GTK_MESSAGE_ERROR', 'GTK_BUTTONS_NONE', '<b><big>Invalid Object Reference</big></b>') :
                                            Gtk3::MessageDialog->new($gui{d}{Main}{win}, 'GTK_DIALOG_MODAL', 'GTK_MESSAGE_ERROR', 'GTK_BUTTONS_NONE', 'Invalid Object Reference');
    $gui{d}{InvalidObj}{dialog}->set_deletable(FALSE);
    $gui{d}{InvalidObj}{dialog}->set_default_response('cancel');
    $gui{d}{InvalidObj}{dialog}->add_button('Continue Anyway', 'ok');
    $gui{d}{InvalidObj}{dialog}->add_button('Disconnect', 'cancel');
    $gui{d}{InvalidObj}{dialog}->signal_connect('hide' => \&transwin_sens_on, $gui{d}{InvalidObj});
    $gui{d}{InvalidObj}{dialog}->signal_connect('show' => \&transwin_sens_off, $gui{d}{InvalidObj});
    $gui{d}{InvalidObj}{dialog}->set_icon(gui_new_pixbuf_from_file('remotebox.png'));
    # Reset Secure Boot Keys dialog
    $gui{d}{SecureBoot}{dialog} = $newgtk ? Gtk3::MessageDialog->new_with_markup($gui{d}{Main}{win}, 'GTK_DIALOG_MODAL', 'GTK_MESSAGE_WARNING', 'GTK_BUTTONS_NONE', '<b><big>Restore default Secure Boot keys?</big></b>') :
                                            Gtk3::MessageDialog->new($gui{d}{Main}{win}, 'GTK_DIALOG_MODAL', 'GTK_MESSAGE_WARNING', 'GTK_BUTTONS_NONE', 'Restore default Secure Boot keys?');
    $newgtk ? $gui{d}{SecureBoot}{dialog}->format_secondary_text("Restoring the Secure Boot keys to the default may affect the ability of the guest to boot correctly. Use with caution.") : print ("format_secondary_text() support missing\n");
    $gui{d}{SecureBoot}{dialog}->set_deletable(FALSE);
    $gui{d}{SecureBoot}{dialog}->set_default_response('cancel');
    $gui{d}{SecureBoot}{dialog}->add_button('Restore Keys', 'ok');
    $gui{d}{SecureBoot}{dialog}->add_button('Cancel', 'cancel');
    $gui{d}{SecureBoot}{dialog}->signal_connect('hide' => \&transwin_sens_on, $gui{d}{SecureBoot}{dialog});
    $gui{d}{SecureBoot}{dialog}->signal_connect('show' => \&transwin_sens_off, $gui{d}{SecureBoot}{dialog});
    $gui{d}{SecureBoot}{dialog}->set_icon(gui_new_pixbuf_from_file('remotebox.png'));
}

# Build local file choosers
sub build_filechooserDialogsAll {
    # Chooser for saving a screenshot
    $gui{d}{ScreenShotFileChooser}{dialog} = Gtk3::FileChooserDialog->new('Save Screenshot', undef, 'GTK_FILE_CHOOSER_ACTION_SAVE', 'Cancel', 'cancel', 'Save', 'ok');
    $gui{d}{ScreenShotFileChooser}{dialog}->signal_connect('hide' => \&transwin_sens_on, $gui{d}{ScreenShotFileChooser}{dialog});
    $gui{d}{ScreenShotFileChooser}{dialog}->signal_connect('show' => \&transwin_sens_off, $gui{d}{ScreenShotFileChooser}{dialog});
    $gui{d}{ScreenShotFileChooser}{dialog}->set_icon(gui_new_pixbuf_from_file('remotebox.png'));
    # Chooser for saving a log
    $gui{d}{LogFileChooser}{dialog} = Gtk3::FileChooserDialog->new('Save Log File', undef, 'GTK_FILE_CHOOSER_ACTION_SAVE', 'Cancel', 'cancel', 'Save', 'ok');
    $gui{d}{LogFileChooser}{dialog}->signal_connect('hide' => \&transwin_sens_on, $gui{d}{LogFileChooser});
    $gui{d}{LogFileChooser}{dialog}->signal_connect('show' => \&transwin_sens_off, $gui{d}{LogFileChooser});
    $gui{d}{LogFileChooser}{dialog}->set_icon(gui_new_pixbuf_from_file('remotebox.png'));
}

# Build the Custom Resolution Dialog
sub build_dialogCustomResolution {
    $gui{d}{CustomVideo}{dialog} = gui_new_dialog({title  => 'Resolution Hint', cancel => TRUE});
    $gui{d}{CustomVideo}{sbVideoW} = gui_new_spinbutton({lo  => 1,
                                                          hi  => 9999,
                                                          inc => 1,
                                                          tip => 'Resolution width'});

    $gui{d}{CustomVideo}{sbVideoH} = gui_new_spinbutton({lo  => 1,
                                                          hi  => 9999,
                                                          inc => 1,
                                                          tip => 'Resolution height'});

    $gui{d}{CustomVideo}{cboxVideoDepth} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::Uint'],
                                                                                              [0, 1],
                                                                                              [['8bit  - 256 colours', 8],
                                                                                               ['16bit - 65k colours', 16],
                                                                                               ['32bit - 16m colours', 32]]),
                                                                    active => 2,
                                                                    tip    => 'Resolution depth. Higher depths mean more colours'});

    $gui{adjCustomVideoW} = gui_new_adjustment($gui{d}{CustomVideo}{sbVideoW}, 640, 80, 8000, 1, 10, 0);
    $gui{adjCustomVideoH} = gui_new_adjustment($gui{d}{CustomVideo}{sbVideoH}, 480, 80, 4000, 1, 10, 0);
    $gui{d}{CustomVideo}{labelVideoInfo} = gui_new_widgetlabel({text => '', xalign => 0.5});
    $gui{d}{CustomVideo}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(gui_new_widgetlabel({text => '_Width:', mnwidget => $gui{d}{CustomVideo}{sbVideoW}}), 0, 0, 1, 1);
    $grid->attach($gui{d}{CustomVideo}{sbVideoW},  1, 0, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Height:', mnwidget => $gui{d}{CustomVideo}{sbVideoH}}), 0, 1, 1, 1);
    $grid->attach($gui{d}{CustomVideo}{sbVideoH},  1, 1, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Depth:', mnwidget => $gui{d}{CustomVideo}{cboxVideoDepth}}), 0, 2, 1, 1);
    $grid->attach($gui{d}{CustomVideo}{cboxVideoDepth}, 1, 2, 1, 1);
    $grid->attach($gui{d}{CustomVideo}{labelVideoInfo}, 1, 3, 2, 1);
    $gui{d}{CustomVideo}{sbVideoW}->signal_connect('value-changed' => \&update_vidmeminfo);
    $gui{d}{CustomVideo}{sbVideoH}->signal_connect('value-changed' => \&update_vidmeminfo);
    $gui{d}{CustomVideo}{cboxVideoDepth}->signal_connect('changed' => \&update_vidmeminfo);
}

# Build the connection dialog
sub build_dialogConnect {
    $gui{d}{Connect}{dialog} = gui_new_dialog({title  => 'Connect to VirtualBox Server',
                                                cancel => TRUE,
                                                ok     => 'Connect'});

    $gui{d}{Connect}{cboxProfile} = gui_new_simplecombobox({model  => $gui{d}{Connect}{lstoreProfile} = gui_new_lstore(['Glib::String', 'Glib::String', 'Glib::String', 'Glib::String']), # This is also shared with the profile manager
                                                             active => -1,
                                                             tip    => 'Choose a connection profile'});

    $gui{d}{Connect}{entryURL} = gui_new_entry({width => 60,
                                                 tip   => 'The URL of the VirtualBox server. For example http://myserver:18083'});

    $gui{d}{Connect}{entryUser} = gui_new_entry({width => 60,
                                                  tip   => 'The user to connect as. Leave blank if authentication is disabled on the server'});

    $gui{d}{Connect}{entryPass} = gui_new_entry({width => 60,
                                                  tip   => 'The user password. Leave blank if authentication is disabled on the server',
                                                  pass  => TRUE});

    $gui{d}{Connect}{checkSSL} = gui_new_check({text   => '_Verify certificate on SSL connections',
                                                 active => TRUE,
                                                 tip    => 'Only connects to the server if its certificate passes verification'});

    $gui{d}{Connect}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(gui_new_widgetlabel({text => 'C_onnection Profile:', mnwidget => $gui{d}{Connect}{cboxProfile}}), 0, 0, 1, 1);
    $grid->attach($gui{d}{Connect}{cboxProfile}, 1, 0, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_URL:', mnwidget => $gui{d}{Connect}{entryURL}}), 0, 1, 1, 1);
    $grid->attach($gui{d}{Connect}{entryURL}, 1, 1, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'User_name:', mnwidget => $gui{d}{Connect}{entryUser}}), 0, 2, 1, 1);
    $grid->attach($gui{d}{Connect}{entryUser}, 1, 2, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Password:', mnwidget => $gui{d}{Connect}{entryPass}}), 0, 3, 1, 1);
    $grid->attach($gui{d}{Connect}{entryPass}, 1, 3, 1, 1);
    $grid->attach($gui{d}{Connect}{checkSSL}, 1, 4, 1, 1);
    $gui{d}{Connect}{cboxProfile}->signal_connect('changed' => \&select_profile);
    $gui{d}{Connect}{entryURL}->signal_connect('key-press-event' => \&set_connection_prof_inactive);
    $gui{d}{Connect}{entryUser}->signal_connect('key-press-event' => \&set_connection_prof_inactive);
    $gui{d}{Connect}{entryPass}->signal_connect('key-press-event' => \&set_connection_prof_inactive);
    $gui{d}{Connect}{checkSSL}->signal_connect('toggled' => \&rbprefs_sslverify);
}

# Build the password dialog for encryped guests
sub build_dialogDecPassword {
    $gui{d}{DecPassword}{dialog} = gui_new_dialog({title  => 'Decryption Password', cancel => TRUE});
    $gui{d}{DecPassword}{entryPass} = gui_new_entry({width => 60,
                                                  tip   => 'The password to decrypt the specified medium',
                                                  pass  => TRUE});

    $gui{d}{DecPassword}{labelKeyID} = gui_new_widgetlabel({text => '',
                                                             xalign => 0.5});

    $gui{d}{DecPassword}{labelDisk} = gui_new_widgetlabel({text => '',
                                                            xalign => 0.5});

    $gui{d}{DecPassword}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach($gui{d}{DecPassword}{labelKeyID}, 0, 0, 2, 1);
    $grid->attach($gui{d}{DecPassword}{labelDisk}, 0, 1, 2, 1);
    $grid->attach(gui_new_widgetlabel({text => 'Password:', mnwidget => $gui{d}{DecPassword}{entryPass}}), 0, 2, 1, 1);
    $grid->attach($gui{d}{DecPassword}{entryPass}, 1, 2, 1, 1);
}

# Build the dialog for Shared Folders.
sub build_dialogSharedFolders {
    $gui{d}{SharedFolders}{dialog} = gui_new_dialog({title  => 'Shared Folders', cancel => TRUE});
    $gui{d}{SharedFolders}{entryPath} = gui_new_entry({width  => 35,
                                                        tip    => 'Full path to the shared folder, which must be accessible by the server'});

    $gui{d}{SharedFolders}{entryName} = gui_new_entry({width  => 35,
                                                        maxlen => 128,
                                                        tip    => 'The name of shared folder as referenced by the guest'});

    $gui{d}{SharedFolders}{checkReadOnly} = gui_new_check({text   => '_Read-Only',
                                                            active => FALSE,
                                                            tip    => 'Mount the folder as read-only'});

    $gui{d}{SharedFolders}{checkAutoMount} = gui_new_check({text   => '_Auto Mount',
                                                             active => FALSE,
                                                             tip    => 'Automatically mount the folder when the guest starts'});

    $gui{d}{SharedFolders}{checkPermanent} = gui_new_check({text   => '_Make Permanent',
                                                             active => FALSE,
                                                             tip    => 'Make this share non-transient'});

    my $buttonfolder = gui_new_imgbutton({image => 'sf_16px.png', tip => 'Choose the folder on the server'});
    $gui{d}{SharedFolders}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(gui_new_widgetlabel({text => 'Folder _Path:', mnwidget => $gui{d}{SharedFolders}{entryPath}}), 0, 0, 1, 1);
    $grid->attach($gui{d}{SharedFolders}{entryPath}, 1, 0, 1, 1);
    $grid->attach($buttonfolder, 2, 0, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'Folder _Name:', mnwidget => $gui{d}{SharedFolders}{entryName}}), 0, 1, 1, 1);
    $grid->attach($gui{d}{SharedFolders}{entryName}, 1, 1, 2, 1);
    $grid->attach($gui{d}{SharedFolders}{checkReadOnly}, 1, 3, 2, 1);
    $grid->attach($gui{d}{SharedFolders}{checkAutoMount}, 1, 4, 2, 1);
    $grid->attach($gui{d}{SharedFolders}{checkPermanent}, 1, 5, 2, 1);

    $buttonfolder->signal_connect('clicked' => \&show_remote_filechooser, {title       => 'Choose Shared Folder',
                                                                           entrywidget => \$gui{d}{SharedFolders}{entryPath},
                                                                           mode        => 'dir',
                                                                           filter      => ' ^',
                                                                           callback    => \&handle_remote_folder_entry}),
}

# Build the Copy Floppy Dialog
sub build_dialogCopyFloppy {
    $gui{d}{CopyFloppy}{dialog} = gui_new_dialog({title  => 'Copy Floppy Disk Image',
                                                   cancel => TRUE,
                                                   ok     => 'Copy'});

    $gui{d}{CopyFloppy}{entrySrc} = gui_new_entry({width  => 35, tip => 'The source floppy disk image'});
    $gui{d}{CopyFloppy}{entrySrc}->set_editable(FALSE);
    $gui{d}{CopyFloppy}{entrySrc}->set_can_focus(FALSE);
    $gui{d}{CopyFloppy}{entryDst} = gui_new_entry({width  => 35, tip => 'The destination floppy disk image'});
    my $buttonfolder = gui_new_imgbutton({image => 'sf_16px.png', tip => 'Choose the destination and image name'});
    $gui{d}{CopyFloppy}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(gui_new_widgetlabel({text => 'Source Floppy:'}), 0, 0, 1, 1);
    $grid->attach($gui{d}{CopyFloppy}{entrySrc}, 1, 0, 2, 1);
    $grid->attach(gui_new_widgetlabel({text => 'New Floppy _Name:', mnwidget => $gui{d}{CopyFloppy}{entryDst}}), 0, 1, 1, 1);
    $grid->attach($gui{d}{CopyFloppy}{entryDst}, 1, 1, 1, 1);
    $grid->attach($buttonfolder, 2, 1, 1, 1);
    $buttonfolder->signal_connect('clicked' => \&show_remote_filechooser, {title       => 'Destination Floppy Image',
                                                                           entrywidget => \$gui{d}{CopyFloppy}{entryDst},
                                                                           mode        => 'file',
                                                                           filter      => '.*',
                                                                           callback    => \&handle_remote_file_entry});
}

# Build the Move Medium dialog
sub build_dialogMoveMedium {
    $gui{d}{MoveMedium}{dialog} = gui_new_dialog({title  => 'Move Medium',
                                           cancel => TRUE,
                                           ok     => 'Move'});

    $gui{d}{MoveMedium}{entrySrc} = gui_new_entry({width  => 35,
                                                    tip    => 'The source medium to move'});
    $gui{d}{MoveMedium}{entrySrc}->set_editable(FALSE);
    $gui{d}{MoveMedium}{entrySrc}->set_can_focus(FALSE);

    $gui{d}{MoveMedium}{entryDst} = gui_new_entry({width  => 35,
                                                    tip    => 'The destination location and file name'});

    my $buttonfolder = gui_new_imgbutton({image => 'sf_16px.png',
                                           tip   => 'Choose the destination and file name'});

    $gui{d}{MoveMedium}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(gui_new_widgetlabel({text => 'Medium:'}), 0, 0, 1, 1);
    $grid->attach($gui{d}{MoveMedium}{entrySrc}, 1, 0, 2, 1);
    $grid->attach(gui_new_widgetlabel({text => 'New _Destination:', mnwidget => $gui{d}{MoveMedium}{entryDst}}), 0, 1, 1, 1);
    $grid->attach($gui{d}{MoveMedium}{entryDst}, 1, 1, 1, 1);
    $grid->attach($buttonfolder, 2, 1, 1, 1);
    $buttonfolder->signal_connect('clicked' => \&show_remote_filechooser, {title       => 'Destination Medium',
                                                                           entrywidget => \$gui{d}{MoveMedium}{entryDst},
                                                                           mode        => 'file',
                                                                           filter      => '.*',
                                                                           callback    => \&handle_remote_file_entry});
}

# Build Create Floppy dialog
sub build_dialogCreateFloppy {
    $gui{d}{CreateFloppy}{dialog} = gui_new_dialog({title   => 'Create Floppy Disk Image',
                                                     cancel  => TRUE,
                                                     ok      => 'Create',
                                                     okimage => gui_new_img_from_file('fd_create_16px.png')});

    $gui{d}{CreateFloppy}{entryImage} = gui_new_entry({width  => 35, tip => 'The floppy disk image filename, without extension'});
    my $buttonfolder = gui_new_imgbutton({image => 'sf_16px.png', tip => 'Choose the destination and file name'});

    $gui{d}{CreateFloppy}{cboxSize} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                         [0, 1],
                                                                                         [['2.88 MB', '2949120'],
                                                                                          ['1.44 MB', '1474560'],
                                                                                          ['1.2 MB',  '1228800'],
                                                                                          ['720 KB',  '737280'],
                                                                                          ['360 KB',  '368640']]),
                                                               active => 1,
                                                               tip    => 'The size of the floppy disk image'});

    $gui{d}{CreateFloppy}{checkFAT12} = gui_new_check({text => '_FAT12 Formatted',
                                                        active => TRUE,
                                                        tip    => 'Preformat the disk with the FAT12 filesystem'});

    $gui{d}{CreateFloppy}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(gui_new_widgetlabel({text => 'Floppy _Image:', mnwidget => $gui{d}{CreateFloppy}{entryImage}}), 0, 0, 1, 1);
    $grid->attach($gui{d}{CreateFloppy}{entryImage}, 1, 0, 1, 1);
    $grid->attach($buttonfolder, 2, 0, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'Floppy _Size:', mnwidget => $gui{d}{CreateFloppy}{cboxSize}}), 0, 1, 1, 1);
    $grid->attach($gui{d}{CreateFloppy}{cboxSize}, 1, 1, 2, 1);
    $grid->attach($gui{d}{CreateFloppy}{checkFAT12}, 1, 2, 2, 1);
    $buttonfolder->signal_connect('clicked' => \&show_remote_filechooser, {title       => 'Destination Floppy Image',
                                                                           entrywidget => \$gui{d}{CreateFloppy}{entryImage},
                                                                           mode        => 'file',
                                                                           filter      => '.*',
                                                                           callback    => \&handle_remote_file_entry});
}

# Build the USB Filter dialog
sub build_dialogUSBFilter {
    $gui{d}{USBFilter}{dialog} = gui_new_dialog({title  => 'USB Filter Properties', cancel => TRUE});
    $gui{d}{USBFilter}{entryName} = gui_new_entry({tip => 'Name of the USB filter'});
    $gui{d}{USBFilter}{entryVendorID} = gui_new_entry({maxlen => 4, tip => 'The hex number of the vendor ID to match. Leave empty to match any'});
    $gui{d}{USBFilter}{entryProductID} = gui_new_entry({maxlen => 4, tip => 'The hex number of the product ID to match. Leave empty to match any'});
    $gui{d}{USBFilter}{entryRev} = gui_new_entry({maxlen => 4, tip => 'The hex number of the revision to match. Leave empty to match any'});
    $gui{d}{USBFilter}{entryManufacturer} = gui_new_entry({tip => 'The manufacturer string to match. Leave empty to match any'});
    $gui{d}{USBFilter}{entryProduct} = gui_new_entry({tip => 'The product string to match. Leave empty to match any'});
    $gui{d}{USBFilter}{entrySerial} = gui_new_entry({tip => 'The serial string to match. Leave empty to match any'});
    $gui{d}{USBFilter}{entryPort} = gui_new_entry({maxlen => 4, tip => 'The host USB port number to match. Leave empty to match any USB port'});
    $gui{d}{USBFilter}{cboxRemote} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                        [0, 1],
                                                                                        [['Any', 'any'],
                                                                                         ['Yes', 'yes'],
                                                                                         ['No', 'no']]),
                                                              active => 0,
                                                              tip    => 'Whether to apply the filters remotely, locally or both'});

    $gui{d}{USBFilter}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(gui_new_widgetlabel({text => '_Name:', mnwidget => $gui{d}{USBFilter}{entryName}}), 0, 0, 1, 1);
    $grid->attach($gui{d}{USBFilter}{entryName}, 1, 0, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Vendor ID:', mnwidget => $gui{d}{USBFilter}{entryVendorID}}), 0, 1, 1, 1);
    $grid->attach($gui{d}{USBFilter}{entryVendorID}, 1, 1, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Product ID:', mnwidget => $gui{d}{USBFilter}{entryProductID}}), 0, 2, 1, 1);
    $grid->attach($gui{d}{USBFilter}{entryProductID}, 1, 2, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Revision:', mnwidget => $gui{d}{USBFilter}{entryRev}}), 0, 3, 1, 1);
    $grid->attach($gui{d}{USBFilter}{entryRev}, 1, 3, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Manufacturer:', mnwidget => $gui{d}{USBFilter}{entryManufacturer}}), 0, 4, 1, 1);
    $grid->attach($gui{d}{USBFilter}{entryManufacturer}, 1, 4, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'Pro_duct:', mnwidget => $gui{d}{USBFilter}{entryProduct}}), 0, 5, 1, 1);
    $grid->attach($gui{d}{USBFilter}{entryProduct}, 1, 5, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Serial #:', mnwidget => $gui{d}{USBFilter}{entrySerial}}), 0, 6, 1, 1);
    $grid->attach($gui{d}{USBFilter}{entrySerial}, 1, 6, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'Por_t:', mnwidget => $gui{d}{USBFilter}{entryPort}}), 0, 7, 1, 1);
    $grid->attach($gui{d}{USBFilter}{entryPort}, 1, 7, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'R_emote:', mnwidget => $gui{d}{USBFilter}{cboxRemote}}), 0, 8, 1, 1);
    $grid->attach($gui{d}{USBFilter}{cboxRemote}, 1, 8, 1, 1);
    # Signals
    $gui{d}{USBFilter}{entryVendorID}->signal_connect('changed' => \&valid_hex_char);
    $gui{d}{USBFilter}{entryProductID}->signal_connect('changed' => \&valid_hex_char);
    $gui{d}{USBFilter}{entryRev}->signal_connect('changed' => \&valid_hex_char);
    $gui{d}{USBFilter}{entryPort}->signal_connect('changed' => \&valid_number_char);
}

# Build the Import Appliance Dialog
sub build_dialogImportAppl {
    $gui{d}{ImportAppl}{dialog} = gui_new_dialog({title   => 'Import Appliance',
                                                   cancel  => TRUE,
                                                   ok      => 'Import',
                                                   okimage => gui_new_img_from_file('dialog_import_16px.png')});

    $gui{d}{ImportAppl}{entryAppl} = gui_new_entry({width  => 35, tip => 'The path and file name of the appliance to import'});
    my $buttonfolder = gui_new_imgbutton({image => 'sf_16px.png', tip => 'Choose the appliance to import'});

    $gui{d}{ImportAppl}{cboxMAC} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String'],
                                                                                      [0],
                                                                                      [['Keep all network adapter MAC addresses'],
                                                                                       ['Keep only NAT network adapter MAC addresses'],
                                                                                       ['Generate new MAC addresses for all network adapters']]),
                                                            active => 1,
                                                            tip    => 'Choose how the MAC addresses are handled on import'});

    $gui{d}{ImportAppl}{checkConvert} = gui_new_check({text   => '_Convert hard drives to VDI format',
                                                        active => FALSE,
                                                        tip    => 'Convert hard drive images to VDI format on import'});

    $gui{d}{ImportAppl}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(my $img = gui_new_img_from_file('wizard_ovf_import.png'), 0, 0, 1, 4);
    $img->set_alignment(0.0, 0.0);
    $grid->attach(gui_new_widgetlabel({text => '_Appliance (OVA/OVF):', mnwidget => $gui{d}{ImportAppl}{entryAppl}}), 1, 0, 1, 1);
    $grid->attach($gui{d}{ImportAppl}{entryAppl}, 2, 0, 1, 1);
    $grid->attach($buttonfolder, 3, 0, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_MAC Address Policy:', mnwidget => $gui{d}{ImportAppl}{cboxMAC}}), 1, 1, 1, 1);
    $grid->attach($gui{d}{ImportAppl}{cboxMAC}, 2, 1, 2, 1);
    $grid->attach($gui{d}{ImportAppl}{checkConvert}, 2, 2, 2, 1);
    $grid->attach(gui_new_layout(), 3, 3, 1, 1);
    $buttonfolder->signal_connect('clicked' => \&show_remote_filechooser, {title       => 'Choose Import Appliance File',
                                                                           entrywidget => \$gui{d}{ImportAppl}{entryAppl},
                                                                           mode        => 'file',
                                                                           filter      => '^.*\.ova$|^.*\.ovf$|^.*\.tar\.gz$|^.*\.tgz$',
                                                                           callback     => \&handle_remote_file_entry});
}

# Build the Export Appliance Dialog
sub build_dialogExportAppl {
    $gui{d}{ExportAppl}{dialog} = gui_new_dialog({title   => 'Export Appliance',
                                                   cancel  => TRUE,
                                                   ok      => 'Export',
                                                   okimage => gui_new_img_from_file('dialog_export_16px.png')});

    $gui{d}{ExportAppl}{dialog}->set_default_size(800,800);
    $gui{d}{ExportAppl}{entryFile} = gui_new_entry({width  => 35, tip => "Location and filename on the server where the appliance will be saved\n* Location must be absolute and writable\n* Do not specify the file extension\nThe path and file name of the appliance to import"});
    my $buttonfolder = gui_new_imgbutton({image => 'sf_16px.png', tip => 'Choose where on the server to save the appliance'});

    $gui{d}{ExportAppl}{cboxFormat} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String', 'Glib::String'],
                                                                                         [0, 1, 2],
                                                                                         [['OVA 0.9 (Open Virtualization Archive)', 'ovf-0.9', '.ova'],
                                                                                          ['OVA 1.0 (Open Virtualization Archive)', 'ovf-1.0', '.ova'],
                                                                                          ['OVA 2.0 (Open Virtualization Archive)', 'ovf-2.0', '.ova'],
                                                                                          ['OVF 0.9 (Open Virtualization Format)',  'ovf-0.9', '.ovf'],
                                                                                          ['OVF 1.0 (Open Virtualization Format)',  'ovf-1.0', '.ovf'],
                                                                                          ['OVF 2.0 (Open Virtualization Format)',  'ovf-2.0', '.ovf'],
                                                                                          ['OPC 1.0 (Oracle Public Cloud)',         'ovc-1.0', '.tar.gz']]),
                                                               active => 2,
                                                               tip    => 'The OVF format version'});

    $gui{d}{ExportAppl}{cboxMAC} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String'],
                                                                                      [0],
                                                                                      [['Include all network adapter MAC addresses'],
                                                                                       ['Include only NAT network adapter MAC addresses'],
                                                                                       ['Strip all MAC addresses for all network adapters']]),
                                                            active => 1,
                                                            tip    => 'Choose how the MAC addresses are handled on export'});

    $gui{d}{ExportAppl}{checkISO} = gui_new_check({text   => '_Include ISO image files',
                                                    active => FALSE,
                                                    tip    => 'Include any attached ISO files in the exported appliance'});

    $gui{d}{ExportAppl}{entryName} = gui_new_entry({width  => 35, tip => 'The name of the appliance'});
    $gui{d}{ExportAppl}{entryProduct} = gui_new_entry({width  => 35, tip =>  'The name of the product'});
    $gui{d}{ExportAppl}{entryProductURL} = gui_new_entry({width  => 35, tip => "The URL of the product's website"});
    $gui{d}{ExportAppl}{entryVendor} = gui_new_entry({width  => 35, tip => 'The name of the vendor'});
    $gui{d}{ExportAppl}{entryVendorURL} = gui_new_entry({width  => 35, tip => "The URL of the vendor's website"});
    $gui{d}{ExportAppl}{entryVersion} = gui_new_entry({width  => 35, tip => 'The version of the appliance'});
    $gui{d}{ExportAppl}{tbDescription} = Gtk3::TextBuffer->new();
    $gui{d}{ExportAppl}{tbLicense} = Gtk3::TextBuffer->new();

    my $tv1 = gui_new_textview({editable => TRUE,
                                 buffer   => $gui{d}{ExportAppl}{tbDescription},
                                 tip      => 'A description of the appliance'});

    my $tv2 = gui_new_textview({editable => TRUE,
                                 buffer   => $gui{d}{ExportAppl}{tbLicense},
                                 tip      => "The appliance's license"});

    my $frame1 = gui_new_frame({label => 'Export To'});
    my $frame2 = gui_new_frame({label => 'Appliance Information'});
    $gui{d}{ExportAppl}{dialog}->get_content_area()->add(my $grid1 = gui_new_grid());
    # COL ROW WIDTH HEIGHT
    $grid1->attach(my $img = gui_new_img_from_file('wizard_ovf_export.png'), 0, 0, 1, 2);
    $img->set_alignment(0.0, 0.0);
    $grid1->attach($frame1, 1, 0, 1, 1);
    $grid1->attach($frame2, 1, 1, 1, 1);
    $frame1->add(my $grid2 = gui_new_grid());
    $grid2->attach(gui_new_widgetlabel({text => '_File:', mnwidget => $gui{d}{ExportAppl}{entryFile}}), 0, 0, 1, 1);
    $grid2->attach($gui{d}{ExportAppl}{entryFile}, 1, 0, 1, 1);
    $grid2->attach($buttonfolder, 2, 0, 1, 1);
    $grid2->attach(gui_new_widgetlabel({text => 'F_ormat:', mnwidget => $gui{d}{ExportAppl}{cboxFormat}}), 0, 1, 1, 1);
    $grid2->attach($gui{d}{ExportAppl}{cboxFormat}, 1, 1, 2, 1);
    $grid2->attach(gui_new_widgetlabel({text => '_MAC Address Policy:', mnwidget => $gui{d}{ExportAppl}{cboxMAC}}), 0, 2, 1, 1);
    $grid2->attach($gui{d}{ExportAppl}{cboxMAC}, 1, 2, 2, 1);
    $grid2->attach($gui{d}{ExportAppl}{checkISO}, 1, 4, 2, 1);
    $frame2->add(my $grid3 = gui_new_grid());
    $grid3->attach(gui_new_widgetlabel({text => '_Name:', mnwidget => $gui{d}{ExportAppl}{entryName}}), 0, 0, 1, 1);
    $grid3->attach($gui{d}{ExportAppl}{entryName}, 1, 0, 1, 1);
    $grid3->attach(gui_new_widgetlabel({text => '_Product:', mnwidget => $gui{d}{ExportAppl}{entryProduct}}), 0, 1, 1, 1);
    $grid3->attach($gui{d}{ExportAppl}{entryProduct}, 1, 1, 1, 1);
    $grid3->attach(gui_new_widgetlabel({text => 'Product _URL:', mnwidget => $gui{d}{ExportAppl}{entryProductURL}}), 0, 2, 1, 1);
    $grid3->attach($gui{d}{ExportAppl}{entryProductURL}, 1, 2, 1, 1);
    $grid3->attach(gui_new_widgetlabel({text => '_Vendor:', mnwidget => $gui{d}{ExportAppl}{entryVendor}}), 0, 3, 1, 1);
    $grid3->attach($gui{d}{ExportAppl}{entryVendor}, 1, 3, 1, 1);
    $grid3->attach(gui_new_widgetlabel({text => 'V_endor URL:', mnwidget => $gui{d}{ExportAppl}{entryVendorURL}}), 0, 4, 1, 1);
    $grid3->attach($gui{d}{ExportAppl}{entryVendorURL}, 1, 4, 1, 1);
    $grid3->attach(gui_new_widgetlabel({text => 'Ve_rsion:', mnwidget => $gui{d}{ExportAppl}{entryVersion}}), 0, 5, 1, 1);
    $grid3->attach($gui{d}{ExportAppl}{entryVersion}, 1, 5, 1, 1);
    $grid3->attach(gui_new_widgetlabel({text => '_Description:', mnwidget => $tv1}), 0, 6, 1, 1);
    $grid3->attach(my $scrollwin1 = gui_new_scrolledwindow(), 1, 6, 1, 1);
    $scrollwin1->add($tv1);
    $grid3->attach(gui_new_widgetlabel({text => '_License:', mnwidget => $tv2}), 0, 7, 1, 1);
    $grid3->attach(my $scrollwin2 = gui_new_scrolledwindow(), 1, 7, 1, 1);
    $scrollwin2->add($tv2);
    # Signals
    $buttonfolder->signal_connect('clicked' => \&show_remote_filechooser, {title       => 'Choose Export Appliance File',
                                                                           entrywidget => \$gui{d}{ExportAppl}{entryFile},
                                                                           mode        => 'file',
                                                                           filter      => '.*',
                                                                           callback    => \&handle_remote_file_entry});
    $gui{d}{ExportAppl}{entryName}->signal_connect('changed' => \&valid_guestname_char);
}

# Build the Import Appliance Dialog
sub build_dialogClone {
    $gui{d}{Clone}{dialog} = gui_new_dialog({title   => 'Clone Guest',
                                              cancel  => TRUE,
                                              ok      => 'Clone',
                                              okimage => gui_new_img_from_file('dialog_clone_16px.png')});

    $gui{d}{Clone}{entryName} = gui_new_entry({width  => 35,
                                                maxlen => 255,
                                                tip    => 'The name give the clone'});

    $gui{d}{Clone}{cboxType} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String'],
                                                                                  [0],
                                                                                  [['All States'],
                                                                                   ['Current State Only'],
                                                                                    ['Linked']]),
                                                        active => 0,
                                                        tip    => '* All States : Includes any associated snapshots in the clone\n* Current State Only: Clones the current state, not any associated snapshots\n* Linked: Takes a snapshot of the original guest and links it to the cloneChoose how the MAC addresses are handled on import'});

    $gui{d}{Clone}{cboxMAC} = gui_new_simplecombobox({model => gui_new_lstore(['Glib::String'],
                                                                                [0],
                                                                                [['Keep all network adapter MAC addresses'],
                                                                                 ['Keep only NAT network adapter MAC addresses'],
                                                                                 ['Generate new MAC addresses for all network adapters']]),
                                                       active => 1,
                                                       tip    => 'Choose how the MAC addresses are handled during cloning'});

    $gui{d}{Clone}{checkKeepDiskName} = gui_new_check({text   => 'Keep _Disk Names',
                                                        active => FALSE,
                                                        tip    => 'Maintain the disk names during cloning'});

    $gui{d}{Clone}{checkKeepUUIDs} = gui_new_check({text   => 'Keep _Hardware UUIDs',
                                                        active => FALSE,
                                                        tip    => 'Maintain the hardware UUIDs during cloning'});

    $gui{d}{Clone}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(my $img = gui_new_img_from_file('wizard_clone.png'), 0, 0, 1, 6);
    $img->set_alignment(0.0, 0.0);
    $grid->attach(gui_new_widgetlabel({text => 'Clone _Name:', mnwidget => $gui{d}{Clone}{entryName}}), 1, 0, 1, 1);
    $grid->attach($gui{d}{Clone}{entryName}, 2, 0, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'Clone _Type:', mnwidget => $gui{d}{Clone}{cboxType}}), 1, 1, 1, 1);
    $grid->attach($gui{d}{Clone}{cboxType}, 2, 1, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_MAC Address Policy:', mnwidget => $gui{d}{Clone}{cboxMAC}}), 1, 2, 1, 1);
    $grid->attach($gui{d}{Clone}{cboxMAC}, 2, 2, 1, 1);
    $grid->attach($gui{d}{Clone}{checkKeepDiskName}, 2, 3, 1, 1);
    $grid->attach($gui{d}{Clone}{checkKeepUUIDs}, 2, 4, 1, 1);
    $grid->attach(gui_new_layout(), 2, 5, 1, 1);
}

# Build the IPv4 PortFordwarding dialog
sub build_dialogPFRule4 {
    $gui{d}{PFRule4}{dialog} = gui_new_dialog({title  => 'Add IPv4 Port-Forwarding Rule',
                                                cancel => TRUE,
                                                ok     => 'Apply'});

    $gui{d}{PFRule4}{entryName} = gui_new_entry({width  => 35,
                                                  maxlen => 255,
                                                  tip    => 'Name of the port-forwarding rule'});

    $gui{d}{PFRule4}{cboxProtocol} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                        [0, 1],
                                                                                        [['TCP', 'TCP'],
                                                                                         ['UDP', 'UDP']]),
                                                              active => 0,
                                                              tip    => 'The protocol for the port-forwarding rule'});

    $gui{d}{PFRule4}{entryHostIP} = gui_new_entry({width  => 35,
                                                    maxlen => 15,
                                                    tip    => 'The IP of the host to port-forward'});

    $gui{d}{PFRule4}{adjHostPort} = gui_new_adjustment(undef, 0, 0, 65535, 1, 10, 0);
    $gui{d}{PFRule4}{sbHostPort} = gui_new_spinbutton({adj    => $gui{d}{PFRule4}{adjHostPort},
                                                        lo     => 1,
                                                        hi     => 65535,
                                                        inc    => 1,
                                                        maxlen => 5,
                                                        tip    => 'The port number on the host to port-forward'});

    $gui{d}{PFRule4}{entryGuestIP} = gui_new_entry({width  => 35,
                                                     maxlen => 15,
                                                     tip    => 'The IP of the guest to port-forward to'});

    $gui{d}{PFRule4}{adjGuestPort} = gui_new_adjustment(undef, 0, 0, 65535, 1, 10, 0);
    $gui{d}{PFRule4}{sbGuestPort} = gui_new_spinbutton({adj    => $gui{d}{PFRule4}{adjGuestPort},
                                                         lo     => 1,
                                                         hi     => 65535,
                                                         inc    => 1,
                                                         maxlen => 5,
                                                         tip    => 'The port number on the guest to port-forward to'});

    $gui{d}{PFRule4}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(gui_new_widgetlabel({text => '_Name:', mnwidget => $gui{d}{PFRule4}{entryName}}), 0, 0, 1, 1);
    $grid->attach($gui{d}{PFRule4}{entryName}, 1, 0, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Protocol:', mnwidget => $gui{d}{PFRule4}{cboxProtocol}}), 0, 1, 1, 1);
    $grid->attach($gui{d}{PFRule4}{cboxProtocol}, 1, 1, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Host IP:', mnwidget => $gui{d}{PFRule4}{entryHostIP}}), 0, 2, 1, 1);
    $grid->attach($gui{d}{PFRule4}{entryHostIP}, 1, 2, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'H_ost Port:', mnwidget => $gui{d}{PFRule4}{sbHostPort}}), 0, 3, 1, 1);
    $grid->attach($gui{d}{PFRule4}{sbHostPort}, 1, 3, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Guest IP:', mnwidget => $gui{d}{PFRule4}{entryGuestIP}}), 0, 4, 1, 1);
    $grid->attach($gui{d}{PFRule4}{entryGuestIP}, 1, 4, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'G_uest Port:', mnwidget => $gui{d}{PFRule4}{sbGuestPort}}), 0, 5, 1, 1);
    $grid->attach($gui{d}{PFRule4}{sbGuestPort}, 1, 5, 1, 1);
    $gui{d}{PFRule4}{entryHostIP}->signal_connect('changed' => \&valid_ipv4_char);
    $gui{d}{PFRule4}{entryGuestIP}->signal_connect('changed' => \&valid_ipv4_char);
}

# Build the IPv6 PortFordwarding dialog
sub build_dialogPFRule6 {
    $gui{d}{PFRule6}{dialog} = gui_new_dialog({title  => 'Add IPv6 Port-Forwarding Rule',
                                                cancel => TRUE,
                                                ok     => 'Apply'});

    $gui{d}{PFRule6}{entryName} = gui_new_entry({width  => 35,
                                                  maxlen => 255,
                                                  tip    => 'Name of the port-forwarding rule'});

    $gui{d}{PFRule6}{cboxProtocol} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                        [0, 1],
                                                                                        [['TCP', 'TCP'],
                                                                                         ['UDP', 'UDP']]),
                                                              active => 0,
                                                              tip    => 'The protocol for the port-forwarding rule'});

    $gui{d}{PFRule6}{entryHostIP} = gui_new_entry({width  => 35,
                                                    maxlen => 45,
                                                    tip    => 'The IPv6 of the host to port-forward'});

    $gui{d}{PFRule6}{adjHostPort} = gui_new_adjustment(undef, 0, 0, 65535, 1, 10, 0);
    $gui{d}{PFRule6}{sbHostPort} = gui_new_spinbutton({adj    => $gui{d}{PFRule6}{adjHostPort},
                                                        lo     => 1,
                                                        hi     => 65535,
                                                        inc    => 1,
                                                        maxlen => 5,
                                                        tip    => 'The port number on the host to port-forward'});

    $gui{d}{PFRule6}{entryGuestIP} = gui_new_entry({width  => 35,
                                                     maxlen => 45,
                                                     tip    => 'The IPv6 of the guest to port-forward to'});

    $gui{d}{PFRule6}{adjGuestPort} = gui_new_adjustment(undef, 0, 0, 65535, 1, 10, 0);
    $gui{d}{PFRule6}{sbGuestPort} = gui_new_spinbutton({adj    => $gui{d}{PFRule6}{adjGuestPort},
                                                         lo     => 1,
                                                         hi     => 65535,
                                                         inc    => 1,
                                                         maxlen => 5,
                                                         tip    => 'The port number on the guest to port-forward to'});

    $gui{d}{PFRule6}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(gui_new_widgetlabel({text => '_Name:', mnwidget => $gui{d}{PFRule6}{entryName}}), 0, 0, 1, 1);
    $grid->attach($gui{d}{PFRule6}{entryName}, 1, 0, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Protocol:', mnwidget => $gui{d}{PFRule6}{cboxProtocol}}), 0, 1, 1, 1);
    $grid->attach($gui{d}{PFRule6}{cboxProtocol}, 1, 1, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Host IPv6:', mnwidget => $gui{d}{PFRule6}{entryHostIP}}), 0, 2, 1, 1);
    $grid->attach($gui{d}{PFRule6}{entryHostIP}, 1, 2, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'H_ost Port:', mnwidget => $gui{d}{PFRule6}{sbHostPort}}), 0, 3, 1, 1);
    $grid->attach($gui{d}{PFRule6}{sbHostPort}, 1, 3, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Guest IPv6:', mnwidget => $gui{d}{PFRule6}{entryGuestIP}}), 0, 4, 1, 1);
    $grid->attach($gui{d}{PFRule6}{entryGuestIP}, 1, 4, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'G_uest Port:', mnwidget => $gui{d}{PFRule6}{sbGuestPort}}), 0, 5, 1, 1);
    $grid->attach($gui{d}{PFRule6}{sbGuestPort}, 1, 5, 1, 1);
    $gui{d}{PFRule6}{entryHostIP}->signal_connect('changed' => \&valid_ipv6_char);
    $gui{d}{PFRule6}{entryGuestIP}->signal_connect('changed' => \&valid_ipv6_char);
}

# Build Host Only Network dialog
sub build_dialogHON {
    $gui{d}{HON}{dialog} = gui_new_dialog({title  => 'Host-Only Network Manager', cancel => TRUE});

    $gui{d}{HON}{entryIPV4Addr} = gui_new_entry({width  => 39,
                                                  maxlen => 15,
                                                  tip    => 'The IPv4 address of the host for this adapter'});

    $gui{d}{HON}{entryIPV4Netmask} = gui_new_entry({width  => 39,
                                                     maxlen => 15,
                                                     tip    => 'The netmask of the host for this adapter'});

    $gui{d}{HON}{entryIPV6Addr} = gui_new_entry({width  => 39,
                                                  maxlen => 39,
                                                  tip    => 'The IPv6 address of the host for this adapter'});

    $gui{d}{HON}{entryIPV6Netmask} = gui_new_entry({width  => 39,
                                                     maxlen => 3,
                                                     tip    => 'The IPv6 netmask of the host for this adapter'});

    $gui{d}{HON}{checkEnableDHCP} = gui_new_check({text   => '_Enable Server',
                                                    active => FALSE,
                                                    tip    => 'Enable the DHCP Server'});

    $gui{d}{HON}{entryServerAddr} = gui_new_entry({width  => 39,
                                                    maxlen => 15,
                                                    tip    => 'The IP address of the DHCP server assigned to this adapter'});

    $gui{d}{HON}{entryServerNetmask} = gui_new_entry({width  => 39,
                                                       maxlen => 15,
                                                       tip    => 'The netmask of the DHCP server assigned to this adapter'});

    $gui{d}{HON}{entryLowerBound} = gui_new_entry({width  => 39,
                                                    maxlen => 15,
                                                    tip    => 'The lowest assignable IP address in the range'});

    $gui{d}{HON}{entryUpperBound} = gui_new_entry({width  => 39,
                                                    maxlen => 15,
                                                    tip    => 'The highest assignable IP address in the range'});

    my $box = gui_new_box('vertical');
    $gui{d}{HON}{gridDHCP} = gui_new_grid();
    my $notebook = Gtk3::Notebook->new();
    $notebook->append_page(my $grid = gui_new_grid(), gui_new_widgetlabel({text => '_Adapter'}));
    $notebook->append_page($box, gui_new_widgetlabel({text => '_DHCP Server'}));
    $notebook->show_all();
    $box->pack_start($gui{d}{HON}{checkEnableDHCP}, TRUE, TRUE, 2);
    $box->pack_start($gui{d}{HON}{gridDHCP}, TRUE, TRUE, 2);
    $gui{d}{HON}{dialog}->get_content_area()->add($notebook);
    $grid->attach(gui_new_widgetlabel({text => '_IPv4 Address:', mnwidget => $gui{d}{HON}{entryIPV4Addr}}), 0, 0, 1, 1);
    $grid->attach($gui{d}{HON}{entryIPV4Addr}, 1, 0, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'IPv4 _Netmask:', mnwidget => $gui{d}{HON}{entryIPV4Netmask}}), 0, 1, 1, 1);
    $grid->attach($gui{d}{HON}{entryIPV4Netmask}, 1, 1, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'I_Pv6 Address:', mnwidget => $gui{d}{HON}{entryIPV6Addr}}), 0, 2, 1, 1);
    $grid->attach($gui{d}{HON}{entryIPV6Addr}, 1, 2, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'IPv6 Netmask _Length:', mnwidget => $gui{d}{HON}{entryIPV6Netmask}}), 0, 3, 1, 1);
    $grid->attach($gui{d}{HON}{entryIPV6Netmask}, 1, 3, 1, 1);
    $gui{d}{HON}{gridDHCP}->attach(gui_new_widgetlabel({text => 'Server Add_ress:', mnwidget => $gui{d}{HON}{entryServerAddr}}), 0, 1, 1, 1);
    $gui{d}{HON}{gridDHCP}->attach($gui{d}{HON}{entryServerAddr}, 1, 1, 1, 1);
    $gui{d}{HON}{gridDHCP}->attach(gui_new_widgetlabel({text => 'Server _Netmask:', mnwidget => $gui{d}{HON}{entryServerNetmask}}), 0, 2, 1, 1);
    $gui{d}{HON}{gridDHCP}->attach($gui{d}{HON}{entryServerNetmask}, 1, 2, 1, 1);
    $gui{d}{HON}{gridDHCP}->attach(gui_new_widgetlabel({text => '_Lower Address Bound:', mnwidget => $gui{d}{HON}{entryLowerBound}}), 0, 3, 1, 1);
    $gui{d}{HON}{gridDHCP}->attach($gui{d}{HON}{entryLowerBound}, 1, 3, 1, 1);
    $gui{d}{HON}{gridDHCP}->attach(gui_new_widgetlabel({text => '_Upper Address Bound:', mnwidget => $gui{d}{HON}{entryUpperBound}}), 0, 4, 1, 1);
    $gui{d}{HON}{gridDHCP}->attach($gui{d}{HON}{entryUpperBound}, 1, 4, 1, 1);
    $gui{d}{HON}{entryIPV4Addr}->signal_connect('changed' => \&valid_ipv4_char);
    $gui{d}{HON}{entryIPV4Netmask}->signal_connect('changed' => \&valid_ipv4_char);
    $gui{d}{HON}{entryServerAddr}->signal_connect('changed' => \&valid_ipv4_char);
    $gui{d}{HON}{entryServerNetmask}->signal_connect('changed' => \&valid_ipv4_char);
    $gui{d}{HON}{entryLowerBound}->signal_connect('changed' => \&valid_ipv4_char);
    $gui{d}{HON}{entryUpperBound}->signal_connect('changed' => \&valid_ipv4_char);
    $gui{d}{HON}{entryIPV6Addr}->signal_connect('changed' => \&valid_ipv6_char);
}

# Build Set Group Dialog
sub build_dialogSetGroup {
    $gui{d}{SetGroup}{dialog} = gui_new_dialog({title  => 'Set Group Membership', cancel => TRUE});

    $gui{d}{SetGroup}{entryGroup} = gui_new_entry({width  => 50,
                                                    maxlen => 255,
                                                    tip    => 'Set the group membership for the guest. Groups are dynamically created and destroyed as needed'});

    $gui{d}{SetGroup}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(gui_new_widgetlabel({text => '_Group:', mnwidget => $gui{d}{SetGroup}{entryGroup}}), 0, 0, 1, 1);
    $grid->attach($gui{d}{SetGroup}{entryGroup}, 1, 0, 1, 1);
    $grid->attach(gui_new_markuplabel({text => "Subgroups must be separated with /\n<i>Example: /GroupA/SubGroup/SubSubGroup</i>\nNew groups are dynamically created and empty groups automatically destroyed."}), 1, 1, 1, 1);
    # Signals
    $gui{d}{SetGroup}{entryGroup}->signal_connect('changed' => \&valid_group_char);
}

# Build the VB Prefs dialog
sub build_dialogVBPrefs {
    $gui{d}{VBPrefs}{dialog} = gui_new_dialog({title  => 'VirtualBox Preferences',
                                                cancel => TRUE,
                                                ok     => 'Save'});

    $gui{d}{VBPrefs}{entryMachineFolder} = gui_new_entry({width  => 35, tip => 'The default path where guests are created. This location must be accessible by the server'});
    my $buttonfolder1 = gui_new_imgbutton({image => 'sf_16px.png', tip => 'Choose the default machine folder'});
    $gui{d}{VBPrefs}{buttonMachineReset} = gui_new_imgbutton({image => 'reset_defmacfolder_16px.png', tip => 'Reset the machine folder to the default value'});
    $gui{d}{VBPrefs}{entryDatabaseFolder} = gui_new_entry({width => 35, tip => "Folder containing the autostart database.\n* Server configuration is required for this option. See the RemoteBox manual\n* The autostart database folder should be set the same as the server's configuration"});
    my $buttonfolder2 = gui_new_imgbutton({image => 'sf_16px.png', tip => 'Choose the autostart database folder'});
    $gui{d}{VBPrefs}{entryVRDPLib} = gui_new_entry({width => 35, tip => "The default VRDP (Remote Display) authentication library to use. The library must be accessible by the server\n* Do not specify the .dll or .so suffix.\n* If unsure, specify VBoxAuth"});
    $gui{d}{VBPrefs}{buttonVRDPLibReset} = gui_new_imgbutton({image => 'reset_defmacfolder_16px.png', tip => 'Reset the VRDP Authentication Library to the default'});

    $gui{d}{VBPrefs}{checkExclusive} = gui_new_check({text   => '_Hardware Virtualization Exclusive to VirtualBox',
                                                       active => FALSE,
                                                       tip    => "Permits the use of alternative hypervisors alongside VirtualBox\n* Disable if your server runs other hypervisors\n* Enable if your server only runs VirtualBox"});
    $gui{d}{VBPrefs}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(gui_new_widgetlabel({text => 'Default _Machine Folder:', mnwidget => $gui{d}{VBPrefs}{entryMachineFolder}}), 0, 0, 1, 1);
    $grid->attach($gui{d}{VBPrefs}{entryMachineFolder}, 1, 0, 1, 1);
    $grid->attach($buttonfolder1, 2, 0, 1, 1);
    $grid->attach($gui{d}{VBPrefs}{buttonMachineReset}, 3, 0, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Autostart Database Folder:', mnwidget => $gui{d}{VBPrefs}{entryDatabaseFolder}}), 0, 1, 1, 1);
    $grid->attach($gui{d}{VBPrefs}{entryDatabaseFolder}, 1, 1, 1, 1);
    $grid->attach($buttonfolder2, 2, 1, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_VRDP Authentication Library:', mnwidget => $gui{d}{VBPrefs}{entryVRDPLib}}), 0, 2, 1, 1);
    $grid->attach($gui{d}{VBPrefs}{entryVRDPLib}, 1, 2, 1, 1);
    $grid->attach($gui{d}{VBPrefs}{buttonVRDPLibReset}, 2, 2, 1, 1);
    $grid->attach($gui{d}{VBPrefs}{checkExclusive}, 1, 3, 3, 1);
    # Signals
    $buttonfolder1->signal_connect('clicked' => \&show_remote_filechooser, {title       => 'Choose Machine Folder',
                                                                            entrywidget => \$gui{d}{VBPrefs}{entryMachineFolder},
                                                                            mode        => 'dir',
                                                                            filter      => ' ^',
                                                                            callback    => \&handle_remote_folder_entry});

    $buttonfolder2->signal_connect('clicked' => \&show_remote_filechooser, {title       => 'Choose Autostart Database Folder',
                                                                            entrywidget => \$gui{d}{VBPrefs}{entryDatabaseFolder},
                                                                            mode        => 'dir',
                                                                            filter      => ' ^',
                                                                            callback    => \&handle_remote_folder_entry});

    $gui{d}{VBPrefs}{buttonMachineReset}->signal_connect('clicked' => \&vbprefs_reset);
    $gui{d}{VBPrefs}{buttonVRDPLibReset}->signal_connect('clicked' => \&vbprefs_reset);
}

# Build the Snapshot Dialog
sub build_dialogSnapshot {
    $gui{d}{Snapshot}{dialog} = gui_new_dialog({title  => 'Snapshot Properties',
                                                 cancel => TRUE,
                                                 ok     => 'Save'});

    $gui{d}{Snapshot}{Name} = gui_new_entry({width  => 50,
                                              maxlen => 255,
                                              tip    => 'The name of the snapshot'});

    $gui{d}{Snapshot}{tbDescription} = Gtk3::TextBuffer->new();

    my $tv1 = gui_new_textview({editable => TRUE,
                                 buffer   => $gui{d}{Snapshot}{tbDescription},
                                 tip      => 'The snapshot description'});

    $gui{d}{Snapshot}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(gui_new_widgetlabel({text => 'Snapshot _Name:', mnwidget => $gui{d}{Snapshot}{Name}}), 0, 0, 1, 1);
    $grid->attach($gui{d}{Snapshot}{Name}, 1, 0, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Description:', mnwidget => $tv1}), 0, 1, 1, 1);
    $grid->attach(my $scrollwin1 = gui_new_scrolledwindow(), 1, 1, 1, 1);
    $scrollwin1->add($tv1);
}

# Build the Create HD Dialog
sub build_dialogCreateHD {
    $gui{d}{CreateHD}{dialog} = gui_new_dialog({title   => 'Create Hard Disk Image',
                                                 cancel  => TRUE,
                                                 ok      => 'Create',
                                                 okimage => gui_new_img_from_file('dialog_create_hd_16px.png')});

    $gui{d}{CreateHD}{entryImage} = gui_new_entry({width => 35, tip => 'The hard disk image filename, without extension'});
    my $buttonfolder = gui_new_imgbutton({image => 'sf_16px.png', tip => 'Choose the destination and file name'});

    $gui{d}{CreateHD}{sbSize} = gui_new_spinbutton({lo        => 4.00,
                                                     hi        => 2097152.00,
                                                     inc       => 1.00,
                                                     decplaces => 2,
                                                     numeric   => FALSE,
                                                     tip       => 'The size of the hard disk'});

    $gui{d}{CreateHD}{cboxFormat} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                       [0, 1],
                                                                                       [['VDI (VirtualBox)',          'vdi'],
                                                                                        ['VMDK (VMWare)',             'vmdk'],
                                                                                        ['VHD (HyperV / Virtual PC)', 'vhd'],
                                                                                        ['HDD (Parallels)',           'parallels'],
                                                                                        ['QED (QEMU Enhanced Disk)',  'qed'],
                                                                                        ['QCOW (QEMU Copy-On-Write)', 'qcow']]),
                                                             active => 0,
                                                             tip    => "Disk image format to use\n* If unsure, select VDI (VirtualBox Format)"});

    $gui{d}{CreateHD}{radioDynamic} = gui_new_radio({text   => 'Dynamically _allocated',
                                                      group  => undef,
                                                      active => TRUE,
                                                      tip    => "The Hard disk image is thin provisioned. The image will increase in size as the guest consumes space but does not require the entire disk to be allocated from the start\n* If unsure, choose dynamically allocated"});

    $gui{d}{CreateHD}{radioFixed} = gui_new_radio({text   => 'F_ixed size',
                                                    group  => $gui{d}{CreateHD}{radioDynamic},
                                                    active => FALSE,
                                                    tip    => "Allocates the entire disk size from the start. The image takes longer to create but can be faster to use than dynamic images\n* Recommended when maximum disk performance is required"});

    $gui{d}{CreateHD}{radioSplit} = gui_new_radio({text   => 'Split into _2GB files',
                                                    group  => $gui{d}{CreateHD}{radioDynamic},
                                                    active => FALSE,
                                                    tip    => "Splits the hard disk image into 2GB chunks.\n* Only recommended if the hard disk image will be stored on a filesystem that doesn't support files larger than 2GB"});

    $gui{d}{CreateHD}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(my $img = gui_new_img_from_file('wizard_new_harddisk.png'), 0, 0, 1, 7);
    $img->set_alignment(0.0, 0.0);
    $grid->attach(gui_new_widgetlabel({text => '_Disk Image:', mnwidget => $gui{d}{CreateHD}{entryImage}}), 1, 0, 1, 1);
    $grid->attach($gui{d}{CreateHD}{entryImage}, 2, 0, 1, 1);
    $grid->attach($buttonfolder, 3, 0, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Size:', mnwidget => $gui{d}{CreateHD}{sbSize}}), 1, 1, 1, 1);
    $grid->attach($gui{d}{CreateHD}{sbSize}, 2, 1, 2, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Format:', mnwidget => $gui{d}{CreateHD}{cboxFormat}}), 1, 2, 1, 1);
    $grid->attach($gui{d}{CreateHD}{cboxFormat}, 2, 2, 2, 1);
    $grid->attach(gui_new_widgetlabel({text => 'Allocation Mode:'}), 1, 3, 1, 3);
    $grid->attach($gui{d}{CreateHD}{radioDynamic}, 2, 3, 2, 1);
    $grid->attach($gui{d}{CreateHD}{radioFixed}, 2, 4, 2, 1);
    $grid->attach($gui{d}{CreateHD}{radioSplit}, 2, 5, 2, 1);
    $grid->attach(gui_new_layout(), 4, 6, 1, 1);
    $gui{d}{CreateHD}{cboxFormat}->signal_connect('changed' => \&storage_sens_create_hd);
    $gui{d}{CreateHD}{sbSize}->signal_connect('input' => \&sb_bytes_in);
    $gui{d}{CreateHD}{sbSize}->signal_connect('output' => \&sb_bytes_out);

    $buttonfolder->signal_connect('clicked' => \&show_remote_filechooser, {title       => 'Destination Hard Disk Image File',
                                                                           entrywidget => \$gui{d}{CreateHD}{entryImage},
                                                                           mode        => 'file',
                                                                           filter      => '.*',
                                                                           callback    => \&handle_remote_file_entry});
}

# Build the Copy HD Dialog
sub build_dialogCopyHD {
    $gui{d}{CopyHD}{dialog} = gui_new_dialog({title   => 'Copy & Convert Hard Disk Image',
                                               cancel  => TRUE,
                                               ok      => 'Copy',
                                               okimage => gui_new_img_from_file('hd_copy_16px.png')});

    $gui{d}{CopyHD}{entrySource} = gui_new_entry({width => 35, tip => 'The source hard disk image'});
    $gui{d}{CopyHD}{entryDest} = gui_new_entry({width => 35, tip => 'The file name of the new hard disk image, without file extension'});
    my $buttonfolder = gui_new_imgbutton({image => 'sf_16px.png', tip => 'Choose the destination and file name of the new hard disk image'});

    $gui{d}{CopyHD}{cboxFormat} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                     [0, 1],
                                                                                     [['VDI (VirtualBox)',          'vdi'],
                                                                                      ['VMDK (VMWare)',             'vmdk'],
                                                                                      ['VHD (HyperV / Virtual PC)', 'vhd'],
                                                                                      ['HDD (Parallels)',           'parallels'],
                                                                                      ['QED (QEMU Enhanced Disk)',  'qed'],
                                                                                      ['QCOW (QEMU Copy-On-Write)', 'qcow']]),
                                                           active => 0,
                                                           tip    => "Disk image format to use\n* If unsure, select VDI (VirtualBox Format)"});

    $gui{d}{CopyHD}{radioDynamic} = gui_new_radio({text   => 'Dynamically _allocated',
                                                    group  => undef,
                                                    active => TRUE,
                                                    tip    => "The Hard disk image is thin provisioned. The image will increase in size as the guest consumes space but does not require the entire disk to be allocated from the start\n* If unsure, choose dynamically allocated"});

    $gui{d}{CopyHD}{radioFixed} = gui_new_radio({text   => 'F_ixed size',
                                                  group  => $gui{d}{CopyHD}{radioDynamic},
                                                  active => FALSE,
                                                  tip    => "Allocates the entire disk size from the start. The image takes longer to create but can be faster to use than dynamic images\n* Recommended when maximum disk performance is required"});

    $gui{d}{CopyHD}{radioSplit} = gui_new_radio({text   => 'Split into _2GB files',
                                                  group  => $gui{d}{CopyHD}{radioDynamic},
                                                  active => FALSE,
                                                  tip    => "Splits the hard disk image into 2GB chunks.\n* Only recommended if the hard disk image will be stored on a filesystem that doesn't support files larger than 2GB"});

    $gui{d}{CopyHD}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(my $img = gui_new_img_from_file('wizard_new_harddisk.png'), 0, 0, 1, 7);
    $img->set_alignment(0.0, 0.0);
    $grid->attach(gui_new_widgetlabel({text => 'Source _Disk:', mnwidget => $gui{d}{CopyHD}{entrySource}}), 1, 0, 1, 1);
    $grid->attach($gui{d}{CopyHD}{entrySource}, 2, 0, 2, 1);
    $grid->attach(gui_new_widgetlabel({text => '_New Disk:', mnwidget => $gui{d}{CopyHD}{entryDest}}), 1, 1, 1, 1);
    $grid->attach($gui{d}{CopyHD}{entryDest}, 2, 1, 1, 1);
    $grid->attach($buttonfolder, 3, 1, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'New _Format:', mnwidget => $gui{d}{CopyHD}{cboxFormat}}), 1, 2, 1, 1);
    $grid->attach($gui{d}{CopyHD}{cboxFormat}, 2, 2, 2, 1);
    $grid->attach(gui_new_widgetlabel({text => 'Allocation Mode:'}), 1, 3, 1, 3);
    $grid->attach($gui{d}{CopyHD}{radioDynamic}, 2, 3, 2, 1);
    $grid->attach($gui{d}{CopyHD}{radioFixed}, 2, 4, 2, 1);
    $grid->attach($gui{d}{CopyHD}{radioSplit}, 2, 5, 2, 1);
    $grid->attach(gui_new_layout(), 4, 6, 1, 1);
    $gui{d}{CopyHD}{cboxFormat}->signal_connect('changed' => \&sens_copyhdformat);
    $buttonfolder->signal_connect('clicked' => \&show_remote_filechooser, {title       => 'New Hard Disk Image',
                                                                           entrywidget => \$gui{d}{CopyHD}{entryDest},
                                                                           mode        => 'file',
                                                                           filter      => '.*',
                                                                           callback    => \&handle_remote_file_entry});
}

# Build the Progress Dialog
sub build_dialogProgress {
    # We can probably optimise this now with the new dialog function
    $gui{d}{Progress}{dialog} = Gtk3::Dialog->new('Please wait...', undef, 'GTK_DIALOG_MODAL'); # Transient is determined automatically
    $gui{d}{Progress}{dialog}->set_type_hint('GDK_WINDOW_TYPE_HINT_DIALOG');
    $gui{d}{Progress}{dialog}->set_skip_taskbar_hint(TRUE);
    $gui{d}{Progress}{buttonCancel} = $gui{d}{Progress}{dialog}->add_button('Cancel', 'cancel');
    $gui{d}{Progress}{dialog}->set_position('GTK_WIN_POS_CENTER_ON_PARENT');
    $gui{d}{Progress}{dialog}->set_deletable(FALSE);
    $gui{d}{Progress}{dialog}->set_default_response('cancel');
    $gui{d}{Progress}{dialog}->set_icon_name("$sharedir/icons/remotebox.png");
    $gui{d}{Progress}{dialog}->signal_connect('hide' => \&transwin_sens_on, $gui{d}{Progress});
    $gui{d}{Progress}{dialog}->signal_connect('show' => \&transwin_sens_off, $gui{d}{Progress});
    $gui{d}{Progress}{dialog}->set_default_size(800,150);
    my $spinner = Gtk3::Spinner->new();
    $spinner->set_hexpand(TRUE);
    $spinner->start();
    $spinner->show();
    $gui{d}{Progress}{bar} = Gtk3::ProgressBar->new();
    $gui{d}{Progress}{bar}->set_hexpand(TRUE);
    $gui{d}{Progress}{bar}->set_pulse_step(0.1);
    $gui{d}{Progress}{bar}->set_show_text(TRUE);
    $gui{d}{Progress}{bar}->show();
    $gui{d}{Progress}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach($gui{d}{Progress}{img} = gui_new_img_from_file('progress_refresh_90px.png'), 0, 0, 1, 4);
    $gui{d}{Progress}{img}->set_alignment(0.0, 0.0);
    $grid->attach($gui{d}{Progress}{label} = gui_new_markuplabel({text => 'Please Wait...'}), 1, 0, 1, 1);
    $grid->attach($spinner, 1, 1, 1, 1);
    $grid->attach($gui{d}{Progress}{bar}, 1, 2, 1, 1);
}

# Build the ServerInfo Dialog
sub build_dialogServerInfo {
    $gui{d}{ServerInfo}{dialog} = gui_new_dialog({title => 'Server Information'});
    $gui{d}{ServerInfo}{dialog}->set_default_size(600,800);
    $gui{d}{ServerInfo}{dialog}->get_content_area()->add(my $scrollwin1 = gui_new_scrolledwindow());
    $gui{d}{ServerInfo}{lstoreInfo} = gui_new_lstore(['Glib::String', 'Glib::String', 'Glib::Uint', 'Glib::Double']);
    my $treeview = gui_new_treeview({model   => $gui{d}{ServerInfo}{lstoreInfo},
                                      headers => FALSE,
                                      tip     => 'Information about the VirtualBox server'});

    $treeview->get_selection->set_mode('GTK_SELECTION_NONE');
    $treeview->append_column(gui_new_treeviewcolumn({title   => 'Field',
                                                      type    => 'text',
                                                      typecol => 0}));

    $treeview->append_column(gui_new_treeviewcolumn({title   => 'Value',
                                                      type    => 'text',
                                                      typecol => 1}));

    $scrollwin1->set_propagate_natural_height(TRUE);
    $scrollwin1->set_propagate_natural_width(TRUE);
    $scrollwin1->add($treeview);
}

# Build the Host Network Manager dialog
sub build_dialogHostNetMan {
    $gui{d}{HostNetMan}{dialog} = gui_new_dialog({title => 'Network Manager'});
    $gui{d}{HostNetMan}{dialog}->set_default_size(400,400);
    my $notebook = Gtk3::Notebook->new();
    $notebook->append_page(my $grid1 = gui_new_grid(), gui_new_widgetlabel({text => '_Host-Only Networks'}));
    $notebook->append_page(my $grid2 = gui_new_grid(), gui_new_widgetlabel({text => '_NAT Networks_'}));
    $notebook->show_all();
    my $bb1 = gui_new_buttonbox({orientation => 'vertical'});
    $bb1->add(my $buttonAddHON = gui_new_imgbutton({image => 'add_host_iface_16px.png', tip => 'Add a Host-Only network'}));
    $bb1->add($gui{d}{HostNetMan}{buttonDelHON} = gui_new_imgbutton({image => 'remove_host_iface_16px.png', tip => 'Delete Host-Only network'}));
    $bb1->add($gui{d}{HostNetMan}{buttonEditHON}= gui_new_imgbutton({image => 'host_iface_edit_16px.png', tip => 'Edit Host-Only network'}));
    my $bb2 = gui_new_buttonbox({orientation => 'vertical'});
    $bb2->add(my $buttonAddNAT = gui_new_imgbutton({image => 'add_host_iface_16px.png', tip => 'Add a NAT network'}));
    $bb2->add($gui{d}{HostNetMan}{buttonDelNAT} = gui_new_imgbutton({image => 'remove_host_iface_16px.png', tip => 'Delete NAT network'}));
    $bb2->add($gui{d}{HostNetMan}{buttonEditNAT} = gui_new_imgbutton({image => 'host_iface_edit_16px.png', tip => 'Edit NAT network'}));

    $gui{d}{HostNetMan}{lstoreHON} = gui_new_lstore(['Glib::String', 'Glib::String', 'Glib::String']);
    $gui{d}{HostNetMan}{treeviewHON} = gui_new_treeview({model   => $gui{d}{HostNetMan}{lstoreHON},
                                                          headers => TRUE,
                                                          tip     => 'The list of available Host-Only networks'});

    $gui{d}{HostNetMan}{treeviewHON}->append_column(gui_new_treeviewcolumn({title   => 'Host-Only Networks',
                                                                             type    => 'text',
                                                                             typecol => 0}));

    $gui{d}{HostNetMan}{treeviewNAT} = gui_new_treeview({model => $gui{d}{HostNetMan}{lstoreNAT} = gui_new_lstore(['Glib::Boolean', 'Glib::String', 'Glib::String']),
                                                          tip   => 'The list of available NAT networks'});

    my ($col, $celltoggle) = gui_new_treeviewcolumntoggle({title   => 'Enabled',
                                                            type    => 'active',
                                                            typecol => 0});
    $gui{d}{HostNetMan}{treeviewNAT}->append_column($col);
    $gui{d}{HostNetMan}{treeviewNAT}->append_column(gui_new_treeviewcolumn({title  => '',
                                                                             type    => 'text',
                                                                             typecol => 1}));

    $gui{d}{HostNetMan}{dialog}->get_content_area()->add($notebook);
    $grid1->attach(my $scrollwin1 = gui_new_scrolledwindow(), 0, 0, 1, 1);
    $scrollwin1->add($gui{d}{HostNetMan}{treeviewHON});
    $grid1->attach($bb1, 1, 0, 1, 1);
    $grid2->attach(my $scrollwin2 = gui_new_scrolledwindow(), 0, 0, 1, 1);
    $scrollwin2->add($gui{d}{HostNetMan}{treeviewNAT});
    $grid2->attach($bb2, 1, 0, 1, 1);
    $buttonAddHON->signal_connect('clicked' => \&vbprefs_createhon);
    $gui{d}{HostNetMan}{buttonDelHON}->signal_connect('clicked' => \&vbprefs_removehon);
    $gui{d}{HostNetMan}{buttonEditHON}->signal_connect('clicked' => \&show_dialog_edithon);
    $buttonAddNAT->signal_connect('clicked' => \&vbprefs_createnat);
    $gui{d}{HostNetMan}{buttonDelNAT}->signal_connect('clicked' => \&vbprefs_removenat);
    $gui{d}{HostNetMan}{buttonEditNAT}->signal_connect('clicked' => \&show_dialog_editnat);
    $signal{HostNetMan_treeviewHON_cursorChanged} = $gui{d}{HostNetMan}{treeviewHON}->signal_connect('cursor-changed' => \&onsel_list_vbprefshon);
    $signal{HostNetMan_treeviewNAT_cursorChanged} = $gui{d}{HostNetMan}{treeviewNAT}->signal_connect('cursor-changed' => \&onsel_list_vbprefsnat),
    $gui{d}{HostNetMan}{treeviewHON}->signal_connect('row-activated' => \&show_dialog_edithon);
    $gui{d}{HostNetMan}{treeviewNAT}->signal_connect('row-activated' => \&show_dialog_editnat);
    $celltoggle->signal_connect('toggled' => \&vbprefs_togglenat);
}

# Build the guest log diaglog
sub build_dialogGuestLog {
    $gui{d}{GuestLog}{dialog} = gui_new_dialog({title => 'Guest Log Viewer'});
    $gui{d}{GuestLog}{dialog}->set_default_size(600,600);
    my $toolbar = gui_new_toolbar();
    $toolbar->insert(my $toolbutton1 = gui_new_toolbutton({image => 'log_viewer_save_32px.png',
                                                            label => '_Save',
                                                            tip   => 'Save the log to a text file'}), 0);

    $toolbar->insert(my $toolbutton2 = gui_new_toolbutton({image => 'log_viewer_refresh_32px.png',
                                                            label => '_Refresh',
                                                            tip  => 'Refresh the guest logs'}), 1);

    $gui{d}{GuestLog}{lstoreLog0} = gui_new_lstore(['Glib::String', 'Glib::String', 'Glib::Uint']); #Log, Category, Value Weight
    $gui{d}{GuestLog}{lstoreLog1} = gui_new_lstore(['Glib::String', 'Glib::String', 'Glib::Uint']); #Log, Category, Value Weight
    $gui{d}{GuestLog}{lstoreLog2} = gui_new_lstore(['Glib::String', 'Glib::String', 'Glib::Uint']); #Log, Category, Value Weight
    $gui{d}{GuestLog}{lstoreLog3} = gui_new_lstore(['Glib::String', 'Glib::String', 'Glib::Uint']); #Log, Category, Value Weight

    my $treeview1 = gui_new_treeview({model   => $gui{d}{GuestLog}{lstoreLog0},
                                       headers => FALSE,
                                       tip     => 'VirtualBox Guest Log 0'});

    $treeview1->get_selection->set_mode('GTK_SELECTION_NONE');
    $treeview1->append_column(gui_new_treeviewcolumn({title   => 'Category',
                                                       type    => 'text',
                                                       typecol => 1}));

    $treeview1->append_column(gui_new_treeviewcolumn({title   => 'Value',
                                                       type    => 'text',
                                                       typecol => 0}));

    my $treeview2 = gui_new_treeview({model   => $gui{d}{GuestLog}{lstoreLog1},
                                       headers => FALSE,
                                       tip     => 'VirtualBox Guest Log 1'});

    $treeview2->get_selection->set_mode('GTK_SELECTION_NONE');
    $treeview2->append_column(gui_new_treeviewcolumn({title   => 'Category',
                                                       type    => 'text',
                                                       typecol => 1}));

    $treeview2->append_column(gui_new_treeviewcolumn({title   => 'Value',
                                                       type    => 'text',
                                                       typecol => 0}));

    my $treeview3 = gui_new_treeview({model   => $gui{d}{GuestLog}{lstoreLog2},
                                       headers => FALSE,
                                       tip     => 'VirtualBox Guest Log 2'});

    $treeview3->get_selection->set_mode('GTK_SELECTION_NONE');
    $treeview3->append_column(gui_new_treeviewcolumn({title   => 'Category',
                                                       type    => 'text',
                                                       typecol => 1}));

    $treeview3->append_column(gui_new_treeviewcolumn({title   => 'Value',
                                                       type    => 'text',
                                                       typecol => 0}));

    my $treeview4 = gui_new_treeview({model   => $gui{d}{GuestLog}{lstoreLog3},
                                       headers => FALSE,
                                       tip     => 'VirtualBox Guest Log 3'});

    $treeview4->get_selection->set_mode('GTK_SELECTION_NONE');
    $treeview4->append_column(gui_new_treeviewcolumn({title   => 'Category',
                                                       type    => 'text',
                                                       typecol => 1}));

    $treeview4->append_column(gui_new_treeviewcolumn({title   => 'Value',
                                                       type    => 'text',
                                                       typecol => 0}));

    $gui{d}{GuestLog}{notebookLog} = Gtk3::Notebook->new();
    $gui{d}{GuestLog}{notebookLog}->append_page(my $scrollwin1 = gui_new_scrolledwindow(), gui_new_widgetlabel({text => 'Log _0'}));
    $scrollwin1->set_propagate_natural_height(TRUE);
    $scrollwin1->set_propagate_natural_width(TRUE);
    $scrollwin1->add($treeview1);
    $gui{d}{GuestLog}{notebookLog}->append_page(my $scrollwin2 = gui_new_scrolledwindow(), gui_new_widgetlabel({text => 'Log _1'}));
    $scrollwin2->set_propagate_natural_height(TRUE);
    $scrollwin2->set_propagate_natural_width(TRUE);
    $scrollwin2->add($treeview2);
    $gui{d}{GuestLog}{notebookLog}->append_page(my $scrollwin3 = gui_new_scrolledwindow(), gui_new_widgetlabel({text => 'Log _2'}));
    $scrollwin3->set_propagate_natural_height(TRUE);
    $scrollwin3->set_propagate_natural_width(TRUE);
    $scrollwin3->add($treeview3);
    $gui{d}{GuestLog}{notebookLog}->append_page(my $scrollwin4 = gui_new_scrolledwindow(), gui_new_widgetlabel({text => 'Log _3'}));
    $scrollwin4->set_propagate_natural_height(TRUE);
    $scrollwin4->set_propagate_natural_width(TRUE);
    $scrollwin4->add($treeview4);
    $gui{d}{GuestLog}{notebookLog}->show_all();
    $gui{d}{GuestLog}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach($toolbar, 0, 0, 1, 1);
    $grid->attach($gui{d}{GuestLog}{notebookLog}, 0, 1, 1, 1);
    # Signals
    $toolbutton1->signal_connect('clicked' => \&guest_log_save);
    $toolbutton2->signal_connect('clicked' => \&refresh_guest_logs);
}

# Build the Profiles dialog
sub build_dialogProfile {
    $gui{d}{Profile}{dialog} = gui_new_dialog({title => 'Connection Profile Manager'});
    $gui{d}{Profile}{treeviewProfile} = gui_new_treeview({model   => $gui{d}{Connect}{lstoreProfile}, # Note, is correct as it's shared with the connection dialog
                                                           headers => FALSE,
                                                           tip     => 'List of connection profiles'});

    $gui{d}{Profile}{treeviewProfile}->append_column(gui_new_treeviewcolumn({title   => 'Name',
                                                                              type    => 'text',
                                                                              typecol => 0}));

    $gui{d}{Profile}{entryName} = gui_new_entry({width  => 60,
                                                  maxlen => 255,
                                                  tip    => 'The name to assign the connection profile'});

    $gui{d}{Profile}{entryURL} = gui_new_entry({width => 60, tip => 'The URL of the VirtualBox server. For example http://myserver:18083'});
    $gui{d}{Profile}{entryUser} = gui_new_entry({width => 60, tip => 'The user to connect as. Leave blank if authentication is disabled on the server'});

    $gui{d}{Profile}{entryPass} = gui_new_entry({width => 60,
                                                  tip   => 'The user password. Leave blank if authentication is disabled on the server',
                                                  pass  => TRUE});

    $gui{d}{Profile}{checkAutoConnect} = gui_new_check({text   => 'Auto-_Connect on Start',
                                                         active => FALSE,
                                                         tip    => 'Automatically connect with this profile when RemoteBox starts'});

    $gui{d}{Profile}{dialog}->get_content_area()->add(my $box = gui_new_box('horizontal'));
    $box->pack_start(my $grid = gui_new_grid(), TRUE, TRUE, 2);
    $box->pack_start($gui{d}{Profile}{gridProfile} = gui_new_grid(), TRUE, TRUE, 2);
    $grid->attach(my $scrollwin1 = gui_new_scrolledwindow(), 0, 0, 2, 5);
    $scrollwin1->set_propagate_natural_height(TRUE);
    $scrollwin1->set_propagate_natural_width(TRUE);
    $scrollwin1->add($gui{d}{Profile}{treeviewProfile});
    $grid->attach(my $button = gui_new_button({label => '_Add Profile', tip => 'Add a new connection profile'}), 0, 6, 1, 1);
    $grid->attach($gui{d}{Profile}{buttonDelete} = gui_new_button({label => '_Delete Profile', tip => 'Delete selected connection profile'}), 1, 6, 1, 1);
    $gui{d}{Profile}{gridProfile}->attach(gui_new_widgetlabel({text => 'P_rofile Name:', mnwidget => $gui{d}{Profile}{entryName}}), 0, 0, 1, 1);
    $gui{d}{Profile}{gridProfile}->attach($gui{d}{Profile}{entryName}, 1, 0, 1, 1);
    $gui{d}{Profile}{gridProfile}->attach(gui_new_widgetlabel({text => '_URL:', mnwidget => $gui{d}{Profile}{entryURL}}), 0, 1, 1, 1);
    $gui{d}{Profile}{gridProfile}->attach($gui{d}{Profile}{entryURL}, 1, 1, 1, 1);
    $gui{d}{Profile}{gridProfile}->attach(gui_new_widgetlabel({text => 'User_name:', mnwidget => $gui{d}{Profile}{entryUser}}), 0, 2, 1, 1);
    $gui{d}{Profile}{gridProfile}->attach($gui{d}{Profile}{entryUser}, 1, 2, 1, 1);
    $gui{d}{Profile}{gridProfile}->attach(gui_new_widgetlabel({text => '_Password:', mnwidget => $gui{d}{Profile}{entryPass}}), 0, 3, 1, 1);
    $gui{d}{Profile}{gridProfile}->attach($gui{d}{Profile}{entryPass}, 1, 3, 1, 1);
    $gui{d}{Profile}{gridProfile}->attach($gui{d}{Profile}{checkAutoConnect}, 1, 4, 1, 1);
    $gui{d}{Profile}{treeviewProfile}->signal_connect('cursor-changed' => \&onsel_list_profile);
    $button->signal_connect('clicked' => \&addrow_profile);
    $gui{d}{Profile}{buttonDelete}->signal_connect('clicked' => \&remove_profile);
    $gui{d}{Profile}{checkAutoConnect}->signal_connect('toggled' => \&profile_autoconn_change);
    $gui{d}{Profile}{entryName}->signal_connect('changed' => \& profile_name_change);
    $gui{d}{Profile}{entryURL}->signal_connect('changed' => \& profile_url_change);
    $gui{d}{Profile}{entryUser}->signal_connect('changed' => \& profile_username_change);
    $gui{d}{Profile}{entryPass}->signal_connect('changed' => \& profile_password_change);

}

# Build the new guest dialog
sub build_dialogNew {
    $gui{d}{New}{dialog} = gui_new_dialog({title   => 'Create New Guest',
                                    cancel  => TRUE,
                                    ok      => 'Create',
                                    okimage => gui_new_img_from_file('dialog_create_new_guest_16px.png')});

    $gui{d}{New}{entryName} = gui_new_entry({width  => 50,
                                              maxlen => 255,
                                              tip    => 'The unique name of the guest'});

    $gui{d}{New}{cboxISO} = gui_new_simplecombobox({model  => $gui{d}{New}{lstoreISO} = gui_new_lstore(['Glib::String', 'Glib::String']), # New Guest ISO 'ISO Name', 'IMedium'
                                                     active => 0,
                                                     tip    => 'Attach an ISO image to use with installation'});

    $gui{d}{New}{cboxFamily} = gui_new_imgcombobox({model  => $gui{d}{New}{lstoreFamily} = gui_new_lstore(['Glib::String', 'Glib::String', 'Gtk3::Gdk::Pixbuf']),
                                                     imgcol => 2,
                                                     active => 0,
                                                     tip    => 'The operating system family the guest will run'});

    $gui{d}{New}{cboxVersion} = gui_new_imgcombobox({model => $gui{d}{New}{lstoreVersion} = gui_new_lstore(['Glib::String', 'Glib::String', 'Glib::String', 'Gtk3::Gdk::Pixbuf']),
                                                     imgcol => 3,
                                                     active => 0,
                                                     tip    => 'The version of the operating system the guest will run'});

    $gui{d}{New}{sbMemory} = gui_new_spinbutton({lo        => 4.00,
                                                  hi        => 2097152.00,
                                                  inc       => 1.00,
                                                  decplaces => 2,
                                                  numeric   => FALSE,
                                                  tip       => 'The amount of memory to assign the guest'});

    $gui{d}{New}{scaleMemory} = gui_new_scale({adj => $gui{d}{New}{sbMemory}->get_adjustment(), tip => 'The amount of memory to assign the guest'});
    $gui{d}{New}{checkStartupDisk} = gui_new_check({text   => 'Start-up _Disk',
                                                     active => TRUE,
                                                     tip    => 'Provide the guest with a start-up hard disk'});

    $gui{d}{New}{radioNewDisk} = gui_new_radio({text => '_Create a new hard disk',
                                                 group  => undef,
                                                 active => TRUE,
                                                 tip    => 'Create a new hard disk image'});

    $gui{d}{New}{radioExistingDisk} = gui_new_radio({text => '_Use an existing hard disk',
                                                 group  => $gui{d}{New}{radioNewDisk},
                                                 active => FALSE,
                                                 tip    => 'Use an existing hard disk image'});

    $gui{d}{New}{sbSize} = gui_new_spinbutton({lo        => 4.00,
                                                hi        => 2097152.00,
                                                inc       => 1.00,
                                                decplaces => 2,
                                                numeric   => FALSE,
                                                tip       => 'The size of the hard disk'});

    $gui{d}{New}{cboxFormat} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                  [0, 1],
                                                                                  [['VDI (VirtualBox)',          'vdi'],
                                                                                   ['VMDK (VMWare)',             'vmdk'],
                                                                                   ['VHD (HyperV / Virtual PC)', 'vhd'],
                                                                                   ['HDD (Parallels)',           'parallels'],
                                                                                   ['QED (QEMU Enhanced Disk)',  'qed'],
                                                                                   ['QCOW (QEMU Copy-On-Write)', 'qcow']]),
                                                        active => 0,
                                                        tip    => "Disk image format to use\n* If unsure, select VDI (VirtualBox Format)"});

    $gui{d}{New}{radioDynamic} = gui_new_radio({text   => 'Dynamically _allocated',
                                                 group  => undef,
                                                 active => TRUE,
                                                 tip    => "The Hard disk image is thin provisioned. The image will increase in size as the guest consumes space but does not require the entire disk to be allocated from the start\n* If unsure, choose dynamically allocated"});

    $gui{d}{New}{radioFixed} = gui_new_radio({text   => 'F_ixed size',
                                               group  => $gui{d}{New}{radioDynamic},
                                               active => FALSE,
                                               tip    => "Allocates the entire disk size from the start. The image takes longer to create but can be faster to use than dynamic images\n* Recommended when maximum disk performance is required"});

    $gui{d}{New}{radioSplit} = gui_new_radio({text   => 'Split into _2GB files',
                                               group  => $gui{d}{New}{radioDynamic},
                                               active => FALSE,
                                               tip    => "Splits the hard disk image into 2GB chunks.\n* Only recommended if the hard disk image will be stored on a filesystem that doesn't support files larger than 2GB"});

    $gui{d}{New}{cboxExistingDisk} = gui_new_simplecombobox({model  => $gui{d}{New}{lstoreExistingDisk} = gui_new_lstore(['Glib::String', 'Glib::String']),
                                                              active => -1,
                                                              tip    => 'The hard disk image to attach to the guest'});

    $gui{d}{New}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(my $img = gui_new_img_from_file('wizard_new_welcome.png'), 0, 0, 1, 11);
    $img->set_alignment(0.0, 0.0);
    $grid->attach(gui_new_widgetlabel({text => '_Name:', mnwidget => $gui{d}{New}{entryName}}), 1, 0, 1, 1);
    $grid->attach($gui{d}{New}{entryName}, 2, 0, 2, 1);
    $grid->attach(gui_new_widgetlabel({text => '_ISO Image:', mnwidget => $gui{d}{New}{cboxISO}}), 1, 1, 1, 1);
    $grid->attach($gui{d}{New}{cboxISO}, 2, 1, 2, 1);
    $grid->attach(gui_new_widgetlabel({text => '_OS Family:', mnwidget => $gui{d}{New}{cboxFamily}}), 1, 2, 1, 1);
    $grid->attach($gui{d}{New}{cboxFamily}, 2, 2, 2, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Version:', mnwidget => $gui{d}{New}{cboxVersion}}), 1, 3, 1, 1);
    $grid->attach($gui{d}{New}{cboxVersion}, 2, 3, 2, 1);
    $grid->attach(gui_new_widgetlabel({text => '_Memory:', mnwidget => $gui{d}{New}{sbMemory}}), 1, 4, 1, 1);
    $grid->attach($gui{d}{New}{scaleMemory}, 2, 4, 1, 1);
    $grid->attach($gui{d}{New}{sbMemory}, 3, 4, 1, 1);
    $grid->attach(gui_new_separator(), 1, 5, 3, 1);
    $grid->attach($gui{d}{New}{checkStartupDisk}, 1, 6, 3, 1);
    $grid->attach($gui{d}{New}{radioNewDisk}, 1, 7, 3, 1);
    $grid->attach($gui{d}{New}{HD} = gui_new_grid(), 1, 8, 3, 1);
    $gui{d}{New}{HD}->attach(gui_new_widgetlabel({text => '_Size:', mnwidget => $gui{d}{New}{sbSize}}), 0, 0, 1, 1);
    $gui{d}{New}{HD}->attach($gui{d}{New}{sbSize}, 1, 0, 1, 1);
    $gui{d}{New}{HD}->attach(gui_new_widgetlabel({text => '_Image Format:', mnwidget => $gui{d}{New}{cboxFormat}}), 0, 1, 1, 1);
    $gui{d}{New}{HD}->attach($gui{d}{New}{cboxFormat}, 1, 1, 1, 1);
    $gui{d}{New}{HD}->attach(gui_new_widgetlabel({text => 'Allocation Mode:'}), 0, 4, 1, 1);
    $gui{d}{New}{HD}->attach($gui{d}{New}{radioDynamic}, 1, 3, 1, 1);
    $gui{d}{New}{HD}->attach($gui{d}{New}{radioFixed}, 1, 4, 1, 1);
    $gui{d}{New}{HD}->attach($gui{d}{New}{radioSplit}, 1, 5, 1, 1);
    $grid->attach($gui{d}{New}{radioExistingDisk}, 1, 9, 3, 1);
    $grid->attach($gui{d}{New}{cboxExistingDisk}, 1, 10, 3, 1);
    # Signals
    $gui{d}{New}{sbMemory}->signal_connect('input' => \&sb_bytes_in);
    $gui{d}{New}{sbMemory}->signal_connect('output' => \&sb_bytes_out);
    $gui{d}{New}{sbSize}->signal_connect('input' => \&sb_bytes_in);
    $gui{d}{New}{sbSize}->signal_connect('output' => \&sb_bytes_out);
    $gui{d}{New}{checkStartupDisk}->signal_connect('toggled' => \&toggle_newstartupdisk);
    $gui{d}{New}{radioNewDisk}->signal_connect('toggled' => \&newstor_new_exist);
    $gui{d}{New}{cboxFormat}->signal_connect('changed' => \&sens_hdformatchanged);
    $signal{New_cboxFamily_changed} = $gui{d}{New}{cboxFamily}->signal_connect('changed' => \&newgen_osfam, $gui{d}{New}{cboxVersion});
    $signal{New_cboxVersion_changed} = $gui{d}{New}{cboxVersion}->signal_connect('changed' => \&newgen_osver, $gui{d}{New}{cboxFamily});
    $gui{d}{New}{entryName}->signal_connect('changed' => \&valid_guestname_char);
}

# Build the Modify HD Dialog
sub build_dialogModifyHD {
    $gui{d}{ModifyHD}{dialog} = gui_new_dialog({title   => 'Modify & Resize Hard Disk',
                                         cancel  => TRUE,
                                         ok      => 'Apply'});

    $gui{d}{ModifyHD}{entryHD} = gui_new_entry({width  => 35, tip => 'The hard disk image to modify'});
    $gui{d}{ModifyHD}{cboxType} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                     [0, 1],
                                                                                     [['Normal', 'Normal'],
                                                                                      ['Immutable', 'Immutable'],
                                                                                      ['Writethrough', 'Writethrough'],
                                                                                      ['Shareable', 'Shareable'],
                                                                                      ['MultiAttach', 'MultiAttach']]),
                                                           active => -1,
                                                           tip    => "Modify the medium type:\n* Normal - Standard format for hard disks\n* Immutable - Changes to disk are discarded on guest start\n* Writethrough - Directly attached, snapshots are not taken\n* Shareable - Enables concurrent use (eg clustered disks)\n* Multi-Attach - Like Immutable but guests maintain their changesDisk image format to use\n* If unsure, select VDI (VirtualBox Format)"});

    $gui{d}{ModifyHD}{checkResize} = gui_new_check({text   => '_Resize Hard Disk Image',
                                                     active => TRUE,
                                                     tip    => "Increase the virtual hard disk size\n* Shrinking the hard disk size is not supported\n* You may still need to increase the file system in the guest"});

    $gui{d}{ModifyHD}{sbSize} = gui_new_spinbutton({lo        => 4.00,
                                                     hi        => 2097152.00,
                                                     inc       => 1.00,
                                                     decplaces => 2,
                                                     numeric   => FALSE,
                                                     tip       => 'The new size of the hard disk'});

    $gui{d}{ModifyHD}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(my $img = gui_new_img_from_file('wizard_new_harddisk.png'), 0, 0, 1, 5);
    $img->set_alignment(0.0, 0.0);
    $grid->attach(gui_new_widgetlabel({text => '_Disk Image:', mnwidget => $gui{d}{ModifyHD}{entryHD}}), 1, 0, 1, 1);
    $grid->attach($gui{d}{ModifyHD}{entryHD}, 2, 0, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => 'Image _Type:', mnwidget => $gui{d}{ModifyHD}{cboxType}}), 1, 1, 1, 1);
    $grid->attach($gui{d}{ModifyHD}{cboxType}, 2, 1, 1, 1);
    $grid->attach($gui{d}{ModifyHD}{checkResize}, 2, 2, 1, 1);
    $grid->attach(gui_new_widgetlabel({text => '_New Disk Size:', mnwidget => $gui{d}{ModifyHD}{sbSize}}), 1, 3, 1, 1);
    $grid->attach($gui{d}{ModifyHD}{sbSize}, 2, 3, 1, 1);
    $grid->attach(gui_new_layout(), 2, 4, 1, 1);
    $gui{d}{ModifyHD}{checkResize}->signal_connect('toggled' => \&vmm_modify_sens_resize);
    $gui{d}{ModifyHD}{sbSize}->signal_connect('input' => \&sb_bytes_in),
    $gui{d}{ModifyHD}{sbSize}->signal_connect('output' => \&sb_bytes_out),
}

# Build the VNC / RDP Info Dialog
sub build_dialogRDPVNCInfo {
    $gui{d}{RDPVNCInfo}{dialog} = gui_new_dialog({title => 'Detected Display Clients'});
    $gui{d}{RDPVNCInfo}{dialog}->set_default_size(500,500);
    $gui{d}{RDPVNCInfo}{dialog}->get_content_area()->add(my $scrollwin1 = gui_new_scrolledwindow());
    $gui{d}{RDPVNCInfo}{lstoreInfo} = gui_new_lstore(['Glib::String', 'Glib::String', 'Glib::String']);
    my $treeview = gui_new_treeview({model   => $gui{d}{RDPVNCInfo}{lstoreInfo},
                                      headers => TRUE,
                                      tip     => 'List of detected RDP or VNC clients'});

    $treeview->get_selection->set_mode('GTK_SELECTION_NONE');
    $treeview->append_column(gui_new_treeviewcolumn({title   => 'Client',
                                                      type    => 'text',
                                                      typecol => 0}));

    $treeview->append_column(gui_new_treeviewcolumn({title   => 'Type',
                                                      type    => 'text',
                                                      typecol => 1}));

    $treeview->append_column(gui_new_treeviewcolumn({title   => 'Location',
                                                      type    => 'text',
                                                      typecol => 2}));

    $scrollwin1->set_propagate_natural_height(TRUE);
    $scrollwin1->set_propagate_natural_width(TRUE);
    $scrollwin1->add($treeview);
}

# Build the RemoteBox Preferences Dialog
sub build_dialogPrefs {
    $gui{d}{Prefs}{dialog} = gui_new_dialog({title  => 'RemoteBox Preferences',
                                              ok     => 'Save',
                                              cancel => TRUE});

    $gui{d}{Prefs}{cboxStop} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                  [0, 1],
                                                                                  [['Instant Power Off', 'INSTANT'],
                                                                                   ['ACPI Shutdown', 'ACPI'],
                                                                                   ['Save Guest State', 'STATE']]),
                                                        active => 0,
                                                        tip    => 'Default action to take when the guest stop button is pressed'});

    $gui{d}{Prefs}{checkAdditions} = gui_new_check({text   => '_Add the guest additions ISO to the Virtual Media Manager on connection',
                                                     active => TRUE,
                                                     tip    => 'Automatically add the guest additions ISO to the Virtual Media Manager when connecting to a server'});

    $gui{d}{Prefs}{checkSortGuest} = gui_new_check({text   => '_Sort guest list alphabetically',
                                                     active => TRUE,
                                                     tip    => 'Sort the guest list alphabetically or use natural order'});

    $gui{d}{Prefs}{checkNoExtPackWarn} = gui_new_check({text   => '_Do not show the VirtualBox Extension Pack missing dialog',
                                                         active => FALSE,
                                                         tip    => 'Surpresses the warning dialog stating that the VirtualBox Extension Pack is missing.'});

    $gui{d}{Prefs}{checkNoVersionWarn} = gui_new_check({text   => 'Do _not show the Unsupported VirtualBox version dialog',
                                                         active => FALSE,
                                                         tip    => 'Surpresses the warning dialog stating that the VirtualBox version is unsupported'});

    $gui{d}{Prefs}{entryRDP} = gui_new_entry({width => 100, tip => "The command to call when making RDP connections to guests.\n* Choose a preset or customise your own command\n* Consult the documentation for details of % variable substitutions"});
    $gui{d}{Prefs}{buttonRDPPresets} = gui_new_imgbutton({image => 'rdp_preset_16px.png', tip => 'Select an RDP client preset or customise your own command'});
    $gui{d}{Prefs}{buttonRDPInfo} = gui_new_imgbutton({image => 'session_info_16px.png', tip => 'Show detected display clients'});
    $gui{d}{Prefs}{entryVNC} = gui_new_entry({width  => 100, tip => "The command to call when making VNC connections to guests.\n* Choose a preset or customise your own command\n* Consult the documentation for details of % variable substitutions"});
    $gui{d}{Prefs}{buttonVNCPresets} = gui_new_imgbutton({image => 'rdp_preset_16px.png', tip => 'Select a VNC client preset or customise your own command'});
    $gui{d}{Prefs}{buttonVNCInfo} = gui_new_imgbutton({image => 'session_info_16px.png', tip => 'Show detected display clients'});
    $gui{d}{Prefs}{checkOpenDisplay} = gui_new_check({text   => "_Open the guest's display at power on",
                                                       active => TRUE,
                                                       tip    => 'When a guest is started, automatically open its display'});

    $gui{d}{Prefs}{checkAutoHint} = gui_new_check({text   => '_Auto-Hint resolution',
                                                    active => FALSE,
                                                    tip    => 'Sends a resolution hint to the guest in order to set the screen resolution to the desired size. In general this method is unreliable and the best place to set the screen resolution is by using %X and %Y substitutions with the RDP client'});

    $gui{d}{Prefs}{sbWidth} = gui_new_spinbutton({lo        => 320,
                                                   hi        => 10000.00,
                                                   inc       => 1,
                                                   decplaces => 0,
                                                   numeric   => TRUE,
                                                   tip       => 'Desired display width. This value is used for auto-hints and with the %X substitution'});

    $gui{d}{Prefs}{sbHeight} = gui_new_spinbutton({lo        => 240,
                                                    hi        => 10000,
                                                    inc       => 1,
                                                    decplaces => 0,
                                                    numeric   => TRUE,
                                                    tip       => 'Desired display height. This value is used for auto-hints and with the %Y substitution'});

    $gui{d}{Prefs}{cboxDepth} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                   [0, 1],
                                                                                   [['8bit  - 256 colours', 8],
                                                                                    ['16bit - 65k colours', 16],
                                                                                    ['32bit - 16m colours', 32]]),
                                                         active => 2,
                                                         tip    => 'Desired display depth. A higher depth provides more colours but may be slower and use more bandwidth. This value is used for auto-hints and with the %D substitution'});
    $gui{menu}{RDPPreset} = gui_new_menu(); # Popup Menu
    $gui{menu}{VNCPreset} = gui_new_menu(); # Popup Menu

    foreach my $preset (@{get_rdp_preset_tbl()}) {
        $gui{'miRDPPreset' . $$preset{num}} = gui_new_menu_item($$preset{desc}, 'vrdp_16px.png', $gui{menu}{RDPPreset});
        $gui{'miRDPPreset' . $$preset{num}}->signal_connect('activate' => \&set_rdppreset, $$preset{command});
    }

    foreach my $preset (@{get_vnc_preset_tbl()}) {
        $gui{'miVNCPreset' . $$preset{num}} = gui_new_menu_item($$preset{desc}, 'vrdp_16px.png', $gui{menu}{VNCPreset});
        $gui{'miVNCPreset' . $$preset{num}}->signal_connect('activate' => \&set_vncpreset, $$preset{command});
    }

    my $notebook = Gtk3::Notebook->new();
    $notebook->append_page(my $grid1 = gui_new_grid(), gui_new_imglabel({text => '_General', img => 'machine_16px.png'}));
    $notebook->append_page(my $grid2 = gui_new_grid(), gui_new_imglabel({text => 'Guest _Display', img => 'vrdp_16px.png'}));
    $notebook->show_all();
    $gui{d}{Prefs}{dialog}->get_content_area()->add($notebook);
    $grid1->attach(gui_new_widgetlabel({text => 'Default Stop _Action:', mnwidget => $gui{d}{Prefs}{cboxStop}}), 0, 0, 1, 1);
    $grid1->attach($gui{d}{Prefs}{cboxStop}, 1, 0, 1, 1);
    $grid1->attach($gui{d}{Prefs}{checkAdditions}, 1, 1, 1, 1);
    $grid1->attach($gui{d}{Prefs}{checkSortGuest}, 1, 2, 1, 1);
    $grid1->attach($gui{d}{Prefs}{checkNoExtPackWarn}, 1, 3, 1, 1);
    $grid1->attach($gui{d}{Prefs}{checkNoVersionWarn}, 1, 4, 1, 1);
    $grid2->attach(gui_new_markuplabel({text => "<small><b>Server hostname</b> %h, <b>Guest name</b> %n, <b>Guest OS</b> %o, <b>RDP / VNC Port</b> %p,\n<b>Password</b> %P, <b>Username</b> %U, <b>Auto-Hint Resolution (X, Y, Depth)</b> %X, %Y, %D</small>"}), 1, 0, 4, 1);
    $grid2->attach(gui_new_widgetlabel({text => '_RDP Client:', mnwidget => $gui{d}{Prefs}{entryRDP}}), 0, 1, 1, 1);
    $grid2->attach($gui{d}{Prefs}{entryRDP}, 1, 1, 3, 1);
    $grid2->attach($gui{d}{Prefs}{buttonRDPPresets}, 4, 1, 1, 1);
    $grid2->attach($gui{d}{Prefs}{buttonRDPInfo}, 5, 1, 1, 1);
    $grid2->attach(gui_new_widgetlabel({text => '_VNC Client:', mnwidget => $gui{d}{Prefs}{entryVNC}}), 0, 2, 1, 1);
    $grid2->attach($gui{d}{Prefs}{entryVNC}, 1, 2, 3, 1);
    $grid2->attach($gui{d}{Prefs}{buttonVNCPresets}, 4, 2, 1, 1);
    $grid2->attach($gui{d}{Prefs}{buttonVNCInfo}, 5, 2, 1, 1);
    $grid2->attach($gui{d}{Prefs}{checkOpenDisplay}, 1, 3, 3, 1);
    $grid2->attach($gui{d}{Prefs}{checkAutoHint}, 1, 4, 3, 1);
    $grid2->attach(gui_new_widgetlabel({text => '_Width (%X):', mnwidget => $gui{d}{Prefs}{sbWidth}}), 0, 5, 1, 1);
    $grid2->attach($gui{d}{Prefs}{sbWidth}, 1, 5, 1, 1);
    $grid2->attach(gui_new_widgetlabel({text => '_Height (%Y):', mnwidget => $gui{d}{Prefs}{sbHeight}}), 2, 5, 1, 1);
    $grid2->attach($gui{d}{Prefs}{sbHeight}, 3, 5, 1, 1);
    $grid2->attach(gui_new_widgetlabel({text => '_Depth (%D):', mnwidget => $gui{d}{Prefs}{cboxDepth}}), 0, 6, 1, 1);
    $grid2->attach($gui{d}{Prefs}{cboxDepth}, 1, 6, 3, 1);
    $gui{d}{Prefs}{buttonRDPPresets}->signal_connect('button-release-event' => \&show_rdppreset_menu);
    $gui{d}{Prefs}{buttonVNCPresets}->signal_connect('button-release-event' => \&show_vncpreset_menu);
    $gui{d}{Prefs}{buttonRDPInfo}->signal_connect('button-release-event' => \&show_dialog_rdpvncinfo);
    $gui{d}{Prefs}{buttonVNCInfo}->signal_connect('button-release-event' => \&show_dialog_rdpvncinfo);
}

# Built the NAT Details Dialog
sub build_dialogNAT {
    $gui{d}{NAT}{dialog} = gui_new_dialog({title  => 'NAT Network Manager',
                                            cancel => TRUE});

    $gui{d}{NAT}{dialog}->set_default_size(600,500);
    $gui{d}{NAT}{entryName} = gui_new_entry({width  => 50,
                                              maxlen => 255,
                                              tip    => 'The name assigned to this NAT network'});

    $gui{d}{NAT}{entryCIDR} = gui_new_entry({width  => 50,
                                              maxlen => 18,
                                              tip    => 'Network and mask definition in CIDR format'});

    $gui{d}{NAT}{checkDHCP} = gui_new_check({text   => '_Supports DHCP',
                                              active => FALSE,
                                              tip    => 'Enable DHCP support on this network'});

    $gui{d}{NAT}{checkIPv6} = gui_new_check({text   => '_Supports IPv6',
                                              active => FALSE,
                                              tip    => 'Enable IPv6 on this network'});

    $gui{d}{NAT}{checkRoute} = gui_new_check({text   => 'Advertise default IPv6 _route',
                                               active => FALSE,
                                               tip    => 'Advertise the default route for IPv6 if it is enabled'});

    $gui{d}{NAT}{treeviewIPv4} = gui_new_treeview({model => $gui{d}{NAT}{lstoreIPv4} = gui_new_lstore(['Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String']),
                                                    tip   => 'Active IPv4 portfordwarding rules on this network'});

    $gui{d}{NAT}{treeviewIPv4}->append_column(gui_new_treeviewcolumn({title   => 'Name',
                                                                       type    => 'text',
                                                                       typecol => 0}));

    $gui{d}{NAT}{treeviewIPv4}->append_column(gui_new_treeviewcolumn({title   => 'Protocol',
                                                                       type    => 'text',
                                                                       typecol => 1}));

    $gui{d}{NAT}{treeviewIPv4}->append_column(gui_new_treeviewcolumn({title   => 'Host IP',
                                                                       type    => 'text',
                                                                       typecol => 2}));

    $gui{d}{NAT}{treeviewIPv4}->append_column(gui_new_treeviewcolumn({title   => 'Host Port',
                                                                       type    => 'text',
                                                                       typecol => 3}));

    $gui{d}{NAT}{treeviewIPv4}->append_column(gui_new_treeviewcolumn({title   => 'Guest IP',
                                                                       type    => 'text',
                                                                       typecol => 4}));

    $gui{d}{NAT}{treeviewIPv4}->append_column(gui_new_treeviewcolumn({title   => 'Guest Port',
                                                                       type    => 'text',
                                                                       typecol => 5}));

    $gui{d}{NAT}{treeviewIPv6} = gui_new_treeview({model => $gui{d}{NAT}{lstoreIPv6} = gui_new_lstore(['Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String']),
                                                    tip   => 'Active IPv6 portfordwarding rules on this network'});

    $gui{d}{NAT}{treeviewIPv6}->append_column(gui_new_treeviewcolumn({title   => 'Name',
                                                                       type    => 'text',
                                                                       typecol => 0}));

    $gui{d}{NAT}{treeviewIPv6}->append_column(gui_new_treeviewcolumn({title   => 'Protocol',
                                                                       type    => 'text',
                                                                       typecol => 1}));

    $gui{d}{NAT}{treeviewIPv6}->append_column(gui_new_treeviewcolumn({title   => 'Host IP',
                                                                       type    => 'text',
                                                                       typecol => 2}));

    $gui{d}{NAT}{treeviewIPv6}->append_column(gui_new_treeviewcolumn({title   => 'Host Port',
                                                                       type    => 'text',
                                                                       typecol => 3}));

    $gui{d}{NAT}{treeviewIPv6}->append_column(gui_new_treeviewcolumn({title   => 'Guest IP',
                                                                       type    => 'text',
                                                                       typecol => 4}));

    $gui{d}{NAT}{treeviewIPv6}->append_column(gui_new_treeviewcolumn({title   => 'Guest Port',
                                                                       type    => 'text',
                                                                       typecol => 5}));

    my $notebook = Gtk3::Notebook->new();
    $notebook->append_page(my $grid2 = gui_new_grid(), gui_new_widgetlabel({text => 'IPv_4'}));
    $notebook->append_page(my $grid3 = gui_new_grid(), gui_new_widgetlabel({text => 'IPv_6'}));
    $notebook->show_all();
    my $bb1 = gui_new_buttonbox({orientation => 'vertical'});
    $bb1->add(my $buttonAdd4 = gui_new_imgbutton({image => 'rule_add_16px.png', tip => 'Add an IPv4 Port Forwarding Rule'}));
    $bb1->add($gui{d}{NAT}{buttonEdit4} = gui_new_imgbutton({image => 'rule_edit_16px.png', tip => 'Edit an IPv4 Port Forwarding Rule'}));
    $bb1->add($gui{d}{NAT}{buttonRemove4} = gui_new_imgbutton({image => 'rule_remove_16px.png', tip => 'Remove an  IPv4 Port Forwarding Rule'}));
    my $bb2 = gui_new_buttonbox({orientation => 'vertical'});
    $bb2->add(my $buttonAdd6 = gui_new_imgbutton({image => 'rule_add_16px.png', tip => 'Add an IPv6 Port Forwarding Rule'}));
    $bb2->add($gui{d}{NAT}{buttonEdit6} = gui_new_imgbutton({image => 'rule_edit_16px.png', tip => 'Edit an IPv6 Port Forwarding Rule'}));
    $bb2->add($gui{d}{NAT}{buttonRemove6} = gui_new_imgbutton({image => 'rule_remove_16px.png', tip => 'Remove an  IPv6 Port Forwarding Rule'}));
    my $frame = gui_new_frame({label => 'Port Forwarding Rules'});
    $frame->add($notebook);
    $gui{d}{NAT}{dialog}->get_content_area()->add(my $grid1 = gui_new_grid());
    $grid1->attach(gui_new_widgetlabel({text => 'Network _Name:', mnwidget => $gui{d}{NAT}{entryName}}), 0, 0, 1, 1);
    $grid1->attach($gui{d}{NAT}{entryName}, 1, 0, 1, 1);
    $grid1->attach(gui_new_widgetlabel({text => 'Network _CIDR:', mnwidget => $gui{d}{NAT}{entryCIDR}}), 0, 1, 1, 1);
    $grid1->attach($gui{d}{NAT}{entryCIDR}, 1, 1, 1, 1);
    $grid1->attach(gui_new_widgetlabel({text => 'Network Options:'}), 0, 3, 1, 1);
    $grid1->attach($gui{d}{NAT}{checkDHCP}, 1, 2, 1, 1);
    $grid1->attach($gui{d}{NAT}{checkIPv6}, 1, 3, 1, 1);
    $grid1->attach($gui{d}{NAT}{checkRoute}, 1, 4, 1, 1);
    $grid1->attach($frame, 0, 5, 2, 1);
    $grid2->attach(my $scrollwin1 = gui_new_scrolledwindow(), 0, 0, 1, 1);
    $scrollwin1->add($gui{d}{NAT}{treeviewIPv4});
    $grid2->attach($bb1, 1, 0, 1, 1);
    $grid3->attach(my $scrollwin2 = gui_new_scrolledwindow(), 0, 0, 1, 1);
    $scrollwin2->add($gui{d}{NAT}{treeviewIPv6});
    $grid3->attach($bb2, 1, 0, 1, 1);
    $signal{NAT_treeviewIPv4_cursor_changed} = $gui{d}{NAT}{treeviewIPv4}->signal_connect('cursor-changed' => \&onsel_list_pf4);
    $signal{NAT_treeviewIPv6_cursor_changed} = $gui{d}{NAT}{treeviewIPv6}->signal_connect('cursor-changed' => \&onsel_list_pf6);
    $buttonAdd4->signal_connect('clicked' => \&show_dialog_pf4, 'ADD');
    $buttonAdd6->signal_connect('clicked' => \&show_dialog_pf6, 'ADD');
    $gui{d}{NAT}{buttonEdit4}->signal_connect('clicked' => \&show_dialog_pf4, 'EDIT');
    $gui{d}{NAT}{buttonEdit6}->signal_connect('clicked' => \&show_dialog_pf6, 'EDIT');
    $gui{d}{NAT}{buttonRemove4}->signal_connect('clicked' => \&remove_pf_rule4);
    $gui{d}{NAT}{buttonRemove6}->signal_connect('clicked' => \&remove_pf_rule6);
    $gui{d}{NAT}{entryCIDR}->signal_connect('changed' => \&valid_cidr_char);
}

# Build the remote file chooser dialog
sub build_dialogRemoteFileChooser {
    $gui{d}{RemoteFileChooser}{dialog} = gui_new_dialog({title  => 'Choose File...', cancel => TRUE});
    $gui{d}{RemoteFileChooser}{dialog}->set_default_size(500,500);
    $gui{d}{RemoteFileChooser}{entryLocation} = gui_new_entry({width => 35, tip => 'Current directory location on the remote server'});
    my $button1 = gui_new_imgbutton({image => 'sf_parent_16px.png', tip => 'Change to the parent directory'});
    my $button2 = gui_new_imgbutton({image => 'refresh_16px.png', tip => 'Refresh the contents of the current directory'});

    $gui{d}{RemoteFileChooser}{treeviewFile} = gui_new_treeview({model => $gui{d}{RemoteFileChooser}{lstoreFile} = gui_new_lstore(['Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Gtk3::Gdk::Pixbuf']),
                                                                  tip   => 'Files in the current directory'});

    $gui{d}{RemoteFileChooser}{treeviewFile}->append_column(gui_new_treeviewcolumn({title   => '',
                                                                                     type    => 'pixbuf',
                                                                                     typecol => 4}));

    $gui{d}{RemoteFileChooser}{treeviewFile}->append_column(gui_new_treeviewcolumn({title   => 'Type',
                                                                                     type    => 'text',
                                                                                     typecol => 0}));

    $gui{d}{RemoteFileChooser}{treeviewFile}->append_column(gui_new_treeviewcolumn({title   => 'Name',
                                                                                     type    => 'text',
                                                                                     typecol => 1}));

    $gui{d}{RemoteFileChooser}{treeviewFile}->append_column(gui_new_treeviewcolumn({title   => 'Size',
                                                                                     type    => 'text',
                                                                                     typecol => 2}));

    $gui{d}{RemoteFileChooser}{treeviewFile}->append_column(gui_new_treeviewcolumn({title   => 'Mode',
                                                                                     type    => 'text',
                                                                                     typecol => 3}));

    $gui{d}{RemoteFileChooser}{entryFile} = gui_new_entry({tip   => 'Current directory location on the remote server'});
    $gui{d}{RemoteFileChooser}{entryFilter} = gui_new_entry({tip   => 'Current directory location on the remote server'});
    $gui{d}{RemoteFileChooser}{dialog}->get_content_area()->add(my $grid = gui_new_grid());
    $grid->attach(gui_new_widgetlabel({text => '_Location:', mnwidget => $gui{d}{RemoteFileChooser}{entryLocation}}), 0, 0, 1, 1);
    $grid->attach($gui{d}{RemoteFileChooser}{entryLocation}, 1, 0, 3, 1);
    $grid->attach(my $box = gui_new_box('horizontal'), 4, 0, 1, 1);
    $box->pack_start($button1, TRUE, TRUE, 2);
    $box->pack_start($button2, TRUE, TRUE, 2);
    $grid->attach(my $scrollwin = gui_new_scrolledwindow(), 0, 1, 5, 1);
    $scrollwin->add($gui{d}{RemoteFileChooser}{treeviewFile});
    $grid->attach($gui{d}{RemoteFileChooser}{boxFile} = gui_new_box('horizontal'), 0, 2, 5, 1);
    $gui{d}{RemoteFileChooser}{boxFile}->pack_start(gui_new_widgetlabel({text => '_File:', mnwidget => $gui{d}{RemoteFileChooser}{entryLocation}}), TRUE, TRUE, 2);
    $gui{d}{RemoteFileChooser}{boxFile}->pack_start($gui{d}{RemoteFileChooser}{entryFile}, TRUE, TRUE, 2);
    $gui{d}{RemoteFileChooser}{boxFile}->pack_start($gui{d}{RemoteFileChooser}{entryFilter}, TRUE, TRUE, 2);
    $gui{d}{RemoteFileChooser}{entryLocation}->signal_connect('activate' => \&refresh_remotefilechooser);
    $button1->signal_connect('clicked' => \&cdup_remotefilechooser);
    $button2->signal_connect('clicked' => \&refresh_remotefilechooser);
    $signal{RemoteFileChooser_treeviewRemoteFileChooser_cursorChanged} = $gui{d}{RemoteFileChooser}{treeviewFile}->signal_connect('cursor-changed' => \&onsel_list_remotefiles_single);
    $gui{d}{RemoteFileChooser}{treeviewFile}->signal_connect('row-activated' => \&onsel_list_remotefiles);
}

# Build the VMM dialog
sub build_dialogVMM {
    $gui{d}{VMM}{dialog} = gui_new_dialog({title  => 'Virtual Media Manager'});
    $gui{d}{VMM}{dialog}->set_default_size(800,600);
    $gui{d}{VMM}{imgHDAdd} = gui_new_img_from_file('hd_add_32px.png');
    $gui{d}{VMM}{imgHDCopy} = gui_new_img_from_file('hd_copy_32px.png');
    $gui{d}{VMM}{imgHDCreate} = gui_new_img_from_file('hd_create_32px.png');
    $gui{d}{VMM}{imgHDModify} = gui_new_img_from_file('hd_modify_32px.png');
    $gui{d}{VMM}{imgHDMove} = gui_new_img_from_file('hd_move_32px.png');
    $gui{d}{VMM}{imgHDRelease} = gui_new_img_from_file('hd_release_32px.png');
    $gui{d}{VMM}{imgHDRemove} = gui_new_img_from_file('hd_remove_32px.png');
    $gui{d}{VMM}{imgCompact} = gui_new_img_from_file('compact_32px.png');
    $gui{d}{VMM}{imgRefresh} = gui_new_img_from_file('refresh_32px.png');
    $gui{d}{VMM}{imgFDAdd} = gui_new_img_from_file('fd_add_32px.png');
    $gui{d}{VMM}{imgFDCopy} = gui_new_img_from_file('fd_copy_32px.png');
    $gui{d}{VMM}{imgFDCreate} = gui_new_img_from_file('fd_create_32px.png');
    $gui{d}{VMM}{imgFDModify} = gui_new_img_from_file('fd_modify_32px.png');
    $gui{d}{VMM}{imgFDMove} = gui_new_img_from_file('fd_move_32px.png');
    $gui{d}{VMM}{imgFDRelease} = gui_new_img_from_file('fd_release_32px.png');
    $gui{d}{VMM}{imgFDRemove} = gui_new_img_from_file('fd_remove_32px.png');
    $gui{d}{VMM}{imgDVDAdd} = gui_new_img_from_file('cd_add_32px.png');
    $gui{d}{VMM}{imgDVDCopy} = gui_new_img_from_file('cd_copy_32px.png');
    $gui{d}{VMM}{imgDVDCreate} = gui_new_img_from_file('cd_create_32px.png');
    $gui{d}{VMM}{imgDVDModify} = gui_new_img_from_file('cd_modify_32px.png');
    $gui{d}{VMM}{imgDVDMove} = gui_new_img_from_file('cd_move_32px.png');
    $gui{d}{VMM}{imgDVDRelease} = gui_new_img_from_file('cd_release_32px.png');
    $gui{d}{VMM}{imgDVDRemove} = gui_new_img_from_file('cd_remove_32px.png');
    my $toolbar = gui_new_toolbar();
    $toolbar->insert($gui{d}{VMM}{buttonAdd} = gui_new_toolbutton({image => 'hd_add_32px.png',
                                                                    label => '_Add',
                                                                    tip   => 'Add a medium to the VMM on the server'}), 0);

    $toolbar->insert($gui{d}{VMM}{buttonCreate} = gui_new_toolbutton({image => 'hd_create_32px.png',
                                                                       label => '_Create',
                                                                       tip  => 'Create a new disk image'}), 1);

    $toolbar->insert($gui{d}{VMM}{buttonCopy} = gui_new_toolbutton({image => 'hd_create_32px.png',
                                                                     label => 'C_opy & Convert',
                                                                     tip  => 'Copy an existing hard disk image and optionally change its format'}), 2);

    $toolbar->insert($gui{d}{VMM}{buttonMove} = gui_new_toolbutton({image => 'hd_move_32px.png',
                                                                     label => '_Move',
                                                                     tip  => 'Move a storage medium to a different location'}), 3);

    $toolbar->insert($gui{d}{VMM}{buttonModify} = gui_new_toolbutton({image => 'hd_modify_32px.png',
                                                                       label => 'Modify & Resi_ze',
                                                                       tip  => 'Modify the low-level hard disk type or resize the hard disk'}), 4);

    $toolbar->insert($gui{d}{VMM}{buttonRemove} = gui_new_toolbutton({image => 'hd_remove_32px.png',
                                                                       label => 'R_emove',
                                                                       tip  => 'Remove the medium from VirtualBox'}), 5);

    $toolbar->insert($gui{d}{VMM}{buttonRelease} = gui_new_toolbutton({image => 'hd_release_32px.png',
                                                                        label => 'Re_lease',
                                                                        tip  => 'Release medium from guests. Media associated with snapshots will not be released'}), 6);

    $toolbar->insert($gui{d}{VMM}{buttonCompact} = gui_new_toolbutton({image => 'compact_32px.png',
                                                                        label => 'Com_pact',
                                                                        tip  => 'Attempt to compact the hard disk image, making it physically smaller'}), 7);

    $toolbar->insert($gui{d}{VMM}{buttonRefresh} = gui_new_toolbutton({image => 'refresh_32px.png',
                                                                        label => '_Refresh',
                                                                        tip  => 'Refresh the media list in the VMM'}), 8);

    $gui{d}{VMM}{notebook} = Gtk3::Notebook->new();
    $gui{d}{VMM}{notebook}->append_page(my $scrollwin1 = gui_new_scrolledwindow(), gui_new_imglabel({text => '_Hard Disks', img => 'hd_16px.png'}));
    $gui{d}{VMM}{notebook}->append_page(my $scrollwin2 = gui_new_scrolledwindow(), gui_new_imglabel({text => '_Optical Discs', img => 'cd_16px.png'}));
    $gui{d}{VMM}{notebook}->append_page(my $scrollwin3 = gui_new_scrolledwindow(), gui_new_imglabel({text => '_Floppy Disks', img => 'fd_16px.png'}));
    $gui{d}{VMM}{notebook}->show_all();
    $gui{d}{VMM}{treeviewHD} = gui_new_treeview({model   => $gui{d}{VMM}{tstoreHD} = gui_new_tstore(['Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Gtk3::Gdk::Pixbuf', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String']),
                                                  headers => TRUE,
                                                  tip     => 'Hard Disk Images'});

    $gui{d}{VMM}{treeviewHD}->append_column(gui_new_treeviewcolumn({title   => '',
                                                                     type    => 'pixbuf',
                                                                     typecol => 4}));

    $gui{d}{VMM}{treeviewHD}->append_column(gui_new_treeviewcolumn({title   => 'Name',
                                                                     type    => 'text',
                                                                     typecol => 0}));

    $gui{d}{VMM}{treeviewHD}->append_column(gui_new_treeviewcolumn({title   => 'Virtual Size',
                                                                     type    => 'text',
                                                                     typecol => 3}));

    $gui{d}{VMM}{treeviewHD}->append_column(gui_new_treeviewcolumn({title   => 'Actual Size',
                                                                     type    => 'text',
                                                                     typecol => 2}));

    $scrollwin1->add($gui{d}{VMM}{treeviewHD});
    $gui{d}{VMM}{treeviewDVD} = gui_new_treeview({model   => $gui{d}{VMM}{tstoreDVD} = gui_new_tstore(['Glib::String', 'Glib::String', 'Glib::String', 'Gtk3::Gdk::Pixbuf', 'Glib::String', 'Glib::String', 'Glib::String']),
                                                   headers => TRUE,
                                                   tip     => 'Optical Disc Images'});

    $gui{d}{VMM}{treeviewDVD}->append_column(gui_new_treeviewcolumn({title   => '',
                                                                      type    => 'pixbuf',
                                                                      typecol => 3}));

    $gui{d}{VMM}{treeviewDVD}->append_column(gui_new_treeviewcolumn({title   => 'Name',
                                                                      type    => 'text',
                                                                      typecol => 0}));

    $gui{d}{VMM}{treeviewDVD}->append_column(gui_new_treeviewcolumn({title   => 'Size',
                                                                      type    => 'text',
                                                                      typecol => 2}));

    $scrollwin2->add($gui{d}{VMM}{treeviewDVD});
    $gui{d}{VMM}{treeviewFD} = gui_new_treeview({model   => $gui{d}{VMM}{tstoreFD} = gui_new_tstore(['Glib::String', 'Glib::String', 'Glib::String', 'Gtk3::Gdk::Pixbuf', 'Glib::String', 'Glib::String', 'Glib::String']),
                                                  headers => TRUE,
                                                  tip     => 'Floppy Disk Images'});

    $gui{d}{VMM}{treeviewFD}->append_column(gui_new_treeviewcolumn({title   => '',
                                                                     type    => 'pixbuf',
                                                                     typecol => 3}));

    $gui{d}{VMM}{treeviewFD}->append_column(gui_new_treeviewcolumn({title   => 'Name',
                                                                     type    => 'text',
                                                                     typecol => 0}));

    $gui{d}{VMM}{treeviewFD}->append_column(gui_new_treeviewcolumn({title   => 'Size',
                                                                     type    => 'text',
                                                                     typecol => 2}));

    $scrollwin3->add($gui{d}{VMM}{treeviewFD});
    my $frame = gui_new_frame({label => 'Details'});
    $frame->add(my $grid = gui_new_grid());
    $grid->attach(gui_new_markuplabel({text => '<b>Type:</b>', xalign => 1.0}), 0, 0, 1, 1);
    $grid->attach($gui{d}{VMM}{labelType} = gui_new_markuplabel({text => 'Field', xalign => 0.0}), 1, 0, 1, 1);
    $grid->attach(gui_new_markuplabel({text => '<b>Location:</b>', xalign => 1.0}), 0, 1, 1, 1);
    $grid->attach($gui{d}{VMM}{labelLocation} = gui_new_markuplabel({text => 'Field', xalign => 0.0}), 1, 1, 1, 1);
    $grid->attach(gui_new_markuplabel({text => '<b>Attached To:</b>', xalign => 1.0}), 0, 2, 1, 1);
    $grid->attach($gui{d}{VMM}{labelAttachedTo} = gui_new_markuplabel({text => 'Field', xalign => 0.0}), 1, 2, 1, 1);
    $grid->attach(gui_new_markuplabel({text => '<b>Encryption Key:</b>', xalign => 1.0}), 0, 3, 1, 1);
    $grid->attach($gui{d}{VMM}{labelEncrypted} = gui_new_markuplabel({text => 'Field', xalign => 0.0}), 1, 3, 1, 1);
    $grid->attach(gui_new_markuplabel({text => '<b>UUID:</b>', xalign => 1.0}), 0, 4, 1, 1);
    $grid->attach($gui{d}{VMM}{labelUUID} = gui_new_markuplabel({text => 'Field', xalign => 0.0}), 1, 4, 1, 1);
    $gui{d}{VMM}{dialog}->get_content_area()->add(my $box = gui_new_box('vertical'));
    $box->pack_start($toolbar, FALSE, FALSE, 2);
    $box->pack_start($gui{d}{VMM}{notebook}, TRUE, TRUE, 2);
    $box->pack_start($frame, FALSE, FALSE, 2);
    $gui{d}{VMM}{buttonAdd}->signal_connect('clicked' => \&show_remote_filechooser, {title       => 'Choose Media Images',
                                                                                     entrywidget => '',
                                                                                     mode        => 'multifile',
                                                                                     filter      => '.*',
                                                                                     callback    => \&vmm_add});
    $gui{d}{VMM}{buttonCreate}->signal_connect('clicked' => \&vmm_create_broker);
    $gui{d}{VMM}{buttonCopy}->signal_connect('clicked' => \&vmm_copy_broker);
    $gui{d}{VMM}{buttonMove}->signal_connect('clicked' => \&vmm_move_broker);
    $gui{d}{VMM}{buttonModify}->signal_connect('clicked' => \&show_dialog_vmm_modify);
    $gui{d}{VMM}{buttonRemove}->signal_connect('clicked' => \&vmm_rem);
    $gui{d}{VMM}{buttonRelease}->signal_connect('clicked' => \&vmm_release);
    $gui{d}{VMM}{buttonCompact}->signal_connect('clicked' => \&vmm_compact);
    $gui{d}{VMM}{buttonRefresh}->signal_connect('clicked' => \&vmm_refresh_broker);
    $gui{d}{VMM}{notebook}->signal_connect('switch-page', => \&vmm_tabchanged);
    $gui{d}{VMM}{treeviewHD}->signal_connect('row-activated' => \&show_dialog_vmm_modify);
    $signal{VMM_treeviewHD_cursorChanged} = $gui{d}{VMM}{treeviewHD}->signal_connect('cursor-changed' => \&onsel_list_vmmhd);
    $signal{VMM_treeviewDVD_cursorChanged} = $gui{d}{VMM}{treeviewDVD}->signal_connect('cursor-changed' => \&onsel_list_vmmdvd);
    $gui{d}{VMM}{treeviewFD}->signal_connect('row-activated' => \&show_dialog_vmm_modify);
    $signal{VMM_treeviewFD_cursorChanged} = $gui{d}{VMM}{treeviewFD}->signal_connect('cursor-changed' => \&onsel_list_vmmfloppy);
}

sub build_dialogEdit {
    $gui{d}{Edit}{dialog} = gui_new_dialog({title   => 'Edit Settings',
                                             ok      => 'Save',
                                             okimage => gui_new_img_from_file('vm_settings_16px.png'),
                                             cancel  => TRUE});
    $gui{d}{Edit}{notebook} = Gtk3::Notebook->new();
    $gui{d}{Edit}{notebook}->set_tab_pos('GTK_POS_LEFT');
    $gui{d}{Edit}{dialog}->get_content_area()->add($gui{d}{Edit}{notebook});
    $gui{d}{Edit}{notebook}->show_all();
}

sub build_dialogEditGeneral {
    # Basic Tab
    $gui{d}{Edit}{entryGenName} = gui_new_entry({width  => 50,
                                                  tip    => 'The name of the guest'});

    $gui{d}{Edit}{cboxGenFamily} = gui_new_imgcombobox({model  => $gui{d}{Edit}{lstoreGenFamily} = gui_new_lstore(['Glib::String', 'Glib::String', 'Gtk3::Gdk::Pixbuf']),
                                                         imgcol => 2,
                                                         active => 0,
                                                         tip    => 'The operating system family the guest is running'});

    $gui{d}{Edit}{cboxGenVersion} = gui_new_imgcombobox({model => $gui{d}{Edit}{lstoreGenVersion} = gui_new_lstore(['Glib::String', 'Glib::String', 'Gtk3::Gdk::Pixbuf']),
                                                          imgcol => 2,
                                                          active => 0,
                                                          tip    => 'The version of the operating system the guest is running'});
    # Advanced Tab
    $gui{d}{Edit}{entryGenSnapfolder} = gui_new_entry({width  => 50,
                                                        tip    => "Location of the snapshot folder for this guest\n* Cannot be changed if the guest already has snapshots\n* Set to empty to reset to the default"});

    $gui{d}{Edit}{buttonGenSnapfolder} = gui_new_imgbutton({image => 'sf_16px.png',
                                                             tip   => 'Choose the snapshot folder location on the server'});

    $gui{d}{Edit}{cboxGenClip} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                    [0, 1],
                                                                                    [['Disabled', 'Disabled'],
                                                                                     ['Host To Guest', 'HostToGuest'],
                                                                                     ['Guest To Host', 'GuestToHost'],
                                                                                     ['Bidirectional', 'Bidirectional']]),
                                                          active => 0,
                                                          tip    => 'Set clipboard sharing preferences between guest and host'});

    $gui{d}{Edit}{checkGenAutostart} = gui_new_check({text   => '_Autostart Guest on Host Boot',
                                                       active => FALSE,
                                                       tip    => 'Automatically start this guest when the host boots'});

    $gui{d}{Edit}{sbGenAutostart} = gui_new_spinbutton({lo      => 0,
                                                         hi      => 600,
                                                         inc     => 1,
                                                         numeric => FALSE,
                                                         tip     => 'The amount of time delay before starting this guest when the host boots'});

    $gui{d}{Edit}{cboxGenAutostop} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                        [0, 1],
                                                                                        [['None', 'Disabled'],
                                                                                         ['Save State', 'SaveState'],
                                                                                         ['Instant Power Off', 'PowerOff'],
                                                                                         ['ACPI Shutdown', 'AcpiShutdown']]),
                                                              active => 0,
                                                              tip    => 'The stop mode to use for this guest when the host shutsdown'});
    # Description Tab
    my $tv = gui_new_textview({editable => TRUE,
                                buffer   => $gui{d}{Edit}{tbGenDescription} = Gtk3::TextBuffer->new(),
                                tip      => 'Description of the guest'});
    # Disk Encryption Tab
    $gui{d}{Edit}{checkGenEncryption} = gui_new_check({text   => 'Enable Encr_yption',
                                                        active => FALSE,
                                                        tip    => 'Enable disk encryption'});

    $gui{d}{Edit}{cboxGenCiper} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                     [0, 1],
                                                                                     [['Leave Unchanged', 'Unchanged'],
                                                                                      ['AES-XTS256-PLAIN64', 'AES-XTS256-PLAIN64'],
                                                                                      ['AES-XTS128-PLAIN64', 'AES-XTS128-PLAIN64']]),
                                                           active => 0,
                                                           tip    => 'Selects the cipher to use for encrypting disks'});

    $gui{d}{Edit}{entryGenPass} = gui_new_entry({width => 50,
                                                  tip   => 'The new encryption password',
                                                  pass  => TRUE});

    $gui{d}{Edit}{entryGenConfirm} = gui_new_entry({width => 50,
                                                  tip   => 'Confirm the new encryption password',
                                                  pass  => TRUE});

    $gui{d}{Edit}{notebookGen} = Gtk3::Notebook->new();
    # Basic Tab
    $gui{d}{Edit}{notebookGen}->append_page(my $gridBasic = gui_new_grid(), gui_new_widgetlabel({text => '_Basic'}));
    $gridBasic->attach(gui_new_widgetlabel({text => '_Name:', mnwidget => $gui{d}{Edit}{entryGenName}}), 0, 0, 1, 1);
    $gridBasic->attach($gui{d}{Edit}{entryGenName}, 1, 0, 1, 1);
    $gridBasic->attach(gui_new_widgetlabel({text => 'OS _Family:', mnwidget => $gui{d}{Edit}{cboxGenFamily}}), 0, 1, 1, 1);
    $gridBasic->attach($gui{d}{Edit}{cboxGenFamily}, 1, 1, 1, 1);
    $gridBasic->attach(gui_new_widgetlabel({text => '_Version:', mnwidget => $gui{d}{Edit}{cboxGenVersion}}), 0, 2, 1, 1);
    $gridBasic->attach($gui{d}{Edit}{cboxGenVersion}, 1, 2, 1, 1);
    # Advanced Tab
    $gui{d}{Edit}{notebookGen}->append_page(my $gridAdvanced = gui_new_grid(), gui_new_widgetlabel({text => '_Advanced'}));
    $gridAdvanced->attach(gui_new_widgetlabel({text => 'S_napshot Folder:', mnwidget => $gui{d}{Edit}{entryGenSnapfolder}}), 0, 0, 1, 1);
    $gridAdvanced->attach($gui{d}{Edit}{entryGenSnapfolder}, 1, 0, 1, 1);
    $gridAdvanced->attach($gui{d}{Edit}{buttonGenSnapfolder}, 2, 0, 1, 1);
    $gridAdvanced->attach(gui_new_widgetlabel({text => '_Shared Clipboard:', mnwidget => $gui{d}{Edit}{cboxGenClip}}), 0, 1, 1, 1);
    $gridAdvanced->attach($gui{d}{Edit}{cboxGenClip}, 1, 1, 2, 1);
    $gridAdvanced->attach(gui_new_separator(), 0, 2, 3, 1);
    $gridAdvanced->attach(gui_new_widgetlabel({text => 'Autostart Settings:'}), 0, 3, 1, 1);
    $gridAdvanced->attach($gui{d}{Edit}{checkGenAutostart}, 1, 3, 2, 1);
    $gridAdvanced->attach($gui{d}{Edit}{labelGenAutostartdelay} = gui_new_widgetlabel({text => 'Autostart De_lay:', mnwidget => $gui{d}{Edit}{sbGenAutostart}}), 0, 4, 1, 1);
    $gridAdvanced->attach($gui{d}{Edit}{sbGenAutostart}, 1, 4, 2, 1);
    $gridAdvanced->attach($gui{d}{Edit}{labelGenAutostop} = gui_new_widgetlabel({text => 'Autostop _Mode:', mnwidget => $gui{d}{Edit}{cboxGenAutostop}}), 0, 5, 1, 1);
    $gridAdvanced->attach($gui{d}{Edit}{cboxGenAutostop}, 1, 5, 2, 1);
    # Description Tab
    $gui{d}{Edit}{notebookGen}->append_page(my $scrollwin = gui_new_scrolledwindow(), gui_new_widgetlabel({text => '_Description'}));
    $scrollwin->add($tv);
    # Disk Encryption Tab
    $gui{d}{Edit}{notebookGen}->append_page(my $debox = gui_new_box('vertical'), gui_new_widgetlabel({text => 'Disk _Encryption'}));
    $debox->pack_start($gui{d}{Edit}{checkGenEncryption}, FALSE, FALSE, 2);
    $debox->pack_start($gui{d}{Edit}{gridGenEncryption} = gui_new_grid(), TRUE, TRUE, 2);
    $gui{d}{Edit}{gridGenEncryption}->attach(gui_new_widgetlabel({text => 'Encryption _Cipher:', mnwidget => $gui{d}{Edit}{cboxGenCiper}}), 0, 0, 1, 1);
    $gui{d}{Edit}{gridGenEncryption}->attach($gui{d}{Edit}{cboxGenCiper}, 1, 0, 1, 1);
    $gui{d}{Edit}{gridGenEncryption}->attach(gui_new_widgetlabel({text => '_New Password:', mnwidget => $gui{d}{Edit}{entryGenPass}}), 0, 1, 1, 1);
    $gui{d}{Edit}{gridGenEncryption}->attach($gui{d}{Edit}{entryGenPass}, 1, 1, 1, 1);
    $gui{d}{Edit}{gridGenEncryption}->attach(gui_new_widgetlabel({text => 'Confirm _Password:', mnwidget => $gui{d}{Edit}{entryGenConfirm}}), 0, 2, 1, 1);
    $gui{d}{Edit}{gridGenEncryption}->attach($gui{d}{Edit}{entryGenConfirm}, 1, 2, 1, 1);
    $gui{d}{Edit}{notebookGen}->show_all();
    # Signals
    $gui{d}{Edit}{notebookGen}->signal_connect('switch-page' => \&edit_gen_tabchanged);
    $gui{d}{Edit}{entryGenName}->signal_connect('activate' => \&gen_basic_name);
    $gui{d}{Edit}{entryGenName}->signal_connect('focus-out-event' => \&gen_basic_name);
    $signal{Edit_cboxGenFamily_changed} = $gui{d}{Edit}{cboxGenFamily}->signal_connect('changed' => \&gen_basic_os_family, $gui{d}{Edit}{cboxGenVersion});
    $signal{Edit_cboxGenVersion_changed} = $gui{d}{Edit}{cboxGenVersion}->signal_connect('changed' => \&gen_basic_os_version, $gui{d}{Edit}{cboxGenFamily});
    $signal{Edit_entryGenSnapfolder_activate} = $gui{d}{Edit}{entryGenSnapfolder}->signal_connect('activate' => \&gen_snapfolder);
    $signal{Edit_entryGenSnapfolder_focus} = $gui{d}{Edit}{entryGenSnapfolder}->signal_connect('focus-out-event' => \&gen_snapfolder);
    $gui{d}{Edit}{buttonGenSnapfolder}->signal_connect('clicked' => \&show_remote_filechooser, {title       => 'Choose Snapshot Folder',
                                                                                                entrywidget => \$gui{d}{Edit}{entryGenSnapfolder},
                                                                                                mode        => 'dir',
                                                                                                filter      => ' ^',
                                                                                                callback    => \&handle_snapshotfolderchooser});
    $gui{d}{Edit}{cboxGenClip}->signal_connect('changed' => \&gen_adv_clipboard);
    $gui{d}{Edit}{checkGenAutostart}->signal_connect('toggled' => \&gen_adv_autostart);
    $gui{d}{Edit}{sbGenAutostart}->signal_connect('value-changed' => \&gen_adv_autostart_delay);
    $gui{d}{Edit}{cboxGenAutostop}->signal_connect('changed' => \&gen_adv_autostop_mode);
    $tv->signal_connect('focus-out-event' => \&gen_description);
    $gui{d}{Edit}{checkGenEncryption}->signal_connect('toggled' => \&gen_encryption);
    $gui{d}{Edit}{entryGenName}->signal_connect('changed' => \&valid_guestname_char);
    $gui{d}{Edit}{sbGenAutostart}->signal_connect('input' => \&sb_time_s_in);
    $gui{d}{Edit}{sbGenAutostart}->signal_connect('output' => \&sb_time_s_out);
    # Main Notebook
    $gui{d}{Edit}{notebook}->append_page(my $box = gui_new_box('vertical'), gui_new_imglabel({text => '_General', img => 'machine_24px.png'}));
    $box->pack_start(gui_new_titlelabel({text => 'General'}), FALSE, FALSE, 2);
    $box->pack_start($gui{d}{Edit}{notebookGen}, TRUE, TRUE, 2);
}

sub build_dialogEditSystem {
    # Motherboard Tab
    $gui{d}{Edit}{sbSysMemory} = gui_new_spinbutton({adj       => gui_new_adjustment($gui{d}{Edit}{sbSysMemory}, 4, 4, 2097152, 1, 16, 0),
                                                      lo        => 4,
                                                      hi        => 2097152,
                                                      inc       => 4,
                                                      decplaces => 2,
                                                      numeric   => FALSE,
                                                      tip       => 'Amount of memory assign to the guest'});

    $gui{d}{Edit}{treeviewSysBoot} = gui_new_treeview({model   => $gui{d}{Edit}{lstoreSysBoot} = gui_new_tstore(['Glib::Boolean', 'Glib::String', 'Gtk3::Gdk::Pixbuf', 'Glib::String']),
                                                        headers => FALSE,
                                                        tip     => 'Defines the BIOS boot order. The BIOS will only attempt to boot from enabled devices'});

    my ($col, $celltoggle) = gui_new_treeviewcolumntoggle({title   => 'Enabled',
                                                            type    => 'active',
                                                            typecol => 0});

    $gui{d}{Edit}{treeviewSysBoot}->append_column($col);
    $gui{d}{Edit}{treeviewSysBoot}->append_column(gui_new_treeviewcolumn({title   => 'Icon',
                                                                           type    => 'pixbuf',
                                                                           typecol => 2}));

    $gui{d}{Edit}{treeviewSysBoot}->append_column(gui_new_treeviewcolumn({title   => 'Boot Order',
                                                                           type    => 'text',
                                                                           typecol => 3}));

    $gui{d}{Edit}{buttonSysBootup} = gui_new_imgbutton({image => 'arrow_up_10px.png',
                                                         tip   => 'Move boot device up'});

    $gui{d}{Edit}{buttonSysBootdown} = gui_new_imgbutton({image => 'arrow_down_10px.png',
                                                           tip   => 'Move boot device down'});

    $gui{d}{Edit}{cboxSysChipset} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                       [0, 1],
                                                                                       [['PIIX3', 'PIIX3'],
                                                                                        ['ICH9', 'ICH9']]),
                                                             active => 0,
                                                             tip    => "Defines the chipset this guest will see\n* PIIX3 is recommended for most operating systems\n* ICH9 is experimental. Recommended only for Mac OS X\n* IO APIC must be enabled for the ICH9 chipset"});

    $gui{d}{Edit}{cboxSysTPM} = gui_new_simplecombobox({model  => $gui{d}{Edit}{lstoreSysTPM} = gui_new_lstore(['Glib::String', 'Glib::String']),
                                                         active => -1,
                                                         tip    => 'The type of Trusted Platform Module (TPM)'});

    $gui{d}{Edit}{cboxSysPoint} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                     [0, 1],
                                                                                     [['None', 'None'],
                                                                                      ['PS2 Mouse', 'PS2Mouse'],
                                                                                      ['USB Mouse', 'USBMouse'],
                                                                                      ['USB Tablet', 'USBTablet'],
                                                                                      ['Combo USB/PS2 Mouse', 'ComboMouse'],
                                                                                      ['USB Multi-Touch Tablet', 'USBMultiTouch'],
                                                                                      ['USB Multi-Touch Screen and Pad', 'USBMultiTouchScreenPlusPad']]),
                                                           active => 0,
                                                           tip    => "Selects the emulated pointing device the guest will see\n* USB options require USB support to be enabled\n* If unsure choose PS2 Mouse"});

    $gui{d}{Edit}{cboxSysKeyboard} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                        [0, 1],
                                                                                        [['None', 'None'],
                                                                                         ['PS2 Keyboard', 'PS2Keyboard'],
                                                                                         ['USB Keyboard', 'USBKeyboard'],
                                                                                         ['Combo USB/PS2 Keyboard', 'ComboKeyboard']]),
                                                              active => 0,
                                                              tip    => "Selects the emulated keyboard the guest will see\n* USB options require USB support to be enabled\n* If unsure choose PS2 Keyboard"});

    $gui{d}{Edit}{checkSysAPIC} = gui_new_check({text   => 'Enable _IO APIC',
                                                  active => FALSE,
                                                  tip    => "Provides IO APIC to the guest\n* Required for 64bit operating systems\n* Required if 2 or more CPUs are assigned to a guest\n* Caution: For Windows guests, do NOT disable after installation"});

    $gui{d}{Edit}{checkSysUTC} = gui_new_check({text   => 'Hardware Clock is in _UTC time',
                                                 active => FALSE,
                                                 tip    => "The hardware clock of the guest is set to use UTC otherwise local time will be used\n* UNIX and Linux generally expects UTC\n* Windows and DOS generally does not use UTC"});

    $gui{d}{Edit}{checkSysEFI} = gui_new_check({text   => 'Enable _EFI',
                                                 active => FALSE,
                                                 tip    => "Enable EFI support instead of BIOS\n* EFI must be supported by the guest OS"});

    $gui{d}{Edit}{checkSysSecure} = gui_new_check({text   => 'Enable _Secure Boot',
                                                    active => FALSE,
                                                    tip    => "Enable the use of Secure Boot where supported\n* EFI must be enabled\n* Secure Boot must be supported by your guest OS"});

    $gui{d}{Edit}{buttonSysSecure} = gui_new_button({label => '_Restore Secure Boot Keys',
                                                      tip   => 'Restores the Secure Boot keys back to the defaults'});
    # Processor Tab
    $gui{d}{Edit}{adjSysProcessor} = gui_new_adjustment(undef, 1, 1, 33, 1, 1, 1);
    $gui{d}{Edit}{scaleSysProcessor} = gui_new_scale({adj       => $gui{d}{Edit}{adjSysProcessor},
                                                       showvalue => TRUE,
                                                       decplaces => 0,
                                                       tip       => 'The number of virtual CPUs assigned to the guest'});

    $gui{d}{Edit}{adjSysCap} = gui_new_adjustment(undef, 100, 1, 100, 1, 10, 0);
    $gui{d}{Edit}{scaleSysCap} = gui_new_scale({adj       => $gui{d}{Edit}{adjSysCap},
                                                 showvalue => TRUE,
                                                 decplaces => 0,
                                                 tip       => 'Restricts the amount of CPU time a guest can use'});

    $gui{d}{Edit}{checkSysPAE} = gui_new_check({text   => 'Enable PAE/_NX',
                                                 active => FALSE,
                                                 tip    => "Makes Physical Address Extensions and NX available to the guest\n* Allows 32bit guests which support PAE, to address more than 4GB"});

    $gui{d}{Edit}{checkSysVTX} = gui_new_check({text   => 'Enable Nested _VT-x/AMD-V',
                                                 active => FALSE,
                                                 tip    => 'Enable nested hardware virtualization on processors which support it'});

    $gui{d}{Edit}{checkSysHot} = gui_new_check({text   => 'Allow CPU _Hot-Plugging',
                                                 active => FALSE,
                                                 tip    => 'Allow processors to be hot plugged or removed. The OS must support it'});
    # Advanced Tab
    $gui{d}{Edit}{sbSysTime} = gui_new_spinbutton({lo      => 0,
                                                    hi      => 86400000,
                                                    inc     => 1,
                                                    numeric => FALSE,
                                                    tip     => "A delta time to run the guest clock, ahead of the host clock. Guest additions will honour this offset when using time synchronisation\n* Default is 0"});

    $gui{d}{Edit}{checkSysHPET} = gui_new_check({text   => '_High Precision Event Timer (HPET)',
                                                  active => FALSE,
                                                  tip    => 'Provides your guest with a high precision time source if your operating system supports it'});

    $gui{d}{Edit}{checkSysFusion} = gui_new_check({text   => 'Enable Page _Fusion',
                                                    active => FALSE,
                                                    tip    => 'Reduce the host memory consumption by sharing similar memory pages between guests on supported operating systems'});

    $gui{d}{Edit}{checkSysLargepages} = gui_new_check({text   => 'Use _Large Pages',
                                                        active => FALSE,
                                                        tip    => 'Using large pages can increase performance slightly if your OS supports them'});
    # Acceleration Tab
    $gui{d}{Edit}{cboxSysPara} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                    [0, 1],
                                                                                    [['None', 'None'],
                                                                                     ['Default', 'Default'],
                                                                                     ['Legacy', 'Legacy'],
                                                                                     ['Minimal', 'Minimal'],
                                                                                     ['Microsoft Hyper-V', 'HyperV'],
                                                                                     ['Linux KVM', 'KVM']]),
                                                          active => -1,
                                                          tip    => 'The interface type to use for paravirtualization'});

    $gui{d}{Edit}{checkSysNested} = gui_new_check({text   => 'Enable _Nested Paging (EPT)',
                                                    active => FALSE,
                                                    tip    => 'Enables Nested Paging (EPT) which can increase performance if your host CPU supports it'});

    $gui{d}{Edit}{checkSysVPID} = gui_new_check({text   => 'Enable _VPID',
                                                  active => FALSE,
                                                  tip    => 'Enable VPID if your CPU supports it'});
    # Boot Logo Tab
    $gui{d}{Edit}{sbSysLogotime} = gui_new_spinbutton({lo      => 0,
                                                        hi      => 86400000,
                                                        inc     => 1,
                                                        numeric => FALSE,
                                                        tip     => 'The amount of time to wait at the BIOS screen'});

    $gui{d}{Edit}{entrySysLogo} = gui_new_entry({width => 50,
                                                  tip   => "Use an alternative image for the BIOS logo. Note the following requirements\n* It must be 640x480 in exactly 256 colours (8 bit)\n* It must be saved without colourspace information\n* It must be an uncompressed Windows 3.1x BMP file format\n* The image file must be accessible by the server at the specified path\n* Set to empty to revert to the default logo"});

    $gui{d}{Edit}{buttonSysLogo} = gui_new_imgbutton({image => 'sf_16px.png',
                                                       tip   => 'Choose the BMP image on the server'});

    $gui{d}{Edit}{checkSysFadein} = gui_new_check({text   => 'Fade _In',
                                                    active => FALSE,
                                                    tip    => 'Enable the fade in of the BIOS logo'});

    $gui{d}{Edit}{checkSysFadeout} = gui_new_check({text   => 'Fade _Out',
                                                     active => FALSE,
                                                     tip    => 'Enable the fade out of the BIOS logo'});

    $gui{d}{Edit}{notebookSys} = Gtk3::Notebook->new();
    # Motherboard Tab
    $gui{d}{Edit}{notebookSys}->append_page(my $gridMother = gui_new_grid(), gui_new_widgetlabel({text => '_Motherboard'}));
    $gridMother->attach(gui_new_widgetlabel({text => 'Base Memor_y:', mnwidget => $gui{d}{Edit}{sbSysMemory}}), 0, 0, 1, 1);
    $gridMother->attach($gui{d}{Edit}{sbSysMemory}, 1, 0, 1, 1);
    $gridMother->attach(gui_new_widgetlabel({text => 'Boot _Order:', mnwidget => $gui{d}{Edit}{treeviewSysBoot}}), 0, 1, 1, 1);
    $gridMother->attach(my $gridBoot = gui_new_grid(), 1, 1, 1, 1);
    $gridBoot->attach(my $frame = gui_new_frame(), 0, 0, 1, 2);
    $frame->add($gui{d}{Edit}{treeviewSysBoot});
    $gridBoot->attach($gui{d}{Edit}{buttonSysBootup}, 1, 0, 1, 1);
    $gridBoot->attach($gui{d}{Edit}{buttonSysBootdown}, 1, 1, 1, 1);
    $gridMother->attach(gui_new_widgetlabel({text => 'C_hipset:', mnwidget => $gui{d}{Edit}{cboxSysChipset}}), 0, 2, 1, 1);
    $gridMother->attach($gui{d}{Edit}{cboxSysChipset}, 1, 2, 1, 1);
    $gridMother->attach(gui_new_widgetlabel({text => '_TPM:', mnwidget => $gui{d}{Edit}{cboxSysTPM}}), 0, 3, 1, 1);
    $gridMother->attach($gui{d}{Edit}{cboxSysTPM}, 1, 3, 1, 1);
    $gridMother->attach(gui_new_widgetlabel({text => 'Pointing _Device:', mnwidget => $gui{d}{Edit}{cboxSysPoint}}), 0, 4, 1, 1);
    $gridMother->attach($gui{d}{Edit}{cboxSysPoint}, 1, 4, 1, 1);
    $gridMother->attach(gui_new_widgetlabel({text => '_Keyboard:', mnwidget => $gui{d}{Edit}{cboxSysKeyboard}}), 0, 5, 1, 1);
    $gridMother->attach($gui{d}{Edit}{cboxSysKeyboard}, 1, 5, 1, 1);
    $gridMother->attach(gui_new_widgetlabel({text => 'Extended Features:', mnwidget => $gui{d}{Edit}{entryGenName}}), 0, 6, 1, 4);
    $gridMother->attach($gui{d}{Edit}{checkSysAPIC}, 1, 6, 1, 1);
    $gridMother->attach($gui{d}{Edit}{checkSysUTC}, 1, 7, 1, 1);
    $gridMother->attach($gui{d}{Edit}{checkSysEFI}, 1, 8, 1, 1);
    $gridMother->attach($gui{d}{Edit}{checkSysSecure}, 1, 9, 1, 1);
    $gridMother->attach($gui{d}{Edit}{buttonSysSecure}, 1, 10, 1, 1);
    # Processor Tab
    $gui{d}{Edit}{notebookSys}->append_page(my $gridProc = gui_new_grid(), gui_new_widgetlabel({text => '_Processor'}));
    $gridProc->attach(gui_new_widgetlabel({text => 'P_rocessors:', mnwidget => $gui{d}{Edit}{scaleSysProcessor}}), 0, 0, 1, 1);
    $gridProc->attach($gui{d}{Edit}{scaleSysProcessor}, 1, 0, 1, 1);
    $gridProc->attach(gui_new_widgetlabel({text => 'Execution _Cap:', mnwidget => $gui{d}{Edit}{scaleSysCap}}), 0, 1, 1, 1);
    $gridProc->attach($gui{d}{Edit}{scaleSysCap}, 1, 1, 1, 1);
    $gridProc->attach(gui_new_widgetlabel({text => 'Extended Features:'}), 0, 2, 1, 3);
    $gridProc->attach($gui{d}{Edit}{checkSysPAE}, 1, 2, 1, 1);
    $gridProc->attach($gui{d}{Edit}{checkSysVTX}, 1, 3, 1, 1);
    $gridProc->attach($gui{d}{Edit}{checkSysHot}, 1, 4, 1, 1);
    # Advanced Tab
    $gui{d}{Edit}{notebookSys}->append_page(my $gridAdv = gui_new_grid(), gui_new_widgetlabel({text => '_Advanced'}));
    $gridAdv->attach(gui_new_widgetlabel({text => '_Time Offset:', mnwidget => $gui{d}{Edit}{sbSysTime}}), 0, 0, 1, 1);
    $gridAdv->attach($gui{d}{Edit}{sbSysTime}, 1, 0, 1, 1);
    $gridAdv->attach(gui_new_widgetlabel({text => 'Extended Features:'}), 0, 1, 1, 3);
    $gridAdv->attach($gui{d}{Edit}{checkSysHPET}, 1, 1, 1, 1);
    $gridAdv->attach($gui{d}{Edit}{checkSysFusion}, 1, 2, 1, 1);
    $gridAdv->attach($gui{d}{Edit}{checkSysLargepages}, 1, 3, 1, 1);
    # Acceleration Tab
    $gui{d}{Edit}{notebookSys}->append_page(my $gridAcc = gui_new_grid(), gui_new_widgetlabel({text => 'A_cceleration'}));
    $gridAcc->attach(gui_new_widgetlabel({text => 'Paravirtualization _Interface:', mnwidget => $gui{d}{Edit}{cboxSysPara}}), 0, 0, 1, 1);
    $gridAcc->attach($gui{d}{Edit}{cboxSysPara}, 1, 0, 1, 1);
    $gridAcc->attach(gui_new_widgetlabel({text => 'Hardware Virtualization:'}), 0, 1, 1, 2);
    $gridAcc->attach($gui{d}{Edit}{checkSysNested}, 1, 1, 1, 1);
    $gridAcc->attach($gui{d}{Edit}{checkSysVPID}, 1, 2, 1, 1);
    # Boot Logo Tab
    $gui{d}{Edit}{notebookSys}->append_page(my $gridLogo = gui_new_grid(), gui_new_widgetlabel({text => '_Boot Logo'}));
    $gridLogo->attach(gui_new_widgetlabel({text => 'BIOS _Display Time:', mnwidget => $gui{d}{Edit}{sbSysLogotime}}), 0, 0, 1, 1);
    $gridLogo->attach($gui{d}{Edit}{sbSysLogotime}, 1, 0, 2, 1);
    $gridLogo->attach(gui_new_widgetlabel({text => 'BIOS Boot _Logo:', mnwidget => $gui{d}{Edit}{entrySysLogo}}), 0, 1, 1, 1);
    $gridLogo->attach($gui{d}{Edit}{entrySysLogo}, 1, 1, 1, 1);
    $gridLogo->attach($gui{d}{Edit}{buttonSysLogo}, 2, 1, 1, 1);
    $gridLogo->attach(gui_new_widgetlabel({text => 'Fade Logo:'}), 0, 2, 1, 2);
    $gridLogo->attach($gui{d}{Edit}{checkSysFadein}, 1, 2, 1, 1);
    $gridLogo->attach($gui{d}{Edit}{checkSysFadeout}, 1, 3, 1, 1);
    $gui{d}{Edit}{notebookSys}->show_all();
    # Signals
    $gui{d}{Edit}{notebookSys}->signal_connect('switch-page' => \&edit_sys_tabchanged);
    $gui{d}{Edit}{sbSysMemory}->signal_connect('input' => \&sb_bytes_in);
    $gui{d}{Edit}{sbSysMemory}->signal_connect('output' => \&sb_bytes_out);
    $gui{d}{Edit}{sbSysMemory}->signal_connect('value-changed' => \&sys_mother_mem);
    $celltoggle->signal_connect('toggled' => \&sys_mother_boot_dev_toggle);
    $signal{Edit_treeviewSysBoot_cursorchanged} = $gui{d}{Edit}{treeviewSysBoot}->signal_connect('cursor-changed' => \&sys_mother_boot_order);
    $gui{d}{Edit}{treeviewSysBoot}->signal_connect('cursor-changed' => \&sys_mother_sens_boot_sel);
    $gui{d}{Edit}{buttonSysBootup}->signal_connect('clicked' => \&sys_mother_boot_dev_up);
    $gui{d}{Edit}{buttonSysBootup}->signal_connect('clicked' => \&sys_mother_boot_order);
    $gui{d}{Edit}{buttonSysBootdown}->signal_connect('clicked' => \&sys_mother_boot_dev_down);
    $gui{d}{Edit}{buttonSysBootdown}->signal_connect('clicked' => \&sys_mother_boot_order);
    $gui{d}{Edit}{cboxSysChipset}->signal_connect('changed' => \&sys_mother_chipset);
    $signal{Edit_cboxSysTPM_changed} = $gui{d}{Edit}{cboxSysTPM}->signal_connect('changed' => \&sys_mother_tpm);
    $gui{d}{Edit}{cboxSysPoint}->signal_connect('changed' => \&sys_mother_pointer);
    $gui{d}{Edit}{cboxSysKeyboard}->signal_connect('changed' => \&sys_mother_keyboard);
    $gui{d}{Edit}{checkSysAPIC}->signal_connect('toggled' => \&sys_mother_ioapic);
    $gui{d}{Edit}{checkSysUTC}->signal_connect('toggled' => \&sys_mother_utc);
    $gui{d}{Edit}{checkSysEFI}->signal_connect('toggled' => \&sys_mother_efi);
    $signal{Edit_checkSysSecure_toggled} = $gui{d}{Edit}{checkSysSecure}->signal_connect('toggled' => \&sys_mother_secureboot);
    $gui{d}{Edit}{buttonSysSecure}->signal_connect('released' => \&sys_mother_restore_secureboot);
    $gui{d}{Edit}{scaleSysProcessor}->signal_connect('format-value' => sub { return " $_[1] vCPUs"; }); # Formats the slider value for the processors
    $gui{d}{Edit}{scaleSysProcessor}->signal_connect('value-changed' => \&sys_proc_count);
    $gui{d}{Edit}{scaleSysCap}->signal_connect('format-value' => sub { return " $_[1]% Max"; }); # Formats the slider for the execution cap
    $gui{d}{Edit}{scaleSysCap}->signal_connect('value-changed' => \&sys_proc_cap);
    $gui{d}{Edit}{checkSysPAE}->signal_connect('toggled' => \&sys_proc_pae);
    $gui{d}{Edit}{checkSysVTX}->signal_connect('toggled' => \&sys_proc_nested_vtx);
    $gui{d}{Edit}{checkSysHot}->signal_connect('toggled' => \&sys_proc_hotplug);
    $gui{d}{Edit}{sbSysTime}->signal_connect('input' => \&sb_time_ms_in);
    $gui{d}{Edit}{sbSysTime}->signal_connect('output' => \&sb_time_ms_out);
    $gui{d}{Edit}{sbSysTime}->signal_connect('value-changed' => \&sys_adv_time_offset);
    $gui{d}{Edit}{checkSysHPET}->signal_connect('toggled' => \&sys_adv_hpet);
    $gui{d}{Edit}{checkSysFusion}->signal_connect('toggled' => \&sys_adv_page_fusion);
    $gui{d}{Edit}{checkSysLargepages}->signal_connect('toggled' => \&sys_adv_large_pages);
    $gui{d}{Edit}{cboxSysPara}->signal_connect('changed' => \&sys_accel_paravirt);
    $gui{d}{Edit}{checkSysNested}->signal_connect('toggled' => \&sys_accel_nested_paging);
    $gui{d}{Edit}{checkSysVPID}->signal_connect('toggled' => \&sys_accel_vpid);
    $gui{d}{Edit}{sbSysLogotime}->signal_connect('input' => \&sb_time_ms_in);
    $gui{d}{Edit}{sbSysLogotime}->signal_connect('output' => \&sb_time_ms_out);
    $gui{d}{Edit}{sbSysLogotime}->signal_connect('value-changed' => \&sys_logo_disp_time);
    $gui{d}{Edit}{entrySysLogo}->signal_connect('activate' => \&sys_logo_path);
    $gui{d}{Edit}{entrySysLogo}->signal_connect('focus-out-event' => \&sys_logo_path);
    $gui{d}{Edit}{buttonSysLogo}->signal_connect('clicked' => \&show_remote_filechooser, {title       => 'Choose BIOS Logo',
                                                                                          entrywidget => \$gui{d}{Edit}{entrySysLogo},
                                                                                          mode        => 'file',
                                                                                          filter      => '^.*\.bmp$',
                                                                                          callback    => \&handle_bioslogofilechooser});
    $gui{d}{Edit}{checkSysFadein}->signal_connect('toggled' => \&sys_logo_fade_in);
    $gui{d}{Edit}{checkSysFadeout}->signal_connect('toggled' => \&sys_logo_fade_out);
    # Main Notebook
    $gui{d}{Edit}{notebook}->append_page(my $box = gui_new_box('vertical'), gui_new_imglabel({text => '_System', img => 'chipset_24px.png'}));
    $box->pack_start(gui_new_titlelabel({text => 'System'}), FALSE, FALSE, 2);
    $box->pack_start($gui{d}{Edit}{notebookSys}, TRUE, TRUE, 2);
}

sub build_dialogEditDisplay {
    # Screen Tab
    $gui{d}{Edit}{cboxDispController} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                           [0, 1],
                                                                                           [['<None>', 'Null'],
                                                                                            ['VBoxVGA (VirtualBox VGA)', 'VBoxVGA'],
                                                                                            ['VMSVGA (VMware SVGA II)', 'VMSVGA'],
                                                                                            ['VBoxSVGA (VirtualBox VGA + VMware SVGA II extensions)', 'VBoxSVGA']]),
                                                                 active => -1,
                                                                 tip    => 'Configure the type of virtualized graphics card'});

    $gui{d}{Edit}{scaleDispMemory} = gui_new_scale({adj       => my $adjDispMem = gui_new_adjustment(undef, 2, 2, 256, 1, 1, 0),
                                                     showvalue => TRUE,
                                                     decplaces => 0,
                                                     tip       => 'Amount of video memory assigned to the guest. This option consumes main memory on the host, not its video memory'});

    $gui{d}{Edit}{sbDispMemory} = gui_new_spinbutton({adj       => $adjDispMem,
                                                       lo        => 2,
                                                       hi        => 256,
                                                       inc       => 1,
                                                       decplaces => 0,
                                                       numeric   => FALSE,
                                                       tip       => 'Amount of video memory assigned to the guest. This option consumes main memory on the host, not its video memory'});

    $gui{d}{Edit}{scaleDispMonitor} = gui_new_scale({adj       => my $adjDispMon = gui_new_adjustment(undef, 0, 1, 64, 1, 1, 0),
                                                      showvalue => TRUE,
                                                      decplaces => 0,
                                                      tip       => 'The number of virtual monitors assigned to the guest. RemoteBox only supports connecting to the first monitor'});

    $gui{d}{Edit}{sbDispMonitor} = gui_new_spinbutton({adj       => $adjDispMon,
                                                        lo        => 1,
                                                        hi        => 64,
                                                        inc       => 1,
                                                        decplaces => 0,
                                                        tip       => 'The number of virtual monitors assigned to the guest. RemoteBox only supports connecting to the first monitor'});

    $gui{d}{Edit}{checkDisp3D} = gui_new_check({text   => 'Enable _3D Acceleration',
                                                 active => FALSE,
                                                 tip    => "Enable 3D (OpenGL / Direct X / Vulcan) hardware acceleration\n* Acceleration may not function over RDP connections\n* Only supported for Windows, Linux and Solaris guests"});
    # Remote Display Tab
    $gui{d}{Edit}{checkDispRemote} = gui_new_check({text   => '_Enable Remote Display Server (RDP/VNC)',
                                                     active => FALSE,
                                                     tip    => "Enable the RDP or VNC server for this guest\n* Allows remote control and display using an RDP or VNC client\n* Requires the Oracle or VNC Extension pack to be installed"});

    $gui{d}{Edit}{entryDispBind} = gui_new_entry({width  => 50,
                                                   maxlen => 253,
                                                   tip    => "Bind the RDP/VNC server to a specific IP address or hostname\n* If unsure, leave empty which means all IP addresses on the server"});

    $gui{d}{Edit}{entryDispPort} = gui_new_entry({width  => 50,
                                                   maxlen => 128,
                                                   tip    => "Port range the RDP/VNC server will use\n* If unsure, use: 3389-4389"});

    $gui{d}{Edit}{cboxDispRDPauth} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                        [0, 1],
                                                                                        [['No Authentication', 'Null'],
                                                                                         ['External', 'External'],
                                                                                         ['Guest', 'Guest']]),
                                                              active => -1,
                                                              tip    => 'RDP authentication method. Does not apply to VNC display connections'});

    $gui{d}{Edit}{sbDispRDPtimeout} = gui_new_spinbutton({lo        => 0,
                                                           hi        => 180000,
                                                           inc       => 1,
                                                           decplaces => 0,
                                                           numeric   => FALSE,
                                                           tip       => 'The authentication timeout value. Does not apply to VNC display connections'});

    #gui_new_adjustment($gui{d}{Edit}{sbDispRDPtimeout}, 0, 0, 10000, 1, 100, 0);
    $gui{d}{Edit}{checkDispRDPmultiple} = gui_new_check({text   => '_Allow Multiple RDP Connections',
                                                          active => FALSE,
                                                          tip    => 'Allows multiple simultaneous RDP connects to the same guest'});
    # Recording Tab
    $gui{d}{Edit}{checkDispRecording} = gui_new_check({text   => '_Enable Recording',
                                                        active => FALSE,
                                                        tip    => 'Record the audio and display of the guest to a movie file'});

    $gui{d}{Edit}{cboxDispRecordingmode} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                              [0, 1],
                                                                                              [['Audio & Video', 'videoaudio'],
                                                                                               ['Audio Only', 'audio'],
                                                                                               ['Video Only', 'video']]),
                                                                    active => -1,
                                                                    tip    => 'Record both audio and video or select only either'});

    $gui{d}{Edit}{entryDispRecordingpath} = gui_new_entry({width => 50,
                                                            tip   => "Location and filename on the server where the video will be recorded\n* Location must be absolute"});

    $gui{d}{Edit}{buttonDispRecordingpath} = gui_new_imgbutton({image => 'sf_16px.png',
                                                                 tip   => 'Choose the filename and location of the video file'});

    $gui{d}{Edit}{cboxDispRecordingsize} = gui_new_simplecombobox({model  => $gui{d}{Edit}{lstoreDispRecordingsize} = gui_new_lstore(['Glib::String', 'Glib::Uint', 'Glib::Uint'], [0, 1, 2], [['User Defined', 0, 0]]),
                                                                    active => -1,
                                                                    tip    => 'The resolution (frame size) of the recording'});

    $gui{d}{Edit}{sbDispRecordingw} = gui_new_spinbutton({lo        => 320,
                                                           hi        => 2880,
                                                           inc       => 16,
                                                           decplaces => 0,
                                                           numeric   => TRUE,
                                                           tip       => 'The horizontal resolution (frame width) of the recording'});

    gui_new_adjustment($gui{d}{Edit}{sbDispRecordingw}, 320, 16, 2880, 1, 10, 0);
    $gui{d}{Edit}{sbDispRecordingh} = gui_new_spinbutton({lo        => 200,
                                                           hi        => 1800,
                                                           inc       => 16,
                                                           decplaces => 0,
                                                           numeric   => TRUE,
                                                           tip       => 'The vertical resolution (frame height) of the recording'});

    gui_new_adjustment($gui{sbEditDispCaptureSizeH}, 200, 16, 1800, 1, 10, 0);
    $gui{d}{Edit}{scaleDispRecordingrate} = gui_new_scale({adj       => $gui{d}{Edit}{adjSysProcessor},
                                                            showvalue => TRUE,
                                                            decplaces => 0,
                                                            tip       => 'More frames per second produces smoother video at the expense of an increase in file size'});

    $gui{d}{Edit}{sbDispRecordingrate} = gui_new_spinbutton({lo        => 15,
                                                              hi        => 15,
                                                              inc       => 1,
                                                              decplaces => 0,
                                                              numeric   => TRUE,
                                                              tip       => 'More frames per second produces smoother video at the expense of an increase in file size'});

    $gui{d}{Edit}{scaleDispRecordingrate}->set_adjustment(gui_new_adjustment($gui{d}{Edit}{sbDispRecordingrate}, 15, 1, 30, 1, 5, 0));
    $gui{d}{Edit}{scaleDispRecordingVidqual} = gui_new_scale({adj       => $gui{d}{Edit}{adjSysProcessor},
                                                               showvalue => TRUE,
                                                               decplaces => 0,
                                                               tip       => 'The higher the video quality, the larger the file size'});

    $gui{d}{Edit}{sbDispRecordingVidqual} = gui_new_spinbutton({lo        => 128,
                                                                 hi        => 2048,
                                                                 inc       => 32,
                                                                 decplaces => 0,
                                                                 numeric   => TRUE,
                                                                 tip       => 'The higher the video quality, the larger the file size'});

    $gui{d}{Edit}{scaleDispRecordingVidqual}->set_adjustment(gui_new_adjustment($gui{d}{Edit}{sbDispRecordingVidqual}, 128, 32, 2048, 1, 10, 0));
    $gui{d}{Edit}{cboxDispAudqual} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                        [0, 1],
                                                                                        [['Low Quality', 'low'],
                                                                                         ['Medium Quality', 'med'],
                                                                                         ['High Quality', 'high']]),
                                                              active => -1,
                                                              tip    => 'The resolution (frame size) of the recording'});

    $gui{d}{Edit}{notebookDisp} = Gtk3::Notebook->new();
    # Screen Tab
    $gui{d}{Edit}{notebookDisp}->append_page(my $gridScr = gui_new_grid(), gui_new_widgetlabel({text => '_Screen'}));
    $gridScr->attach(gui_new_widgetlabel({text => '_Graphics Controller:', mnwidget => $gui{d}{Edit}{cboxDispController}}), 0, 0, 1, 1);
    $gridScr->attach($gui{d}{Edit}{cboxDispController}, 1, 0, 1, 1);
    $gridScr->attach(gui_new_widgetlabel({text => '_Video Memory:', mnwidget => $gui{d}{Edit}{sbDispMemory}}), 0, 1, 1, 1);
    $gridScr->attach(my $vmembox = gui_new_box('horizontal'), 1, 1, 1, 1);
    $vmembox->pack_start($gui{d}{Edit}{scaleDispMemory}, TRUE, TRUE, 2);
    $vmembox->pack_start($gui{d}{Edit}{sbDispMemory}, TRUE, TRUE, 2);
    $gridScr->attach(gui_new_widgetlabel({text => '_Monitor Count:', mnwidget => $gui{d}{Edit}{sbDispMonitor}}), 0, 2, 1, 1);
    $gridScr->attach(my $monbox = gui_new_box('horizontal'), 1, 2, 1, 1);
    $monbox->pack_start($gui{d}{Edit}{scaleDispMonitor}, TRUE, TRUE, 2);
    $monbox->pack_start($gui{d}{Edit}{sbDispMonitor}, TRUE, TRUE, 2);
    $gridScr->attach(gui_new_widgetlabel({text => 'Extended Features:'}), 0, 3, 1, 2);
    $gridScr->attach($gui{d}{Edit}{checkDisp3D}, 1, 3, 2, 1);
    # Remote Display Tab
    $gui{d}{Edit}{notebookDisp}->append_page(my $boxRemotedisp = gui_new_box('vertical'), gui_new_widgetlabel({text => 'Remote _Display'}));
    $boxRemotedisp->pack_start($gui{d}{Edit}{checkDispRemote}, FALSE, FALSE, 2);
    $boxRemotedisp->pack_start($gui{d}{Edit}{gridDispRemote} = gui_new_grid(), TRUE, TRUE, 2);
    $gui{d}{Edit}{gridDispRemote}->attach(gui_new_widgetlabel({text => '_Bind Server to IP:', mnwidget => $gui{d}{Edit}{entryDispBind}}), 0, 0, 1, 1);
    $gui{d}{Edit}{gridDispRemote}->attach($gui{d}{Edit}{entryDispBind}, 1, 0, 1, 1);
    $gui{d}{Edit}{gridDispRemote}->attach(gui_new_widgetlabel({text => 'Server _Port:', mnwidget => $gui{d}{Edit}{entryDispPort}}), 0, 1, 1, 1);
    $gui{d}{Edit}{gridDispRemote}->attach($gui{d}{Edit}{entryDispPort}, 1, 1, 1, 1);
    $gui{d}{Edit}{gridDispRemote}->attach(gui_new_widgetlabel({text => 'RDP Authentication _Method:', mnwidget => $gui{d}{Edit}{cboxDispController}}), 0, 2, 1, 1);
    $gui{d}{Edit}{gridDispRemote}->attach($gui{d}{Edit}{cboxDispRDPauth}, 1, 2, 1, 1);
    $gui{d}{Edit}{gridDispRemote}->attach(gui_new_widgetlabel({text => 'RDP Authentication _Timeout:', mnwidget => $gui{d}{Edit}{cboxDispController}}), 0, 3, 1, 1);
    $gui{d}{Edit}{gridDispRemote}->attach($gui{d}{Edit}{sbDispRDPtimeout}, 1, 3, 1, 1);
    $gui{d}{Edit}{gridDispRemote}->attach($gui{d}{Edit}{checkDispRDPmultiple}, 1, 4, 1, 1);
    # Recording Tab
    $gui{d}{Edit}{notebookDisp}->append_page(my $boxRecording = gui_new_box('vertical'), gui_new_widgetlabel({text => '_Recording'}));
    $boxRecording->pack_start($gui{d}{Edit}{checkDispRecording}, FALSE, FALSE, 2);
    $boxRecording->pack_start($gui{d}{Edit}{gridDispRecording} = gui_new_grid(), TRUE, TRUE, 2);
    $gui{d}{Edit}{gridDispRecording}->attach(gui_new_widgetlabel({text => 'Recording _Mode:', mnwidget => $gui{d}{Edit}{cboxDispRecordingmode}}), 0, 0, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach($gui{d}{Edit}{cboxDispRecordingmode}, 1, 0, 3, 1);
    $gui{d}{Edit}{gridDispRecording}->attach(gui_new_widgetlabel({text => 'File _Path:', mnwidget => $gui{d}{Edit}{entryDispRecordingpath}}), 0, 1, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach($gui{d}{Edit}{entryDispRecordingpath}, 1, 1, 2, 1);
    $gui{d}{Edit}{gridDispRecording}->attach($gui{d}{Edit}{buttonDispRecordingpath}, 3, 1, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach(gui_new_widgetlabel({text => 'Frame Si_ze:', mnwidget => $gui{d}{Edit}{cboxDispRecordingsize}}), 0, 2, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach($gui{d}{Edit}{cboxDispRecordingsize}, 1, 2, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach($gui{d}{Edit}{sbDispRecordingw}, 2, 2, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach($gui{d}{Edit}{sbDispRecordingh}, 3, 2, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach(gui_new_widgetlabel({text => '_Frame Rate:', mnwidget => $gui{d}{Edit}{sbDispRecordingrate}}), 0, 3, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach($gui{d}{Edit}{scaleDispRecordingrate}, 1, 3, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach($gui{d}{Edit}{sbDispRecordingrate}, 2, 3, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach(gui_new_widgetlabel({text => 'fps'}), 3, 3, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach(gui_new_widgetlabel({text => '_Video Quality:', mnwidget => $gui{d}{Edit}{sbDispRecordingVidqual}}), 0, 4, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach($gui{d}{Edit}{scaleDispRecordingVidqual}, 1, 4, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach($gui{d}{Edit}{sbDispRecordingVidqual}, 2, 4, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach(gui_new_widgetlabel({text => 'kbps'}), 3, 4, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach(gui_new_widgetlabel({text => '_Audio Quality:', mnwidget => $gui{d}{Edit}{cboxDispAudqual}}), 0, 5, 1, 1);
    $gui{d}{Edit}{gridDispRecording}->attach($gui{d}{Edit}{cboxDispAudqual}, 1, 5, 3, 1);
    $gui{d}{Edit}{notebookDisp}->show_all();
    # Signals
    $gui{d}{Edit}{notebookDisp}->signal_connect('switch-page' => \&edit_disp_tabchanged);
    $gui{d}{Edit}{cboxDispController}->signal_connect('changed' => \&disp_scr_VGA);
    $gui{d}{Edit}{sbDispMemory}->signal_connect('input' => \&sb_bytes_in);
    $gui{d}{Edit}{sbDispMemory}->signal_connect('output' => \&sb_bytes_out);
    $gui{d}{Edit}{sbDispMemory}->signal_connect('value-changed' => \&disp_scr_vid_mem);
    $gui{d}{Edit}{sbDispMonitor}->signal_connect('value-changed' => \&disp_scr_monitors);
    $gui{d}{Edit}{checkDisp3D}->signal_connect('toggled' => \&disp_scr_3D);
    $gui{d}{Edit}{checkDispRemote}->signal_connect('toggled' => \&disp_toggleRemote);
    $gui{d}{Edit}{entryDispBind}->signal_connect('activate' => \&disp_rem_bind);
    $gui{d}{Edit}{entryDispBind}->signal_connect('focus-out-event' => \&disp_rem_bind);
    $gui{d}{Edit}{entryDispPort}->signal_connect('activate' => \&disp_rem_ports);
    $gui{d}{Edit}{entryDispPort}->signal_connect('focus-out-event' => \&disp_rem_ports);
    $gui{d}{Edit}{cboxDispRDPauth}->signal_connect('changed' => \&disp_rem_auth);
    $gui{d}{Edit}{checkDispRDPmultiple}->signal_connect('toggled' => \&disp_rem_multi);
    $gui{d}{Edit}{sbDispRDPtimeout}->signal_connect('input' => \&sb_time_ms_in);
    $gui{d}{Edit}{sbDispRDPtimeout}->signal_connect('output' => \&sb_time_ms_out);
    $gui{d}{Edit}{sbDispRDPtimeout}->signal_connect('value-changed' => \&disp_rem_timeout);
    $gui{d}{Edit}{checkDispRecording}->signal_connect('toggled' => \&disp_toggleCapture);
    $gui{d}{Edit}{cboxDispRecordingmode}->signal_connect('changed' => \&disp_cap_mode);
    $gui{d}{Edit}{entryDispRecordingpath}->signal_connect('activate' => \&disp_cap_path);
    $gui{d}{Edit}{entryDispRecordingpath}->signal_connect('focus-out-event' => \&disp_cap_path);
    $gui{d}{Edit}{buttonDispRecordingpath}->signal_connect('clicked' => \&show_remote_filechooser, {title       => 'Choose Capture File',
                                                                                                    entrywidget => \$gui{d}{Edit}{entryDispRecordingpath},
                                                                                                    mode        => 'file',
                                                                                                    filter      => '.*',
                                                                                                    callback    => \&handle_videofilechooser});
    $gui{d}{Edit}{cboxDispRecordingsize}->signal_connect('changed' => \&disp_cap_size);
    $gui{d}{Edit}{sbDispRecordingw}->signal_connect('value-changed' => \&disp_cap_size_w);
    $gui{d}{Edit}{sbDispRecordingh}->signal_connect('value-changed' => \&disp_cap_size_h);
    $gui{d}{Edit}{sbDispRecordingrate}->signal_connect('value-changed' => \&disp_cap_fps);
    $gui{d}{Edit}{sbDispRecordingVidqual}->signal_connect('value-changed' => \&disp_cap_vidrate);
    $gui{d}{Edit}{cboxDispAudqual}->signal_connect('changed' => \&disp_cap_audio_quality);
    $gui{d}{Edit}{entryDispPort}->signal_connect('changed' => \&valid_portrange_char);
    # Main Notebook
    $gui{d}{Edit}{notebook}->append_page(my $box = gui_new_box('vertical'), gui_new_imglabel({text => '_Display', img => 'vrdp_24px.png'}));
    $box->pack_start(gui_new_titlelabel({text => 'Display'}), FALSE, FALSE, 2);
    $box->pack_start($gui{d}{Edit}{notebookDisp}, TRUE, TRUE, 2);

    my $fsiter;
    # Populate the liststore for the framesize for video capture
    foreach my $res (@{get_scr_res_tbl()}) {
        $fsiter = $gui{d}{Edit}{lstoreDispRecordingsize}->append;
        $gui{d}{Edit}{lstoreDispRecordingsize}->set($fsiter, [0, 1, 2], ["$$res{w}x$$res{h} ($$res{aspx}:$$res{aspy})", $$res{w}, $$res{h}]);
    }
}

sub build_dialogEditStorage {
    my ($sas_ports, $sata_ports, $scsi_ports, $usb_ports, $virt_ports, $nvme_ports) = [];
    for my $port (0..7) { push @{$usb_ports}, ["USB Port $port", 0, $port]; }

    for my $port (0..29) {
        push @{$sata_ports}, ["SATA Port $port", 0, $port];
        push @{$scsi_ports}, ["SCSI Port $port", 0, $port];
    }

    for my $port (0..254) {
        push @{$virt_ports}, ["Virtio-SCSI Port $port", 0, $port];
        push @{$nvme_ports}, ["NVME Port $port", 0, $port];
        push @{$sas_ports}, ["SAS Port $port", 0, $port];
    }
    # Device Ports
    $gui{liststoreEditStorDevPortSAS} = gui_new_lstore(['Glib::String', 'Glib::Uint', 'Glib::Uint'], [0, 1, 2], $sas_ports);
    $gui{liststoreEditStorDevPortSATA} = gui_new_lstore(['Glib::String', 'Glib::Uint', 'Glib::Uint'], [0, 1, 2], $sata_ports);
    $gui{liststoreEditStorDevPortSCSI} = gui_new_lstore(['Glib::String', 'Glib::Uint', 'Glib::Uint'], [0, 1, 2], $scsi_ports);
    $gui{liststoreEditStorDevPortUSB} = gui_new_lstore(['Glib::String', 'Glib::Uint', 'Glib::Uint'], [0, 1, 2], $usb_ports);
    $gui{liststoreEditStorDevPortNVMe} = gui_new_lstore(['Glib::String', 'Glib::Uint', 'Glib::Uint'], [0, 1, 2], $nvme_ports);
    $gui{liststoreEditStorDevPortVirtio} = gui_new_lstore(['Glib::String', 'Glib::Uint', 'Glib::Uint'], [0, 1, 2], $virt_ports);
    $gui{liststoreEditStorDevPortIDE} = gui_new_lstore(['Glib::String', 'Glib::Uint', 'Glib::Uint'],
                                                        [0, 1, 2],
                                                        [['Primary Master', 0, 0],
                                                         ['Primary Slave', 1, 0],
                                                         ['Secondary Master', 0, 1],
                                                         ['Secondary Slave', 1, 1]]);

    $gui{liststoreEditStorDevPortFloppy} = gui_new_lstore(['Glib::String', 'Glib::Uint', 'Glib::Uint'],
                                                           [0, 1, 2],
                                                           [['Floppy Drive A', 0, 0],
                                                           ['Floppy Drive B', 1, 0]]);
    # Controller Types
    $gui{liststoreEditStorIDECtrType} = gui_new_lstore(['Glib::String', 'Glib::String'],
                                                        [0, 1],
                                                        [['PIIX3', 'PIIX3'],
                                                         ['PIIX4', 'PIIX4'],
                                                         ['ICH6', 'ICH6']]);

    $gui{liststoreEditStorSCSICtrType} = gui_new_lstore(['Glib::String', 'Glib::String'],
                                                         [0, 1],
                                                         [['LSI Logic', 'LsiLogic'],
                                                          ['BusLogic', 'BusLogic']]);

    $gui{liststoreEditStorNVMeCtrType} = gui_new_lstore(['Glib::String', 'Glib::String'], [0, 1], [['NVMe', 'NVMe']]);
    $gui{liststoreEditStorSASCtrType} = gui_new_lstore(['Glib::String', 'Glib::String'], [0, 1],  [['LSI Logic SAS', 'LsiLogicSas']]);
    $gui{liststoreEditStorSATACtrType} = gui_new_lstore(['Glib::String', 'Glib::String'], [0, 1], [['AHCI', 'IntelAhci']]);
    $gui{liststoreEditStorFloppyCtrType} = gui_new_lstore(['Glib::String', 'Glib::String'], [0, 1], [['I82078', 'I82078']]);
    $gui{liststoreEditStorUSBCtrType} = gui_new_lstore(['Glib::String', 'Glib::String'], [0, 1], [['USB', 'USB']]);
    $gui{liststoreEditStorVirtioSCSICtrType} = gui_new_lstore(['Glib::String', 'Glib::String'], [0, 1], [['Virtio-SCSI', 'VirtioSCSI']]);

    $gui{d}{Edit}{treeviewStorage} = gui_new_treeview({model   => $gui{d}{Edit}{tstoreStorage} = gui_new_tstore(['Glib::String', 'Glib::String', 'Glib::String', 'Glib::Uint', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::Uint', 'Glib::Uint', 'Glib::String', 'Gtk3::Gdk::Pixbuf']),
                                                        headers => FALSE,
                                                        tip     => 'Storage controllers and media attached to this guest'});

    $gui{d}{Edit}{treeviewStorage}->append_column(gui_new_treeviewcolumn({title   => '',
                                                                           type    => 'pixbuf',
                                                                           typecol => 12}));

    $gui{d}{Edit}{treeviewStorage}->append_column(gui_new_treeviewcolumn({title   => 'Name',
                                                                           type    => 'text',
                                                                           typecol => 0}));

    my $buttonAddCtr = gui_new_imgbutton({image => 'controller_add_16px.png',
                                           tip   => 'Add a new controller'});

    $gui{d}{Edit}{buttonStorageRemovectr} = gui_new_imgbutton({image => 'controller_remove_16px.png',
                                                                tip   => 'Remove selected controller'});

    $gui{d}{Edit}{buttonStorageAddattach} = gui_new_imgbutton({image => 'attachment_add_16px.png',
                                                                tip   => 'Attach a storage medium'});

    $gui{d}{Edit}{buttonStorageRemoveattach} = gui_new_imgbutton({image => 'attachment_remove_16px.png',
                                                                   tip   => 'Remove a storage medium'});

    $gui{d}{Edit}{entryStorageName} = gui_new_entry({width  => 20,
                                                      tip    => 'Name of the controller'});

    $gui{d}{Edit}{entryStorageName}->set_editable(FALSE);
    $gui{d}{Edit}{cboxStorageCtrtype} = gui_new_simplecombobox({active => -1,
                                                                 tip    => 'The variant of controller to use'});

    $gui{d}{Edit}{sbStoragePortcount} = gui_new_spinbutton({lo        => 1,
                                                             hi        => 30,
                                                             inc       => 1,
                                                             decplaces => 0,
                                                             numeric   => TRUE,
                                                             tip       => "Set the number of Controller Ports\n* Setting the port count lower than the number of attached storage devices will disable the storage for the guest"});

    $gui{d}{Edit}{adjStoragePortcount} = $gui{d}{Edit}{sbStoragePortcount}->get_adjustment();

    $gui{d}{Edit}{checkStorageIOcache} = gui_new_check({text   => '_Use the host I/O cache',
                                                         active => FALSE,
                                                         tip    => 'Use the I/O caching capability of the host'});

    $gui{d}{Edit}{cboxStorageConnectedport} = gui_new_simplecombobox({active => -1,
                                                                       tip    => 'The device and port on the controller that the medium is attached to'});

    $gui{d}{Edit}{checkStorageSolidstate} = gui_new_check({text   => '_Solid-State Drive',
                                                            active => FALSE,
                                                            tip    => 'When selected the disk appears to the guest as a solid-state drive (SSD)'});

    $gui{d}{Edit}{checkStorageLivedisc} = gui_new_check({text   => '_Live Disc',
                                                          active => FALSE,
                                                          tip    => 'Indicates a Live CD/DVD. The disc will not be ejected when requested by the operating system'});

    $gui{d}{Edit}{checkStorageHotplug} = gui_new_check({text   => '_Hot Pluggable',
                                                         active => FALSE,
                                                         tip    => 'Indicates to the operating system that this is a hot-pluggable disk'});

    $gui{d}{Edit}{checkStorageBootable} = gui_new_check({text   => 'Controller _Bootable',
                                                          active => FALSE,
                                                          tip    => 'Toggles boot support for this controller'});

    $gui{d}{Edit}{cboxStorageFloppytype} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                              [0, 1],
                                                                                              [['5¼" 360KB Floppy', 'Floppy 360'],
                                                                                               ['3½" 720KB Floppy', 'Floppy 720'],
                                                                                               ['5¼" 1.2MB Floppy', 'Floppy 1.20'],
                                                                                               ['3½" 1.44MB Floppy', 'Floppy 1.44'],
                                                                                               ['3½" 2.88MB Floppy', 'Floppy 2.88'],
                                                                                               ['Fake 15.6MB Floppy', 'Floppy 15.6'],
                                                                                               ['Fake 63.5MB Floppy', 'Floppy 63.5']]),
                                                                    active => -1,
                                                                    tip    => 'The type of floppy drive'});
    # Popup Menu
    $gui{menu}{CtrAdd} = gui_new_menu();
    my $miCtrAddIDE = gui_new_menu_item('_IDE Controller', 'ide_add_16px.png', $gui{menu}{CtrAdd});
    my $miCtrAddSCSI = gui_new_menu_item('_SCSI Controller', 'scsi_add_16px.png', $gui{menu}{CtrAdd});
    my $miCtrAddSATA = gui_new_menu_item('SA_TA Controller', 'sata_add_16px.png', $gui{menu}{CtrAdd});
    my $miCtrAddSAS = gui_new_menu_item('S_AS Controller', 'sata_add_16px.png', $gui{menu}{CtrAdd});
    my $miCtrAddFloppy = gui_new_menu_item('_Floppy Controller', 'floppy_add_16px.png', $gui{menu}{CtrAdd});
    my $miCtrAddUSB = gui_new_menu_item('_USB Controller', 'usb_add_16px.png', $gui{menu}{CtrAdd});
    my $miCtrAddNVMe = gui_new_menu_item('_NVMe (PCIe) Controller', 'nvme_add_16px.png', $gui{menu}{CtrAdd});
    my $miCtrAddVirtioSCSI = gui_new_menu_item('_Virtio-SCSI Controller', 'virtio_scsi_add_16px.png', $gui{menu}{CtrAdd});
    $gui{d}{Edit}{notebook}->append_page(my $vbox = gui_new_box('vertical'), gui_new_imglabel({text => '_Storage', img => 'hd_24px.png'}));
    $vbox->pack_start(gui_new_titlelabel({text => 'Storage'}), FALSE, FALSE, 2);
    $vbox->pack_start(my $hbox = gui_new_box('horizontal'), TRUE, TRUE, 2);
    $vbox->pack_start(my $bbox = gui_new_box('horizontal'), FALSE, FALSE, 2);
    $vbox->pack_start(gui_new_warnlabel({text => 'Attaching storage explicitly saves settings'}), FALSE, FALSE, 2);
    $hbox->pack_start(my $frame = gui_new_frame({label => 'Media'}), TRUE, TRUE, 2);
    $frame->add(my $scrollwin = gui_new_scrolledwindow());
    $hbox->pack_start($gui{d}{Edit}{gridStorageattr} = gui_new_grid(), TRUE, TRUE, 2);
    $scrollwin->add($gui{d}{Edit}{treeviewStorage});
    $bbox->pack_start($buttonAddCtr, FALSE, FALSE, 0);
    $bbox->pack_start($gui{d}{Edit}{buttonStorageRemovectr}, FALSE, FALSE, 0);
    $bbox->pack_start($gui{d}{Edit}{buttonStorageAddattach}, FALSE, FALSE, 0);
    $bbox->pack_start($gui{d}{Edit}{buttonStorageRemoveattach}, FALSE, FALSE, 0);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{labelStorageName} = gui_new_widgetlabel({text => 'Name:'}), 0, 0, 1, 1);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{entryStorageName}, 1, 0, 1, 1);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{labelStorageCtrtype} = gui_new_widgetlabel({text => '_Type:', mnwidget => $gui{d}{Edit}{cboxStorageCtrtype}}), 0, 1, 1, 1);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{cboxStorageCtrtype}, 1, 1, 1, 1);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{labelPortcount} = gui_new_widgetlabel({text => '_Port Count:', mnwidget => $gui{d}{Edit}{sbStoragePortcount}}), 0, 2, 1, 1);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{sbStoragePortcount}, 1, 2, 1, 1);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{checkStorageIOcache}, 1, 3, 1, 1);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{labelStorageConnectedport} = gui_new_widgetlabel({text => '_Connected Port:', mnwidget => $gui{d}{Edit}{cboxStorageConnectedport}}), 0, 4, 1, 1);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{cboxStorageConnectedport}, 1, 4, 1, 1);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{checkStorageSolidstate}, 1, 5, 1, 1);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{checkStorageLivedisc}, 1, 6, 1, 1);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{checkStorageHotplug}, 1, 7, 1, 1);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{checkStorageBootable}, 1, 8, 1, 1);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{labelStorageFloppytype} = gui_new_widgetlabel({text => '_Drive Type:', mnwidget => $gui{d}{Edit}{cboxStorageFloppytype}}), 0, 9, 1, 1);
    $gui{d}{Edit}{gridStorageattr}->attach($gui{d}{Edit}{cboxStorageFloppytype}, 1, 9, 1, 1);
    # Signals
    $signal{Edit_treeviewStorage_cursorchanged} = $gui{d}{Edit}{treeviewStorage}->signal_connect('cursor-changed' => \&onsel_list_editstorage);
    $buttonAddCtr->signal_connect('button-release-event' => \&show_ctr_menu);
    $gui{d}{Edit}{buttonStorageRemovectr}->signal_connect('clicked' => \&storage_ctr_rem);
    $gui{d}{Edit}{buttonStorageAddattach}->signal_connect('button-release-event' => \&show_attach_menu);
    $gui{d}{Edit}{buttonStorageRemoveattach}->signal_connect('clicked' => \&storage_attach_rem);
    $signal{Edit_cboxStorageCtrtype_changed} = $gui{d}{Edit}{cboxStorageCtrtype}->signal_connect('changed' => \&storage_ctr_type);
    $gui{d}{Edit}{sbStoragePortcount}->signal_connect('value-changed' => \&storage_port_count);
    $gui{d}{Edit}{checkStorageIOcache}->signal_connect('toggled' => \&storage_ctr_cache);
    $gui{d}{Edit}{cboxStorageConnectedport}->signal_connect('changed' => \&storage_connected_port);
    $gui{d}{Edit}{checkStorageSolidstate}->signal_connect('toggled' => \&storage_ssd);
    $gui{d}{Edit}{checkStorageLivedisc}->signal_connect('toggled' => \&storage_livecd);
    $gui{d}{Edit}{checkStorageHotplug}->signal_connect('toggled' => \&storage_hot_pluggable);
    $gui{d}{Edit}{checkStorageBootable}->signal_connect('toggled' => \&storage_ctr_bootable);
    $gui{d}{Edit}{cboxStorageFloppytype}->signal_connect('changed' => \&storage_floppy_type);
    $miCtrAddFloppy->signal_connect('activate' => \&storage_ctr_add, 'Floppy');
    $miCtrAddIDE->signal_connect('activate' => \&storage_ctr_add, 'IDE');
    $miCtrAddNVMe->signal_connect('activate' => \&storage_ctr_add, 'PCIe');
    $miCtrAddSAS->signal_connect('activate' => \&storage_ctr_add, 'SAS');
    $miCtrAddSATA->signal_connect('activate' => \&storage_ctr_add, 'SATA');
    $miCtrAddSCSI->signal_connect('activate' => \&storage_ctr_add, 'SCSI');
    $miCtrAddUSB->signal_connect('activate' => \&storage_ctr_add, 'USB');
    $miCtrAddVirtioSCSI->signal_connect('activate' => \&storage_ctr_add, 'VirtioSCSI');
}

sub build_dialogEditAudio {
    $gui{liststoreEditAudioDriverFreeBSD} = gui_new_lstore(['Glib::String', 'Glib::String'],
                                                            [0, 1],
                                                            [['Dummy Audio Driver', 'Null'],
                                                             ['Default', 'Default'],
                                                             ['OSS (Open Sound System)', 'OSS']]);

    $gui{liststoreEditAudioDriverLin} = gui_new_lstore(['Glib::String', 'Glib::String'],
                                                        [0, 1],
                                                        [['Dummy Audio Driver', 'Null'],
                                                         ['Default', 'Default'],
                                                         ['ALSA (Advanced Linux Sound Architecture)','ALSA'],
                                                         ['OSS (Open Sound System)', 'OSS'],
                                                         ['PulseAudio', 'Pulse']]);

    $gui{liststoreEditAudioDriverMac} = gui_new_lstore(['Glib::String', 'Glib::String'],
                                                        [0, 1],
                                                        [['Dummy Audio Driver','Null'],
                                                         ['Default', 'Default'],
                                                         ['CoreAudio', 'CoreAudio']]);

    $gui{liststoreEditAudioDriverOther} = gui_new_lstore(['Glib::String', 'Glib::String'],
                                                          [0, 1],
                                                          [['Dummy Audio Driver', 'Null'],
                                                           ['Default', 'Default']]);

    $gui{liststoreEditAudioDriverSol} = gui_new_lstore(['Glib::String', 'Glib::String'],
                                                        [0, 1],
                                                        [['Dummy Audio Driver', 'Null'],
                                                         ['OSS (Open Sound System)', 'OSS'],
                                                         ['Default', 'Default']]);

    $gui{liststoreEditAudioDriverWin} = gui_new_lstore(['Glib::String', 'Glib::String'],
                                                        [0, 1],
                                                        [['Dummy Audio Driver', 'Null'],
                                                         ['Default', 'Default'],
                                                         ['DirectSound', 'DirectSound'],
                                                         ['WAS (Windows Audio Session)', 'WAS']]);

    $gui{liststoreEditAudioCodecAC97} = gui_new_lstore(['Glib::String', 'Glib::String'],
                                                        [0, 1],
                                                        [['STAC9700', 'STAC9700'],
                                                        ['AD1980 (Recommended for Linux)', 'AD1980']]);

    # Note, these liststore names are used by joining  liststoreEditAudioCodec + $controller
    $gui{liststoreEditAudioCodecSB16} = gui_new_lstore(['Glib::String', 'Glib::String'], [0, 1], [['SB16', 'SB16']]);
    $gui{liststoreEditAudioCodecHDA} = gui_new_lstore(['Glib::String', 'Glib::String'], [0, 1], [['STAC9221', 'STAC9221']]);

    $gui{d}{Edit}{checkAudio} = gui_new_check({text   => '_Enable Audio',
                                                active => FALSE,
                                                tip    => 'Enable a virtual sound card'});

    $gui{d}{Edit}{cboxAudioDriver} = gui_new_simplecombobox({model  => $gui{liststoreEditAudioDriverOther},
                                                              active => -1,
                                                              tip    => 'The host audio driver to use'});

    $gui{d}{Edit}{cboxAudioController} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                            [0, 1],
                                                                                            [['HDA (Intel High Definition Audio)', 'HDA'],
                                                                                             ['Intel ICH AC97', 'AC97'],
                                                                                             ['SoundBlaster 16', 'SB16']]),
                                                                                             #['VirtioSound', 'VirtioSound']]), Is this actuall supported yet?
                                                                  active => -1,
                                                                  tip    => 'The virtual sound card presented to the guest'});

    $gui{d}{Edit}{cboxAudioCodec} = gui_new_simplecombobox({model  => $gui{liststoreEditAudioCodecHDA},
                                                             active => -1,
                                                             tip    => 'The codec the audio controller should use'});

    $gui{d}{Edit}{checkAudioInput} = gui_new_check({text   => 'Enable Audio _Input',
                                                     active => FALSE,
                                                     tip    => 'Enables the audio input (e.g. microphone) for the guest\'s soundcard'});

    $gui{d}{Edit}{checkAudioOutput} = gui_new_check({text   => 'Enable Audio _Output',
                                                      active => FALSE,
                                                      tip    => 'Enables audio output for the guest\'s soundcard. If disabled the guest will not output sound'});

    $gui{d}{Edit}{notebook}->append_page(my $audioBox = gui_new_box('vertical'), gui_new_imglabel({text => '_Audio', img => 'sound_24px.png'}));
    $audioBox->pack_start(gui_new_titlelabel({text => 'Audio'}), FALSE, FALSE, 2);
    $audioBox->pack_start($gui{d}{Edit}{checkAudio}, FALSE, FALSE, 2);
    $audioBox->pack_start($gui{d}{Edit}{gridAudioTop} = gui_new_grid(), FALSE, FALSE, 2);
    $gui{d}{Edit}{gridAudioTop}->attach(gui_new_widgetlabel({text => '_Host Audio Driver:', mnwidget => $gui{d}{Edit}{cboxAudioDriver}}), 0, 0, 1, 1);
    $gui{d}{Edit}{gridAudioTop}->attach($gui{d}{Edit}{cboxAudioDriver}, 1, 0, 1, 1);
    $gui{d}{Edit}{gridAudioTop}->attach(gui_new_widgetlabel({text => 'Audio _Controller:', mnwidget => $gui{d}{Edit}{cboxAudioController}}), 0, 1, 1, 1);
    $gui{d}{Edit}{gridAudioTop}->attach($gui{d}{Edit}{cboxAudioController}, 1, 1, 1, 1);
    $gui{d}{Edit}{gridAudioTop}->attach(gui_new_widgetlabel({text => 'Audio Co_dec:', mnwidget => $gui{d}{Edit}{cboxAudioCodec}}), 0, 2, 1, 1);
    $gui{d}{Edit}{gridAudioTop}->attach($gui{d}{Edit}{cboxAudioCodec}, 1, 2, 1, 1);
    $audioBox->pack_start($gui{d}{Edit}{gridAudioBottom} = gui_new_grid(), FALSE, FALSE, 2);
    $gui{d}{Edit}{gridAudioBottom}->attach(gui_new_widgetlabel({text => 'Audio Input/Output:'}), 0, 0, 1, 2);
    $gui{d}{Edit}{gridAudioBottom}->attach($gui{d}{Edit}{checkAudioInput}, 1, 0, 1, 1);
    $gui{d}{Edit}{gridAudioBottom}->attach($gui{d}{Edit}{checkAudioOutput}, 1, 1, 1, 1);
    # Signals
    $gui{d}{Edit}{checkAudio}->signal_connect('toggled' => \&audio_toggle);
    $signal{Edit_cboxAudioDriver_changed} = $gui{d}{Edit}{cboxAudioDriver}->signal_connect('changed' => \&audio_driver);
    $signal{Edit_cboxAudioController_changed} = $gui{d}{Edit}{cboxAudioController}->signal_connect('changed' => \&audio_ctr);
    $signal{Edit_cboxAudioCodec_changed} = $gui{d}{Edit}{cboxAudioCodec}->signal_connect('changed' => \&audio_codec);
    $gui{d}{Edit}{checkAudioInput}->signal_connect('toggled' => \&audio_input_toggle);
    $gui{d}{Edit}{checkAudioOutput}->signal_connect('toggled' => \&audio_output_toggle);
}

sub build_dialogEditNetwork {
    $gui{d}{Edit}{cboxNetwork} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::Uint'],
                                                                                    [0, 1],
                                                                                    [['Adapter 1', 0],
                                                                                     ['Adapter 2', 1],
                                                                                     ['Adapter 3', 2],
                                                                                     ['Adapter 4', 3],
                                                                                     ['Adapter 5', 4],
                                                                                     ['Adapter 6', 5],
                                                                                     ['Adapter 7', 6],
                                                                                     ['Adapter 8', 7]]),
                                                          active => 0,
                                                          tip    => 'Choose the virtual network adapter'});

    $gui{d}{Edit}{checkNetwork} = gui_new_check({text => '_Enable Network Adapter',
                                                  active => FALSE,
                                                  tip    => 'Enable this virtual network adapater in the guest'});

    $gui{d}{Edit}{cboxNetworkAttached} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                            [0, 1],
                                                                                            [['Not Attached', 'Null'],
                                                                                             ['NAT (General)', 'NAT'],
                                                                                             ['NAT (Named Network)', 'NATNetwork'],
                                                                                             ['Bridged Network', 'Bridged'],
                                                                                             ['Internal Network', 'Internal'],
                                                                                             ['Host Only', 'HostOnly'],
                                                                                             ['Generic Driver', 'Generic'],
                                                                                             ['Cloud Network (Unsupported)', 'Cloud']]),
                                                                  active => -1,
                                                                  tip    => 'The method used to connect the virtual network adapter to the network'});

    $gui{d}{Edit}{cboxNetworkName} = gui_new_simplecombobox({model  => $gui{d}{Edit}{lstoreNetworkName} = gui_new_lstore(['Glib::String', 'Glib::String']),
                                                              active => -1,
                                                              tip    => 'The host network adapter the virtual network adapter should use'});

    $gui{d}{Edit}{ecboxNetworkInternal} = gui_new_entrycombobox({model  => $gui{d}{Edit}{lstoreNetworkInternal} = gui_new_lstore(['Glib::String']),
                                                                  active => -1,
                                                                  tip    => 'The name of the internal network the virtual adapter should be connected to.'});

    $gui{d}{Edit}{ecboxNetworkGeneric} = gui_new_entrycombobox({model  => $gui{d}{Edit}{lstoreNetworkGeneric} = gui_new_lstore(['Glib::String']),
                                                                 active => -1,
                                                                 tip    => 'Select a generic driver, if available'});

    $gui{d}{Edit}{cboxNetworkAdapter} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                           [0, 1],
                                                                                           [['AMD PCnet-ISA/NE2100 (Am79C960)', 'Am79C960'],
                                                                                            ['AMD PCnet-PCI II (Am79C970A)', 'Am79C970A'],
                                                                                            ['AMD PCnet-FAST III (Am79C973)', 'Am79C973'],
                                                                                            ['Intel PRO/1000 MT Desktop (82540EM)', 'I82540EM'],
                                                                                            ['Intel PRO/1000 T Server (82543GC)', 'I82543GC'],
                                                                                            ['Intel PRO/1000 MT Server (82545EM)', 'I82545EM'],
                                                                                            ['Paravirtualized (virtio-net)', 'Virtio'],
                                                                                            ['Novell NE2000', 'NE2000'],
                                                                                            ['Novell NE1000', 'NE1000'],
                                                                                            ['WD/SMC EtherCard Plus 16 (WD8013EBT)', 'WD8013'],
                                                                                            ['WD/SMC EtherCard Plus (WD8003E)', 'WD8003'],
                                                                                            ['3Com EtherLink II (3C503)', 'ELNK2'],
                                                                                            ['3Com EtherLink (3C501/3C500)', 'ELNK1']]),
                                                                active => -1,
                                                                tip    => 'The type of virtual network adapter'});

    $gui{d}{Edit}{cboxNetworkPromisc} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                           [0, 1],
                                                                                           [['Deny', 'Deny'],
                                                                                            ['Allow VMs Only', 'AllowNetwork'],
                                                                                            ['Allow All', 'AllowAll']]),
                                                                 active => 0,
                                                                 tip    => 'Sets the promiscuous mode policy of the network adapter'});

    $gui{d}{Edit}{entryNetworkMAC} = gui_new_entry({width  => 12,
                                                     maxlen => 12,
                                                     tip    => 'The MAC address of the virtual network adapter'});

    $gui{d}{Edit}{buttonNetworkMACgen} = gui_new_imgbutton({image => 'refresh_22px.png',
                                                             tip   => 'Generate a new MAC address for this virtual network adapter'});

    $gui{d}{Edit}{tvNetworkGenericprop} = gui_new_textview({editable => TRUE,
                                                             buffer   => $gui{d}{Edit}{tbNetworkGenericprop} = Gtk3::TextBuffer->new(),
                                                             tip      => "Define the configuration paramters for the generic network driver\nThey should be in the form of key=value pairs"});

    $gui{d}{Edit}{checkNetworkCable} = gui_new_check({text   => '_Cable Connected',
                                                       active => FALSE,
                                                       tip    => 'Plug or unplug the virtual network cable'});

    $gui{d}{Edit}{notebook}->append_page(my $box = gui_new_box('vertical'), gui_new_imglabel({text => '_Network', img => 'nw_24px.png'}));
    $box->pack_start(gui_new_titlelabel({text => 'Network'}), FALSE, FALSE, 2);
    $box->pack_start(my $grid = gui_new_grid(), FALSE, FALSE, 2);
    $grid->attach(gui_new_widgetlabel({text => '_Select Network Adapter:', mnwidget => $gui{d}{Edit}{cboxNetwork}}), 0, 0, 1, 1);
    $grid->attach($gui{d}{Edit}{cboxNetwork}, 1, 0, 1, 1);
    $grid->attach($gui{d}{Edit}{checkNetwork}, 0, 1, 1, 1);
    $box->pack_start($gui{d}{Edit}{gridNetwork} = gui_new_grid(), FALSE, FALSE, 2);
    $gui{d}{Edit}{gridNetwork}->attach(gui_new_widgetlabel({text => '_Attached to:', mnwidget => $gui{d}{Edit}{cboxNetworkAttached}}), 0, 0, 1, 1);
    $gui{d}{Edit}{gridNetwork}->attach($gui{d}{Edit}{cboxNetworkAttached}, 1, 0, 1, 1);
    $gui{d}{Edit}{gridNetwork}->attach($gui{d}{Edit}{labelNetworkName} = gui_new_widgetlabel({text => '_Name:', mnwidget => $gui{d}{Edit}{cboxNetworkName}}), 0, 1, 1, 1);
    $gui{d}{Edit}{gridNetwork}->attach($gui{d}{Edit}{cboxNetworkName}, 1, 1, 1, 1);
    $gui{d}{Edit}{gridNetwork}->attach($gui{d}{Edit}{labelNetworkInternal} = gui_new_widgetlabel({text => '_Internal Network Name:', mnwidget => $gui{d}{Edit}{ecboxNetworkInternal}}), 0, 2, 1, 1);
    $gui{d}{Edit}{gridNetwork}->attach($gui{d}{Edit}{ecboxNetworkInternal}, 1, 2, 1, 1);
    $gui{d}{Edit}{gridNetwork}->attach($gui{d}{Edit}{labelNetworkGeneric} = gui_new_widgetlabel({text => '_Generic Driver:', mnwidget => $gui{d}{Edit}{ecboxNetworkGeneric}}), 0, 3, 1, 1);
    $gui{d}{Edit}{gridNetwork}->attach($gui{d}{Edit}{ecboxNetworkGeneric}, 1, 3, 1, 1);
    $box->pack_start($gui{d}{Edit}{gridNetworkAdv} = gui_new_grid(), FALSE, FALSE, 2);
    $gui{d}{Edit}{gridNetworkAdv}->attach(gui_new_widgetlabel({text => 'Adapter _Type:', mnwidget => $gui{d}{Edit}{cboxNetworkAdapter}}), 0, 0, 1, 1);
    $gui{d}{Edit}{gridNetworkAdv}->attach($gui{d}{Edit}{cboxNetworkAdapter}, 1, 0, 2, 1);
    $gui{d}{Edit}{gridNetworkAdv}->attach($gui{d}{Edit}{labelNetworkPromisc} = gui_new_widgetlabel({text => '_Promiscuous Mode:', mnwidget => $gui{d}{Edit}{cboxNetworkPromisc}}), 0, 1, 1, 1);
    $gui{d}{Edit}{gridNetworkAdv}->attach($gui{d}{Edit}{cboxNetworkPromisc}, 1, 1, 2, 1);
    $gui{d}{Edit}{gridNetworkAdv}->attach(gui_new_widgetlabel({text => '_MAC Address:', mnwidget => $gui{d}{Edit}{entryNetworkMAC}}), 0, 2, 1, 1);
    $gui{d}{Edit}{gridNetworkAdv}->attach($gui{d}{Edit}{entryNetworkMAC}, 1, 2, 1, 1);
    $gui{d}{Edit}{gridNetworkAdv}->attach($gui{d}{Edit}{buttonNetworkMACgen}, 2, 2, 1, 1);
    $gui{d}{Edit}{gridNetworkAdv}->attach($gui{d}{Edit}{labelNetworkGenericprop} = gui_new_widgetlabel({text => 'Generic _Properties:', mnwidget => $gui{d}{Edit}{tvNetworkGenericprop}}), 0, 3, 1, 1);
    $gui{d}{Edit}{gridNetworkAdv}->attach($gui{d}{Edit}{frameNetworkGenericprop} = gui_new_frame(), 1, 3, 2, 1);
    $gui{d}{Edit}{frameNetworkGenericprop}->add($gui{d}{Edit}{tvNetworkGenericprop});
    $gui{d}{Edit}{gridNetworkAdv}->attach($gui{d}{Edit}{checkNetworkCable}, 1, 4, 2, 1);
    # Signals
    $gui{d}{Edit}{cboxNetwork}->signal_connect('changed' => \&init_edit_network);
    $gui{d}{Edit}{checkNetwork}->signal_connect('toggled' => \&net_toggle);
    $signal{Edit_cboxNetworkAttached_changed} = $gui{d}{Edit}{cboxNetworkAttached}->signal_connect('changed' => \&net_attach, $gui{d}{Edit}{checkNetwork});
    $signal{Edit_cboxNetworkName_changed} = $gui{d}{Edit}{cboxNetworkName}->signal_connect('changed' => \&net_name, $gui{d}{Edit}{checkNetwork});
    $signal{Edit_ecboxNetworkInternal_changed} = $gui{d}{Edit}{ecboxNetworkInternal}->signal_connect('changed' => \&net_name_internal, $gui{d}{Edit}{checkNetwork});
    $signal{Edit_ecboxNetworkGeneric_changed} = $gui{d}{Edit}{ecboxNetworkGeneric}->signal_connect('changed' => \&net_generic_driver, $gui{d}{Edit}{checkNetwork});
    $signal{Edit_cboxNetworkAdapter_changed} = $gui{d}{Edit}{cboxNetworkAdapter}->signal_connect('changed' => \&net_adapter_type, $gui{d}{Edit}{checkNetwork});
    $gui{d}{Edit}{cboxNetworkPromisc}->signal_connect('changed' => \&net_promiscuous);
    $gui{d}{Edit}{entryNetworkMAC}->signal_connect('activate' => \&net_mac);
    $gui{d}{Edit}{entryNetworkMAC}->signal_connect('focus-out-event' => \&net_mac);
    $gui{d}{Edit}{buttonNetworkMACgen}->signal_connect('pressed' => \&net_mac_regenerate);
    $gui{d}{Edit}{tvNetworkGenericprop}->signal_connect('focus-out-event' => \&net_generic_properties);
    $gui{d}{Edit}{checkNetworkCable}->signal_connect('toggled' => \&net_cable);
    $gui{d}{Edit}{entryNetworkMAC}->signal_connect('changed' => \&valid_hex_char);
}

sub build_dialogEditIOPorts {
    $gui{d}{Edit}{cboxIOSerial} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::Uint'],
                                                                                     [0, 1],
                                                                                     [['Port 1', 0],
                                                                                      ['Port 2', 1],
                                                                                      ['Port 3', 2],
                                                                                      ['Port 4', 3]]),
                                                           active => 0,
                                                           tip    => 'The selected serial port number'});

    $gui{d}{Edit}{checkIOSerial} = gui_new_check({text   => '_Enable Serial Port',
                                                   active => FALSE,
                                                   tip    => 'Enable or Disable this serial port'});

    $gui{d}{Edit}{cboxIOSerialuart} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String', 'Glib::String'],
                                                                                         [0, 1],
                                                                                         [['U16450 (No FIFO)', 'U16450'],
                                                                                          ['U16550A (16Byte FIFO)', 'U16550A'],
                                                                                          ['U16750 (64Byte FIFO, FC)', 'U16750']]),
                                                               active => 0,
                                                               tip    => 'The type of UART chip to emulate'});

    $gui{d}{Edit}{cboxIOSerialnum} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String'],
                                                                                        [0],
                                                                                        [['COM1'],
                                                                                         ['COM2'],
                                                                                         ['COM3'],
                                                                                         ['COM4'],
                                                                                         ['Custom']]),
                                                              active => 0,
                                                              tip    => 'Choose a standard serial port or use customised settings'});

    $gui{d}{Edit}{entryIOSerialirq} = gui_new_entry({width  => 3,
                                                      maxlen => 3,
                                                      tip    => "IRQ number must be between 0 and 255.\n* IRQs greater than 15 require IO APIC to be enabled and may required a 64bit OS"});

    $gui{d}{Edit}{entryIOSerialio} = gui_new_entry({width   => 4,
                                                      maxlen => 4,
                                                      tip    => 'I/O port address to use. Must be between 0 and FFFF'});

    $gui{d}{Edit}{cboxIOSerialmode} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String'],
                                                                                         [0],
                                                                                         [['Disconnected'],
                                                                                          ['HostPipe'],
                                                                                          ['HostDevice'],
                                                                                          ['RawFile'],
                                                                                          ['TCP']]),
                                                               active => -1,
                                                               tip    => 'Working mode of the serial port. Disconnected means the guest will see it, but it will not be usable'});

    $gui{d}{Edit}{checkIOSerialpipe} = gui_new_check({text    => '_Connect to an existing pipe or socket',
                                                        active => FALSE,
                                                        tip    => 'Connect to an existing pipe or socket or create a new one'});

    $gui{d}{Edit}{entryIOSerialpath} = gui_new_entry({width => 32,
                                                      tip    => 'Path to the serial port\'s pipe on the host when in HostPipe mode otherwise the host\'s serial port device name to use'});

    $gui{d}{Edit}{buttonIOSerialPath} = gui_new_imgbutton({image => 'refresh_22px.png',
                                                            tip   => 'Attempt to automatically generate a suitable port or path'});

    # Parallel Tab
    $gui{d}{Edit}{checkIOParallel} = gui_new_check({text   => '_Enable Parallel Port',
                                                     active => FALSE,
                                                     tip    => 'Enable or Disable this parallel port'});

    $gui{d}{Edit}{cboxIOParallelnum} = gui_new_simplecombobox({model  => gui_new_lstore(['Glib::String'],
                                                                                          [0],
                                                                                          [['LPT1'],
                                                                                           ['LPT2'],
                                                                                           ['LPT3'],
                                                                                           ['Custom']]),
                                                                active => 0,
                                                                tip    => 'Choose a standard parallel port or use customised settings'});

    $gui{d}{Edit}{entryIOParallelirq} = gui_new_entry({width  => 3,
                                                        maxlen => 3,
                                                        tip    => "IRQ number must be between 0 and 255.\n* IRQs greater than 15 require IO APIC to be enabled and may required a 64bit OS"});

    $gui{d}{Edit}{entryIOParallelio} = gui_new_entry({width  => 4,
                                                       maxlen => 4,
                                                       tip    => 'I/O port address to use. Must be between 0 and FFFF'});

    $gui{d}{Edit}{entryIOParallelpath} = gui_new_entry({width  => 32,
                                                         tip    => 'Path to the parallel port\'s pipe on the host when in HostPipe mode otherwise the host\'s parallel port device name to use'});

    $gui{d}{Edit}{notebookIOPorts} = Gtk3::Notebook->new();
    # Serial Port Tab
    $gui{d}{Edit}{notebookIOPorts}->append_page(my $vboxserial = gui_new_box('vertical'), gui_new_widgetlabel({text => '_Serial Ports'}));
    $vboxserial->pack_start(my $gridserial = gui_new_grid(), FALSE, FALSE, 2);
    $gridserial->attach(gui_new_widgetlabel({text => 'Se_lect Serial Port:', mnwidget => $gui{d}{Edit}{cboxIOSerial}}), 0, 0, 1, 1);
    $gridserial->attach($gui{d}{Edit}{cboxIOSerial}, 1, 0, 1, 1);
    $gridserial->attach($gui{d}{Edit}{checkIOSerial}, 0, 1, 1, 1);
    $vboxserial->pack_start($gui{d}{Edit}{gridIOSerial} = gui_new_grid(), FALSE, FALSE, 2);
    $gui{d}{Edit}{gridIOSerial}->attach(gui_new_widgetlabel({text => '_UART:', mnwidget => $gui{d}{Edit}{cboxIOSerialuart}}), 0, 0, 1, 1);
    $gui{d}{Edit}{gridIOSerial}->attach($gui{d}{Edit}{cboxIOSerialuart}, 1, 0, 5, 1);
    $gui{d}{Edit}{gridIOSerial}->attach(gui_new_widgetlabel({text => 'Port _Number:', mnwidget => $gui{d}{Edit}{cboxIOSerialnum}}), 0, 1, 1, 1);
    $gui{d}{Edit}{gridIOSerial}->attach($gui{d}{Edit}{cboxIOSerialnum}, 1, 1, 1, 1);
    $gui{d}{Edit}{gridIOSerial}->attach(gui_new_widgetlabel({text => '_IRQ:', mnwidget => $gui{d}{Edit}{entryIOSerialirq}}), 2, 1, 1, 1);
    $gui{d}{Edit}{gridIOSerial}->attach($gui{d}{Edit}{entryIOSerialirq}, 3, 1, 1, 1);
    $gui{d}{Edit}{gridIOSerial}->attach(gui_new_widgetlabel({text => 'I/_O Port:', mnwidget => $gui{d}{Edit}{entryIOSerialio}}), 4, 1, 1, 1);
    $gui{d}{Edit}{gridIOSerial}->attach($gui{d}{Edit}{entryIOSerialio}, 5, 1, 1, 1);
    $gui{d}{Edit}{gridIOSerial}->attach(gui_new_widgetlabel({text => 'Port _Mode:', mnwidget => $gui{d}{Edit}{cboxIOSerialmode}}), 0, 2, 1, 1);
    $gui{d}{Edit}{gridIOSerial}->attach($gui{d}{Edit}{cboxIOSerialmode}, 1, 2, 5, 1);
    $gui{d}{Edit}{gridIOSerial}->attach($gui{d}{Edit}{checkIOSerialpipe}, 1, 3, 5, 1);
    $gui{d}{Edit}{gridIOSerial}->attach(my $pathbox = gui_new_box('horizontal'), 1, 4, 5, 1);
    $pathbox->pack_start($gui{d}{Edit}{entryIOSerialpath}, TRUE, TRUE, 2);
    $pathbox->pack_start($gui{d}{Edit}{buttonIOSerialPath}, FALSE, FALSE, 2);
    $gui{d}{Edit}{gridIOSerial}->attach(gui_new_widgetlabel({text => 'Port/_File Path:', mnwidget => $gui{d}{Edit}{entryIOSerialpath}}), 0, 4, 1, 1);
    # Parallel Port Tab
    $gui{d}{Edit}{notebookIOPorts}->append_page(my $vboxparallel = gui_new_box('vertical'), gui_new_widgetlabel({text => '_Parallel Port'}));
    $vboxparallel->pack_start($gui{d}{Edit}{checkIOParallel}, FALSE, FALSE, 2);
    $vboxparallel->pack_start($gui{d}{Edit}{gridIOParallel} = gui_new_grid(), FALSE, FALSE, 2);
    $gui{d}{Edit}{gridIOParallel}->attach(gui_new_widgetlabel({text => 'Port _Number:', mnwidget => $gui{d}{Edit}{cboxIOParallelnum}}), 0, 0, 1, 1);
    $gui{d}{Edit}{gridIOParallel}->attach($gui{d}{Edit}{cboxIOParallelnum}, 1, 0, 1, 1);
    $gui{d}{Edit}{gridIOParallel}->attach(gui_new_widgetlabel({text => '_IRQ:', mnwidget => $gui{d}{Edit}{entryIOParallelirq}}), 2, 0, 1, 1);
    $gui{d}{Edit}{gridIOParallel}->attach($gui{d}{Edit}{entryIOParallelirq}, 3, 0, 1, 1);
    $gui{d}{Edit}{gridIOParallel}->attach(gui_new_widgetlabel({text => 'I/_O Port:', mnwidget => $gui{d}{Edit}{entryIOParallelio}}), 4, 0, 1, 1);
    $gui{d}{Edit}{gridIOParallel}->attach($gui{d}{Edit}{entryIOParallelio}, 5, 0, 1, 1);
    $gui{d}{Edit}{gridIOParallel}->attach(gui_new_widgetlabel({text => 'Port/_File Path:', mnwidget => $gui{d}{Edit}{entryIOParallelpath}}), 0, 1, 1, 1);
    $gui{d}{Edit}{gridIOParallel}->attach($gui{d}{Edit}{entryIOParallelpath}, 1, 1, 5, 1);
    $gui{d}{Edit}{notebookIOPorts}->show_all();
    # Signals
    $gui{d}{Edit}{notebookIOPorts}->signal_connect('switch-page' => \&edit_io_tabchanged);
    $gui{d}{Edit}{checkIOSerial}->signal_connect('toggled' => \&io_ser);
    $gui{d}{Edit}{cboxIOSerial}->signal_connect('changed' => \&init_edit_io_serial);
    $gui{d}{Edit}{cboxIOSerialuart}->signal_connect('changed' => \&io_ser_uart);
    $gui{d}{Edit}{cboxIOSerialnum}->signal_connect('changed' => \&io_ser_num);
    $gui{d}{Edit}{entryIOSerialirq}->signal_connect('activate' => \&io_ser_irq);
    $gui{d}{Edit}{entryIOSerialirq}->signal_connect('focus-out-event' => \&io_ser_irq);
    $gui{d}{Edit}{entryIOSerialio}->signal_connect('activate' => \&io_ser_port);
    $gui{d}{Edit}{entryIOSerialio}->signal_connect('focus-out-event' => \&io_ser_port);
    $gui{d}{Edit}{cboxIOSerialmode}->signal_connect('changed' => \&io_ser_mode);
    $gui{d}{Edit}{checkIOSerialpipe}->signal_connect('toggled' => \&io_ser_make_pipe);
    $gui{d}{Edit}{entryIOSerialpath}->signal_connect('activate' => \&io_ser_path);
    $gui{d}{Edit}{entryIOSerialpath}->signal_connect('focus-out-event' => \&io_ser_path);
    $gui{d}{Edit}{checkIOParallel}->signal_connect('toggled' => \&io_par);
    $gui{d}{Edit}{cboxIOParallelnum}->signal_connect('changed' => \&io_par_num);
    $gui{d}{Edit}{entryIOParallelirq}->signal_connect('activate' => \&io_par_irq);
    $gui{d}{Edit}{entryIOParallelirq}->signal_connect('focus-out-event' => \&io_par_irq);
    $gui{d}{Edit}{entryIOParallelio}->signal_connect('activate' => \&io_par_port);
    $gui{d}{Edit}{entryIOParallelio}->signal_connect('focus-out-event' => \&io_par_port);
    $gui{d}{Edit}{entryIOParallelpath}->signal_connect('activate' => \&io_par_path);
    $gui{d}{Edit}{entryIOParallelpath}->signal_connect('focus-out-event' => \&io_par_path);
    $gui{d}{Edit}{buttonIOSerialPath}->signal_connect('pressed' => \&io_ser_path_generate);
    $gui{d}{Edit}{entryIOSerialirq}->signal_connect('changed' => \&valid_number_char);
    $gui{d}{Edit}{entryIOSerialio}->signal_connect('changed' => \&valid_hex_char);
    $gui{d}{Edit}{entryIOParallelirq}->signal_connect('changed' => \&valid_number_char);
    $gui{d}{Edit}{entryIOParallelio}->signal_connect('changed' => \&valid_hex_char);

    # Main Notebook
    $gui{d}{Edit}{notebook}->append_page(my $box = gui_new_box('vertical'), gui_new_imglabel({text => '_I/O Ports', img => 'serial_port_24px.png'}));
    $box->pack_start(gui_new_titlelabel({text => 'I/O Ports'}), FALSE, FALSE, 2);
    $box->pack_start($gui{d}{Edit}{notebookIOPorts}, TRUE, TRUE, 2);
}

sub build_dialogEditUSB {
    $gui{d}{Edit}{checkUSB} = gui_new_check({text   => '_Enable USB Controller',
                                              active => FALSE,
                                              tip    => 'Enable a USB Controller'});

    $gui{d}{Edit}{radioUSB1} = gui_new_radio({text   => '_1.1 (OHCI)',
                                               group  => undef,
                                               active => TRUE,
                                               tip    => 'Adds a USB 1.1 OHCI controller'});

    $gui{d}{Edit}{radioUSB2} = gui_new_radio({text   => '_2.0 (EHCI)',
                                               group  => $gui{d}{Edit}{radioUSB1},
                                               active => FALSE,
                                               tip    => 'Adds a USB 2.0 EHCI controller'});

    $gui{d}{Edit}{radioUSB3} = gui_new_radio({text   => '_3.0 (xHCI)',
                                               group  => $gui{d}{Edit}{radioUSB1},
                                               active => FALSE,
                                               tip    => 'Adds a USB 3.0 OHCI controller'});

    $gui{d}{Edit}{treeviewUSB} = gui_new_treeview({model   => $gui{d}{Edit}{lstoreUSB} = gui_new_lstore(['Glib::Boolean', 'Glib::String', 'Glib::String', 'Glib::Uint']),
                                                    headers => FALSE,
                                                    tip     => 'USB Device Filters'});

    my ($col, $celltoggle) = gui_new_treeviewcolumntoggle({title   => 'Enabled',
                                                            type    => 'active',
                                                            typecol => 0});

    $gui{d}{Edit}{treeviewUSB}->append_column($col);
    $gui{d}{Edit}{treeviewUSB}->append_column(gui_new_treeviewcolumn({title   => 'Filter',
                                                                       type    => 'text',
                                                                       typecol => 2}));

    my $buttonAddz = gui_new_imgbutton({image => 'usb_new_16px.png', tip => 'Add an empty USB filter'});
    $gui{d}{Edit}{buttonUSBAdd} = gui_new_imgbutton({image => 'usb_add_16px.png', tip => 'Add a USB filter'});
    $gui{d}{Edit}{buttonUSBRemove} = gui_new_imgbutton({image => 'usb_remove_16px.png', tip => 'Remove USB filter'});
    $gui{d}{Edit}{buttonUSBEdit} = gui_new_imgbutton({image => 'usb_filter_edit_16px.png', tip => 'Edit USB filter'});
    $gui{d}{Edit}{buttonUSBUp} = gui_new_imgbutton({image => 'usb_moveup_16px.png', tip => 'Move USB filter up'});
    $gui{d}{Edit}{buttonUSBDown} = gui_new_imgbutton({image => 'usb_movedown_16px.png', tip => 'Move USB filter down'});
    # Layout
    $gui{d}{Edit}{notebook}->append_page(my $vbox = gui_new_box('vertical'), gui_new_imglabel({text => '_USB', img => 'usb_24px.png'}));
    $vbox->pack_start(gui_new_titlelabel({text => 'USB'}), FALSE, FALSE, 2);
    $vbox->pack_start($gui{d}{Edit}{checkUSB}, FALSE, FALSE, 2);
    $vbox->pack_start($gui{d}{Edit}{gridUSBVersions} = gui_new_grid(), FALSE, FALSE, 2);
    $gui{d}{Edit}{gridUSBVersions}->attach(gui_new_widgetlabel({text => 'USB Controller:'}), 0, 0, 1, 1);
    $gui{d}{Edit}{gridUSBVersions}->attach($gui{d}{Edit}{radioUSB1}, 1, 0, 1, 1);
    $gui{d}{Edit}{gridUSBVersions}->attach($gui{d}{Edit}{radioUSB2}, 2, 0, 1, 1);
    $gui{d}{Edit}{gridUSBVersions}->attach($gui{d}{Edit}{radioUSB3}, 3, 0, 1, 1);
    $vbox->pack_start(my $hbox = gui_new_box('horizontal'), TRUE, TRUE, 2);
    $hbox->pack_start(my $frame = gui_new_frame(), TRUE, TRUE, 2);
    $frame->add(my $scrollwin1 = gui_new_scrolledwindow());
    $scrollwin1->add($gui{d}{Edit}{treeviewUSB});
    $hbox->pack_start($gui{d}{Edit}{vboxUSBButton} = gui_new_box('vertical'), FALSE, FALSE, 2);
    $gui{d}{Edit}{vboxUSBButton}->pack_start($buttonAddz, FALSE, FALSE, 0);
    $gui{d}{Edit}{vboxUSBButton}->pack_start($gui{d}{Edit}{buttonUSBAdd}, FALSE, FALSE, 0);
    $gui{d}{Edit}{vboxUSBButton}->pack_start($gui{d}{Edit}{buttonUSBRemove}, FALSE, FALSE, 0);
    $gui{d}{Edit}{vboxUSBButton}->pack_start($gui{d}{Edit}{buttonUSBEdit}, FALSE, FALSE, 0);
    $gui{d}{Edit}{vboxUSBButton}->pack_start($gui{d}{Edit}{buttonUSBUp}, FALSE, FALSE, 0);
    $gui{d}{Edit}{vboxUSBButton}->pack_start($gui{d}{Edit}{buttonUSBDown}, FALSE, FALSE, 0);
    # Signals
    $celltoggle->signal_connect('toggled' => \&usb_toggle_filter);
    $signal{Edit_buttonUSBEnable_toggled} = $gui{d}{Edit}{checkUSB}->signal_connect('toggled' => \&usb_toggle);
    $gui{d}{Edit}{radioUSB1}->signal_connect('toggled' => \&usb_ctr_type);
    $gui{d}{Edit}{radioUSB2}->signal_connect('toggled' => \&usb_ctr_type);
    $gui{d}{Edit}{radioUSB3}->signal_connect('toggled' => \&usb_ctr_type);
    $signal{Edit_treeviewUSB_cursorchanged} = $gui{d}{Edit}{treeviewUSB}->signal_connect('cursor-changed' => \&onsel_list_usbfilters);
    $buttonAddz->signal_connect('clicked' => \&usb_add_zero_filter);
    $gui{d}{Edit}{buttonUSBRemove}->signal_connect('clicked' => \&usb_remove_filter);
    $gui{d}{Edit}{buttonUSBEdit}->signal_connect('clicked' => \&show_dialog_usbfilter);
}

sub build_dialogEditShared {
    $gui{d}{Edit}{treeviewShared} = gui_new_treeview({model   => $gui{d}{Edit}{lstoreShared} = gui_new_lstore(['Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Gtk3::Gdk::Pixbuf', 'Glib::String', 'Glib::String']),
                                                       headers => TRUE,
                                                       tip     => 'List of shared folders accessible to the guest'});

    $gui{d}{Edit}{treeviewShared}->append_column(gui_new_treeviewcolumn({title   => '',
                                                                          type    => 'pixbuf',
                                                                          typecol => 4}));

    $gui{d}{Edit}{treeviewShared}->append_column(gui_new_treeviewcolumn({title   => 'Name',
                                                                          type    => 'text',
                                                                          typecol => 0}));

    $gui{d}{Edit}{treeviewShared}->append_column(gui_new_treeviewcolumn({title   => 'Folder',
                                                                          type    => 'text',
                                                                          typecol => 1}));

    $gui{d}{Edit}{treeviewShared}->append_column(gui_new_treeviewcolumn({title   => 'Auto-Mount',
                                                                          type    => 'text',
                                                                          typecol => 3}));

    $gui{d}{Edit}{treeviewShared}->append_column(gui_new_treeviewcolumn({title   => 'Access',
                                                                          type    => 'text',
                                                                          typecol => 2}));

    $gui{d}{Edit}{treeviewShared}->append_column(gui_new_treeviewcolumn({title   => 'Permanent',
                                                                          type    => 'text',
                                                                          typecol => 6}));

    $gui{d}{Edit}{buttonSharedAdd} = gui_new_imgbutton({image => 'sf_add_16px.png', tip => 'Add a shared folder. Folder path must be absolute'});
    $gui{d}{Edit}{buttonSharedRemove} = gui_new_imgbutton({image => 'remove_host_iface_16px.png', tip => 'Remove a shared folder'});
    $gui{d}{Edit}{buttonSharedEdit} = gui_new_imgbutton({image => 'host_iface_edit_16px.png', tip => 'Edit shared folder'});
    # Layout
    $gui{d}{Edit}{notebook}->append_page(my $vbox = gui_new_box('vertical'), gui_new_imglabel({text => 'Shared _Folders', img => 'sf_24px.png'}));
    $vbox->pack_start(gui_new_titlelabel({text => 'Shared Folders'}), FALSE, FALSE, 2);
    $vbox->pack_start(my $hbox = gui_new_box('horizontal'), TRUE, TRUE, 2);
    $hbox->pack_start(my $frame = gui_new_frame(), TRUE, TRUE, 2);
    $frame->add(my $scrollwin = gui_new_scrolledwindow());
    $hbox->pack_start(my $bbox = gui_new_box('vertical'), FALSE, FALSE, 2);
    $scrollwin->add($gui{d}{Edit}{treeviewShared});
    $bbox->pack_start($gui{d}{Edit}{buttonSharedAdd}, FALSE, FALSE, 0);
    $bbox->pack_start($gui{d}{Edit}{buttonSharedRemove}, FALSE, FALSE, 0);
    $bbox->pack_start($gui{d}{Edit}{buttonSharedEdit}, FALSE, FALSE, 0);
    $vbox->pack_start(gui_new_warnlabel({text => 'Attaching storage explicitly saves settings'}), FALSE, FALSE, 2);
    # Signals
    $signal{Edit_treeviewShared_cursorchanged} = $gui{d}{Edit}{treeviewShared}->signal_connect('cursor-changed' => \&onsel_list_shared);
    $gui{d}{Edit}{treeviewShared}->signal_connect('row-activated' => \&show_dialog_shared);
    $gui{d}{Edit}{buttonSharedAdd}->signal_connect('clicked' => \&show_dialog_shared);
    $gui{d}{Edit}{buttonSharedRemove}->signal_connect('clicked' => \&share_remove);
    $gui{d}{Edit}{buttonSharedEdit}->signal_connect('clicked' => \&show_dialog_shared);
    $gui{d}{Edit}{buttonUSBUp}->signal_connect('clicked' => \&usb_move_filter);
    $gui{d}{Edit}{buttonUSBDown}->signal_connect('clicked' => \&usb_move_filter);
    # This signal actually needs to be in the last tab so it doesn't get triggered when adding other tabs
    $gui{d}{Edit}{notebook}->signal_connect('switch-page' => \&edit_tabchanged);
}

sub build_winMain {
    $gui{d}{Main}{win} = Gtk3::Window->new('toplevel');
    $gui{d}{Main}{win}->set_title('RemoteBox');
    $gui{d}{Main}{win}->set_icon(gui_new_pixbuf_from_file('remotebox.png'));
    my $menubar = Gtk3::MenuBar->new;
    my $miFile = gui_new_menu_item('_File', undef, $menubar);
    $miFile->set_submenu(my $menuFile = gui_new_menu());
    my $miConnect = gui_new_menu_item('_Connect to VirtualBox', 'connect_16px.png', $menuFile);
    my $miProfiles = gui_new_menu_item('Connection P_rofiles', 'profile_16px.png', $menuFile);
    $gui{mi}{ImportAppl} = gui_new_menu_item('_Import Appliance', 'import_16px.png', $menuFile);
    $gui{mi}{ExportAppl} = gui_new_menu_item('_Export Appliance', 'export_16px.png', $menuFile);
    $gui{mi}{VMM} = gui_new_menu_item('_Virtual Media Manager', 'media_manager_16px.png', $menuFile);
    $gui{mi}{HostNetMan} = gui_new_menu_item('_Network Manager', 'host_iface_manager_16px.png', $menuFile);
    $gui{mi}{ServerInfo} = gui_new_menu_item('_Server Information', 'session_info_16px.png', $menuFile);
    my $miPrefs = gui_new_menu_item('RemoteBox _Preferences', 'rb_settings_16px.png', $menuFile);
    $gui{mi}{VBPrefs} = gui_new_menu_item('Virtual_Box Preferences', 'global_settings_16px.png', $menuFile);
    $menuFile->append(Gtk3::SeparatorMenuItem->new());
    my $miQuit = gui_new_menu_item('_Quit', 'close_16px.png', $menuFile);
    my $miMachine = gui_new_menu_item('_Machine', undef, $menubar);
    $miMachine->set_submenu($gui{menu}{Machine} = gui_new_menu());
    $gui{mi}{New} = gui_new_menu_item('_New Guest', 'vm_new_16px.png', $gui{menu}{Machine});
    $gui{mi}{Add} = gui_new_menu_item('_Add Guest', 'vm_add_16px.png', $gui{menu}{Machine});
    $gui{mi}{Settings} = gui_new_menu_item('_Settings', 'vm_settings_16px.png', $gui{menu}{Machine});
    $gui{mi}{Clone} = gui_new_menu_item('Cl_one', 'vm_clone_16px.png', $gui{menu}{Machine});
    $gui{mi}{Remove} = gui_new_menu_item('_Remove', 'delete_16px.png', $gui{menu}{Machine});
    $gui{mi}{SetGroup} = gui_new_menu_item('Set _Group', 'vm_group_name_16px.png', $gui{menu}{Machine});
    $gui{mi}{Ungroup} = gui_new_menu_item('_Ungroup', 'vm_group_remove_16px.png', $gui{menu}{Machine});
    $gui{menu}{Machine}->append(Gtk3::SeparatorMenuItem->new());
    $gui{mi}{Screenshot} = gui_new_menu_item('Screenshot', 'screenshot_take_16px.png', $gui{menu}{Machine}); # Has a sub menu
    $gui{mi}{Screenshot}->set_submenu(my $menuScreenshot = gui_new_menu());
    $gui{mi}{Screenshotsavepng} = gui_new_menu_item('Save _PNG screenshot...', 'screenshot_take_16px.png', $menuScreenshot);
    $gui{mi}{ScreenshotIcon} = gui_new_menu_item('_Set screenshot as icon', 'screenshot_take_16px.png', $menuScreenshot);
    $gui{mi}{ScreenshotReset} = gui_new_menu_item('_Reset guest icon', 'reset_scrshot_16px.png', $menuScreenshot);
    $gui{mi}{Logs} = gui_new_menu_item('Show Guest _Logs', 'show_logs_16px.png', $gui{menu}{Machine});
    $gui{mi}{Action} = gui_new_menu_item('_Action', undef, $menubar);
    $gui{mi}{Action}->set_submenu(my $menuAction = gui_new_menu());
    $gui{mi}{Start} = gui_new_menu_item('_Start', 'vm_start_16px.png', $menuAction);
    $gui{mi}{Stop} = gui_new_menu_item('Stop', 'state_aborted_16px.png', $menuAction); # Has a sub menu
    $gui{mi}{Stop}->set_submenu(my $menuStop = gui_new_menu());
    $gui{mi}{Pause} = gui_new_menu_item('_Pause', 'vm_pause_16px.png', $menuAction);
    $gui{mi}{Resume} = gui_new_menu_item('Res_ume', 'vm_start_16px.png', $menuAction);
    $gui{mi}{Discard} = gui_new_menu_item('_Discard Saved State', 'vm_discard_16px.png', $menuAction);
    $gui{mi}{Reset} = gui_new_menu_item('_Reset', 'vm_reset_16px.png', $menuAction);
    my $miPower = gui_new_menu_item('Instant _Power Off', 'vm_poweroff_16px.png', $menuStop);
    my $miACPI = gui_new_menu_item('_ACPI Shutdown', 'vm_shutdown_16px.png', $menuStop);
    my $miSave = gui_new_menu_item('_Save State', 'vm_save_state_16px.png', $menuStop);
    # A menu can only be attached to one widget, so the Stop toolbar button needs its own
    my $menuStopButton = gui_new_menu();
    my $miPowerButton = gui_new_menu_item('Instant _Power Off', 'vm_poweroff_16px.png', $menuStopButton);
    my $miACPIButton = gui_new_menu_item('_ACPI Shutdown', 'vm_shutdown_16px.png', $menuStopButton);
    my $miSaveButton = gui_new_menu_item('_Save State', 'vm_save_state_16px.png', $menuStopButton);
    my $miDevices = gui_new_menu_item('_Devices', undef, $menubar);
    $miDevices->set_submenu($gui{menu}{Devices} = gui_new_menu());
    $gui{mi}{Display} = gui_new_menu_item('Display', 'vrdp_16px.png', $gui{menu}{Devices});
    $gui{mi}{Display}->set_submenu(my $menuDisplay = gui_new_menu()); # Has a sub menu
    $gui{mi}{RemoteDisplay} = gui_new_menu_item('_Open Guest Display', 'vrdp_16px.png', $menuDisplay);
    $gui{mi}{SetVideo} = gui_new_menu_item('Resolution Hint', 'vrdp_16px.png', $menuDisplay); # Has a sub-menu
    $gui{mi}{SetVideo}->set_submenu(my $menuSetVideo = gui_new_menu());
    $gui{mi}{SetVideoCustom} = gui_new_menu_item('_Custom', 'vrdp_16px.png', $menuSetVideo);

    foreach my $res (@{get_scr_res_tbl()}) {
        $gui{mi}{'miSetVideo' . "$$res{w}_$$res{h}"} = gui_new_menu_item($$res{w} . 'x' . $$res{h} . ":32 ($$res{aspx}:$$res{aspy})", 'vrdp_16px.png', $menuSetVideo);
        $gui{mi}{'miSetVideo' . "$$res{w}_$$res{h}"}->signal_connect('activate' => \&send_video_hint, [$$res{w}, $$res{h}, 32]);
        $gui{mi}{'miSetVideo' . "$$res{w}_$$res{h}"}->set_tooltip_text('Requires a minimum of ' . vram_needed($$res{w}, $$res{h}, 32) . 'MB of video memory assigned to the guest');
    }

    $gui{mi}{Keyboard} = gui_new_menu_item('Keyboard', 'keyboard_16px.png', $gui{menu}{Devices}); # Has a sub menu
    $gui{mi}{Keyboard}->set_submenu(my $menuKeyboard = gui_new_menu());
    my $miKeyboardCAF = gui_new_menu_item('Ctrl-Alt-F...', 'keyboard_16px.png', $menuKeyboard); # Has sub menu
    my $miKeyboardASF = gui_new_menu_item('Alt-Sysrq+...', 'keyboard_16px.png', $menuKeyboard); # Has sub menu
    $miKeyboardCAF->set_submenu(my $menuKeyboardCAF = gui_new_menu());
    $miKeyboardASF->set_submenu(my $menuKeyboardASF = gui_new_menu());
    my $miKeyboardCAD = gui_new_menu_item('Ctrl-Alt-Del', 'keyboard_16px.png', $menuKeyboard);
    $gui{menu}{KeyboardMini} = gui_new_menu();

    foreach my $code (@{get_cafx_code_tbl()}) {
        $gui{mi}{'Keyboard' . $$code{desc}} = gui_new_menu_item($$code{desc}, 'keyboard_16px.png', $menuKeyboardCAF);
        $gui{mi}{'Keyboard' . $$code{desc}}->signal_connect('activate' => \&keyboard_send, $code);
    }

    foreach my $code (@{get_asfx_code_tbl()}) {
        $gui{mi}{'Keyboard' . $$code{desc}} = gui_new_menu_item($$code{desc}, 'keyboard_16px.png', $menuKeyboardASF);
        $gui{mi}{'Keyboard' . $$code{desc}}->signal_connect('activate' => \&keyboard_send, $code);
    }

    foreach my $code (@{get_misc_code_tbl()}) {
        $gui{mi}{'Keyboard' . $$code{desc}} = gui_new_menu_item($$code{desc}, 'keyboard_16px.png', $menuKeyboard);
        $gui{mi}{'Keyboard' . $$code{desc}}->signal_connect('activate' => \&keyboard_send, $code);
        $gui{mi}{'KeyboardMini' . $$code{desc}} = gui_new_menu_item($$code{desc}, 'keyboard_16px.png', $gui{menu}{KeyboardMini});
        $gui{mi}{'KeyboardMini' . $$code{desc}}->signal_connect('activate' => \&keyboard_send, $code);
    }

    my $miKeyboardRK = gui_new_menu_item('Release Keys', 'keyboard_16px.png', $menuKeyboard);
    $gui{mi}{Floppy} = gui_new_menu_item('Change _Floppy...', 'fd_16px.png', $gui{menu}{Devices}); # Has a dynamic sub menu
    $gui{mi}{Floppy}->set_submenu(gui_new_menu()); # This menu is not used here, but hints for GTK. We attach one later
    $gui{mi}{DVD} = gui_new_menu_item('Change _Optical Disc...', 'cd_16px.png', $gui{menu}{Devices}); # Has a dynamic sub menu
    $gui{mi}{DVD}->set_submenu(gui_new_menu()); # This menu is not used here, but hints for GTK. We attach one later
    $gui{mi}{USB} = gui_new_menu_item('HotPlug _USB Device...', 'usb_16px.png', $gui{menu}{Devices}); # Has a dynamic sub menu
    $gui{mi}{USB}->set_submenu(gui_new_menu()); # This menu is not used here, but hints for GTK. We attach one later
    $gui{mi}{HotPlugCPU} = gui_new_menu_item('HotPlug _CPU...', 'cpu_16px.png', $gui{menu}{Devices}); # Has a dynamic sub menu
    $gui{mi}{HotPlugCPU}->set_submenu(gui_new_menu()); # This menu is not used here, but hints for GTK. We attach one later
    my $miHelp = gui_new_menu_item('_Help', undef, $menubar);
    $miHelp->set_submenu(my $menuHelp = gui_new_menu());
    my $miAbout = gui_new_menu_item('_About', 'session_info_16px.png', $menuHelp);
    my $toolbar = gui_new_toolbar();
    $toolbar->insert(my $buttonConnect = gui_new_toolbutton({image => 'connect_32px.png',
                                                              label => '_Connect',
                                                              tip   => 'Connect to a VirtualBox server'}), -1);

    $toolbar->insert($gui{d}{Main}{buttonNew} = gui_new_toolbutton({image => 'vm_new_32px.png',
                                                                     label => '_New',
                                                                     tip   => 'Create a new guest'}), -1);

    $toolbar->insert($gui{d}{Main}{buttonSettings} = gui_new_toolbutton({image => 'vm_settings_32px.png',
                                                                          label => 'S_ettings',
                                                                          tip   => 'Edit the guest settings'}), -1);

    $toolbar->insert($gui{d}{Main}{buttonStart} = gui_new_toolbutton({image => 'vm_start_32px.png',
                                                                       label => '_Start',
                                                                       tip   => 'Start or power on the guest'}), -1);

    $toolbar->insert($gui{d}{Main}{buttonStop} = gui_new_menutoolbutton({image => 'stop_32px.png',
                                                                          label => 'S_top',
                                                                          tip   => "Power off the guest\n* Additional options in the button menu"}), -1);

    $gui{d}{Main}{buttonStop}->set_menu($menuStopButton);
    $toolbar->insert($gui{d}{Main}{buttonDiscard} = gui_new_toolbutton({image => 'vm_discard_32px.png',
                                                                       label => '_Discard',
                                                                       tip   => "Discard the guest\'s saved state"}), -1);

    $toolbar->insert($gui{d}{Main}{buttonReset} = gui_new_toolbutton({image => 'reset_32px.png',
                                                                       label => 'Reset',
                                                                       tip   => 'Reset the guest'}), -1);

    $toolbar->insert($gui{d}{Main}{buttonDisplay} = gui_new_toolbutton({image => 'vrdp_32px.png',
                                                                         label => '_Guest Display',
                                                                         tip   => "Open the guest\'s display\n* The guest must have the display server enabled in its settings and you must have a correctly configured RDP/VNC client"}), -1);

    $toolbar->insert($gui{d}{Main}{buttonCAD} = gui_new_menutoolbutton({image => 'keyboard_32px.png',
                                                                         label => 'Ctrl-Alt-Del',
                                                                         tip   => 'Send the Ctrl-Alt-Delete keyboard sequence or select an alternative from the button menu'}), -1);

    $gui{d}{Main}{buttonCAD}->set_menu($gui{menu}{KeyboardMini});
    $toolbar->insert($gui{d}{Main}{buttonRefresh} = gui_new_toolbutton({image => 'refresh_32px.png',
                                                                         label => '_Refresh',
                                                                         tip   => 'Refresh the guest list'}), -1);

    $gui{d}{Main}{barMem} = Gtk3::ProgressBar->new();
    $gui{d}{Main}{barMem}->set_hexpand(TRUE);
    $gui{d}{Main}{barMem}->set_pulse_step(0.1);
    $gui{d}{Main}{barMem}->set_tooltip_text('Available memory on the server. Press refresh to update');
    $gui{d}{Main}{barMem}->set_show_text(TRUE);

    $gui{d}{Main}{treeviewGuest} = gui_new_treeview({model   => $gui{d}{Main}{tstoreGuest} = gui_new_tstore(['Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String', 'Gtk3::Gdk::Pixbuf', 'Glib::String', 'Gtk3::Gdk::Pixbuf']),
                                                      headers => FALSE,
                                                      tip     => 'List of available guests. Refresh to see changes'});

    $gui{d}{Main}{treeviewGuest}->append_column(my $colGuest = gui_new_treeviewcolumn({title   => 'Icon',
                                                                                        type    => 'pixbuf',
                                                                                        typecol => 6}));
    # This column actually has several cellrenders in it
    $colGuest->pack_start(my $statusCell = Gtk3::CellRendererPixbuf->new(), FALSE);
    $colGuest->add_attribute($statusCell, 'pixbuf', 8);
    $colGuest->pack_start(my $nameCell = Gtk3::CellRendererText->new(), FALSE);
    $colGuest->add_attribute($nameCell, 'text', 7);
    my $notebookGuest = Gtk3::Notebook->new();
    $notebookGuest->append_page(my $vboxg = gui_new_box('vertical'), gui_new_imglabel({text => '_Guests', img => 'vm_new_16px.png'}));
    $vboxg->pack_start($gui{d}{Main}{scrolledGuest} = gui_new_scrolledwindow(), TRUE, TRUE, 2);
    $gui{d}{Main}{scrolledGuest}->add($gui{d}{Main}{treeviewGuest});
    $vboxg->pack_start(my $hboxb = gui_new_box('horizontal'), FALSE, FALSE, 0);
    my $buttonGroupExpand = gui_new_imgbutton({image => 'vm_group_expand_16px.png', tip => 'Expand all guest groups'});
    my $buttonGroupShrink = gui_new_imgbutton({image => 'vm_group_shrink_16px.png', tip => 'Shrink all guest groups'});
    $hboxb->pack_start($buttonGroupExpand, FALSE, FALSE, 2);
    $hboxb->pack_start($buttonGroupShrink, FALSE, FALSE, 2);
    my $toolbarMsgLog = gui_new_toolbar();

    $toolbarMsgLog->insert(my $buttonMsgLogSave = gui_new_toolbutton({image => 'log_viewer_save_32px.png',
                                                                       label => '_Save Message Log',
                                                                       tip   => 'Save the message log to a text file. Useful for debugging purposes'}), -1);

    $toolbarMsgLog->insert(my $buttonMsgLogClear = gui_new_toolbutton({image => 'log_viewer_clear_32px.png',
                                                                        label => '_Clear Message Log',
                                                                        tip   => 'Clear the messsage log'}), -1);

    $gui{d}{Main}{treeviewMsgLog} = gui_new_treeview({model  => $gui{d}{Main}{lstoreMsgLog} = gui_new_lstore(['Glib::String']),
                                                      headers => FALSE,
                                                      tip     => 'History of messages including errors, info and operations'});

    $gui{d}{Main}{treeviewMsgLog}->append_column(gui_new_treeviewcolumn({title   => 'Log',
                                                                          type    => 'text',
                                                                          typecol => 0}));

    $notebookGuest->append_page(my $vboxm = gui_new_box('vertical'), gui_new_imglabel({text => '_Message Log', img => 'show_logs_16px.png'}));
    $vboxm->pack_start($toolbarMsgLog, FALSE, FALSE, 0);
    $vboxm->pack_start(my $scrollLog = gui_new_scrolledwindow(), TRUE, TRUE, 0);
    $scrollLog->add($gui{d}{Main}{treeviewMsgLog});
    $gui{d}{Main}{checkbuttonDetails} = Gtk3::CheckButton->new_with_mnemonic('Show _Extended Info');
    $gui{d}{Main}{checkbuttonDetails}->set_image(gui_new_img_from_file('extended_guest_details_32px.png'));
    $gui{d}{Main}{checkbuttonDetails}->set_tooltip_text("Basic guest information is show when selecting a guest\n* Extended will show more information but may be slower when selecting a guest");

    $gui{d}{Main}{treeviewDetails} = gui_new_treeview({model   => $gui{d}{Main}{tstoreDetails} = gui_new_tstore(['Gtk3::Gdk::Pixbuf', 'Glib::String', 'Glib::String', 'Glib::Uint', 'Glib::Double', 'Glib::String']),
                                                        headers => FALSE,
                                                        tip     => 'Summary details about the guest configuration'});

    $gui{d}{Main}{treeviewDetails}->append_column(gui_new_treeviewcolumn({title   => 'Icon',
                                                                           type    => 'pixbuf',
                                                                           typecol => 0}));

    $gui{d}{Main}{treeviewDetails}->append_column(gui_new_treeviewcolumn({title   => 'Field',
                                                                           type    => 'text',
                                                                           typecol => 1}));

    $gui{d}{Main}{treeviewDetails}->append_column(gui_new_treeviewcolumn({title   => 'Value',
                                                                           type    => 'text',
                                                                           typecol => 2}));

    $notebookGuest->show_all();
    my $notebookMain = Gtk3::Notebook->new();
    $notebookMain->append_page(my $vboxd = gui_new_box('vertical'), gui_new_imglabel({text => 'Guest _Info', img => 'vm_settings_16px.png'}));


    $vboxd->pack_start($gui{d}{Main}{checkbuttonDetails}, FALSE, FALSE, 20);
    $vboxd->pack_start(my $scrollDetails = gui_new_scrolledwindow(), TRUE, TRUE, 0);
    $scrollDetails->add($gui{d}{Main}{treeviewDetails});
    my $toolbarSnap = gui_new_toolbar();

    $toolbarSnap->insert($gui{d}{Main}{buttonTakeSnap} = gui_new_toolbutton({image => 'snapshot_take_32px.png',
                                                                              label => '_Take',
                                                                              tip   => 'Take a snapshot of the guest'}), -1);

    $toolbarSnap->insert($gui{d}{Main}{buttonDelSnap} = gui_new_toolbutton({image => 'snapshot_delete_32px.png',
                                                                             label => '_Delete',
                                                                             tip   => 'Delete the selected snapshot'}), -1);

    $toolbarSnap->insert($gui{d}{Main}{buttonRestoreSnap} = gui_new_toolbutton({image => 'snapshot_restore_32px.png',
                                                                                 label => '_Restore',
                                                                                 tip   => 'Restore the guest to the state saved in the snapshot'}), -1);

    $toolbarSnap->insert($gui{d}{Main}{buttonDetailsSnap} = gui_new_toolbutton({image => 'snapshot_show_details_32px.png',
                                                                                 label => '_Properties',
                                                                                 tip   => 'Show the snapshot properties'}), -1);

    $toolbarSnap->insert($gui{d}{Main}{buttonCloneSnap} = gui_new_toolbutton({image => 'vm_clone_32px.png',
                                                                               label => '_Clone',
                                                                               tip   => 'Create a new guest cloned from the snapshot'}), -1);

    $toolbarSnap->insert($gui{d}{Main}{buttonRefreshSnap} = gui_new_toolbutton({image => 'refresh_32px.png',
                                                                                 label => 'Re_fresh',
                                                                                 tip   => "Refresh the guest\'s snapshot list"}), -1);

    $gui{d}{Main}{treeviewSnap} = gui_new_treeview({model  => $gui{d}{Main}{tstoreSnap} = gui_new_tstore(['Glib::String', 'Glib::String', 'Glib::String', 'Gtk3::Gdk::Pixbuf', 'Glib::Int']),
                                                     headers => FALSE,
                                                     tip     => 'History of messages including errors, info and operations'});

    $gui{d}{Main}{treeviewSnap}->append_column(gui_new_treeviewcolumn({title   => 'Icon',
                                                                        type    => 'pixbuf',
                                                                        typecol => 3}));

    $gui{d}{Main}{treeviewSnap}->append_column(gui_new_treeviewcolumn({title   => 'Name',
                                                                        type    => 'text',
                                                                        weight  => 4,
                                                                        typecol => 0}));

    $gui{d}{Main}{treeviewSnap}->append_column(gui_new_treeviewcolumn({title   => 'Date',
                                                                        type    => 'text',
                                                                        typecol => 1}));

    $notebookMain->append_page(my $vboxs = gui_new_box('vertical'), gui_new_imglabel({text => '_Snapshots', img => 'snapshot_manager_16px.png'}));
    $vboxs->pack_start($toolbarSnap, FALSE, FALSE, 0);
    $vboxs->pack_start(my $scrollSnap = gui_new_scrolledwindow(), TRUE, TRUE, 0);
    $scrollSnap->add($gui{d}{Main}{treeviewSnap});
    $gui{d}{Main}{win}->add(my $vbox = gui_new_box('vertical'));
    $vbox->pack_start($menubar, FALSE, FALSE, 0);
    $vbox->pack_start($toolbar, FALSE, FALSE, 0);
    $vbox->pack_start($gui{d}{Main}{barMem}, FALSE, FALSE, 0);
    $vbox->pack_start(my $hbox = gui_new_box('horizontal'), TRUE, TRUE, 0);
    $hbox->pack_start($notebookGuest, TRUE, TRUE, 0);
    $hbox->pack_start($notebookMain, TRUE, TRUE, 0);
    $notebookMain->show_all();
    # Signals
    $miConnect->signal_connect('activate' => \&show_dialog_connect);
    $miProfiles->signal_connect('activate' => \&show_dialog_profiles);
    $gui{mi}{ImportAppl}->signal_connect('activate' => \&show_dialog_importappl);
    $gui{mi}{ExportAppl}->signal_connect('activate' => \&show_dialog_exportappl);
    $gui{mi}{VMM}->signal_connect('activate' => \&show_dialog_vmm);
    $gui{mi}{HostNetMan}->signal_connect('activate' => \&show_dialog_hostnetman);
    $gui{mi}{ServerInfo}->signal_connect('activate' => \&show_dialog_serverinfo);
    $miPrefs->signal_connect('activate' => \&show_dialog_prefs);
    $gui{mi}{VBPrefs}->signal_connect('activate' => \&show_dialog_vbprefs);
    $miQuit->signal_connect('activate' => \&quit_remotebox);
    $gui{mi}{New}->signal_connect('activate' => \&show_dialog_new_guest);
    $gui{mi}{Add}->signal_connect('activate' => \&show_remote_filechooser, {title       => 'Choose Guest VBox File',
                                                                            entrywidget => '',
                                                                            mode        => 'file',
                                                                            filter      => '^.*\.vbox$',
                                                                            callback    => \&handle_vboxfilechooser});
    $gui{mi}{Settings}->signal_connect('activate' => \&show_dialog_edit);
    $gui{mi}{Clone}->signal_connect('activate' => \&show_dialogClone);
    $gui{mi}{Remove}->signal_connect('activate' => \&remove_guest);
    $gui{mi}{SetGroup}->signal_connect('activate' => \&show_dialog_group);
    $gui{mi}{Ungroup}->signal_connect('activate' => \&clear_group);
    $gui{mi}{Screenshotsavepng}->signal_connect('activate' => \&screenshot);
    $gui{mi}{ScreenshotIcon}->signal_connect('activate' => \&screenshot_to_icon);
    $gui{mi}{ScreenshotReset}->signal_connect('activate' => \&reset_icon);
    $gui{mi}{Logs}->signal_connect('activate' => \&show_dialog_log);
    $gui{mi}{Start}->signal_connect('activate' => \&start_guest);
    $gui{mi}{Pause}->signal_connect('activate' => \&pause_guest);
    $gui{mi}{Resume}->signal_connect('activate' => \&resume_guest);
    $gui{mi}{Discard}->signal_connect('activate' => \&discard_saved_state);
    $gui{mi}{Reset}->signal_connect('activate' => \&reset_guest);
    $gui{mi}{RemoteDisplay}->signal_connect('activate' => \&open_remote_display);
    $gui{mi}{SetVideoCustom}->signal_connect('activate' => \&send_video_hint);
    $miKeyboardCAD->signal_connect(activate => \&keyboard_CAD);
    $miKeyboardRK->signal_connect('activate' => \&keyboard_releasekeys);
    $gui{mi}{Floppy}->signal_connect('activate' => \&fill_menu_floppy);
    $gui{mi}{DVD}->signal_connect('activate' => \&fill_menu_optical);
    $gui{mi}{USB}->signal_connect('activate' => \&fill_menu_usb);
    $gui{mi}{HotPlugCPU}->signal_connect('activate' => \&fill_menu_cpu);
    $miPower->signal_connect('activate' => \&stop_guest_poweroff);
    $miACPI->signal_connect('activate' => \&stop_guest_acpi);
    $miSave->signal_connect('activate' => \&stop_guest_savestate);
    $miPowerButton->signal_connect('activate' => \&stop_guest_poweroff);
    $miACPIButton->signal_connect('activate' => \&stop_guest_acpi);
    $miSaveButton->signal_connect('activate' => \&stop_guest_savestate);
    $miAbout->signal_connect('activate' => \&show_dialog_about);
    $buttonConnect->signal_connect('clicked' => \&show_dialog_connect);
    $gui{d}{Main}{buttonNew}->signal_connect('clicked' => \&show_dialog_new_guest);
    $gui{d}{Main}{buttonSettings}->signal_connect('clicked' => \&show_dialog_edit);
    $gui{d}{Main}{buttonStart}->signal_connect('clicked' => \&start_guest);
    $gui{d}{Main}{buttonStop}->signal_connect('clicked' => \&stop_guest);
    $gui{d}{Main}{buttonDiscard}->signal_connect('clicked' => \&discard_saved_state);
    $gui{d}{Main}{buttonReset}->signal_connect('clicked' => \&reset_guest);
    $gui{d}{Main}{buttonDisplay}->signal_connect('clicked' => \&open_remote_display);
    $gui{d}{Main}{buttonCAD}->signal_connect('clicked' => \&keyboard_CAD);
    $gui{d}{Main}{buttonRefresh}->signal_connect('clicked' => \&fill_list_guest);
    $gui{d}{Main}{treeviewGuest}->signal_connect('button-press-event' => \&show_rmb_menu);
    $gui{d}{Main}{treeviewGuest}->signal_connect('row-activated' => \&show_dialog_edit);
    $signal{Main_treeviewGuest_cursorChanged} = $gui{d}{Main}{treeviewGuest}->signal_connect('cursor-changed' => \&onsel_list_guest);
    $buttonGroupExpand->signal_connect('pressed' => \&group_list_expand);
    $buttonGroupShrink->signal_connect('pressed' => \&group_list_collapse);
    $buttonMsgLogSave->signal_connect('clicked' => \&save_msg_log);
    $buttonMsgLogClear->signal_connect('clicked' => \&clear_msg_log);
    $gui{d}{Main}{treeviewDetails}->signal_connect('row-collapsed' => \&collapse_details_row);
    $gui{d}{Main}{treeviewDetails}->signal_connect('row-expanded' => \&expand_details_row);
    $gui{d}{Main}{checkbuttonDetails}->signal_connect('toggled' => \&extended_details);
    $gui{d}{Main}{treeviewSnap}->signal_connect('row-activated' => \&show_dialog_snap_details);
    $signal{Main_treeviewSnap_cursorChanged} = $gui{d}{Main}{treeviewSnap}->signal_connect('cursor-changed' => \&onsel_list_snapshots);
    $gui{d}{Main}{buttonTakeSnap}->signal_connect('clicked' => \&show_dialog_snapshot);
    $gui{d}{Main}{buttonDelSnap}->signal_connect('clicked' => \&delete_snapshot);
    $gui{d}{Main}{buttonRestoreSnap}->signal_connect('clicked' => \&restore_snapshot);
    $gui{d}{Main}{buttonDetailsSnap}->signal_connect('clicked' => \&show_dialog_snapshot);
    $gui{d}{Main}{buttonCloneSnap}->signal_connect('clicked' => \&show_dialogClone);
    $gui{d}{Main}{buttonRefreshSnap}->signal_connect('clicked' => \&fill_list_snapshots);
    $gui{d}{Main}{win}->signal_connect('delete-event' => \&quit_remotebox);
}

build_dialogAbout();
build_messageDialogsAll();
build_filechooserDialogsAll();
build_dialogCustomResolution();
build_dialogConnect();
build_dialogDecPassword();
build_dialogSharedFolders();
build_dialogCopyFloppy();
build_dialogMoveMedium();
build_dialogCreateFloppy();
build_dialogUSBFilter();
build_dialogImportAppl();
build_dialogExportAppl();
build_dialogClone();
build_dialogPFRule4();
build_dialogPFRule6();
build_dialogHON();
build_dialogSetGroup();
build_dialogVBPrefs();
build_dialogSnapshot();
build_dialogCreateHD();
build_dialogCopyHD();
build_dialogProgress();
build_dialogServerInfo();
build_dialogHostNetMan();
build_dialogHostNetMan();
build_dialogGuestLog();
build_dialogProfile();
build_dialogNew();
build_dialogModifyHD();
build_dialogRDPVNCInfo();
build_dialogPrefs();
build_dialogNAT();
&build_dialogRemoteFileChooser;
build_dialogVMM();
build_dialogEdit();
build_dialogEditGeneral();
build_dialogEditSystem();
build_dialogEditDisplay();
build_dialogEditStorage();
build_dialogEditAudio();
build_dialogEditNetwork();
build_dialogEditIOPorts();
build_dialogEditUSB();
build_dialogEditShared();
build_winMain();

# Transient Window Handling
# A window's transient is automatically set on open
{
    my @winlist = ($gui{d}{Main}{win});

    # Set the transient window's (ie parent window) sensitivity on
    sub transwin_sens_on {
        my ($win) = @_;
        pop @winlist;
        my $transwin = $win->get_transient_for();
        $transwin->set_sensitive(1) if ($transwin);
    }

    # Set the transient window's (ie parent window) sensitivity off
    sub transwin_sens_off {
        my ($win) = @_;
        my $transwin = $winlist[$#winlist]; # Get the last opened window
        push @winlist, $win;
        $win->set_transient_for($transwin) if ($transwin);
        $transwin->set_sensitive(0) if ($transwin);
    }
}

# Ghosts window and optionally sets pointer
sub busy_window {
    my ($window, $sens, $pointer) = @_;
    my $gdkwindow = $window->get_window();
    $window->set_sensitive($sens);
    set_pointer($window, $pointer);
}

# Set's the style of the mouse pointer
sub set_pointer {
    my ($window, $pointer) = @_;
    my $gdkwindow = $window->get_window();

    # If the window is no visible, gdkwindow is empty, so check.
    if ($gdkwindow) {
        if ($pointer) { $gdkwindow->set_cursor(Gtk3::Gdk::Cursor->new($pointer)); }
        else {$gdkwindow->set_cursor(undef); }
    }
    Gtk3::main_iteration while Gtk3::events_pending;
}

sub handle_bioslogofilechooser {
    my ($basedir, $filename) = @_;

    if ($basedir and $filename) {
        $gui{d}{Edit}{entrySysLogo}->set_text(rcatfile($basedir, $filename));
        sys_logo_path();
    }
}

sub handle_videofilechooser {
    my ($basedir, $filename) = @_;

    if ($basedir and $filename) {
        $gui{d}{Edit}{entryDispRecordingpath}->set_text(rcatfile($basedir, $filename));
        disp_cap_path();
    }
}

sub handle_remote_folder_entry {
    my ($basedir, $filearr, $entrywidget) = @_;
    my $file = ${$filearr}[0]->{FileName};
    my $type = ${$filearr}[0]->{Type};

    # Depending on what the user does, there will either be an additional directory
    # to append or not. Type (Dir) already excludes (Parent)
    $basedir = rcatdir($basedir, $file) if ($file and $type eq '(Dir)');
    $entrywidget->set_text($basedir) if ($basedir and $entrywidget);
}

sub handle_remote_file_entry {
    my ($basedir, $file, $entrywidget) = @_;
    $entrywidget->set_text(rcatfile($basedir, $file)) if ($basedir and $file and $entrywidget);
}

sub handle_snapshotfolderchooser {
    my ($location, $filearrayref) = @_;
    my $file = ${$filearrayref}[0]->{FileName};
    my $type = ${$filearrayref}[0]->{Type};

    # Depending on what the user does, there will either be an additional directory
    # to append or not. Type (Dir) already excludes (Parent)
    $location = rcatdir($location, $file) if ($file and $type eq '(Dir)');
    $gui{d}{Edit}{entryGenSnapfolder}->set_text($location) if ($location);
    gen_snapfolder();
}

sub handle_vboxfilechooser {
    my ($basedir, $filename) = @_;

    if ($basedir and $filename) {
        my $vboxfile = rcatfile($basedir, $filename);
        my $IMachine = IVirtualBox_openMachine($gui{websn}, $vboxfile);
        if ($IMachine) {
            IVirtualBox_registerMachine($gui{websn}, $IMachine);
            addrow_msg_log("Imported guest from $vboxfile");
            fill_list_guest();
        }
        else { addrow_msg_log("Failed to import guest from $vboxfile"); }
    }
}

sub show_remote_filechooser {
    my ($widget, $data) = @_;
    # Set to the deference entry widget  if it exists or empty
    my $entrywidget = ($$data{entrywidget}) ? ${$$data{entrywidget}} : '';
    my $vhost = vhost();
    my $basedir;
    $gui{d}{RemoteFileChooser}{dialog}->set_title($$data{title} . " $endpoint");
    $gui{d}{RemoteFileChooser}{entryFilter}->set_text($$data{filter});

    if ($$data{mode} eq 'dir') {
        $gui{d}{RemoteFileChooser}{treeviewFile}->get_selection->set_mode('GTK_SELECTION_SINGLE');
        $gui{d}{RemoteFileChooser}{boxFile}->hide();
        $basedir = $entrywidget->get_text() if ($$data{entrywidget});
    }
    elsif ($$data{mode} eq 'multifile') {
        $gui{d}{RemoteFileChooser}{treeviewFile}->get_selection->set_mode('GTK_SELECTION_MULTIPLE');
        $gui{d}{RemoteFileChooser}{boxFile}->hide();
        $basedir = $entrywidget->get_text() if ($$data{entrywidget});
    }
    else {
        $gui{d}{RemoteFileChooser}{treeviewFile}->get_selection->set_mode('GTK_SELECTION_SINGLE');
        $gui{d}{RemoteFileChooser}{boxFile}->show();

        if ($$data{entrywidget}) {
            my ($vol, $dir, $file) = rsplitpath($entrywidget->get_text());
            $basedir = $vol . $dir;
            $gui{d}{RemoteFileChooser}{entryFile}->set_text($file) if ($file);
        }
    }

    $basedir = $$vhost{machinedir} unless ($basedir);
    my $IAppliance = IVirtualBox_createAppliance($gui{websn});
    $gui{IVFSExplorer} = IAppliance_createVFSExplorer($IAppliance, "file://$basedir");
    fill_list_remotefiles($basedir, $$data{filter});
    $gui{d}{RemoteFileChooser}{dialog}->show_all();
    my $response = $gui{d}{RemoteFileChooser}{dialog}->run();
    $gui{d}{RemoteFileChooser}{dialog}->hide();
    IManagedObjectRef_release($gui{IVFSExplorer});
    IManagedObjectRef_release($IAppliance);

    if ($response eq 'ok') {
        my $location = $gui{d}{RemoteFileChooser}{entryLocation}->get_text();
        my $filename = $gui{d}{RemoteFileChooser}{entryFile}->get_text();

        if ($$data{mode} eq 'file') {
            &{$$data{callback}}($location, $filename, $entrywidget)
        }
        else {
            my $filearrayref;
            $filearrayref = getsel_list_remotefiles();
            &{$$data{callback}}($location, $filearrayref, $entrywidget); # Execute the handler
        }
    }

    return $gui{d}{RemoteFileChooser}{entryLocation}->get_text();
}

# Refreshes the contents of the file chooser
sub refresh_remotefilechooser {
    fill_list_remotefiles($gui{d}{RemoteFileChooser}{entryLocation}->get_text(), $gui{d}{RemoteFileChooser}{entryFilter}->get_text());
}

# Moves to the parent directory in the file chooser
sub cdup_remotefilechooser {
    IVFSExplorer_cdUp($gui{IVFSExplorer});
    fill_list_remotefiles(IVFSExplorer_getPath($gui{IVFSExplorer}), $gui{d}{RemoteFileChooser}{entryFilter}->get_text());
}

# Permit certain chars only for a guest name
sub valid_guestname_char {
    my ($entry) = @_;
    my $text = $entry->get_text();

    # Test first then modify to avoid infinite loops on repeated signal emission
    if ($text =~ m/[\?\/\;\*\\\<\>\|\.]/) {
        $text =~ s/[\?\/\;\*\\\<\>\|\.]//g;
        $entry->set_text($text);
    }
}

# Permit only certains chars for group names
sub valid_group_char {
    my ($entry) = @_;
    my $text = $entry->get_text();

    # Test first then modify to avoid infinite loops on repeated signal emission
    if ($text =~ m/[^\w\/]/) {
        $text =~ s/[^\w\/]//g;
        $entry->set_text($text);
    }
}

# Basic character validation for hexadecimal
sub valid_hex_char {
    my ($entry) = @_;
    my $text = $entry->get_text();

    # Test first then modify to avoid infinite loops on repeated signal emission
    if ($text =~ m/[^A-F0-9a-f]/) {
        $text =~ s/[^A-F0-9a-f]//g;
        $entry->set_text($text);
    }
}

# Basic character validation for a port range
sub valid_portrange_char {
    my ($entry) = @_;
    my $text = $entry->get_text();

    # Test first then modify to avoid infinite loops on repeated signal emission
    if ($text =~ m/[^0-9,-]/) {
        $text =~ s/[^0-9,-]//g;
        $entry->set_text($text);
    }
}

# Permit only numbers in an entry
sub valid_number_char {
    my ($entry) = @_;
    my $text = $entry->get_text();

    # Test first then modify to avoid infinite loops on repeated signal emission
    if ($text =~ m/[^0-9]/) {
        $text =~ s/[^0-9]//g;
        $entry->set_text($text);
    }
}

# Realtime ipv4 char validation
sub valid_ipv4_char {
    my ($entry) = @_;
    my $text = $entry->get_text();

    # Test first then modify to avoid infinite loops on repeated signal emission
    if ($text =~ m/[^0-9\.]/) {
        $text =~ s/[^0-9\.]//g;
        $entry->set_text($text);
    }
}

# Realtime ipv6 char validation
sub valid_ipv6_char {
    my ($entry) = @_;
    my $text = $entry->get_text();

    # Test first then modify to avoid infinite loops on repeated signal emission
    if ($text =~ m/[^0-9a-fA-F:]/) {
        $text =~ s/[^0-9a-fA-F:]//g;
        $entry->set_text($text);
    }
}

# Basic character validation for CIDR
sub valid_cidr_char {
    my ($entry) = @_;
    my $text = $entry->get_text();

    # Test first then modify to avoid infinite loops on repeated signal emission
    if ($text =~ m/[^0-9\.\/]/) {
        $text =~ s/[^0-9\.\/]//g;
        $entry->set_text($text);
    }
}

# Validate an IPv4 CIDR
sub valid_cidr {
    # Doesn't appear to be an equiv in Regex::Common
    return 1 if ($_[0] =~ m/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(\d|[1-2]\d|3[0-2]))$/);
    return 0;
}

# Validate an IPv4 Address
sub valid_ipv4 {
    my ($ip) = @_;

    if ($ip =~ /^$RE{net}{IPv4}$/) { return 1; }
    else { return 0; }
}

# Validate an IPv4 Address
sub valid_ipv6 {
    my ($ip) = @_;

    if ($ip =~ /^$RE{net}{IPv6}$/) { return 1; }
    else { return 0; }
}

# Adds appropriate units to a spinbox when specifying memory or disk
sub sb_bytes_out {
    my ($widget) = @_;
    my $txt = $widget->get_text();
    my $adjustment = $widget->get_adjustment();
    my $adjval = int($adjustment->get_value());

    if ($adjval < 1024) {
        $adjustment->set_step_increment(1.00);
        $txt = "$adjval MB";
    }
    elsif ($adjval < 1048576) {
        $adjustment->set_step_increment(10.25);
        $adjval /= 1024;
        $txt = sprintf('%0.2f GB', $adjval);
    }
    else {
        $adjustment->set_step_increment(10486);
        $adjval /= 1048576;
        $txt = sprintf('%0.2f TB', $adjval);
    }

    $widget->set_text($txt);
    return 1;
}

# Parses the input and assumes m is mega, g is Giga and t is tera
sub sb_bytes_in {
    my ($widget) = @_;
    my $txt = $widget->get_text();

    if ($txt =~ m/m/i) {
        $txt =~ s/[^\d.]//g; # Strip all except digits and .
        $txt =~ s/\.+/\./; # Handle many . here but wont catch 3.5.3.5 for example
        $widget->get_adjustment->set_value(int($txt)); # Force to be an integer, can't have <1MB
    }
    elsif ($txt =~ m/g/i) {
        $txt =~ s/[^\d.]//g; # Strip all except digits and .
        $txt =~ s/\.+/\./; # Handle many . here but wont catch 3.5.3.5 for example
        $txt = ($txt * 1024);
        $widget->get_adjustment->set_value($txt);
    }
    elsif ($txt =~ m/t/i) {
        $txt =~ s/[^\d.]//g; # Strip all except digits and .
        $txt =~ s/\.+/\./; # Handle many . here but wont catch 3.5.3.5 for example
        $txt = ($txt * 1048576);
        $widget->get_adjustment->set_value($txt);
    }

    return 0;
}

# Adds appropriate unit to a spinbox based on ms as the basic timeval
sub sb_time_ms_in {
    my ($widget) = @_;
    my $txt = $widget->get_text();

    if ($txt =~ m/ms/i) {
        $txt =~ s/[^\d.]//g; # Strip all except digits and .
        $txt =~ s/\.+/\./; # Handle many . here but wont catch 3.5.3.5 for example
        $widget->get_adjustment->set_value(int($txt));
    }
    elsif ($txt =~ m/sec/i) {
        $txt =~ s/[^\d.]//g; # Strip all except digits and .
        $txt =~ s/\.+/\./; # Handle many . here but wont catch 3.5.3.5 for example
        $txt = ($txt * 1000);
        $widget->get_adjustment->set_value($txt);
    }
    elsif ($txt =~ m/min/) {
        $txt =~ s/[^\d.]//g; # Strip all except digits and .
        $txt =~ s/\.+/\./; # Handle many . here but wont catch 3.5.3.5 for example
        $txt = ($txt * 60000);
        $widget->get_adjustment->set_value($txt);
    }

    return 0;
}

# Adds appropriate unit to a spinbox based on ms as the basic timeval
sub sb_time_ms_out {
    my ($widget) = @_;
    my $txt = $widget->get_text();
    my $adjustment = $widget->get_adjustment();
    my $adjval = int($adjustment->get_value());

    if ($adjval < 1000) {
        $adjustment->set_step_increment(1.00);
        $txt = "$adjval ms";
    }
    elsif ($adjval < 60000) {
        $adjustment->set_step_increment(100.00);
        $adjval /= 1000;
        $txt = sprintf('%0.2f secs', $adjval);
    }
    else {
        $adjustment->set_step_increment(600.00);
        $adjval /= 60000;
        $txt = sprintf('%0.2f mins', $adjval);
    }

    $widget->set_text($txt);
    return 1;
}

# Adds appropriate unit to a spinbox based on seconds as the basic timeval
sub sb_time_s_in {
    my ($widget) = @_;
    my $txt = $widget->get_text();

    if ($txt =~ m/sec/i) {
        $txt =~ s/[^\d]//g; # Strip all except digits
        $widget->get_adjustment->set_value(int($txt));
    }
    elsif ($txt =~ m/min/) {
        $txt =~ s/[^\d.]//g; # Strip all except digits and .
        $txt =~ s/\.+/\./; # Handle many . here but wont catch 3.5.3.5 for example
        $txt = ($txt * 60);
        $widget->get_adjustment->set_value($txt);
    }

    return 0;
}

# Adds appropriate unit to a spinbox based on seconds as the basic timeval
sub sb_time_s_out {
    my ($widget) = @_;
    my $txt = $widget->get_text();
    my $adjustment = $widget->get_adjustment();
    my $adjval = int($adjustment->get_value());

    if ($adjval < 60) {
        $adjustment->set_step_increment(1.00);
        $txt = "$adjval secs";
    }
    else {
        $adjustment->set_step_increment(6.00);
        $adjval /= 60;
        $txt = sprintf('%0.2f mins', $adjval);
    }

    $widget->set_text($txt);
    return 1;
}

# FIXME not actually used
# Adds appropriate units to a spinbox when specifying percent
sub spinbox_pc_out {
    my ($widget) = @_;
    my $adjustment = $widget->get_adjustment();
    my $adjval = int($adjustment->get_value());
    $widget->set_text($adjval . '%');
    return 1;
}

# FIXME not actually used
# Handles a percent when specified in a spinbox
sub spinbox_pc_in {
    my ($widget) = @_;
    my $txt = $widget->get_text();

    if ($txt =~ m/\%/) {
        $txt =~ s/[^\d.]//g; # Strip all except digits and .
        $widget->get_adjustment->set_value(int($txt));
    }

    return 0;
}

# Creates an optionally filled liststore, filled if $cols exists
sub gui_new_lstore {
    my ($coldef, $cols, $data) = @_;
    my $lstore = Gtk3::ListStore->new($coldef);

    foreach my $row (@{$data}) {
        my $iter = $lstore->append();
        $lstore->set($iter, $cols, $row);
    }

    return $lstore;
}

# Creates an empty TreeStore
sub gui_new_tstore {
    my ($coldef) = @_;
    my $tstore = Gtk3::TreeStore->new($coldef);
    return $tstore;
}

# Creates a standard label for the left side of widget
# text : text to place on the label
# mnwidget : The associated mnemonic widget for the label
# xalign : The xalignment (optional)
sub gui_new_widgetlabel {
    my ($p) = @_;
    my $label = Gtk3::Label->new_with_mnemonic($p->{text});
    $label->set_justify('GTK_JUSTIFY_LEFT');
    $label->set_mnemonic_widget($p->{mnwidget}) if ($p->{mnwidget});
    $label->set_xalign($p->{xalign} // 1);
    $label->set_yalign(0.5);
    $label->set_margin_right(5);
    $label->set_vexpand(FALSE);
    $label->show_all();
    return $label;
}

# Creates a dialog title label
# text : text to place on the label
sub gui_new_titlelabel {
    my ($p) = @_;
    my $label = Gtk3::Label->new();
    $label->set_markup("<b><big>$p->{text}</big></b>");
    $label->set_margin_bottom(5);
    $label->show();
    return $label;
}

# Creates a warning label
# text : text to place on the label
sub gui_new_warnlabel {
    my ($p) = @_;
    my $label = Gtk3::Label->new();
    $label->set_markup("<span foreground='red' weight='bold'>$p->{text}</span>");
    $label->set_margin_bottom(5);
    $label->show();
    return $label;
}

# Creates a markup label
# text : Text to place on the lbale
sub gui_new_markuplabel {
    my ($p) = @_;
    my $label = Gtk3::Label->new();
    $label->set_markup($p->{text});
    $label->set_vexpand(FALSE);
    $label->set_xalign($p->{xalign} // 0.5);
    $label->set_justify('GTK_JUSTIFY_CENTER');
    $label->set_margin_bottom(5);
    $label->show_all();
    return $label;
}

# Create a standard Grid
sub gui_new_grid {
    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(5);
    $grid->set_column_spacing(5);
    # Note, there is no set_margin call
    $grid->set_margin_top(5);
    $grid->set_margin_bottom(5);
    $grid->set_margin_right(5);
    $grid->set_margin_left(5);
    $grid->show_all();
    return $grid;
}

# Create a standard box
# oritentation: Whether vertical or horizontal
sub gui_new_box{
    my ($orientation) = @_;
    my $box = Gtk3::Box->new($orientation, 2);
    $box->set_homogeneous(FALSE);
    $box->show_all();
    return $box;
}

# Create a standard spinbutton
# lo = Lowest value for range - May get overriden by an adjustment
# hi = highest value for range - May get overriden by an adjustment
# inc = Amount to increment by - May get overriden by an adjustment
# maxlen = Maximum length in chars - May get overriden by an adjustment
# decplaces = Amount of decimal places (optional)
# adj = An adjustment widget (optional)
# numeric : Whether numeric only or not
sub gui_new_spinbutton {
    my ($p) = @_;
    my $spinbutton = Gtk3::SpinButton->new_with_range($p->{lo}, $p->{hi}, $p->{inc});
    $spinbutton->set_digits($p->{decplaces}) if (defined($p->{decplaces}));
    $spinbutton->set_tooltip_text($p->{tip});
    $spinbutton->set_numeric($p->{numeric} // TRUE);
    $spinbutton->set_hexpand(TRUE);
    $spinbutton->set_max_length($p->{maxlen}) if ($p->{maxlen});
    $spinbutton->set_adjustment($p->{adj}) if ($p->{adj});
    $spinbutton->set_update_policy('if-valid');
    $spinbutton->show();
    return $spinbutton
}

# Create a standard entry field
# width : Width of entry in chars
# maxlen : Maximum length of contents in chars
# pass : If present, sets it to a password entry
sub gui_new_entry {
    my ($p) = @_;
    my $entry = Gtk3::Entry->new();
    $entry->set_tooltip_text($p->{tip});
    $entry->set_hexpand(TRUE);
    $entry->set_vexpand(FALSE);
    $entry->set_width_chars($p->{width}) if ($p->{width});
    $entry->set_max_length($p->{maxlen}) if ($p->{maxlen});

    if ($p->{pass}) {
        $entry->set_visibility(FALSE);
        $entry->set_input_purpose('GTK_INPUT_PURPOSE_PASSWORD');
    }

    $entry->show_all();
    return $entry;
}

# Create a standard image only button
# image : The image filename to add to the button
sub gui_new_imgbutton {
    my ($p) = @_;
    my $button = Gtk3::Button->new();
    $button->set_image(gui_new_img_from_file($p->{image}));
    $button->set_tooltip_text($p->{tip});
    $button->set_hexpand(FALSE);
    $button->set_hexpand(FALSE);
    $button->set_relief('GTK_RELIEF_NONE');
    $button->show_all();
    return $button
}

# Create a standard text button
# image : The image filename to add to the button
sub gui_new_button {
    my ($p) = @_;
    my $button = Gtk3::Button->new_with_mnemonic($p->{label});
    $button->set_tooltip_text($p->{tip});
    $button->set_hexpand(FALSE);
    $button->set_hexpand(FALSE);
    $button->show_all();
    return $button
}

# Create a standard image only button
# image : The image filename to add to the button
# label : The label for the button
sub gui_new_toolbutton {
    my ($p) = @_;
    my $button = Gtk3::ToolButton->new(gui_new_img_from_file($p->{image}), $p->{label});
    $button->set_tooltip_text($p->{tip});
    $button->set_hexpand(FALSE);
    $button->set_hexpand(FALSE);
    $button->set_use_underline(TRUE);
    $button->show_all();
    return $button
}

# Create a standard image only button
# image : The image filename to add to the button
# label : The label for the button
sub gui_new_menutoolbutton {
    my ($p) = @_;
    my $button = Gtk3::MenuToolButton->new(gui_new_img_from_file($p->{image}), $p->{label});
    $button->set_tooltip_text($p->{tip});
    $button->set_hexpand(FALSE);
    $button->set_hexpand(FALSE);
    $button->set_use_underline(TRUE);
    $button->show_all();
    return $button
}

# Create a standard toolbar
sub gui_new_toolbar {
    my $toolbar = Gtk3::Toolbar->new();
    $toolbar->set_show_arrow(FALSE);
    $toolbar->set_hexpand(TRUE);
    $toolbar->set_vexpand(FALSE);
    $toolbar->set_style('GTK_TOOLBAR_BOTH');
    $toolbar->show_all();
    return $toolbar
}

# Creates a new standard dialog
# title: Title of the dialog
# ok : Specify an alternative name for the OK button : optional
# okimage : Specify an image to show on the OK button : optional
sub gui_new_dialog {
    my ($p) = @_;
	my $dialog = Gtk3::Dialog->new($p->{title}, undef, 'GTK_DIALOG_MODAL'); # Transient is determined automatically
    $dialog->set_type_hint('GDK_WINDOW_TYPE_HINT_DIALOG');
    $dialog->set_skip_taskbar_hint(TRUE);
    $dialog->add_button('Cancel', 'cancel') if ($p->{cancel});
    my $okbutton = $p->{ok} ? $dialog->add_button($p->{ok}, 'ok') : $dialog->add_button('OK', 'ok');

    if ($p->{okimage}) {
        $okbutton->set_always_show_image(TRUE);
        $okbutton->set_image($p->{okimage});
        $okbutton->set_image_position('GTK_POS_LEFT');
    }

    $dialog->set_position('GTK_WIN_POS_CENTER_ON_PARENT');
    $dialog->set_destroy_with_parent(TRUE);
    $dialog->set_mnemonics_visible(TRUE);
    $dialog->set_focus_visible(TRUE);
    $dialog->set_decorated(TRUE);
    $dialog->set_accept_focus(TRUE);
    $dialog->set_deletable(FALSE);
    $dialog->set_default_response('ok');
    $dialog->set_icon_name("$sharedir/icons/remotebox.png");
    $dialog->set_icon(gui_new_pixbuf_from_file('remotebox.png'));
    $dialog->signal_connect('hide' => \&transwin_sens_on, $dialog);
    $dialog->signal_connect('show' => \&transwin_sens_off, $dialog);
    return $dialog;
}

# Create a standard layout widget
sub gui_new_layout {
    my $layout = Gtk3::Layout->new();
    $layout->set_vexpand(TRUE);
    $layout->show_all();
    return $layout;
}

sub gui_destroy_dialog {
    my ($widget, $response_id) = @_;
	$widget->destroy();
}

# Create a cell renderer
sub gui_new_cellrenderer {
    my ($type) = @_;
    return Gtk3::CellRendererToggle->new() if $type eq 'toggle';
    warn "WARNING: No cellrenderer type '$type' has been defined\n";
    return undef;
}

# Create an image widget from a file
sub gui_new_img_from_file {
    my ($filename, $parent) = @_;
    my $img = Gtk3::Image->new_from_file("$sharedir/icons/$filename");

    if ($parent) {
        if ($parent->isa('Gtk3::ToolButton') or $parent->isa('Gtk3::MenuToolButton')) { $parent->set_icon_widget($img); }
        else { $parent->set_image($img); }
    }

    $img->show();
    return $img;
}

# Create a pixbuf from a file
sub gui_new_pixbuf_from_file {
    my ($filename) = @_;
    my $pb = Gtk3::Gdk::Pixbuf->new_from_file("$sharedir/icons/$filename");
    return $pb;
}

# Create a base menu
sub gui_new_menu {
    my $menu = Gtk3::Menu->new();
    $menu->set_reserve_toggle_size(TRUE);
    return $menu;
}

# Menu Item with optional image
sub gui_new_menu_item {
    my ($label, $imgfile, $parent) = @_;
    my $item = Gtk3::ImageMenuItem->new_with_mnemonic($label);

    if ($imgfile) {
        $item->set_image(Gtk3::Image->new_from_file("$sharedir/icons/$imgfile"));
        $item->set_always_show_image(TRUE);
    }

    $parent->append($item) if ($parent);
    $item->show_all();
    return $item;
}

# Menu Item with optional image and no mnemoinc
sub gui_new_menu_item_no_mnemonic {
    my ($label, $imgfile, $parent) = @_;
    my $item = Gtk3::ImageMenuItem->new_with_label($label);

    if ($imgfile) {
        $item->set_image(Gtk3::Image->new_from_file("$sharedir/icons/$imgfile"));
        $item->set_always_show_image(TRUE);
    }

    $parent->append($item) if ($parent);
    $item->show_all();
    return $item;
}

# Menu Item with checkmark
sub gui_new_check_menu_item {
    my ($label, $parent) = @_;
    my $item = Gtk3::CheckMenuItem->new_with_label($label);
    $parent->append($item) if ($parent);
    $item->show_all();
    return $item;
}

# Creates an adjustment and optionally attaches it
sub gui_new_adjustment {
    my ($parent, $init, $lower, $upper, $stepinc, $pageinc, $pagesize) = @_;
    my $adj = Gtk3::Adjustment->new($init, $lower, $upper, $stepinc, $pageinc, $pagesize);
    $parent->set_adjustment($adj) if ($parent);
    return $adj;
}

# Creates a new simple text only combobox
# model : The liststore to attach (optional)
# active : The item index to make default, otheriwse -1 will be
sub gui_new_simplecombobox {
    my ($p) = @_;
    my $combobox = Gtk3::ComboBox->new();

    if ($p->{model}) {
        $combobox->set_model($p->{model});
        $combobox->set_active(defined $p->{active} ? $p->{active} : -1);
    }
    my $cellrenderer = Gtk3::CellRendererText->new();
    $combobox->pack_start($cellrenderer, TRUE);
    $combobox->add_attribute($cellrenderer, 'text', 0);
    $combobox->set_tooltip_text($p->{tip});
    $combobox->set_hexpand(TRUE);
    $combobox->set_vexpand(FALSE);
    $combobox->show_all();
    return $combobox;
}

# Creates a new simple text only combobox
# model : The liststore to attach (optional)
# active : The item index to make default, otheriwse -1 will be
sub gui_new_entrycombobox {
    my ($p) = @_;
    my $combobox = Gtk3::ComboBoxText->new_with_entry();

    if ($p->{model}) {
        $combobox->set_model($p->{model});
        $combobox->set_active(defined $p->{active} ? $p->{active} : -1);
    }

    $combobox->set_tooltip_text($p->{tip});
    $combobox->set_hexpand(TRUE);
    $combobox->set_vexpand(FALSE);
    $combobox->show_all();
    return $combobox;
}

# Creates a new image combobox
# model : The liststore to attach (optional)
# active : The item index to make default, otheriwse -1 will be
sub gui_new_imgcombobox {
    my ($p) = @_;
    my $combobox = Gtk3::ComboBox->new();

    if ($p->{model}) {
        $combobox->set_model($p->{model});
        $combobox->set_active(defined $p->{active} ? $p->{active} : -1);
    }

    my $cellrenderertext = Gtk3::CellRendererText->new();
    $cellrenderertext->set_alignment(0.0, 0.5);
    $cellrenderertext->set_padding(5, 5);
    my $cellrendererpb = Gtk3::CellRendererPixbuf->new();
    $cellrendererpb->set_alignment(0.0, 0.5);
    $combobox->pack_start($cellrendererpb, FALSE);
    $combobox->add_attribute($cellrendererpb, 'pixbuf', $p->{imgcol});
    $combobox->pack_start($cellrenderertext, TRUE);
    $combobox->add_attribute($cellrenderertext, 'text', 0);
    $combobox->set_tooltip_text($p->{tip});
    $combobox->set_hexpand(TRUE);
    $combobox->set_vexpand(FALSE);
    $combobox->show_all();
    return $combobox;
}

# Creates a new standard treeview
# model : The liststore / treestore to attach (optional)
sub gui_new_treeview {
    my ($p) = @_;
    my $treeview = $p->{model}
        ? Gtk3::TreeView->new_with_model($p->{model})
        : Gtk3::TreeView->new();

    $treeview->set_tooltip_text($p->{tip});
    $treeview->set_headers_visible($p->{headers}) if (defined($p->{headers}));
    $treeview->set_hexpand(TRUE);
    $treeview->set_vexpand(TRUE);
    $treeview->set_margin_top(5);
    $treeview->set_margin_bottom(5);
    $treeview->show_all();
    return $treeview;
}

# Creates a new standard treeviewcolumn
# model : The liststore / treestore to attach (optional)
# type : The type such as text
# typecol : The column in the model to pull it from
sub gui_new_treeviewcolumn {
    my ($p) = @_;

    my $cellrenderer = ($p->{type} eq 'pixbuf')
        ? Gtk3::CellRendererPixbuf->new
        : Gtk3::CellRendererText->new;

    # Can't use new_with_attributes because we need pack_start to be FALSE
    my $treeviewcol = Gtk3::TreeViewColumn->new();
    $treeviewcol->set_title($p->{title});
    $treeviewcol->set_sizing('GTK_TREE_VIEW_COLUMN_AUTOSIZE');
    $treeviewcol->set_resizable(TRUE);
    $treeviewcol->pack_start($cellrenderer, FALSE);
    $treeviewcol->add_attribute($cellrenderer, $p->{type}, $p->{typecol});
    $treeviewcol->add_attribute($cellrenderer, 'weight', $p->{weight}) if ($p->{weight});
    $treeviewcol->set_clickable(TRUE);
    return $treeviewcol;
}

# Creates a new standard toggle treeviewcolumn
# model : The liststore / treestore to attach (optional)
# type : The type such as text
# typecol : The column in the model to pull it from
# toggle : True if the celltendered should be a toggle type (optional)
sub gui_new_treeviewcolumntoggle {
    my ($p) = @_;
    my $cellrenderer = Gtk3::CellRendererToggle->new();
    # Can't use new with attributes because pak_start is FALSE
    my $treeviewcol = Gtk3::TreeViewColumn->new();
    $treeviewcol->set_title($p->{title});
    $treeviewcol->set_sizing('GTK_TREE_VIEW_COLUMN_AUTOSIZE');
    $treeviewcol->set_resizable(TRUE);
    $treeviewcol->set_clickable(TRUE);
    $treeviewcol->pack_start($cellrenderer, FALSE);
    $treeviewcol->add_attribute($cellrenderer, $p->{type}, $p->{typecol});
    return ($treeviewcol, $cellrenderer);
}

# Creates a standard frame
# label - Title label for the frame
sub gui_new_frame {
    my ($p) = @_;
    my $frame = Gtk3::Frame->new($p->{label});
    $frame->set_label_align(0.0, 0.5);
    $frame->set_shadow_type('GTK_SHADOW_ETCHED_OUT');
    $frame->show_all();
    return $frame
}

# Create a standard check widget
# text : The text next to the checkmark
# active : If the checkmark should be set active or not
sub gui_new_check {
    my ($p) = @_;
    my $check = Gtk3::CheckButton->new_with_mnemonic($p->{text});
    $check->set_active($p->{active});
    $check->set_tooltip_text($p->{tip});
    $check->set_vexpand(FALSE);
    $check->show_all();
    return $check;
}

# Creates a standard radio button
# text : The text to display next to the radio button
# group : The radio button group
# active: Whether it is active or not
sub gui_new_radio {
    my ($p) = @_;
    my $radiobutton = Gtk3::RadioButton->new_with_mnemonic($p->{group}, $p->{text});
    $radiobutton->set_active($p->{active});
    $radiobutton->set_tooltip_text($p->{tip});
    $radiobutton->set_vexpand(FALSE);
    $radiobutton->show_all();
    return $radiobutton
}

# Creates a standard scrolled window
sub gui_new_scrolledwindow {
    my ($p) = @_;
    my $scrollwin = Gtk3::ScrolledWindow->new();
    $scrollwin->set_propagate_natural_height(TRUE);
    $scrollwin->set_propagate_natural_width(TRUE);
    $scrollwin->show_all();
    return $scrollwin;
}

# Creates a standard textview
# editable - Whether it is editable
# buffer - The textbuffer object
sub gui_new_textview {
    my ($p) = @_;
    my $textview = Gtk3::TextView->new_with_buffer($p->{buffer});
    $textview->set_editable($p->{editable});
    $textview->set_tooltip_text($p->{tip});
    $textview->set_wrap_mode('word');
    $textview->set_hexpand(TRUE);
    $textview->set_vexpand(TRUE);
    $textview->show_all();
    return $textview;
}

# Creates a standard button box
# oritentation - Whether vertical or horizontal
sub gui_new_buttonbox {
    my ($p) = @_;
    my $bb = Gtk3::ButtonBox->new($p->{orientation});
    $bb->set_hexpand(FALSE);
    $bb->set_vexpand(FALSE);
    $bb->set_layout('GTK_BUTTONBOX_CENTER');
    $bb->show_all();
    return $bb;
}

# Creates a standhard horizontal separator
sub gui_new_separator {
    my $sep = Gtk3::Separator->new('horizontal');
    $sep->set_hexpand(TRUE);
    $sep->set_vexpand(FALSE);
    $sep->set_margin_top(10);
    $sep->set_margin_bottom(10);
    $sep->show_all();
    return $sep;
}

# Creates a standhard horizontal scale
# adj : The adjustment to attach
# decplaces = Amount of decimal places (optional)
sub gui_new_scale {
    my ($p) = @_;
    my $scale = Gtk3::Scale->new('horizontal', $p->{adj});
    $scale->set_hexpand(TRUE);
    $scale->set_vexpand(FALSE);
    $scale->set_digits($p->{decplaces}) if (defined($p->{decplaces}));
    $scale->set_show_fill_level(TRUE);
    $scale->set_restrict_to_fill_level(TRUE);
    $scale->set_draw_value($p->{showvalue} // 0);
    $scale->set_tooltip_text($p->{tip});
    $scale->show_all();
    return $scale;
}

# Creates a standard label and image for a notebook tab
# text : text to place on the label
# img : img next to the label
sub gui_new_imglabel {
    my ($p) = @_;
    my $box = gui_new_box('horizontal');
    my $label = Gtk3::Label->new_with_mnemonic($p->{text});
    $label->set_justify('GTK_JUSTIFY_LEFT');
    $label->set_xalign($p->{xalign} // 0);
    $label->set_yalign(0.5);
    $label->set_hexpand(FALSE);
    $label->set_vexpand(FALSE);
    $box->pack_start(gui_new_img_from_file($p->{img}), FALSE, FALSE, 5);
    $box->pack_start($label, FALSE, FALSE, 0);
    $box->show_all();
    return $box;
}

1;
