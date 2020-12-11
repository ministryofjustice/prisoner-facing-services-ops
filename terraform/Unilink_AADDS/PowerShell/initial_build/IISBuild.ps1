<# 
#************************************************************************
#*
#* COMMAND FILE
#*  IISBUILD.PS1
#*
#* SYNOPSIS
#*  Installs and configures IIS 8.5 / 9.0 to CIS and OWASP Standard - Configured for E disks
#*
#* ARGUMENTS
#*  NONE
#*
#* PLATFORM
#*  Common Build Framework
#*
#* AUTHOR
#*  Rich Dakin - RADITC 2014
#*
#* VERSION CONTROL
#*  1.0   :: 09-10-2014 :: Creation. 
#*  1.1   :: 24-11-2-14 :: Added Updated following MS RAP
#*  2.0   :: 26-03-2019 :: Updated for Server 2019 Standards
#*  3.0   :: 01-05-2020 :: Updated for use with Unilink WS and API
#*  3.1   :: 13-05-2020 :: Updated the authentication providers. Something about 2019 DCE and not including these.
#*
#************************************************************************
#> 


$ErrorActionPreference = "Stop"
#************************************************************************
# Function to remove default website and application pools
#************************************************************************
function RemoveDefaults {
    
    

    write-Output "Removing Default Application Pools..." 
    Get-ChildItem IIS:\AppPools | Remove-Item -Recurse
    If ($?){
        Write-Output "AppPools removed"
    }

    write-Output "Removing Default Web Site..." 
    Get-ChildItem IIS:\Sites | Remove-Item -Recurse
    If ($?){
        Write-Output "Website removed"
    }
} 



# *********************************************************************** 
# Clear errors
# *********************************************************************** 
$error.clear()


# *********************************************************************** 
# Import ServerManger Module
# *********************************************************************** 
Import-Module ServerManager

# *********************************************************************** 
# Install IIS features
# *********************************************************************** 



$FeaturesRequired = @("FileAndStorage-Services","Storage-Services","Web-Server","Web-WebServer","Web-Common-Http","Web-Default-Doc","Web-Dir-Browsing", `
"Web-Http-Errors","Web-Static-Content","Web-Http-Redirect","Web-Health","Web-Http-Logging","Web-Custom-Logging","Web-Log-Libraries", `
"Web-Request-Monitor","Web-Performance","Web-Stat-Compression","Web-Security","Web-Filtering","Web-Mgmt-Tools","Web-Mgmt-Console", `
"Web-Scripting-Tools","Web-Mgmt-Service","NET-Framework-45-Features", `
"NET-Framework-45-Core","NET-Framework-45-ASPNET","NET-WCF-Services45","NET-WCF-TCP-PortSharing45","BitLocker","EnhancedStorage", `
"System-DataArchiver","Windows-Defender","PowerShellRoot","PowerShell","PowerShell-ISE","WoW64-Support","XPS-Viewer","Web-Windows-Auth","Web-CertProvider", "Web-Client-Auth","Web-Digest-Auth","Web-Cert-Auth", `
"Web-IP-Security","Web-Url-Auth")


for ($i=0; $i -le $FeaturesRequired.Length – 1; $i++){
    $featureToInstall = $FeaturesRequired[$i]
    write-Output "Installing $featureToInstall..." 
    $result = Add-WindowsFeature $featureToInstall
    write-Output $result

    # *********************************************************************** 
    # Check result of install for failure, reboot etc.
    # *********************************************************************** 
    If ($result.Success -eq "True"){
        If ($result.RestartNeeded -eq "No"){
            Write-Output "$featureToInstall has been successfully installed."
        } Else {
            Write-Output "$featureToInstall has been successfully installed, reboot required..."
        }
    } 
}

$DirWebSites = "E:\IISWebsites"
$DirLogfiles = "E:\IISLogfiles"
$DirTemp = "E:\IISTempFiles"
$DirError = $DirWebsites + "\CommonErrorPages"
$DirWMSvc = $DirLogfiles + "\WMSvc"
$DirASPCache = $DirTemp + "\ASPCache"
$DirASPDotNet = $DirTemp + "\TempASPDotNet"
$DirHTTPComp = $DirTemp + "\HTTPCompression"
$DirErrorC = "C:\inetpub\custerr\en-US"
$DirAppLogs = "E:\ApplicationLogfiles\"

$HttpErrRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\HTTP\Parameters"
$HttpErrRegKey = "ErrorLoggingDir"

# *********************************************************************** 
# Create Directory Structure for IIS Websites
# *********************************************************************** 
write-Output "Creating Directory Structure for IIS Websites..." 
If(!(test-path $DirWebSites))
{
      New-Item -ItemType Directory -Force -Path $DirWebSites
          Write-Output "Directory created"
}

# *********************************************************************** 
# Remove inheritance on IIS Websites directory
# *********************************************************************** 
write-Output "Removing inheritance on IIS Websites directory..." 
$acl = Get-Acl $DirWebSites
$acl.SetAccessRuleProtection($True, $True)
$acl | Set-Acl
$acl = Get-Acl $DirWebSites
$acl.Access | where {$_.IdentityReference -eq "NT AUTHORITY\Authenticated Users"} |%{$acl.RemoveAccessRule($_)}
$acl | Set-Acl

If ($?){
    Write-Output "Inheritance Removed"
} 

# *********************************************************************** 
# Create Directory Structure for IIS Error Pages
# *********************************************************************** 
write-Output "Creating Directory Structure for IIS Error Pages..." 

If(!(test-path $DirError))
{
      New-Item -ItemType Directory -Force -Path $DirError
          Write-Output "Directory created"
}


# *********************************************************************** 
# Create Directory Structure for IIS LogFiles
# *********************************************************************** 
write-Output "Creating Directory Structure for IIS LogFiles..." 

If(!(test-path $DirLogfiles))
{
      New-Item -ItemType Directory -Force -Path $DirLogfiles
          Write-Output "Directory created"
}


# *********************************************************************** 
# Create Directory Structure for WMSvc LogFiles
# *********************************************************************** 
write-Output "Creating Directory Structure for WMSvc LogFiles..." 
If(!(test-path $DirWMSvc))
{
      New-Item -ItemType Directory -Force -Path $DirWMSvc
          Write-Output "Directory created"
}

# *********************************************************************** 
# Create Directory Structure for IIS Temp
# *********************************************************************** 
write-Output "Creating Directory Structure for IIS Temp..." 

If(!(test-path $DirTemp))
{
      New-Item -ItemType Directory -Force -Path $DirTemp
          Write-Output "Directory created"
}

# *********************************************************************** 
# Create Directory Structure for ASP Cache
# *********************************************************************** 
write-Output "Creating Directory Structure for ASP Cache..." 
If(!(test-path $DirASPCache))
{
      New-Item -ItemType Directory -Force -Path $DirASPCache
          Write-Output "Directory created"
}

# *********************************************************************** 
# Create Directory Structure for TempASPDotNet
# *********************************************************************** 
write-Output "Creating Directory Structure for TempASPDotNet..." 

If(!(test-path $DirASPDotNet))
{
      New-Item -ItemType Directory -Force -Path $DirASPDotNet
          Write-Output "Directory created"
}

# *********************************************************************** 
# Create Directory Structure for HTTP Compression
# *********************************************************************** 
write-Output "Creating Directory Structure for HTTP Compression..." 

If(!(test-path $DirHTTPComp))
{
      New-Item -ItemType Directory -Force -Path $DirHTTPComp
          Write-Output "Directory created"
}
# *********************************************************************** 
# Create Directory Structure for Application Logs
# *********************************************************************** 
write-Output "Creating Directory Structure for Application Logs..." 

If(!(test-path $DirAppLogs))
{
      New-Item -ItemType Directory -Force -Path $DirAppLogs
          Write-Output "Directory created"
}
# *********************************************************************** 
# Set permissions for Application Logs directory
# *********************************************************************** 
write-Output "Set permissions for Application Logs directory..." 
$acl = Get-Acl $DirAppLogs
$perm = "IIS_IUSRS","FullControl","Allow"
$accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $perm
$acl.AddAccessRule($accessRule)
$acl | Set-Acl

If ($?){
    Write-Output "ACL set"
} 

# *********************************************************************** 
# Copy IIS Error Pages
# *********************************************************************** 
write-Output "Copy IIS Error Pages..." 
Copy-Item $DirErrorC -Destination $DirError -recurse -force
If ($?){
    Write-Output "Files copied"
} 

# *********************************************************************** 
# Import WebAdministration Module
# *********************************************************************** 
Import-Module WebAdministration

# *********************************************************************** 
# Apply IIS configuration
# *********************************************************************** 
write-Output "Setting DefaultWebsite location..." 
set-webconfigurationproperty /system.applicationHost/sites/virtualDirectoryDefaults -name physicalPath -value $DirWebsites
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting Default Log location..." 
set-webconfigurationproperty /system.applicationHost/sites/siteDefaults/logFile -name directory -value $DirLogfiles
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting Default Logging fields..." 
set-webconfigurationproperty /system.applicationHost/sites/siteDefaults/logFile -name logExtFileFlags -value "Date,Time,ClientIP,UserName,ServerIP,Method,UriStem,UriQuery,HttpStatus,Win32Status,BytesSent,BytesRecv,TimeTaken,ServerPort,UserAgent,Referer,HttpSubStatus"
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting ASP enableApplicationRestart..." 
set-webconfigurationproperty /system.webserver/asp -name enableApplicationRestart -value "False"
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting ASP enableParentPaths..." 
set-webconfigurationproperty /system.webserver/asp -name enableParentPaths -value "False"

If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting ASP errorsToNTLog..." 
set-webconfigurationproperty /system.webserver/asp -name errorsToNTLog -value "True"
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting ASP scriptErrorMessage..." 
set-webconfigurationproperty /system.webserver/asp -name scriptErrorMessage -value "ASP Error Message"
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting ASP maxRequestEntityAllowed..." 
set-webconfigurationproperty /system.webserver/asp/limits -name maxRequestEntityAllowed -value 200000
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting ASP diskTemplateCacheDirectory..." 
set-webconfigurationproperty /system.webserver/asp/cache -name diskTemplateCacheDirectory -value $DirASPCache
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting ASP allowSessionState..." 
set-webconfigurationproperty /system.webserver/asp/session -name allowSessionState -value "False"
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting HTTP Compression directory..." 
set-webconfigurationproperty /system.webserver/httpcompression -name directory -value $DirHTTPComp
If ($?){
    Write-Output "Setting applied"
} 

$ErrorCodes = @("401", "403", "404", "405", "406", "412", "500", "501", "502")
for ($i=0; $i -le $ErrorCodes.Length – 1; $i++){
    $ThisErrorCode=$ErrorCodes[$i]
    write-Output "Setting $ThisErrorCode Error Page location..." 
    set-WebConfiguration -Filter /System.WebServer/HttpErrors/Error[@StatusCode=$ThisErrorCode] -value @{PrefixLanguageFilePath=$DirError; Path="$ThisErrorCode.htm"; ResponseMode="File"}
    If ($?){
        Write-Output "Setting applied"
    }
}

write-Output "Setting Default W3C Logfile location..." 
set-webconfigurationproperty /system.applicationHost/log/centralW3CLogFile -name directory -value $DirLogfiles
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting Default Binary Logfile location..." 
set-webconfigurationproperty /system.applicationHost/log/centralBinaryLogFile -name directory -value $DirLogfiles
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting App Pool default processModel..." 
set-webconfigurationproperty /system.applicationHost/applicationPools/applicationPoolDefaults/processModel -name identityType -value "ApplicationPoolIdentity"
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting App Pool default recycling..." 
set-webconfigurationproperty /system.applicationHost/applicationPools/applicationPoolDefaults/recycling -name disallowRotationOnConfigChange -value "True"
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting App Pool default logging..." 
set-webconfigurationproperty /system.applicationHost/applicationPools/applicationPoolDefaults/recycling -name logEventOnRecycle -value "Time, Requests, Schedule, Memory, IsapiUnhealthy, OnDemand, ConfigChange, PrivateMemory"
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting App Pool default recycle period..." 
set-webconfigurationproperty /system.applicationHost/applicationPools/applicationPoolDefaults/recycling/periodicRestart -name time -value "1.05:00:00"
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Setting App Pool default recycle time..." 
set-webconfiguration /system.applicationHost/applicationPools/applicationPoolDefaults/recycling/periodicRestart/schedule -value (New-TimeSpan -h 4 -m 00)
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Remove Customem Headers..." 
clear-webconfiguration /system.webServer/httpProtocol/customHeaders/add
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Clear Request Filtering settings..." 
clear-webconfiguration /system.webServer/security/requestFiltering
If ($?){
    Write-Output "Setting applied"
} 

write-Output "Set Request Filtering - allow only listed extensions..." 
set-webconfigurationproperty /system.webServer/security/requestFiltering/fileExtensions -name allowUnlisted -value "False"
If ($?){
    Write-Output "Setting applied"
} 

$AllowedExt = @(".asp", ".aspx", ".swf", ".htm", ".html", ".gif", ".jpg", ".jpeg", ".js", ".ico", ".css", ".pdf", ".axd", ".ashx", ".png", ".asmx")
for ($i=0; $i -le $AllowedExt.Length – 1; $i++){
    $ThisExt=$AllowedExt[$i]
    write-Output "Set Request Filtering - configure allowed extension $ThisExt..." 
    Add-WebConfiguration /system.webServer/security/requestFiltering/fileExtensions -Value @{fileExtension="$ThisExt"; allowed="true"}
    If ($?){
        Write-Output "Setting applied"
    } 
}

write-Output "Set Request Filtering - allow only listed verbs..." 
set-webconfigurationproperty /system.webServer/security/requestFiltering/verbs -name allowUnlisted -value "False"
If ($?){
    Write-Output "Setting applied"
} 

$AllowedVerb = @("GET", "HEAD", "POST")
for ($i=0; $i -le $AllowedVerb.Length – 1; $i++){
    $ThisVerb=$AllowedVerb[$i]
    write-Output "Set Request Filtering - configure allowed verb $ThisVerb..." 
    Add-WebConfiguration /system.webServer/security/requestFiltering/verbs -Value @{verb="$ThisVerb"; allowed="true"}
    If ($?){
        Write-Output "Setting applied"
    } 
}

$DeniedSeq = @("..", "./", ":", "%", "&", ";\")
for ($i=0; $i -le $DeniedSeq.Length – 1; $i++){
    $ThisSeq=$DeniedSeq[$i]
    write-Output "Set Request Filtering - configure disallowed URL sequence $ThisSeq..." 
    Add-WebConfiguration /system.webServer/security/requestFiltering/denyUrlSequences -Value @{sequence="$ThisSeq"}
    If ($?){
        Write-Output "Setting applied"
    } 
}

write-Output "Disable SessionState..." 
set-webconfigurationproperty /system.web/sessionState -pspath 'MACHINE/WEBROOT' -name mode -value "Off"
If ($?){
    Write-Output "Setting applied"
} 

#call function
RemoveDefaults

get-item -path $HttpErrRegPath | new-Itemproperty -name $HttpErrRegKey -value $DirLogfiles -Force

# *********************************************************************** 
#  Enable Operational Log 
# *********************************************************************** 
write-Output "Enabling Configuration Auditing at Microsoft-IIS-Configuration/Operational"

$EnableOpsLog = new-object System.Diagnostics.ProcessStartInfo
$EnableOpsLog.fileName = "C:\Windows\System32\wevtutil.exe"
$EnableOpsLog.Arguments= ' sl Microsoft-IIS-Configuration/Operational /e:true'
$EnableOpsLog.windowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden

$Process = [System.Diagnostics.Process]::Start($EnableOpsLog)
If ($?){
    Write-Output "Enabled Configuration Auditing"
} 

# *********************************************************************** 
#  Enable HTTP Dynamic Web Compression 
# *********************************************************************** 
write-Output "Setting HTTP Dynamic Web Compression..." 
set-webconfigurationproperty /system.webserver/urlcompression -name doDynamicCompression -value "True"
If ($?){
    Write-Output "Setting applied"
} 

# *********************************************************************** 
#  Enable HTTP Static Web Compression 
# *********************************************************************** 
write-Output "Setting HTTP Static Web Compression..." 
set-webconfigurationproperty /system.webserver/urlcompression -name doStaticCompression -value "True"
If ($?){
    Write-Output "Setting applied"
} 


# *********************************************************************** 
#  Update Request Limits 
#
#  1. The MaxConcurrentRequestsPerCPU setting should be 5000 or higher.
#  2. The MaxConcurrentThreadsPerCPU setting should be 0.
#  3. The RequestQueueLimit setting should be 5000 or higher.
# *********************************************************************** 
write-Output "Setting MaxConcurrentRequestsPerCPU..." 

New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" -Name MaxConcurrentRequestsPerCPU -PropertyType DWord -Value 5000 -Force
If ($?){
    Write-Output "Setting applied"
}


write-Output "Setting MaxConcurrentThreadsPerCPU..." 

New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" -Name MaxConcurrentThreadsPerCPU -PropertyType DWord -Value 0 -Force
If ($?){
    Write-Output "Setting applied"
}

write-Output "Setting RequestQueueLimit..." 

New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" -Name requestQueueLimit -PropertyType DWord -Value 5000 -Force
If ($?){
    Write-Output "Setting applied"
}



# *********************************************************************** 
#  Disable TLS 1.0 
# *********************************************************************** 
write-Output "Disable TLS 1.0" 
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.0" -Force
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0" -Name "Server" -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name Enabled -PropertyType DWord -Value 000000000 -Force
If ($?){
    Write-Output "Setting applied"
}

# *********************************************************************** 
#  Disable TLS 1.1 
# *********************************************************************** 
write-Output "Disable TLS 1.1" 
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.1" -Force
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" -Name "Server" -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name Enabled -PropertyType DWord -Value 000000000 -Force
If ($?){
    Write-Output "Setting applied"
}

# *********************************************************************** 
#  Enable TLS 1.2 
# *********************************************************************** 
write-Output "Enable TLS 1.2" 
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.2" -Force
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2" -Name "Server" -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name Enabled -PropertyType DWord -Value 000000001 -Force
If ($?){
    Write-Output "Setting applied"
}

# *********************************************************************** 
#  Disable SSL 2.0 
# *********************************************************************** 
write-Output "Disable SSL 2.0" 
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "SSL 2.0" -Force
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0" -Name "Server" -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" -Name Enabled -PropertyType DWord -Value 000000000 -Force
If ($?){
    Write-Output "Setting applied"
}

# *********************************************************************** 
#  Disable SSL 3.0 Server 
# *********************************************************************** 
write-Output "Disable SSL 3.0 - Server" 
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "SSL 3.0" -Force
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0" -Name "Server" -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -Name Enabled -PropertyType DWord -Value 000000000 -Force
If ($?){
    Write-Output "Setting applied"
}

# *********************************************************************** 
#  Enable SSL 3.0 - Client 
# *********************************************************************** 
write-Output "Enable SSL 3.0 - Client" 
#New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "SSL 3.0" -Force - dupe
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0" -Name "Client" -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client" -Name Enabled -PropertyType DWord -Value 000000000 -Force
If ($?){
    Write-Output "Setting applied"
}



#************************************************************************
# CBF Standard Error Handler. 
# This formats errors nicely for the user, and makes sure that the
# exception is handed back up the stack if needed.
#************************************************************************
trap { 
  ''
  'Error: 
{0}' -f
   $_.Exception.Message;
   "----------------------------------------------------------------------------------------------------------"
   "Powershell Error Handler Details: "
      if ($Env:CBF_Engine_Host_Language -contains "Powershell") {
            break
      } else {
            #exit 1
      }
    
    $_ | fl * -Force
}
