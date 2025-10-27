; --- ��װ���� ---
#define MyAppName "AdvClone-HDD_IBMC"
;#define MyAppName "AdvClone-HDD" ;support recovery key
#define MyAppVersion "4.0.1"

#define MyAppPublisher "Advantech"
#define MyAppURL "http://www.advantech.com/"
#define ProgressInfo1 'Please wait while getting the disk information, This may take serveral minutes.'
#define ProgressInfo2 'Please wait while create a new partition and modify the boot sequence, This may take serveral minutes.'
[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{F1133BA1-8E34-42BF-B0FE-A9617D50ECCB}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={code:GetDefaultDir}\{#MyAppName} 
DefaultGroupName=AdvClone
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest

;��װ��������ļ��汾
VersionInfoVersion=2025.10.27
;��װ����Ȩ��Ϣ
VersionInfoCopyright={#MyAppPublisher}

OutputBaseFilename={#MyAppName}_{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
;DisableFinishedPage=yes

[Files]
Source: "F:\9.3_Win10_AdvClone\AdvClone_Python_QT\config.ini"; DestDir: "{app}"; Flags: ignoreversion; Check: LicenseCheckPassed
Source: "F:\9.3_Win10_AdvClone\AdvClone_Python_QT\dist\AdvClone.exe"; DestDir: "{app}"; Flags: ignoreversion; Check: LicenseCheckPassed
Source: "F:\9.3_Win10_AdvClone\AdvClone_Python_QT\dist\run_prepare_grub_env.exe"; DestDir: "{app}"; Flags: ignoreversion; Check: LicenseCheckPassed

;Source: "F:\9.3_Win10_AdvClone\AdvClone_QT&Clonezilla_Parts\support_Recovery_Button\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Check: LicenseCheckPassed
;Source: "F:\9.3_Win10_AdvClone\AdvClone_QT&Clonezilla_Parts\support_Recovery_Button\boot\grub\grub.cfg"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Check: LicenseCheckPassed

Source: "F:\9.3_Win10_AdvClone\AdvClone_QT&Clonezilla_Parts\support_IBMC\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Check: LicenseCheckPassed
Source: "F:\9.3_Win10_AdvClone\AdvClone_QT&Clonezilla_Parts\support_IBMC\boot\grub\grub.cfg"; DestDir: "{app}"; Flags: ignoreversion; Check: LicenseCheckPassed

[Icons]
Name: "{group}\AdvClone"; Filename: "{app}\AdvClone.exe"


; --- ���벿�� ---
[Code]
var
  DefaultDir: String;
  gLicensePassed: Boolean;
  RunAppCheckBox: TNewCheckBox;

function GetDefaultDir(S:String): String;
begin
    DefaultDir := 'C:\Program Files'
    //DefaultDir := 'C:\'
    Log('DefaultDir is: '+DefaultDir);
    Result :=  DefaultDir;
end;

procedure InitializeWizard;
begin
  gLicensePassed := True;

  //������ҳ��������û�ѡ���Ƿ�����ִ��
  RunAppCheckBox := TNewCheckBox.Create(WizardForm);
  RunAppCheckBox.Parent := WizardForm.FinishedPage;
  RunAppCheckBox.Caption := '��������AdvCloneִ�г���';
  RunAppCheckBox.Checked := True;
  RunAppCheckBox.Left := ScaleX(16);
  RunAppCheckBox.Top := ScaleY(160);
  RunAppCheckBox.Width := ScaleX(200);
end;

function LicenseCheckPassed: Boolean;
begin
  Result := gLicensePassed;
end;

procedure DeinitializeSetup();
var
  ErrorCode: Integer;
begin
  // �ڰ�װ������ȫ�˳���ִ��
  if RunAppCheckBox.Checked then
  begin
    Exec(ExpandConstant('{app}\AdvClone.exe'), '', '', SW_SHOW, ewNoWait, ErrorCode);
  end;
end;
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  parameter: string;
  ResultCode: integer;
begin
  if CurUninstallStep = usDone then
  begin
    //ɾ�� {app} �ļ��м����������ļ�
    Log('[Debug]ɾ����װĿ¼');
    DelTree(ExpandConstant('{app}'), True, True, True);
  end;
end;