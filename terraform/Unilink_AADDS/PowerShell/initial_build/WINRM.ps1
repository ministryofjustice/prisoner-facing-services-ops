<# 
#************************************************************************
#*
#* COMMAND FILE
#*  WINRM.PS1
#*
#* SYNOPSIS
#*  Makes a quick change to WINRM to allow for the Ansible script top run - Generates certs also
#*
#* ARGUMENTS
#*  NONE
#*
#* PLATFORM
#*  Common Build Framework
#*
#* AUTHOR
#*  Rich Dakin - RADITC 04-05-2020
#*
#* VERSION CONTROL
#*  1.0   :: 04-05-2020 :: Creation. 
#*
#************************************************************************
#> 



$Cert = New-SelfSignedCertificate -DnsName $RemoteHostName, $ComputerName `
-CertStoreLocation "cert:\LocalMachine\My" `
-FriendlyName "Prod WinRM Cert"

$Cert | Out-String

$Thumbprint = $Cert.Thumbprint

Write-Host "Enable HTTPS in WinRM"
$WinRmHttps = "@{Hostname=`"$RemoteHostName`"; CertificateThumbprint=`"$Thumbprint`"}"
winrm create winrm/config/Listener?Address=*+Transport=HTTPS $WinRmHttps

Write-Host "Set Basic Auth in WinRM"
$WinRmBasic = "@{Basic=`"true`"}"
winrm set winrm/config/service/Auth $WinRmBasic

Write-Host "Open Firewall Port"
netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=5985