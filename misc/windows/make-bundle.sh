#!/usr/bin/env bash
# Builds the native Windows distribution of RemoteBox: a self-contained folder
# holding RemoteBox, a trimmed copy of the MSYS2 UCRT64 Perl and GTK 3 runtime
# and a launcher, plus an NSIS installer for it.
#
# Run from a UCRT64 shell after setup-msys2.ps1 (or via make-installer.ps1):
#     misc/windows/make-bundle.sh [output-dir]
#
# Output (default misc/windows/build):
#     RemoteBox/                           the portable application folder
#     RemoteBox-<version>-win64-setup.exe  the installer
set -euo pipefail

if [ "${MSYSTEM:-}" != "UCRT64" ]; then
    echo "Error: this script must run in the MSYS2 UCRT64 environment" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUT="$(mkdir -p "${1:-$SCRIPT_DIR/build}" && cd "${1:-$SCRIPT_DIR/build}" && pwd)"
STAGE="$OUT/RemoteBox"
RT="$STAGE/runtime"
P="$MINGW_PREFIX"

VERSION="$(sed -n 's/^# RemoteBox v\([0-9][0-9.]*\).*/\1/p' "$REPO/remotebox" | head -1)"
[ -n "$VERSION" ] || { echo "Error: unable to determine the RemoteBox version" >&2; exit 1; }
# Windows version resources need exactly four numeric parts
IFS=. read -r V1 V2 V3 V4 <<< "$VERSION"
VERSION_BIN="${V1:-0}.${V2:-0}.${V3:-0}.${V4:-0}"

# The GObject introspection namespaces Perl's Gtk3 module loads. Their
# dependencies are found automatically.
TYPELIB_ROOTS="Gtk-3.0 Gdk-3.0 GdkPixbuf-2.0 GdkPixdata-2.0 Pango-1.0"

echo "Building RemoteBox $VERSION for Windows in $OUT"
rm -rf "$STAGE" "$OUT/obj"
mkdir -p "$RT/bin" "$RT/lib/perl5" "$RT/share" "$RT/etc" "$OUT/obj"

### RemoteBox itself
cp "$REPO/remotebox" "$STAGE/"
cp -r "$REPO/share" "$STAGE/"
mkdir -p "$STAGE/docs"
cp "$REPO/docs/"* "$REPO/LICENSE" "$STAGE/docs/"

### Perl, without the parts only needed for development
echo "Copying Perl..."
cp "$P/bin/perl.exe" "$P"/bin/perl[0-9]*.dll "$RT/bin/"
tar -C "$P/lib/perl5" -cf - \
    --exclude='core_perl/CORE' \
    --exclude='core_perl/pod' \
    --exclude='core_perl/CPAN' --exclude='core_perl/CPAN.pm' \
    --exclude='core_perl/App' \
    --exclude='core_perl/TAP' \
    --exclude='core_perl/Test' --exclude='core_perl/Test2' \
    --exclude='core_perl/Pod/Perldoc' --exclude='core_perl/Pod/Perldoc.pm' \
    --exclude='core_perl/Devel/PPPort.pm' \
    --exclude='core_perl/Unicode/Collate' --exclude='core_perl/auto/Unicode/Collate' \
    --exclude='Encode/CN' --exclude='Encode/JP' --exclude='Encode/KR' --exclude='Encode/TW' \
    --exclude='ExtUtils' \
    --exclude='*/Install' \
    --exclude='*.pod' --exclude='*.h' --exclude='*.a' --exclude='*.packlist' \
    --exclude='typemap' --exclude='*.typemap' \
    core_perl site_perl | tar -C "$RT/lib/perl5" -xf -

### GObject introspection data: the roots and everything they depend on
echo "Resolving GObject introspection dependencies..."
GIR="$P/lib/girepository-1.0"
mkdir -p "$RT/lib/girepository-1.0"
declare -A seen_typelib=()
typelib_dlls=()
queue=($TYPELIB_ROOTS)
while [ ${#queue[@]} -gt 0 ]; do
    ns="${queue[0]}"; queue=("${queue[@]:1}")
    [ -n "${seen_typelib[$ns]:-}" ] && continue
    seen_typelib[$ns]=1
    [ -f "$GIR/$ns.typelib" ] || { echo "Error: missing typelib $ns" >&2; exit 1; }
    cp "$GIR/$ns.typelib" "$RT/lib/girepository-1.0/"
    # A typelib names the namespaces it depends on as "Ns-1.0|Other-2.0" and the
    # DLLs it binds as "libfoo-1.dll,libbar-2.dll"
    deps="$(strings "$GIR/$ns.typelib" | grep -m1 -E '^[A-Za-z0-9]+-[0-9]+\.[0-9]+(\|[A-Za-z0-9]+-[0-9]+\.[0-9]+)*$' || true)"
    dlls="$(strings "$GIR/$ns.typelib" | grep -m1 -i '\.dll' || true)"
    [ -n "$deps" ] && queue+=(${deps//|/ })
    [ -n "$dlls" ] && typelib_dlls+=(${dlls//,/ })
done
echo "  ${!seen_typelib[*]}"

### gdk-pixbuf image loaders. The cache refers to them by relative path.
PIXBUF=lib/gdk-pixbuf-2.0/2.10.0
mkdir -p "$RT/$PIXBUF/loaders"
cp "$P/$PIXBUF"/loaders/*.dll "$RT/$PIXBUF/loaders/"
cp "$P/$PIXBUF/loaders.cache" "$RT/$PIXBUF/"

### DLLs: everything the above needs, found by reading import tables
echo "Resolving DLL dependencies..."
SYSDIR="$(cygpath -u "$SYSTEMROOT")/System32"
declare -A seen_dll=()
missing=()
dll_queue=("$RT/bin/perl.exe" "$RT"/bin/perl[0-9]*.dll)
# XS modules import each other by name (Cairo/GObject.dll needs Glib.dll). Perl
# has already loaded those by then, so they count as resolved.
while IFS= read -r -d '' f; do
    dll_queue+=("$f")
    [[ "$f" == "$RT/lib/perl5/"* ]] && name="${f##*/}" && seen_dll[${name,,}]=1
done < <(find "$RT/lib" -iname '*.dll' -print0)
for d in "${typelib_dlls[@]}"; do
    [ -f "$P/bin/$d" ] || { echo "Error: typelib DLL $d not found" >&2; exit 1; }
    cp "$P/bin/$d" "$RT/bin/"
    dll_queue+=("$RT/bin/$d")
done
while [ ${#dll_queue[@]} -gt 0 ]; do
    f="${dll_queue[0]}"; dll_queue=("${dll_queue[@]:1}")
    while IFS= read -r dep; do
        key="${dep,,}"
        [ -n "${seen_dll[$key]:-}" ] && continue
        seen_dll[$key]=1
        if [ -f "$P/bin/$dep" ]; then
            cp "$P/bin/$dep" "$RT/bin/"
            dll_queue+=("$RT/bin/$dep")
        elif [ -f "$SYSDIR/$dep" ] || [[ "$key" == api-ms-win-* ]]; then
            :   # Part of Windows
        else
            missing+=("$dep (needed by ${f#$STAGE/})")
        fi
    done < <(objdump -p "$f" | sed -n 's/^[[:space:]]*DLL Name: //p')
done
if [ ${#missing[@]} -gt 0 ]; then
    printf 'Error: unresolved DLL: %s\n' "${missing[@]}" >&2
    exit 1
fi
echo "  $(ls "$RT/bin" | wc -l) files in runtime/bin"

### GTK data: settings schemas, icon themes, CA certificates
echo "Copying GTK data..."
mkdir -p "$OUT/obj/schemas" "$RT/share/glib-2.0/schemas"
cp "$P"/share/glib-2.0/schemas/org.gtk.Settings.*.gschema.xml "$OUT/obj/schemas/"
glib-compile-schemas --targetdir="$RT/share/glib-2.0/schemas" "$OUT/obj/schemas"

mkdir -p "$RT/share/icons/hicolor"
cp -r "$P/share/icons/Adwaita" "$RT/share/icons/"
[ -d "$P/share/icons/AdwaitaLegacy" ] && cp -r "$P/share/icons/AdwaitaLegacy" "$RT/share/icons/"
cp "$P/share/icons/hicolor/index.theme" "$RT/share/icons/hicolor/"

mkdir -p "$RT/etc/ssl/certs"
cp "$P/etc/ssl/certs/ca-bundle.crt" "$RT/etc/ssl/certs/"

### Licences of every bundled MSYS2 package
echo "Collecting licences..."
mkdir -p "$RT/share/licenses"
mapfile -t pkgs < <(
    for f in "$RT"/bin/*; do echo "$P/bin/${f##*/}"; done
    for f in "$RT"/lib/girepository-1.0/*; do echo "$GIR/${f##*/}"; done
    for f in "$RT/$PIXBUF"/loaders/*; do echo "$P/$PIXBUF/loaders/${f##*/}"; done
    echo "$P/share/icons/Adwaita/index.theme"
)
for pkg in $(pacman -Qqo "${pkgs[@]}" | sort -u); do
    name="${pkg#${MINGW_PACKAGE_PREFIX}-}"
    [ -d "$P/share/licenses/$name" ] && cp -r "$P/share/licenses/$name" "$RT/share/licenses/"
done
cat > "$RT/share/licenses/CPAN-modules.txt" <<EOF
Perl modules built from CPAN by misc/windows/setup-deps.sh

Glib, Cairo, Cairo::GObject, Glib::Object::Introspection, Gtk3
    GNU Lesser General Public License, version 2.1 or later.
    Cairo was modified with misc/windows/patches/Cairo-1.109-msys2.patch from
    the RemoteBox source repository.
SOAP::Lite, XML::Parser, Class::Inspector, IO::SessionData, File::ShareDir,
Task::Weaken
    The same terms as Perl itself (see the perl directory).

Installed versions:
$(cd "$RT/lib/perl5/site_perl" && "$P/bin/perl" -X -I. -e '
    for my $m (qw(Glib Cairo Cairo::GObject Glib::Object::Introspection Gtk3 SOAP::Lite XML::Parser)) {
        eval "require $m" and printf "    %-30s %s\n", $m, $m->VERSION;
    }')
EOF

### Launcher
echo "Building launcher..."
cat > "$OUT/obj/version.h" <<EOF
#define RB_VERSION "$VERSION"
#define RB_VERSION_BIN ${VERSION_BIN//./,}
#define ICON_FILE "$(cygpath -m "$REPO/packagers-readme/remotebox.ico")"
EOF
(cd "$SCRIPT_DIR/launcher" && windres --include-dir="$OUT/obj" \
    -O coff -o "$OUT/obj/launcher.res.o" launcher.rc)
gcc -O2 -s -municode -mwindows -static-libgcc -Wall \
    -o "$STAGE/RemoteBox.exe" "$SCRIPT_DIR/launcher/remotebox-launcher.c" "$OUT/obj/launcher.res.o" \
    -lshlwapi -lshell32 -lole32 -luuid

### Verify the bundle is self-contained
echo "Verifying the bundle..."
STAGE_W="$(cygpath -m "$STAGE")"
env -i SYSTEMROOT="$SYSTEMROOT" WINDIR="$WINDIR" TEMP="$TEMP" TMP="$TMP" \
    PATH="$RT/bin:$SYSDIR" \
    GI_TYPELIB_PATH="$(cygpath -w "$RT/lib/girepository-1.0")" \
    "$RT/bin/perl.exe" -e '
    my $root = shift;
    use Gtk3; use Glib; use Cairo::GObject;
    use SOAP::Lite; use LWP::UserAgent; use LWP::Protocol::https; use IO::Socket::SSL;
    use XML::Parser; use Regexp::Common qw(net); use File::Which; use File::Spec::Win32;
    use MIME::Base64; use Digest::MD5; use Time::HiRes; use Socket; use POSIX; use Getopt::Std;
    # Started the way remotebox does, see the comment there
    Gtk3::disable_setlocale(); Gtk3::init();
    die "Numbers format with the regional decimal separator after Gtk3::init\n" unless 0.5 eq "0.5";
    Win32::GetCwd();
    my $w = Gtk3::Window->new("toplevel");
    my $p = Gtk3::Gdk::Pixbuf->new_from_file("$root/share/remotebox/icons/connect_32px.png");
    my $l = Pango::Layout->new(Gtk3::Label->new("x")->get_pango_context);
    my @outside = grep { lc(substr($_, 0, length $root)) ne lc $root } values %INC;
    die "Modules loaded from outside the bundle:\n  " . join("\n  ", @outside) . "\n" if @outside;
    print "  OK: ", scalar(keys %INC), " modules, all from the bundle\n";
    ' "$STAGE_W"

### Installer
echo "Building installer..."
SETUP="RemoteBox-$VERSION-win64-setup.exe"
makensis -V2 \
    -DVERSION="$VERSION" -DVERSION_BIN="$VERSION_BIN" \
    -DSTAGE="$(cygpath -w "$STAGE")" -DREPO="$(cygpath -w "$REPO")" \
    -DOUTFILE="$(cygpath -w "$OUT/$SETUP")" \
    "$(cygpath -w "$SCRIPT_DIR/remotebox.nsi")"

rm -rf "$OUT/obj"
echo
echo "Done:"
echo "  Application folder: $(cygpath -w "$STAGE") ($(du -sh "$STAGE" | cut -f1))"
echo "  Installer:          $(cygpath -w "$OUT/$SETUP") ($(du -sh "$OUT/$SETUP" | cut -f1))"
