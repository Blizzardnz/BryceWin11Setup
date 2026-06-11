@echo off
title Bryce Windows 11 Setup

set "PANTHER=C:\Windows\Panther"
set "UNATTEND=%PANTHER%\unattend.xml"

if not exist "%PANTHER%" mkdir "%PANTHER%"

powershell -NoProfile -ExecutionPolicy Bypass ^
"$ErrorActionPreference='Stop'; ^
Add-Type -AssemblyName System.Windows.Forms; ^
Add-Type -AssemblyName System.Drawing; ^
$form = New-Object System.Windows.Forms.Form; ^
$form.Text='Bryce Windows 11 Setup'; ^
$form.Size=New-Object System.Drawing.Size(420,280); ^
$form.StartPosition='CenterScreen'; ^
$form.FormBorderStyle='FixedDialog'; ^
$form.MaximizeBox=$false; ^
$form.MinimizeBox=$false; ^
$form.TopMost=$true; ^
$lblUser=New-Object System.Windows.Forms.Label; ^
$lblUser.Text='Username:'; ^
$lblUser.Location='20,25'; ^
$lblUser.Size='100,20'; ^
$txtUser=New-Object System.Windows.Forms.TextBox; ^
$txtUser.Location='140,20'; ^
$txtUser.Size='220,25'; ^
$txtUser.Text='User'; ^
$chkPass=New-Object System.Windows.Forms.CheckBox; ^
$chkPass.Text='Use Password'; ^
$chkPass.Location='140,60'; ^
$chkPass.Size='150,25'; ^
$lblPass=New-Object System.Windows.Forms.Label; ^
$lblPass.Text='Password:'; ^
$lblPass.Location='20,100'; ^
$lblPass.Size='100,20'; ^
$txtPass=New-Object System.Windows.Forms.TextBox; ^
$txtPass.Location='140,95'; ^
$txtPass.Size='220,25'; ^
$txtPass.UseSystemPasswordChar=$true; ^
$txtPass.Enabled=$false; ^
$chkPass.Add_CheckedChanged({$txtPass.Enabled=$chkPass.Checked}); ^
$btnOK=New-Object System.Windows.Forms.Button; ^
$btnOK.Text='Create Account'; ^
$btnOK.Location='140,150'; ^
$btnOK.Size='140,35'; ^
$btnOK.Add_Click({ ^
 if([string]::IsNullOrWhiteSpace($txtUser.Text)){ ^
  [System.Windows.Forms.MessageBox]::Show('Please enter a username'); ^
  return ^
 } ^
 $global:USERNAME=$txtUser.Text.Trim(); ^
 $global:PASSWORD=$txtPass.Text; ^
 $global:USEPASS=$chkPass.Checked; ^
 $form.Close(); ^
}); ^
$form.Controls.AddRange(@($lblUser,$txtUser,$chkPass,$lblPass,$txtPass,$btnOK)); ^
$form.ShowDialog() | Out-Null; ^
if([string]::IsNullOrWhiteSpace($global:USERNAME)){exit 1}; ^
$xml=@'
<?xml version=""1.0"" encoding=""utf-8""?>
<unattend xmlns=""urn:schemas-microsoft-com:unattend"" xmlns:wcm=""http://schemas.microsoft.com/WMIConfig/2002/State"">
  <settings pass=""specialize"">
    <component name=""Microsoft-Windows-Shell-Setup"" processorArchitecture=""amd64"" publicKeyToken=""31bf3856ad364e35"" language=""neutral"" versionScope=""nonSxS"">
      <ComputerName>*</ComputerName>
    </component>
  </settings>
  <settings pass=""oobeSystem"">
    <component name=""Microsoft-Windows-Shell-Setup"" processorArchitecture=""amd64"" publicKeyToken=""31bf3856ad364e35"" language=""neutral"" versionScope=""nonSxS"">
      <OOBE>
        <HideEULAPage>true</HideEULAPage>
        <NetworkLocation>Work</NetworkLocation>
        <ProtectYourPC>3</ProtectYourPC>
        <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
        <SkipMachineOOBE>true</SkipMachineOOBE>
        <SkipUserOOBE>true</SkipUserOOBE>
      </OOBE>
      <UserAccounts>
        <LocalAccounts>
          <LocalAccount wcm:action=""add"">
            <Password>
              <Value>__PASSWORD__</Value>
              <PlainText>true</PlainText>
            </Password>
            <Description>Local admin created by Bryce setup</Description>
            <DisplayName>__USERNAME__</DisplayName>
            <Group>Administrators</Group>
            <Name>__USERNAME__</Name>
          </LocalAccount>
        </LocalAccounts>
      </UserAccounts>
    </component>
  </settings>
</unattend>
'@; ^
$xml=$xml.Replace('__USERNAME__',$global:USERNAME); ^
if($global:USEPASS){ ^
 $xml=$xml.Replace('__PASSWORD__',$global:PASSWORD) ^
}else{ ^
 $xml=$xml.Replace('__PASSWORD__','') ^
}; ^
Set-Content -Path 'C:\Windows\Panther\unattend.xml' -Value $xml -Encoding UTF8"
 
if errorlevel 1 (
    echo Setup cancelled.
    pause
    exit /b
)

echo.
echo Unattend file created.
echo.
echo Rebooting into OOBE...
echo.

%WINDIR%\System32\Sysprep\Sysprep.exe /oobe /unattend:C:\Windows\Panther\unattend.xml /reboot