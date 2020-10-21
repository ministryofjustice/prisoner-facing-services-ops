#**************************************************************************************************
# AD-CleanUp.ps1
# For use with Windows 2012 (SCRIPT)
#
# SYNOPSIS
# Set of functions
# 1) Add-Log - Creates and addes to a log file at D:\AD-Automation - This is the primary log format.
# 2) Get-ADInfo - Gets the AD infor for Prisoners or Officers based upon the passed Param. Uses this data to create 
# base stats, audit and CSV's for usage later on
# 3) Move-ToDisabled - Moves the found AD objects that are 90 days or more (since usage, password reset, last login)
# to a disable OU in AD. Storage is 180 days from here. Again uses the OU passed and data passed. Thus can be called
# a custom CSV.
# 4) Move-AdRogue - Function to move any accounts that have been renabled in the disabled OU. Stops accidental deletion.
# 5) Remove-ADAccounts - Deletes accounts that are older than 180 days. Login, password set, will reset this counter.
# 6) Final part of the script moves all logs into a secondary folder and keeps for 120 days.
#
#Presumption – This is being run on the Wayland or Berwyn AD Structure.
#
# CUSTOM ATTRIBUTES REQUIRED
# N/A
#
# PLATFORM
# Windows Server 2012 / 2016 / 2019 POSH 4.0 +
#
# AUTHOR
# Richard Dakin
#
# VERSION CONTROL
# 1.0   :: 06/03/2019 :: Creation
# 1.1   :: 21/10/2020 :: Updated - David Robinson
#
#**************************************************************************************************
#**************************************************************************************************



# PowerShell function - Add-Log
# Author: Rich Dakin
Function Add-Log {
    Param ([string]$logstring)
    $logfile = "D:\AD-Automation\Logfile.txt"
    $date = Get-date
    $Global:date = $date.ToString("dd-MM-yyyy-HH-mm")
    add-content $logfile -value "$date :: $logstring"
}
#Sub#
If ((Test-path D:\AD-Automation) -ne $True)
{ New-Item -path D:\AD-Automation -ItemType Directory }

#Adding script start fields

Add-Log "#######################Script start###########################"

#What domain?

If (($env:USERDOMAIN) -eq "WLI") {
    $Global:Domain = "WLI"
}
elseif (($env:USERDOMAIN) -eq "BWI") {
    $Global:Domain = "BWI"
}

Add-Log "This script is running on $domain"


# PowerShell function - AD information
# Author: Rich Dakin
Function Get-ADInfo {
    [cmdletbinding()]
    Param (
        [string]$OU,
        [string]$verb
    )
    # End of Parameters
    $rawlog = "D:\ad-automation\Rawlog-$ou-$date.txt"
    $global:prisonercsv = "D:\ad-automation\Name-Prisoners-$date.csv"
    $global:officercsv = "D:\ad-automation\Name-Officers-$date.csv"

    $90Days = (get-date).adddays(-28)
    #Get Raw data
    Write-Output "Getting raw data"
    Add-Log "Getting raw data"
    $global:AD90Days = Get-ADUser -SearchBase "OU=$OU,OU=$Domain,OU=Accounts,OU=$Domain,OU=Prisons,DC=$Domain,DC=DPN,DC=GOV,DC=UK" -properties * -filter { (lastlogondate -le $90days) -or (logoncount -eq "0") -AND (passwordlastset -le $90days) -and (whencreated -le $90days) }

    #Do we want a verbose log of the accounts found?
    If (($verb) -eq $True) {
        Write-Output "Creating verbose log file at $Rawlog"
        $AD90Days | select Displayname, Created, LastLogonDate, PasswordLastSet, UserPrincipalName, whenCreated, CanonicalName, DistinguishedName, userWorkstations `
        | export-csv $rawlog
        Add-Log "Added data to $rawlog"
    }
    Else {   
        If (($ou) -eq "Prisoners") {
            Write-host "Creating name only Prisoners CSV"
            Add-log "Added data to $prisonercsv"
            $AD90Days | Select distinguishedName | Export-csv $prisonercsv
        }
        ElseIf (($ou) -eq "officers") {
            Write-host "Creating name only Prisoners CSV"
            Add-log "Added data to $officercsv"
            $AD90Days | Select distinguishedName | Export-csv $officercsv
        }
    }
}




# PowerShell function - Disable Accounts
# Author: Rich Dakin
Function Move-ToDisabled {
    [cmdletbinding()]
    Param (
        # Specify CSV path. Import CSV file and assign it to a variable. This is cast in the function Get-ADInfo
        # Allowing it to be parmeratised for future usage
        [string]$CSV,
        [string]$SourceOU
    )
    If (($SourceOU) -eq "Prisoners") {
        # Specify target OU. This is where users will be moved.
        Write-Output "Running job for Prisoners only"
        Add-log "Running job for Prisoners only"
        $global:TargetOU = "OU=Prisoners,OU=Disabled,OU=$Domain,OU=Accounts,OU=$Domain,OU=Prisons,DC=$Domain,DC=DPN,DC=GOV,DC=UK"
    }
    ElseIf (($SourceOU) -eq "Officers") {
        # Specify target OU. This is where users will be moved.
        Write-Output "Running job for Officers only"
        Add-log "Running job for officers only"
        $global:TargetOU = "OU=Officers,OU=Disabled,OU=$Domain,OU=Accounts,OU=$Domain,OU=Prisons,DC=$Domain,DC=DPN,DC=GOV,DC=UK"
    }
    $Imported_csv = Import-Csv -Path "$csv" 
    $rawlogimport = import-csv -Path "$rawlog"

    Foreach ($rawdata in $rawlogimport)
    {
    $sam = $rawdata.samaccountname
    Set-AdUser -Identity $sam -logonworkstation $null
    }

    Foreach ($UserDN in $Imported_csv) {

        # Retrieve DN of user
        $UserDN = $UserDN.distinguishedName
    
        # Move user to target OU.
        Write-Output "Moving $UserDN to $TargetOU"
        Add-log "Moving $UserDN to $TargetOU"
        Move-ADObject -Identity $UserDN -TargetPath $TargetOU



    }

    If (($SourceOU) -eq "Prisoners") {
        #Finally, disable the accounts
        Add-Log "Disabling Prisoners Accounts"
        Add-Log "Writing audit data D:\AD-Automation\Audit.csv"
        $Audit = Get-ADUser -SearchBase "OU=Prisoners,OU=Disabled,OU=$Domain,OU=Accounts,OU=$Domain,OU=Prisons,DC=$Domain,DC=DPN,DC=GOV,DC=UK" -properties * -filter { (Enabled -eq $True) }
        $Audit | Export-Csv D:\Ad-automation\Prisoner-Disable-Audit-$date.csv
        Get-ADUser –SearchBase “$TargetOU” –Filter * | Disable-ADAccount
        $audit.sameaccountname = $sam
    Foreach ($sami in $Sam)
    {
 
    Set-AdUser -Identity $sami -logonworkstation $null
    }


    }
    ElseIf (($SourceOU) -eq "Officers") { 
        ##Staff
        Add-Log "Disabling Officers Accounts"
        Add-Log "Writing audit data D:\AD-Automation\Audit.csv"
        $Audit = Get-ADUser -SearchBase "OU=Officers,OU=Disabled,OU=$Domain,OU=Accounts,OU=$Domain,OU=Prisons,DC=$Domain,DC=DPN,DC=GOV,DC=UK" -properties * -filter { (Enabled -eq $True) }
        $Audit | Export-Csv D:\Ad-automation\Staff-Disable-Audit-$date.csv
        Get-ADUser –SearchBase “$TargetOU” –Filter * | Disable-ADAccount
    }
}


# PowerShell function - Delete older than 180 days
# Author: Rich Dakin
Function Remove-ADAccounts {
    [cmdletbinding()]
    Param (
        [string]$OU
    )
    $180csv = "D:\AD-Automation\DeleteADAccounts-$date"
    $global:180Days = (get-date).adddays(-180)
    $global:AD180Days = Get-ADUser -SearchBase "OU=$OU,OU=Disabled,OU=$Domain,OU=Accounts,OU=$Domain,OU=Prisons,DC=$Domain,DC=DPN,DC=GOV,DC=UK" -properties * -filter { (lastlogondate -le $180Days) -or (logoncount -eq "0") -AND (passwordlastset -le $180Days) -and (whencreated -le $180Days) }
    If (($ou) -eq "Prisoners") {
        $AD180Days | Select distinguishedName | Export-csv $180csv-Prisoner.csv
        $180csv = "$180csv-Prisoner.csv"
    }
    Elseif (($Ou) -eq "Officers") {
        $AD180Days | Select distinguishedName | Export-csv $180csv-Officers.csv 
        $180csv = "$180csv-Officers.csv"
    }
    Write-Output "Deleting accounts from $Ou"
    Add-log "Deleting accounts from $Ou"
    $Imported_csv = Import-Csv -Path "$180csv" 
    Foreach ($UserDelete in $Imported_csv) {
        # Retrieve DN of user.
        $UserDelete = $UserDelete.distinguishedName
        # Move user to target OU.
        Write-host $UserDelete -ForegroundColor Red
        Add-Log "Deleting $UserDelete"
        Remove-ADUser -Identity $UserDelete -Confirm:$False
    }
}


#Check for any rogue accounts in the wrong OU and move them back to the correct OU
# PowerShell function - AD Rogue
# Author: Rich Dakin
Function Move-AdRogue {
    [cmdletbinding()]
    Param (
        [string]$OU
    )
    $Returncsv = "D:\AD-Automation\Return-$OU-$date.csv"
    $ReturnOU = "OU=$OU,OU=$Domain,OU=Accounts,OU=$Domain,OU=Prisons,DC=$Domain,DC=DPN,DC=GOV,DC=UK"
    $ReturnDSN = Get-ADUser -SearchBase "OU=$OU,OU=Disabled,OU=$Domain,OU=Accounts,OU=$Domain,OU=Prisons,DC=$Domain,DC=DPN,DC=GOV,DC=UK" -properties * -filter { (Enabled -eq $True) }
    $ReturnDSN | select distinguishedName | Export-csv $Returncsv
    $Imported_csv = Import-Csv -Path "$Returncsv" 
    Foreach ($Return in $Imported_csv) {
        # Retrieve DN of user.
        $Return = $Return.distinguishedName
        # Move user to target OU.
        Write-Output "Moving $Return to $ReturnOU"
        Add-Log "Moving $Return to $returnOU - Return"
        Move-ADObject  -Identity $Return  -TargetPath $ReturnOU
   
    }
}


###Running Jobs###


Add-Log "Running ADInfo for Prisoners"
Get-ADInfo -Ou prisoners -verb $True
Get-ADinfo -OU Prisoners -verb $false

Add-Log "Running ADInfo for Officers"
Get-ADInfo -Ou Officers -verb $True
Get-ADinfo -OU Officers -verb $false

Add-Log "$officercsv"
Add-Log "$prisonercsv"


Add-Log "Running Move-ToDisabled for Officers"
Move-ToDisabled -CSV $officercsv -SourceOU "Officers"
Add-Log "Running Move-ToDisabled for Prisoners"
Move-ToDisabled -CSV $prisonercsv -SourceOU "Prisoners"

Add-Log "Running Move-AdRogue for Officers"
Move-AdRogue -OU "Officers"
Add-Log "Running Move-AdRogue for Prisoners"
Move-AdRogue -OU "Prisoners"

Add-Log "Remove-ADAccounts for Prisoners"
Remove-ADAccounts -OU "Prisoners"
Add-Log "Remove-ADAccounts for Officers"
Remove-ADAccounts -OU "Officers"





###Clean Up and Audit###

#Begin checks
#Check backup DIR exists first...
If ((Test-Path $BackupDIR) -eq $False) {
    New-item -itemtype directory -path $BackupDIR
    Add-Log 'Backup Folder Being Created'
}


Add-Log "Cleaning up"

$backupdir = "D:\AD-Automation\backup"
$backup = GCI "D:\AD-Automation\*" -Exclude backup, "*.ps1"
Try {
    Add-Log "Running Compress archive job"
    Compress-Archive -Path $backup -CompressionLevel Fastest -DestinationPath $backupdir\$date.zip

    Add-Log "Cleaning up the leftover logs"
    Remove-Item $backup -force
}
Catch {
    Add-Log "Clean up job failed"
    #Although I do nothing with this, it's there to be captured by "something" a later date.
    
    $logFileExists = Get-EventLog -list | Where-Object { $_.logdisplayname -eq "AD-CleanUpJob" } 
    If (($logFileExists) -eq $False) {
        New-EventLog -LogName "Application" -Source "AD-CleanUpJob"
    }
    Write-EventLog -LogName "Application" -Source "AD-CleanUpJob" -EventID 999 -EntryType Error -Message "The AD Clean up job failed to clean up!" -Category 1 -RawData 10, 20
}

#Log Maintenance

#let's do some backup maintenance....
$backupdircount = get-childitem $backupdir | Measure-Object
If (($backupdircount.Count) -gt 10) {
    Add-log "Cleaning up logs older than 60 days"
    Get-ChildItem –Path $backupdir -Recurse | Where-Object { ($_.LastWriteTime -lt (Get-Date).AddDays(-60)) } | Remove-Item
}
  
Add-Log "All done"


