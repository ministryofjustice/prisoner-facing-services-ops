# Inserts registry settings to allow auto logon for kiosks
# Removes EAS policies that disable auto logon when enrolled to AAD
$password = " https://prisoner-ops-vault.vault.azure.net/ kioskuser  "
$username = "Site Specific Username example kioskuser "
Remove-Item -Path Registry::"HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\EAS" -Recurse -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value $password -force
New-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value $username -force
New-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1 -force
New-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultDomainName  -Value "identity.prisoner.service.justice.gov.uk" -force
Restart-Computer -force
