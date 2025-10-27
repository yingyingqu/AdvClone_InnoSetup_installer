; --- ��װ���� ---
;#define MyAppName "AdvClone-HDD_IBMC"
#define MyAppName "AdvClone-HDD" ;support recovery key
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
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest

;��װ��������ļ��汾
VersionInfoVersion=2025.10.24
;��װ����Ȩ��Ϣ
VersionInfoCopyright={#MyAppPublisher}

OutputBaseFilename={#MyAppName}_License_{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
;DisableFinishedPage=yes

[Files]
Source: "F:\9.3_Win10_AdvClone\AdvClone_Python_License\dist\License_Generate_deviceID.exe"; Flags: dontcopy
Source: "F:\9.3_Win10_AdvClone\AdvClone_Python_License\dist\License_Check.exe"; Flags: dontcopy

Source: "F:\9.3_Win10_AdvClone\AdvClone_Python_QT\config.ini"; DestDir: "{app}"; Flags: ignoreversion; Check: LicenseCheckPassed
Source: "F:\9.3_Win10_AdvClone\AdvClone_Python_QT\dist\AdvClone.exe"; DestDir: "{app}"; Flags: ignoreversion; Check: LicenseCheckPassed
Source: "F:\9.3_Win10_AdvClone\AdvClone_Python_QT\dist\run_prepare_grub_env.exe"; DestDir: "{app}"; Flags: ignoreversion; Check: LicenseCheckPassed
;Support Recovery Button
Source: "F:\9.3_Win10_AdvClone\AdvClone_QT&Clonezilla_Parts\support_Recovery_Button\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Check: LicenseCheckPassed
Source: "F:\9.3_Win10_AdvClone\AdvClone_QT&Clonezilla_Parts\support_Recovery_Button\boot\grub\grub.cfg"; DestDir: "{app}"; Flags: ignoreversion; Check: LicenseCheckPassed

;Support IBMC
;Source: "F:\9.3_Win10_AdvClone\AdvClone_QT&Clonezilla_Parts\support_IBMC\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Check: LicenseCheckPassed
;Source: "F:\9.3_Win10_AdvClone\AdvClone_QT&Clonezilla_Parts\support_IBMC\boot\grub\grub.cfg"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Check: LicenseCheckPassed

[Icons]
Name: "{group}\AdvClone"; Filename: "{app}\AdvClone.exe"


; --- ���벿�� ---
[Code]
var
  DefaultDir: String;
  LicensePage: TWizardPage;
  LicenseEdit: TEdit;
  BrowseButton: TButton;
  StatusLabel: TLabel;
  InfoMemo: TMemo;
  gLicensePassed: Boolean;
  RunAppCheckBox: TNewCheckBox;

function GetDefaultDir(S:String): String;
begin
    DefaultDir := 'C:\Program Files'
    //DefaultDir := 'C:\'
    Log('DefaultDir is: '+DefaultDir);
    Result :=  DefaultDir;
end;
// ��ȡ˵�����ݵĺ���
function GetLicenseInfo: string;
var
  InfoToolPath: string;
  ResultCode: Integer;
  TempFile: string;
  OutputString: AnsiString;  // ʹ�� AnsiString ��ȡ�ļ�
  Success: Boolean;
begin
  Result := '�޷���ȡDevice ID��Ϣ��';
  
  // ����device id�Ĺ���
  InfoToolPath := ExpandConstant('{tmp}\License_Generate_deviceID.exe');
  
  // ��鹤���Ƿ����
  if not FileExists(InfoToolPath) then
  begin
    // ���û�й��ߣ�����Ĭ����Ϣ
    Result := '˵�����޷��ɹ������豸��ʶID' + #13#10 +
              '�����ȡ���֤������ϵ��Ӧ��';
    Exit;
  end;
  
  // ������ʱ�ļ�·��
  TempFile := ExpandConstant('{tmp}\device_id.txt');
  
  try
    // ִ�й�������˵����Ϣ
    if Exec(InfoToolPath, '"' + TempFile + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      if (ResultCode = 0) and FileExists(TempFile) then
      begin
        // ��ȡ���ɵ�txt�ļ�����
        //LoadStringFromFile(TempFile, Result);
        // ��ȷʹ�� LoadStringFromFile - ��һ�������� AnsiString
        Success := LoadStringFromFile(TempFile, OutputString);
        if Success then
        begin
          // �� AnsiString ת��Ϊ String
          Result := OutputString;
        end
        else
        begin
          Result := '�޷���ȡ����ļ����ݡ�';
        end;
        
        // ������ʱ�ļ�
        DeleteFile(TempFile);
      end
      else
      begin
        Result := '��ȡDevice IDʧ��';
      end;
    end
    else
    begin
      Result := '�޷�ִ������Device ID�ĳ���';
    end;
  except
    Result := '��ȡDevice ID�����쳣��';
  end;
end;

// �Ľ����ļ��������
procedure BrowseClick(Sender: TObject);
var
  FileName: string;
begin
  if GetOpenFileName(
    '��ѡ�����֤�ļ�',
    FileName,
    '',
    '���֤�ļ� (*.lic)|*.lic|�����ļ� (*.*)|*.*',
    'lic'
  ) then
  begin
    LicenseEdit.Text := FileName;
    StatusLabel.Caption := '��ѡ���ļ�: ' + ExtractFileName(FileName);
    StatusLabel.Font.Color := clWindowText;
  end;
end;

// ҳ����ʾʱ����˵����Ϣ
procedure LicensePageActivate(Sender: TWizardPage);
begin
  // ÿ�ν���ҳ��ʱ����˵����Ϣ
  InfoMemo.Lines.Text := GetLicenseInfo();
end;

// ҳ�洴��ʱ��ʼ��
procedure LicensePageCreate(Sender: TObject);
begin
  // ҳ�洴��ʱ��������˵����Ϣ
  InfoMemo.Lines.Text := '���ڼ���Device ID';
  InfoMemo.Lines.Text := GetLicenseInfo();
end;


function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
  CheckerPath, LicensePath: String;
begin
  Result := True;
  if CurPageID = LicensePage.ID then
  begin
    LicensePath := Trim(LicenseEdit.Text);
    if LicensePath = '' then
    begin
      MsgBox('��ѡ�����֤�ļ���', mbError, MB_OK);
      Result := False;
      Exit;
    end;

    CheckerPath := ExpandConstant('{tmp}\License_Check.exe');

    if not Exec(CheckerPath, '"' + LicensePath + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      MsgBox('�޷�ִ�����֤У�����', mbError, MB_OK);
      Result := False;
      Exit;
    end;

    if ResultCode <> 0 then
    begin
      MsgBox('���֤У��ʧ�ܣ���װ���˳���', mbCriticalError, MB_OK);
      Result := False;
      WizardForm.Close;
    end
    else
    begin
      gLicensePassed := True;  // ���У��ɹ�
    end;
  end;
end;

procedure InitializeWizard;
var
  InfoLabel: TLabel;
  FileLabel: TLabel;
  PageWidth: Integer;
begin
  gLicensePassed := False;
  
  // ��ǰ�ͷű�Ҫ���ļ�
  ExtractTemporaryFile('License_Check.exe');
  ExtractTemporaryFile('License_Generate_deviceID.exe');
  
  // �������֤ҳ��
  LicensePage := CreateCustomPage(wpSelectDir, '���֤��֤', '����֤���֤�Լ�����װ');

  PageWidth := LicensePage.SurfaceWidth;
  
  // ����˵����Ϣ��ǩ
  InfoLabel := TLabel.Create(WizardForm);
  InfoLabel.Parent := LicensePage.Surface;
  InfoLabel.Caption := '���֤��֤��Ϣ��';
  InfoLabel.SetBounds(0, 0, PageWidth, 16);
  InfoLabel.Font.Style := [fsBold];
  
  // ���������ı�����ʾ˵����Ϣ
  InfoMemo := TMemo.Create(WizardForm);
  InfoMemo.Parent := LicensePage.Surface;
  InfoMemo.SetBounds(0, 20, PageWidth, 60);
  InfoMemo.ScrollBars := ssVertical;
  InfoMemo.ReadOnly := True;
  InfoMemo.WordWrap := True;
  //InfoMemo.Color := clInfoBk;  // ���ñ���ɫ
  
  // �����ļ�ѡ���ǩ
  FileLabel := TLabel.Create(WizardForm);
  FileLabel.Parent := LicensePage.Surface;
  FileLabel.Caption := 'ѡ�����֤�ļ���';
  FileLabel.SetBounds(0, 130, 200, 16);
  FileLabel.Font.Style := [fsBold];
  
  // �����ļ�·�������
  LicenseEdit := TEdit.Create(WizardForm);
  LicenseEdit.Parent := LicensePage.Surface;
  LicenseEdit.SetBounds(0, 150, PageWidth-80, 23);
  
  // ���������ť
  BrowseButton := TButton.Create(WizardForm);
  BrowseButton.Parent := LicensePage.Surface;
  BrowseButton.Caption := '���...';
  BrowseButton.SetBounds(PageWidth - 75, 149, 75, 25);
  BrowseButton.OnClick := @BrowseClick;
  
  // ����״̬��ǩ
  StatusLabel := TLabel.Create(WizardForm);
  StatusLabel.Parent := LicensePage.Surface;
  StatusLabel.Caption := '��ѡ�����֤�ļ���ʼ��֤';
  StatusLabel.SetBounds(0, 180, 400, 16);
  
  // ע��ҳ���¼�
  LicensePage.OnActivate := @LicensePageActivate;

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
(*
procedure CurStepChanged(CurStep: TSetupStep);
var
  ErrorCode: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    if RunAppCheckBox.Checked then
    begin
      Exec(ExpandConstant('{app}\AdvClone.exe'), '', '', SW_SHOW, ewNoWait, ErrorCode);
    end;
  end;
end;
*)
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