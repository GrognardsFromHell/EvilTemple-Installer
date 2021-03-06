;NSIS Modern User Interface
;Basic Example Script
;Written by Joost Verburg

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"
  !include "UninstallLog.nsh"

;--------------------------------
;General

  ;Name and file
  Name "EvilTemple"
  OutFile "EvilTemple.exe"

  ;Default installation folder
  InstallDir "$LOCALAPPDATA\EvilTemple\"
  
  ;Get installation folder from registry if available
  ; InstallDirRegKey HKCU "Software\EvilTemple" "InstallDir"

  ;Request application privileges for Windows Vista
  RequestExecutionLevel user
  
  SetCompressor lzma

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !define MUI_FINISHPAGE_TEXT "You have to convert the data files of an existing Temple of Elemental Evil installation before you can start Evil Temple."
  !define MUI_FINISHPAGE_CANCEL_ENABLED
  !define MUI_FINISHPAGE_RUN $INSTDIR\Converter.exe
  !define MUI_FINISHPAGE_RUN_TEXT "Convert necessary data files"

  !insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH 
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_COMPONENTS
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Configure UnInstall log to only remove what is installed
;-------------------------------- 
;Set the name of the uninstall log
!define UninstLog "uninstall.log"
Var UninstLog

;Uninstall log file missing.
LangString UninstLogMissing ${LANG_ENGLISH} "${UninstLog} not found!$\r$\nUninstallation cannot proceed!"

;AddItem macro
!define AddItem "!insertmacro AddItem"

;File macro
!define File "!insertmacro File"

;CreateShortcut macro
!define CreateShortcut "!insertmacro CreateShortcut"

;Copy files macro
!define CopyFiles "!insertmacro CopyFiles"

;Rename macro
!define Rename "!insertmacro Rename"

;CreateDirectory macro
!define CreateDirectory "!insertmacro CreateDirectory"

;SetOutPath macro
!define SetOutPath "!insertmacro SetOutPath"

;WriteUninstaller macro
!define WriteUninstaller "!insertmacro WriteUninstaller"

;WriteRegStr macro
!define WriteRegStr "!insertmacro WriteRegStr"

;WriteRegDWORD macro
!define WriteRegDWORD "!insertmacro WriteRegDWORD" 

Section -openlogfile
CreateDirectory "$INSTDIR"
IfFileExists "$INSTDIR\${UninstLog}" +3
  FileOpen $UninstLog "$INSTDIR\${UninstLog}" w
Goto +4
  SetFileAttributes "$INSTDIR\${UninstLog}" NORMAL
  FileOpen $UninstLog "$INSTDIR\${UninstLog}" a
  FileSeek $UninstLog 0 END
SectionEnd
  
;--------------------------------
;Installer Sections

Section "Main Program" SecMain

  ${SetOutPath} "$INSTDIR"
  
  !include install-files.nsh
  
  ;Store installation folder
  ${WriteRegStr} HKCU "Software\EvilTemple" "InstallDir" $INSTDIR
  
  ; Create Shortcuts
  ${CreateDirectory} "$SMPROGRAMS\Evil Temple"
  ${CreateShortCut} "$SMPROGRAMS\Evil Temple\Evil Temple.lnk" "$INSTDIR\EvilTemple.exe" "" "$INSTDIR\EvilTemple.exe" 0
  ${CreateShortCut} "$SMPROGRAMS\Evil Temple\Convert Game Files.lnk" "$INSTDIR\Converter.exe" "" "$INSTDIR\Converter.exe" 0
  
  ;Create uninstaller
  ${WriteUninstaller} "$INSTDIR\Uninstall.exe"
  
SectionEnd

;--------------------------------
; Uninstaller
;--------------------------------
Section Uninstall
  ;Can't uninstall if uninstall log is missing!
  IfFileExists "$INSTDIR\${UninstLog}" +3
    MessageBox MB_OK|MB_ICONSTOP "$(UninstLogMissing)"
      Abort
 
  Push $R0
  Push $R1
  Push $R2
  SetFileAttributes "$INSTDIR\${UninstLog}" NORMAL
  FileOpen $UninstLog "$INSTDIR\${UninstLog}" r
  StrCpy $R1 -1
 
  GetLineCount:
    ClearErrors
    FileRead $UninstLog $R0
    IntOp $R1 $R1 + 1
    StrCpy $R0 $R0 -2
    Push $R0   
    IfErrors 0 GetLineCount
 
  Pop $R0
 
  LoopRead:
    StrCmp $R1 0 LoopDone
    Pop $R0
 
    IfFileExists "$R0\*.*" 0 +3
      RMDir $R0  #is dir
    Goto +3
    IfFileExists $R0 0 +3
      Delete $R0 #is file
 
    IntOp $R1 $R1 - 1
    Goto LoopRead
  LoopDone:
  FileClose $UninstLog
  Delete "$INSTDIR\${UninstLog}"
  Pop $R2
  Pop $R1
  Pop $R0
  
  DeleteRegKey HKCU "Software\EvilTemple"
SectionEnd

Section "un.Converted Files" converted_files
	Delete "$INSTDIR\ConvertedData.zip"
SectionEnd


;--------------------------------
;Descriptions

;Language strings
LangString DESC_SecMain ${LANG_ENGLISH} "EvilTemple program files."
LangString DESC_GeneratedFiles ${LANG_ENGLISH} "Deletes the data files converted from Temple of Elemental Evil"

!insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${converted_files} $(DESC_GeneratedFiles)
!insertmacro MUI_UNFUNCTION_DESCRIPTION_END

;Assign language strings to sections
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SecMain} $(DESC_SecMain)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
