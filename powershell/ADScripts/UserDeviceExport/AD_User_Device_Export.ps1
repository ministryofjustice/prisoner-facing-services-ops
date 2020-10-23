<# 
#************************************************************************
#*
#* COMMAND FILE
#*  AD_User_Device_Export.ps1
#*
#* SYNOPSIS
#*  1.  Exports Pwhich device a prisoner is locked to, into a dated csv file.
#*  2.  Removes exports that are over 90 days old.
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
#*  1.0   :: 18-06-2020 :: Creation. 
#*
#************************************************************************
#>
# PowerShell function - Add-Log
# Author: Rich Dakin
# Modified: David Robinson
Function Add-Log {
    Param ([string]$logstring)
    $logfile = "D:\Script Logs\Prisoner_Device_Export_Log.txt"
    $date = Get-date
    $Global:date = $date.ToString("dd-MM-yyyy HH:mm")
    add-content $logfile -value "$date :: $logstring"
}
 
# Adding script start fields to log file.
Add-Log "###################### Script Start ###########################"

# Identifies the Domain / Site the script is running on.
If (($env:USERDOMAIN) -eq "WLI") {
    $Global:Domain = "WLI"
}
elseif (($env:USERDOMAIN) -eq "BWI") {
    $Global:Domain = "BWI"
}

# Identifies the Domain / Site for Edu Laptop 1 the script is running on.
If (($env:USERDOMAIN) -eq "WLI") {
    $Global:Edu1 = "PLWLIEDU001"
}
elseif (($env:USERDOMAIN) -eq "BWI") {
    $Global:Edu1 = "PLBWIEDU001"
}

# Identifies the Domain / Site for Edu Laptop 2 the script is running on.
If (($env:USERDOMAIN) -eq "WLI") {
    $Global:Edu2 = "PLWLIEDU002"
}
elseif (($env:USERDOMAIN) -eq "BWI") {
    $Global:Edu2 = "PLBWIEDU002"
}

# Outputs the Domain / Site the script is running on to the log file.
Add-Log "################ This script is running on $domain ################" 
# Target OU (Prisoners Only)
$OUGroup = "OU=Prisoners,OU=$Domain,OU=Accounts,OU=$Domain,OU=Prisons,DC=$Domain,DC=DPN,DC=GOV,DC=UK"
# Export Folder
$Folder = "D:\Exports\"
# Export file name before being edited.
$FileName = "D:\Exports\ADUsers.csv"
# Temp export file name.
$FileTemp = "D:\Exports\ADUsersTemp.csv"
# Sets file name date format.
$enddate = (Get-Date).tostring("yyyy-MM-dd") + ".csv"
# Set time in days before deleting old exports.
$Daysback = "-90"
# Gets date. 
$CurrentDate = Get-Date
# Edu Laptops
$Education = ",$Edu1,$Edu2', '"
# Delete old.
$DatetoDelete = $CurrentDate.AddDays($Daysback)
# Exports prisoner data from AD.
Import-Module ActiveDirectory
Get-ADUser -Filter * -SearchBase $OUGroup -Properties SamAccountName, GivenName, SurName, LogonWorkstations, Lastlogondate | Select-Object SamAccountName, GivenName, SurName, LogonWorkstations, Lastlogondate | export-csv $FileName
# Edits export file.
(Get-Content -Path $FileName) -replace "$Education" -replace '"', '' -replace '#TYPE Selected.Microsoft.ActiveDirectory.Management.ADUser', '' | Add-Content -Path $FileTemp
# Deletes temp export file. 
Remove-Item -Path $FileName
# Renames 2nd temp file to final export.
Move-Item -Path $FileTemp -Destination $Folder"AD_Prisoners_$enddate"  
# Deletes old exports.
Get-ChildItem $Folder | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item 
# Adding script end fields to log file.
Add-Log "####################### Script End ############################"
# End of Script.  

 