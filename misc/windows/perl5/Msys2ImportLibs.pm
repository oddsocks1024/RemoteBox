# Build-time helper for setup-deps.sh, loaded via PERL5OPT while the XS
# bindings (Glib, Cairo, ...) are compiled.
#
# On Win32, ExtUtils::Liblist resolves -lfoo by trying libfoo.a before
# libfoo.dll.a. MSYS2 ships both, so the bindings get linked against the static
# GLib archives while the GLib headers declare everything dllimport, producing
# "undefined reference to __imp_g_*" errors. Prefer the DLL import libraries.
package Msys2ImportLibs;
use strict;
use warnings;
use ExtUtils::Liblist::Kid;

{
    no warnings 'redefine';
    my $orig = \&ExtUtils::Liblist::Kid::_win32_lib_extensions;
    *ExtUtils::Liblist::Kid::_win32_lib_extensions = sub {
        my @ext = @{ $orig->(@_) };
        return [ (grep { $_ eq '.dll.a' } @ext), (grep { $_ ne '.dll.a' } @ext) ];
    };
}

1;
