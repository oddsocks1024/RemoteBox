; NSIS installer for the native Windows build of RemoteBox.
; Built by make-bundle.sh, which defines:
;   VERSION      e.g. 3.7
;   VERSION_BIN  e.g. 3.7.0.0
;   STAGE        the application folder to install
;   REPO         the RemoteBox source tree (for the licence and icon)
;   OUTFILE      the installer to create

!ifndef VERSION | VERSION_BIN | STAGE | REPO | OUTFILE
  !error "Build this installer with make-bundle.sh"
!endif

Unicode true
SetCompressor /SOLID lzma
ManifestDPIAware true

!define APPNAME "RemoteBox"
!define REGKEY "Software\${APPNAME}"
!define UNINSTKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"

Name "${APPNAME} ${VERSION}"
OutFile "${OUTFILE}"
BrandingText "${APPNAME} ${VERSION}"

VIProductVersion "${VERSION_BIN}"
VIAddVersionKey "ProductName" "${APPNAME}"
VIAddVersionKey "ProductVersion" "${VERSION}"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "FileDescription" "${APPNAME} ${VERSION} Setup"
VIAddVersionKey "LegalCopyright" "(c) 2010-2027 Ian Chapman. GPL licensed."

; Install for everyone (needs admin) or just the current user, chosen on a page.
; The choice and folder are remembered for upgrades and the uninstaller.
!define MULTIUSER_EXECUTIONLEVEL Highest
!define MULTIUSER_MUI
!define MULTIUSER_INSTALLMODE_COMMANDLINE
!define MULTIUSER_USE_PROGRAMFILES64
!define MULTIUSER_INSTALLMODE_INSTDIR "${APPNAME}"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_KEY "${REGKEY}"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_VALUENAME "InstallDir"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_KEY "${REGKEY}"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME "InstallMode"
!include MultiUser.nsh
!include MUI2.nsh
!include FileFunc.nsh
!include x64.nsh

!define MUI_ICON "${REPO}\packagers-readme\remotebox.ico"
!define MUI_UNICON "${REPO}\packagers-readme\remotebox.ico"
!define MUI_ABORTWARNING
!define MUI_COMPONENTSPAGE_NODESC

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${REPO}\docs\COPYING"
!insertmacro MULTIUSER_PAGE_INSTALLMODE
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\RemoteBox.exe"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

Function .onInit
    ${IfNot} ${RunningX64}
        MessageBox MB_OK|MB_ICONSTOP "${APPNAME} requires 64-bit Windows."
        Abort
    ${EndIf}
    ; MULTIUSER_INIT sets the default folder, which would override /D=
    StrCpy $0 $INSTDIR
    !insertmacro MULTIUSER_INIT
    StrCmp $0 "" +2
    StrCpy $INSTDIR $0
FunctionEnd

Function un.onInit
    !insertmacro MULTIUSER_UNINIT
FunctionEnd

Section "${APPNAME}" SecMain
    SectionIn RO

    ; Remove the previous version's runtime and program files so that files
    ; dropped from a newer version do not linger
    RMDir /r "$INSTDIR\runtime"
    RMDir /r "$INSTDIR\share\remotebox"

    SetOutPath "$INSTDIR"
    File "${STAGE}\RemoteBox.exe"
    File "${STAGE}\remotebox"
    File /r "${STAGE}\docs"
    File /r "${STAGE}\runtime"
    SetOutPath "$INSTDIR\share"
    File /r "${STAGE}\share\remotebox"
    SetOutPath "$INSTDIR"

    WriteUninstaller "$INSTDIR\uninstall.exe"
    CreateShortcut "$SMPROGRAMS\${APPNAME}.lnk" "$INSTDIR\RemoteBox.exe"

    WriteRegStr SHCTX "${REGKEY}" "InstallDir" "$INSTDIR"
    WriteRegStr SHCTX "${REGKEY}" "InstallMode" "$MultiUser.InstallMode"

    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    WriteRegStr   SHCTX "${UNINSTKEY}" "DisplayName" "${APPNAME}"
    WriteRegStr   SHCTX "${UNINSTKEY}" "DisplayVersion" "${VERSION}"
    WriteRegStr   SHCTX "${UNINSTKEY}" "DisplayIcon" "$INSTDIR\RemoteBox.exe"
    WriteRegStr   SHCTX "${UNINSTKEY}" "Publisher" "Ian Chapman"
    WriteRegStr   SHCTX "${UNINSTKEY}" "URLInfoAbout" "https://remotebox.knobgoblin.org.uk"
    WriteRegStr   SHCTX "${UNINSTKEY}" "InstallLocation" "$INSTDIR"
    WriteRegStr   SHCTX "${UNINSTKEY}" "UninstallString" '"$INSTDIR\uninstall.exe" /$MultiUser.InstallMode'
    WriteRegStr   SHCTX "${UNINSTKEY}" "QuietUninstallString" '"$INSTDIR\uninstall.exe" /$MultiUser.InstallMode /S'
    WriteRegDWORD SHCTX "${UNINSTKEY}" "EstimatedSize" $0
    WriteRegDWORD SHCTX "${UNINSTKEY}" "NoModify" 1
    WriteRegDWORD SHCTX "${UNINSTKEY}" "NoRepair" 1
SectionEnd

Section "Desktop shortcut" SecDesktop
    CreateShortcut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\RemoteBox.exe"
SectionEnd

Section "Uninstall"
    ; Only remove what the installer put there, in case the folder was shared
    Delete "$INSTDIR\RemoteBox.exe"
    Delete "$INSTDIR\remotebox"
    Delete "$INSTDIR\uninstall.exe"
    RMDir /r "$INSTDIR\runtime"
    RMDir /r "$INSTDIR\docs"
    RMDir /r "$INSTDIR\share\remotebox"
    RMDir "$INSTDIR\share"
    RMDir "$INSTDIR"

    Delete "$SMPROGRAMS\${APPNAME}.lnk"
    Delete "$DESKTOP\${APPNAME}.lnk"
    DeleteRegKey SHCTX "${UNINSTKEY}"
    DeleteRegKey SHCTX "${REGKEY}"
SectionEnd
