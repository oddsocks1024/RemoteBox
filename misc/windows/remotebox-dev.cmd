@echo off
rem Runs RemoteBox from the source tree using the MSYS2 UCRT64 environment
rem created by setup-msys2.ps1. Set MSYS2_ROOT if MSYS2 is not in C:\msys64.
setlocal
if not defined MSYS2_ROOT set "MSYS2_ROOT=C:\msys64"

rem Perl loads XS module DLLs without searching perl.exe's own directory, so the
rem GTK DLLs must be found via PATH. Prepend, so that older copies of shared
rem DLLs (libintl, libiconv, ...) from other toolchains on PATH are not used.
set "PATH=%MSYS2_ROOT%\ucrt64\bin;%PATH%"

"%MSYS2_ROOT%\ucrt64\bin\perl.exe" "%~dp0..\..\remotebox" %*
