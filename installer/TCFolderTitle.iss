; TCFolderTitle installer configuration
#define MyAppName "TCFolderTitle"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Adam Samec"
#define MyAppExecutable MyAppName + ".exe"

[CustomMessages]
en.MyDescription=Utility for displaying the names of the currently opened folders in Total Commander window title
en.LaunchAfterInstall=Start {#MyAppName} after finishing installation
cs.MyDescription=Nástroj pro zobrazování názvů aktuálně otevřených složek v titulku okna Total Commanderu
cs.LaunchAfterInstall=Spustit {#MyAppName} po dokončení instalace

[Setup]
OutputBaseFilename={#MyAppName}-{#MyAppVersion}-win32-setup
AppVersion={#MyAppVersion}
AppName={#MyAppName}
AppId={#MyAppName}
AppPublisher={#MyAppPublisher}
;PrivilegesRequired=lowest
DisableProgramGroupPage=yes
WizardStyle=modern
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
VersionInfoDescription={#MyAppName} Setup
VersionInfoProductName={#MyAppName}
; Uncomment the following line to disable the "Select Setup Language"
; dialog and have it rely solely on auto-detection.
;ShowLanguageDialog=no

[Languages]
Name: en; MessagesFile: "compiler:Default.isl"
Name: cs; MessagesFile: "compiler:Languages\Czech.isl"

[Messages]
en.BeveledLabel=English
cs.BeveledLabel=Čeština

[Files]
Source: "..\bin\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExecutable}"
Name: "{userstartup}\{#MyAppName}"; Filename: "{app}\{#MyAppExecutable}"; WorkingDir: "{app}"

[Run]
Filename: {app}\{#MyAppExecutable}; Description: {cm:LaunchAfterInstall,{#MyAppName}}; Flags: nowait postinstall skipifsilent
