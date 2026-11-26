# Native Windows build

RemoteBox runs natively on Windows (no WSL or X server) using the MSYS2 UCRT64
builds of Perl and GTK 3.

## Setting up the build environment

From PowerShell, in the repository root (admin rights are not needed):

    powershell -ExecutionPolicy Bypass -File misc\windows\setup-msys2.ps1 [-Msys2Root C:\msys64]

This downloads and extracts MSYS2 if it is not already present, updates it,
installs GTK 3 and the Perl modules RemoteBox needs. The Perl GTK bindings are
not packaged by MSYS2, so they are built from CPAN. The script is safe to re-run.

Some MSYS2 mirrors rate-limit downloads (HTTP 429). pacman therefore downloads
one package at a time and failed runs are retried with increasing pauses (10s,
20s, 40s, 80s); packages already downloaded are kept. On a fast, reliable
connection `-ParallelDownloads 5` restores pacman's default speed.

Then run RemoteBox from the source tree:

    misc\windows\remotebox-dev.cmd

To run Perl directly instead, `C:\msys64\ucrt64\bin` must come **first** in
`PATH`. Perl does not search its own directory for the DLLs that XS modules
such as Glib and Cairo depend on, and older copies of shared DLLs from other
toolchains (Strawberry Perl, TDM-GCC, ...) elsewhere on `PATH` break loading:

    set PATH=C:\msys64\ucrt64\bin;%PATH%
    perl remotebox

## Building the installer

After setting up the build environment (re-run `setup-msys2.ps1` if it was
set up before NSIS was added to it):

    powershell -ExecutionPolicy Bypass -File misc\windows\make-installer.ps1 [-OutDir <dir>]

This produces, in `misc\windows\build` by default:

* `RemoteBox\` - a self-contained application folder. It can be copied anywhere
  and started with `RemoteBox.exe`; nothing needs to be installed.
* `RemoteBox-<version>-win64-setup.exe` - an installer for that folder.

The version is taken from the header of the `remotebox` script.

The application folder holds a trimmed copy of the MSYS2 runtime. DLLs and
GObject introspection typelibs are found by following dependencies from Perl
and the namespaces Perl's Gtk3 module loads, so new GTK versions need no
changes to the script. The build fails if a DLL cannot be resolved or if the
bundled Perl loads any module from outside the bundle.

    RemoteBox.exe             launcher (no console window)
    remotebox, share\, docs\  RemoteBox itself
    runtime\bin               perl.exe and the DLLs it needs
    runtime\lib               Perl modules, typelibs, gdk-pixbuf loaders
    runtime\share             GSettings schemas, icon themes, licences
    runtime\etc               CA certificates for HTTPS connections

`RemoteBox.exe` puts `runtime\bin` first in `PATH`, clears `PERL5LIB` and
similar variables so other Perl installations cannot interfere, and writes
RemoteBox's output to `%LOCALAPPDATA%\RemoteBox\remotebox.log`. If RemoteBox
exits with an error, it says so and points to the log.

The installer lets the user choose between installing for all users (Program
Files, needs admin rights) or just the current user (no admin rights), and the
destination folder. It adds a Start menu shortcut, an optional desktop
shortcut and an uninstaller. Silent installation is supported:

    RemoteBox-<version>-win64-setup.exe /S /CurrentUser /D=C:\Path\To\RemoteBox
    RemoteBox-<version>-win64-setup.exe /S /AllUsers

`/D=` must be the last argument and must not be quoted. Uninstalling leaves
the user's RemoteBox settings in `%LOCALAPPDATA%` in place.

## Files

| File | Purpose |
|---|---|
| `setup-msys2.ps1` | Installs/updates MSYS2, then runs `setup-deps.sh` |
| `setup-deps.sh` | Installs packages and builds Perl modules inside UCRT64 |
| `pacman-retry.sh` | Runs pacman with limited parallel downloads and retries |
| `remotebox-dev.cmd` | Runs RemoteBox from the source tree with the right `PATH` |
| `make-installer.ps1` | Runs `make-bundle.sh` from PowerShell |
| `make-bundle.sh` | Builds the application folder, launcher and installer |
| `launcher/` | Source of `RemoteBox.exe` |
| `remotebox.nsi` | NSIS installer script |
| `perl5/Msys2ImportLibs.pm` | Build-time fix so XS modules link against GLib's DLL import libraries rather than the static archives |
| `patches/Cairo-1.109-msys2.patch` | Win64 and cairo 1.18 fixes for the Perl Cairo bindings |
