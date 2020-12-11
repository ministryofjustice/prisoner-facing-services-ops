<# 
#************************************************************************
#*
#* COMMAND FILE
#*  CallBuild.PS1
#*
#* SYNOPSIS
#*  Calls other build scripts in a central fashion. One call to rule them all....
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

#Calls each file as required - Addon as require
.\ansible-postconfig.ps1
.\disks.ps1
.\IISBuild.ps1


#Import the external IIS module.
import-module ".\IISStructure.psm1"

#Function call to create application pool
New-IISAPPPool -Name 'APP_Wayland' -Dotnet 'v4.0' -Pipeline 'Integrated'

#Funcation call to create website
New-IISSite -ID 1 -Name 'Unilink_Kiosk' -PhysicalDir 'Unilink' -Port 80 -AppPool 'APP_Wayland' -HostHeader 'unilink.service.wli.dpn.go.uk'

#Function call to create Application
New-IISApplication -Name 'CMSCLRWS' -Website 'Unilink_Kiosk' -Path 'E:\IISWebsites\Unilink\CMSCLRWS' -AppPool 'APP_Wayland'

###Outside the module for now. Will move in when time permits as this isn't simple..
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -location 'Unilink_Kiosk/CMSCLRWS' -filter "system.webServer/security/authentication/windowsAuthentication" -name "enabled" -value "True"
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -location 'Unilink_Kiosk/CMSCLRWS' -filter "system.webServer/security/authentication/anonymousAuthentication" -name "enabled" -value "False"
