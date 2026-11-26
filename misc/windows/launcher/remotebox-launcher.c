/*
 * RemoteBox.exe - launcher for the native Windows build of RemoteBox.
 * (c) 2010-2027 Ian Chapman. Licenced under the terms of the GPL
 *
 * Runs the bundled perl.exe on the remotebox script without a console window.
 * The environment is prepared so that only the bundled runtime is used, even if
 * other Perl or GTK installations are present on the system. Output is written
 * to %LOCALAPPDATA%\RemoteBox\remotebox.log and the user is told about it if
 * RemoteBox exits with an error.
 *
 * Layout, relative to the directory containing this executable:
 *     remotebox                 the RemoteBox script
 *     runtime\bin\perl.exe      bundled Perl and the GTK DLLs
 *     runtime\lib, share, etc   bundled Perl modules and GTK data
 */
#define WIN32_LEAN_AND_MEAN
#ifndef UNICODE
#define UNICODE
#endif
#ifndef _UNICODE
#define _UNICODE
#endif
#include <windows.h>
#include <shlwapi.h>
#include <shlobj.h>
#include <wchar.h>
#include <stdlib.h>

#define BUFLEN 32768

static void fail(const wchar_t *msg, const wchar_t *detail) {
    wchar_t text[BUFLEN];
    _snwprintf(text, BUFLEN, L"%ls\n\n%ls", msg, detail ? detail : L"");
    text[BUFLEN - 1] = 0;
    MessageBoxW(NULL, text, L"RemoteBox", MB_OK | MB_ICONERROR);
    ExitProcess(1);
}

/* Sets NAME to BASE\SUFFIX */
static void setenv_path(const wchar_t *name, const wchar_t *base, const wchar_t *suffix) {
    wchar_t value[MAX_PATH * 2];
    _snwprintf(value, MAX_PATH * 2, L"%ls\\%ls", base, suffix);
    value[MAX_PATH * 2 - 1] = 0;
    SetEnvironmentVariableW(name, value);
}

/* Opens the log file, creating its directory. Returns INVALID_HANDLE_VALUE on failure */
static HANDLE open_log(wchar_t *logpath) {
    wchar_t *appdata = NULL;
    if (SHGetKnownFolderPath(&FOLDERID_LocalAppData, 0, NULL, &appdata) != S_OK) return INVALID_HANDLE_VALUE;
    _snwprintf(logpath, MAX_PATH, L"%ls\\RemoteBox", appdata);
    logpath[MAX_PATH - 1] = 0;
    CoTaskMemFree(appdata);
    CreateDirectoryW(logpath, NULL);
    wcsncat(logpath, L"\\remotebox.log", MAX_PATH - wcslen(logpath) - 1);

    SECURITY_ATTRIBUTES sa = { sizeof(sa), NULL, TRUE }; /* inheritable by perl.exe */
    return CreateFileW(logpath, GENERIC_WRITE, FILE_SHARE_READ, &sa, CREATE_ALWAYS,
                       FILE_ATTRIBUTE_NORMAL, NULL);
}

int WINAPI wWinMain(HINSTANCE hInst, HINSTANCE hPrev, PWSTR cmdline, int show) {
    static wchar_t appdir[MAX_PATH], runtime[MAX_PATH], perl[MAX_PATH], script[MAX_PATH];
    static wchar_t logpath[MAX_PATH], path[BUFLEN], oldpath[BUFLEN], cmd[BUFLEN];
    (void)hInst; (void)hPrev; (void)cmdline; (void)show;

    DWORD n = GetModuleFileNameW(NULL, appdir, MAX_PATH);
    if (n == 0 || n >= MAX_PATH) fail(L"Unable to determine the RemoteBox installation directory.", NULL);
    PathRemoveFileSpecW(appdir);

    _snwprintf(runtime, MAX_PATH, L"%ls\\runtime", appdir);
    _snwprintf(perl, MAX_PATH, L"%ls\\bin\\perl.exe", runtime);
    _snwprintf(script, MAX_PATH, L"%ls\\remotebox", appdir);
    if (!PathFileExistsW(perl)) fail(L"The bundled Perl interpreter is missing. Please reinstall RemoteBox.", perl);
    if (!PathFileExistsW(script)) fail(L"The RemoteBox program files are missing. Please reinstall RemoteBox.", script);

    /* Perl loads XS module DLLs without searching its own directory, so the
       bundled DLLs must come first in PATH, ahead of any other toolchain's copies */
    DWORD len = GetEnvironmentVariableW(L"PATH", oldpath, BUFLEN);
    if (len >= BUFLEN) len = 0;
    oldpath[len] = 0;
    _snwprintf(path, BUFLEN, L"%ls\\bin;%ls", runtime, oldpath);
    path[BUFLEN - 1] = 0;
    SetEnvironmentVariableW(L"PATH", path);

    /* Settings from another Perl installation must not leak into the bundled one */
    SetEnvironmentVariableW(L"PERL5LIB", NULL);
    SetEnvironmentVariableW(L"PERLLIB", NULL);
    SetEnvironmentVariableW(L"PERL5OPT", NULL);
    SetEnvironmentVariableW(L"PERL_LOCAL_LIB_ROOT", NULL);

    setenv_path(L"GI_TYPELIB_PATH", runtime, L"lib\\girepository-1.0");
    setenv_path(L"GDK_PIXBUF_MODULE_FILE", runtime, L"lib\\gdk-pixbuf-2.0\\2.10.0\\loaders.cache");
    setenv_path(L"GSETTINGS_SCHEMA_DIR", runtime, L"share\\glib-2.0\\schemas");
    if (GetEnvironmentVariableW(L"SSL_CERT_FILE", NULL, 0) == 0)
        setenv_path(L"SSL_CERT_FILE", runtime, L"etc\\ssl\\certs\\ca-bundle.crt");

    /* "perl.exe" "remotebox" followed by any arguments given to the launcher */
    _snwprintf(cmd, BUFLEN, L"\"%ls\" \"%ls\" %ls", perl, script, PathGetArgsW(GetCommandLineW()));
    cmd[BUFLEN - 1] = 0;

    STARTUPINFOW si;
    PROCESS_INFORMATION pi;
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    HANDLE log = open_log(logpath);
    if (log != INVALID_HANDLE_VALUE) {
        si.dwFlags = STARTF_USESTDHANDLES;
        si.hStdInput = GetStdHandle(STD_INPUT_HANDLE);
        si.hStdOutput = log;
        si.hStdError = log;
    }

    if (!CreateProcessW(perl, cmd, NULL, NULL, TRUE, CREATE_NO_WINDOW, NULL, appdir, &si, &pi))
        fail(L"Unable to start the bundled Perl interpreter.", perl);

    WaitForSingleObject(pi.hProcess, INFINITE);
    DWORD code = 0;
    GetExitCodeProcess(pi.hProcess, &code);
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
    if (log != INVALID_HANDLE_VALUE) CloseHandle(log);

    if (code != 0) {
        wchar_t msg[MAX_PATH * 2];
        if (log != INVALID_HANDLE_VALUE)
            _snwprintf(msg, MAX_PATH * 2, L"RemoteBox exited unexpectedly (exit code %lu).\n\nDetails were written to:\n%ls", code, logpath);
        else
            _snwprintf(msg, MAX_PATH * 2, L"RemoteBox exited unexpectedly (exit code %lu).", code);
        msg[MAX_PATH * 2 - 1] = 0;
        fail(msg, NULL);
    }
    return 0;
}
