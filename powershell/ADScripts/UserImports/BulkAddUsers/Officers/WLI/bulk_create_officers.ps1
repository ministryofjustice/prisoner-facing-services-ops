###########################################################
# AUTHOR  : Richard Hooper
# DATE    : 21/11/2016  
# COMMENT : Creates Active Directory users and populates
#           different attributes based on NewUsers.csv
###########################################################
Import-Module ActiveDirectory
$path     = Split-Path -parent $MyInvocation.MyCommand.Definition
$newpath  = $path + "\NewUsers.csv"
# Define variables
$log      = $path + "\created_ActiveDirectory_users.log"
$date     = Get-Date
$i        = 0


Function createActiveDirectoryUsers
{

"Created the following Active Directory users (on " + $date + "): " | Out-File $log -append
"--------------------------------------------" | Out-File $log -append

  $Users = Import-CSV $newpath
  ForEach ($user in $Users) { 
    $samAccount = $User.UserID
    
    Try   { $exists = Get-ADUser -LDAPFilter "(sAMAccountName=$samAccount)" }
    Catch { }
    If(!$exists)
    {
      $i++
      # Set all variables according to the table names in the Excel 
      # sheet / import CSV. The names can differ in every project, but 
      # if the names change, make sure to change it below as well.
      $Name = $User.Firstname + " " + $User.Lastname
      $UPN = $User.UserID + "@wli.dpn.com"
      $OU = "OU=Officers,OU=WLI,OU=Accounts,OU=WLI,OU=Prisons,DC=WLI,DC=DPN,DC=GOV,DC=UK"
      $setpass = ConvertTo-SecureString -AsPlainText $User.Password -force
      New-ADUser -Name "$Name" -SamAccountName $User.UserID  `
      -GivenName $User.Firstname -Surname $User.Lastname -DisplayName $User.UserID `
      -UserPrincipalName $User.UPN `
      -ChangePasswordAtLogon $true `
      -AccountPassword $setpass -Enabled $true -Path "$OU"

 
      #Add user to group
    
  if($user.Group1 -match "Staff Admin") {  
    
     
      Add-ADGroupMember -Identity "Staff Admins" -Member $user.UserID 
     
     }
     if($user.Group2 -match "Prisoner Admins Staff") {  
    
     
      Add-ADGroupMember -Identity "Prisoner admin staff" -Member $user.UserID 
     
     }
    
      $output  = $i.ToString() + ") Name: " + $Name + "  UserID: " 
      $output += $User.UserID + "  Pass: " + $User.Password
      $output | Out-File $log -append
    }
    else{
      "SKIPPED - USER ALREADY EXISTS OR ERROR: " + $User.UserID | Out-File $log -append
    }
    }
  
  }
  

  "----------------------------------------" + "`n" | Out-File $log -append


# Run function
createActiveDirectoryUsers
#End Script