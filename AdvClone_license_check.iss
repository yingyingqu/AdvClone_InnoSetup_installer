; --- 安装配置 ---
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

;安装包本身的文件版本
VersionInfoVersion=2025.10.24
;安装包版权信息
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


; --- 代码部分 ---
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
// 获取说明内容的函数
function GetLicenseInfo: string;
var
  InfoToolPath: string;
  ResultCode: Integer;
  TempFile: string;
  OutputString: AnsiString;  // 使用 AnsiString 读取文件
  Success: Boolean;
begin
  Result := '无法获取Device ID信息。';
  
  // 生成device id的工具
  InfoToolPath := ExpandConstant('{tmp}\License_Generate_deviceID.exe');
  
  // 检查工具是否存在
  if not FileExists(InfoToolPath) then
  begin
    // 如果没有工具，返回默认信息
    Result := '说明：无法成功产出设备标识ID' + #13#10 +
              '如需获取许可证，请联系供应商';
    Exit;
  end;
  
  // 生成临时文件路径
  TempFile := ExpandConstant('{tmp}\device_id.txt');
  
  try
    // 执行工具生成说明信息
    if Exec(InfoToolPath, '"' + TempFile + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      if (ResultCode = 0) and FileExists(TempFile) then
      begin
        // 读取生成的txt文件内容
        //LoadStringFromFile(TempFile, Result);
        // 正确使用 LoadStringFromFile - 第一个参数是 AnsiString
        Success := LoadStringFromFile(TempFile, OutputString);
        if Success then
        begin
          // 将 AnsiString 转换为 String
          Result := OutputString;
        end
        else
        begin
          Result := '无法读取输出文件内容。';
        end;
        
        // 清理临时文件
        DeleteFile(TempFile);
      end
      else
      begin
        Result := '获取Device ID失败';
      end;
    end
    else
    begin
      Result := '无法执行生成Device ID的程序。';
    end;
  except
    Result := '获取Device ID发生异常。';
  end;
end;

// 改进的文件浏览函数
procedure BrowseClick(Sender: TObject);
var
  FileName: string;
begin
  if GetOpenFileName(
    '请选择许可证文件',
    FileName,
    '',
    '许可证文件 (*.lic)|*.lic|所有文件 (*.*)|*.*',
    'lic'
  ) then
  begin
    LicenseEdit.Text := FileName;
    StatusLabel.Caption := '已选择文件: ' + ExtractFileName(FileName);
    StatusLabel.Font.Color := clWindowText;
  end;
end;

// 页面显示时更新说明信息
procedure LicensePageActivate(Sender: TWizardPage);
begin
  // 每次进入页面时更新说明信息
  InfoMemo.Lines.Text := GetLicenseInfo();
end;

// 页面创建时初始化
procedure LicensePageCreate(Sender: TObject);
begin
  // 页面创建时立即加载说明信息
  InfoMemo.Lines.Text := '正在加载Device ID';
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
      MsgBox('请选择许可证文件！', mbError, MB_OK);
      Result := False;
      Exit;
    end;

    CheckerPath := ExpandConstant('{tmp}\License_Check.exe');

    if not Exec(CheckerPath, '"' + LicensePath + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      MsgBox('无法执行许可证校验程序！', mbError, MB_OK);
      Result := False;
      Exit;
    end;

    if ResultCode <> 0 then
    begin
      MsgBox('许可证校验失败，安装将退出。', mbCriticalError, MB_OK);
      Result := False;
      WizardForm.Close;
    end
    else
    begin
      gLicensePassed := True;  // 标记校验成功
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
  
  // 提前释放必要的文件
  ExtractTemporaryFile('License_Check.exe');
  ExtractTemporaryFile('License_Generate_deviceID.exe');
  
  // 创建许可证页面
  LicensePage := CreateCustomPage(wpSelectDir, '许可证验证', '请验证许可证以继续安装');

  PageWidth := LicensePage.SurfaceWidth;
  
  // 创建说明信息标签
  InfoLabel := TLabel.Create(WizardForm);
  InfoLabel.Parent := LicensePage.Surface;
  InfoLabel.Caption := '许可证验证信息：';
  InfoLabel.SetBounds(0, 0, PageWidth, 16);
  InfoLabel.Font.Style := [fsBold];
  
  // 创建多行文本框显示说明信息
  InfoMemo := TMemo.Create(WizardForm);
  InfoMemo.Parent := LicensePage.Surface;
  InfoMemo.SetBounds(0, 20, PageWidth, 60);
  InfoMemo.ScrollBars := ssVertical;
  InfoMemo.ReadOnly := True;
  InfoMemo.WordWrap := True;
  //InfoMemo.Color := clInfoBk;  // 设置背景色
  
  // 创建文件选择标签
  FileLabel := TLabel.Create(WizardForm);
  FileLabel.Parent := LicensePage.Surface;
  FileLabel.Caption := '选择许可证文件：';
  FileLabel.SetBounds(0, 130, 200, 16);
  FileLabel.Font.Style := [fsBold];
  
  // 创建文件路径输入框
  LicenseEdit := TEdit.Create(WizardForm);
  LicenseEdit.Parent := LicensePage.Surface;
  LicenseEdit.SetBounds(0, 150, PageWidth-80, 23);
  
  // 创建浏览按钮
  BrowseButton := TButton.Create(WizardForm);
  BrowseButton.Parent := LicensePage.Surface;
  BrowseButton.Caption := '浏览...';
  BrowseButton.SetBounds(PageWidth - 75, 149, 75, 25);
  BrowseButton.OnClick := @BrowseClick;
  
  // 创建状态标签
  StatusLabel := TLabel.Create(WizardForm);
  StatusLabel.Parent := LicensePage.Surface;
  StatusLabel.Caption := '请选择许可证文件开始验证';
  StatusLabel.SetBounds(0, 180, 400, 16);
  
  // 注册页面事件
  LicensePage.OnActivate := @LicensePageActivate;

  //最后完成页面添加让用户选择是否立即执行
  RunAppCheckBox := TNewCheckBox.Create(WizardForm);
  RunAppCheckBox.Parent := WizardForm.FinishedPage;
  RunAppCheckBox.Caption := '立即启动AdvClone执行程序';
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
  // 在安装程序完全退出后执行
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
    //删除 {app} 文件夹及其中所有文件
    Log('[Debug]删除安装目录');
    DelTree(ExpandConstant('{app}'), True, True, True);
  end;
end;