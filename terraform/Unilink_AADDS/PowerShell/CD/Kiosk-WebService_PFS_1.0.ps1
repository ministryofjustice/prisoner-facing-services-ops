###Deployment script

param
(
    [Parameter(Mandatory)] [String]$KioskIISUser,
    [String]$KioskIISUserPassword="",
    [String]$KioskIISLocal="true",
    [String]$WebApplicationName="CMSCLRWS",
    [Parameter(Mandatory)] [String]$CMSSITE,
    [Parameter(Mandatory)] [String]$WebAppPoolName,
    [Parameter(Mandatory)] [String]$Prison

)


# Inclusions
Import-Module WebAdministration

# Main

# Initialise
$WebApplicationFolder = "E:\IISWebsites\$Prison\$WebApplicationName\"
$WebAppPoolRef = "IIS:\AppPools\$WebAppPoolName"


# Allow the IIS workergroup access to the web application folder
$Acl = Get-Acl $WebApplicationFolder
$Ar = New-Object  System.Security.AccessControl.FileSystemAccessRule('IIS_IUSRS','Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl $WebApplicationFolder $Acl

# Create and configure a dedicated Application Pool
New-WebAppPool -Name $WebAppPoolName
Set-ItemProperty $WebAppPoolRef -Name processModel.loadUserProfile -Value $true
Set-ItemProperty $WebAppPoolRef -Name managedRuntimeVersion -Value 'v4.0'

# Create and configure the Application
New-WebApplication -Name $WebApplicationName -Site $CMSSITE -ApplicationPool $WebAppPoolName -PhysicalPath $WebApplicationFolder

# Create a local user to authenticate against
if ($KioskIISLocal -eq "true") {
    $Computername = $env:COMPUTERNAME
    $ADSIComp = [adsi]"WinNT://$Computername"
    $NewUser = $ADSIComp.Create('User',$KioskIISUser)
    $NewUser.SetPassword($KioskIISUserPassword)
    $NewUser.SetInfo()
    $NewUser.FullName = "Kiosk IIS User"
    $NewUser.SetInfo()
    $NewUser.UserFlags = 64 + 65536 # ADS_UF_PASSWD_CANT_CHANGE + ADS_UF_DONT_EXPIRE_PASSWD
    $NewUser.SetInfo()
}
Try  {
# Set Authentication for the Application
Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/anonymousAuthentication" -Name Enabled -Value False -PSPath IIS:\ -Location "$CMSSITE/$WebApplicationName"
Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/windowsAuthentication" -Name Enabled -Value True -PSPath IIS:\ -Location "$CMSSITE/$WebApplicationName"
} 
Catch {
    Write-Output "Authentication set failed"
}

Try { 
# Set Authorisation for the Application.  NB: The included web.config denies all users by default
Add-WebConfiguration "/system.webServer/security/authorization " -value @{accessType="Allow";users="$KioskIISUser"} -PSPath "IIS:\Sites\$CMSSITE\$WebApplicationName"
} 
Catch {
    Write-Output "Authorisation set failed - This is using an ADD, not a SET"
}
