<# 
#************************************************************************
#*
#* COMMAND FILE
#*  Device_Cleanup_In_AD.ps1
#*
#* SYNOPSIS
#*  1.  Disables laptops that have not been active within the last 8 months.
#*  2.  Outputs disabled laptop infomation (date & name) to a log file. 
#*  3.  Moves disabled laptops to a OU called "Disabled Laptops". 
#*  4.  Outputs moved laptop infomation (date & name) to a log file. 
#*
#* ARGUMENTS
#*  NONE
#*
#* PLATFORM
#*  Common Build Framework
#*
#* AUTHOR
#*  David Robinson - Ministry of Justice - Digital & Technology 2020.
#*
#* VERSION CONTROL
#*  1.0   :: 12-05-2020 :: Creation. 
#*
#************************************************************************
#>
# PowerShell function - Add-Log
# Author: Rich Dakin
# Modified: David Robinson
Function Add-Log
        {Param ([string]$logstring)
        $logfile = "D:\Script Logs\Device_Cleanup_Log.txt"
        $date = Get-date
        $Global:date = $date.ToString("dd-MM-yyyy HH:mm")
        add-content $logfile -value "$date :: $logstring"
        }


# Adding script start fields to log file.
Add-Log "###################### Script Start ###########################"

# Identifies the Domain / Site the script is running on.
If (($env:USERDOMAIN) -eq "WLI")
{
    $Global:Domain = "WLI"
}
elseif (($env:USERDOMAIN) -eq "BWI")
{
    $Global:Domain = "BWI"
}

# Outputs the Domain / Site the script is running on to the log file.
Add-Log "################ This script is running on $domain ################"

# Sets the period of time (8 Months) a device ignored by the script before it is disabled. 
$ActiveDate = (Get-Date).AddDays(-243)

# Target OU to search for inactive devices.
$OUGroup = "OU=Laptops,OU=Prisoners,OU=Workstations,OU=$Domain,OU=Prisons,DC=$Domain,DC=DPN,DC=GOV,DC=UK"

# Target OU to move inactive laptops to.
$OUGroupTarget = "OU=Disabled Laptops,OU=Laptops,OU=Prisoners,OU=Workstations,OU=$Domain,OU=Prisons,DC=$Domain,DC=DPN,DC=GOV,DC=UK"

# Disable latops that have need inactive for the set period of time.
$Comp = Get-ADComputer -SearchScope OneLevel -SearchBase $OUGroup -Property Name,lastLogonDate -Filter {lastLogonDate -lt $ActiveDate} | Select-Object Name, LastLogonDate, DistinguishedName

ForEach ($Item in $Comp){
    $ActName = $Item.Name
    Get-ADComputer -SearchScope OneLevel -SearchBase $OUGroup -Property Name,lastLogonDate -Filter {lastLogonDate -lt $ActiveDate} | Set-ADComputer -Enabled $false | Add-Log " $ActName - Set to Disabled."
  }

# Move all disabled laptops to the target OU.
  $MovComp = Get-ADComputer -SearchScope OneLevel -SearchBase $OUGroup -Property Name,Enabled -Filter {Enabled -eq $False} | Select-Object Name, LastLogonDate, DistinguishedName

ForEach ($Item in $MovComp){
    $MovName = $Item.Name
    Get-ADComputer -SearchScope OneLevel -SearchBase $OUGroup -Property Name,Enabled -Filter {Enabled -eq $False} | Move-ADObject -TargetPath $OUGroupTarget | Add-Log " $MovName - Moved to Disabled Laptops OU."
  }

# Adding script end fields to log file.
Add-Log "####################### Script End ############################"

# End of Script.