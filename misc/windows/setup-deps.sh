#!/usr/bin/env bash
# Installs the packages and Perl modules RemoteBox needs into an MSYS2 UCRT64
# environment. Normally invoked by setup-msys2.ps1 but can be run directly from
# a UCRT64 shell.
set -euo pipefail

if [ "${MSYSTEM:-}" != "UCRT64" ]; then
    echo "Error: this script must run in the MSYS2 UCRT64 environment" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG=mingw-w64-ucrt-x86_64

# cpanm and the tools it installs live outside the default PATH
export PATH="$MINGW_PREFIX/bin/site_perl:$MINGW_PREFIX/bin/core_perl:$PATH"

# pacman-retry.sh limits parallel downloads and retries on mirror errors (429).
# Runtime: Perl, GTK 3, the introspection data Perl's Gtk3 module binds to and
# the Perl modules MSYS2 already packages.
# Build-only: compiler, make and pkg-config for the XS modules built by cpanm,
# NSIS for the installer made by make-bundle.sh.
"$SCRIPT_DIR/pacman-retry.sh" -S --needed --noconfirm \
    $PKG-perl \
    $PKG-perl-mozilla-ca \
    $PKG-perl-lwp-protocol-https \
    $PKG-perl-regexp-common \
    $PKG-perl-file-which \
    $PKG-gtk3 \
    $PKG-gobject-introspection \
    $PKG-adwaita-icon-theme \
    $PKG-gcc \
    $PKG-pkgconf \
    $PKG-make \
    $PKG-nsis \
    make \
    patch

# Native Perl does not look in MSYS2's certificate store, so HTTPS downloads by
# Perl tools fail with "Couldn't find a CA bundle". Mozilla::CA (above) covers
# HTTP::Tiny and IO::Socket::SSL, SSL_CERT_FILE covers anything else.
export SSL_CERT_FILE="$(cygpath -w "$MINGW_PREFIX/etc/ssl/certs/ca-bundle.crt")"

# Bootstrap cpanm from its CPAN release. cpan itself is avoided: it needs an
# interactive first-run configuration.
CPANM_DIST=App-cpanminus-1.7049
if ! command -v cpanm >/dev/null 2>&1; then
    work="$(mktemp -d)"
    curl -fsSL --retry 5 -o "$work/$CPANM_DIST.tar.gz" \
        "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/$CPANM_DIST.tar.gz"
    tar -xzf "$work/$CPANM_DIST.tar.gz" -C "$work"
    # The release contains a self-contained cpanm, used here to install itself
    (cd "$work/$CPANM_DIST" && perl bin/cpanm --notest .)
    rm -rf "$work"
    hash -r
fi

# Order matters: the build helpers must exist before the XS bindings
cpanm --notest --skip-satisfied \
    ExtUtils::Depends \
    ExtUtils::PkgConfig

# See perl5/Msys2ImportLibs.pm for why the extra module is loaded. -I is used
# rather than PERL5LIB because some module tests run under taint mode.
export PERL5OPT="-I$(cygpath -m "$SCRIPT_DIR/perl5") -MMsys2ImportLibs"

# Builds a CPAN distribution with a local patch applied, unless already installed
install_patched() {
    local module=$1 dist=$2 url=$3 patchfile=$4
    perl -M"$module" -e1 2>/dev/null && return 0
    local work
    work="$(mktemp -d)"
    curl -fsSL --retry 5 -o "$work/$dist.tar.gz" "$url"
    tar -xzf "$work/$dist.tar.gz" -C "$work"
    patch -d "$work/$dist" -p1 < "$SCRIPT_DIR/patches/$patchfile"
    # cpanm only treats arguments starting with . or / as local directories
    (cd "$work/$dist" && cpanm .)
    rm -rf "$work"
}

# MSYS2 exports a UTF-8 LANG, but native GLib decodes argv in the ANSI code
# page, so Glib's wide-character option parsing tests fail. A non-UTF-8 locale
# makes them skip.
LC_ALL=C cpanm --skip-satisfied Glib

install_patched Cairo Cairo-1.109 \
    https://cpan.metacpan.org/authors/id/X/XA/XAOC/Cairo-1.109.tar.gz \
    Cairo-1.109-msys2.patch

cpanm --skip-satisfied \
    Cairo::GObject \
    Glib::Object::Introspection

unset PERL5OPT

# Gtk3's tests call gtk_init(), whose setlocale() also changes the locale Perl
# uses on Windows. With a decimal comma regional format (e.g. Russian) Perl's
# version checks then fail ("Win32 version 0.27 required--this is only version
# 0"). RemoteBox avoids this with Gtk3::disable_setlocale(), but the tests
# cannot. Gtk3 is pure Perl; make-bundle.sh exercises it instead.
cpanm --notest --skip-satisfied Gtk3

cpanm --notest --skip-satisfied \
    SOAP::Lite

echo "Checking RemoteBox module dependencies..."
perl -MGtk3 -MSOAP::Lite -MLWP::Protocol::https -MRegexp::Common -MFile::Which \
     -e 'print "OK: Gtk3 $Gtk3::VERSION, Glib $Glib::VERSION, SOAP::Lite $SOAP::Lite::VERSION\n"'
