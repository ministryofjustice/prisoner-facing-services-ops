 <# 
#************************************************************************
#*
#* COMMAND FILE
#*  AADCleanup.ps1
#*
#* SYNOPSIS
#*  1.  Adds Prison name to department to all users.
#*  2.  Outputs updated User infomation (date & name) to a log file. 
#*  3.  Adds "identity.prisoner.service.justice.gov.uk" to User Principal Name. 
#*  4.  Outputs updated User infomation (date & name) to a log file. 
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
#*  1.0   :: 03-12-2020 :: Creation. 
#*
#************************************************************************
#>
# PowerShell function - Add-Log
# Author: Rich Dakin
# Modified: David Robinson
Function Add-Log
        {Param ([string]$logstring)
        $logfile = "D:\Script Logs\AAD_Cleanup_Log.txt"
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
    $Department = "Wayland"
}
elseif (($env:USERDOMAIN) -eq "BWI")
{
    $Global:Domain = "BWI"
    $Department = "Berwyn"
}


# Outputs the Domain / Site the script is running on to the log file.
Add-Log "################ This script is running on $domain ################"

# Target OU to search.
$OUGroup = "OU=$Domain,OU=Accounts,OU=$Domain,OU=Prisons,DC=$Domain,DC=DPN,DC=GOV,DC=UK"

# Sets Department to User.
$SetDep = Get-ADUser -SearchBase $OUGroup -Filter {(Department -NotLike $Department)} 

ForEach ($Item in $SetDep){
    $UName = $Item.Name
    Get-ADUser -SearchBase $OUGroup -Filter {(Department -NotLike $Department)} | Set-ADUser -Identity $_ -Department $Department | Add-Log " $UName - Setting Updated."
}

# Set full username to users.
Get-ADUser -Filter * -SearchBase $OUGroup -Properties userPrincipalName | foreach { Set-ADUser $_ -UserPrincipalName (“{0}@{1}” -f $_.samaccountname,”identity.prisoner.service.justice.gov.uk”)}

# Adding script end fields to log file.
Add-Log "####################### Script End ############################" 
