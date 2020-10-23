#Enter a path to your import CSV file
$ADUsers = Import-csv C:\Scripts\Import.csv

foreach ($User in $ADUsers)
{

       $Username    = $User.Username
       $Password    = $User.Password
       $Firstname   = $User.First
       $Lastname    = $User.Last
       $OU           = $User.OU

       #Check if the user account already exists in AD
       if (Get-ADUser -F {SamAccountName -eq $Username})
       {
               #If user does exist, output a warning message
               Write-Warning "A user account $Username has already exist in Active Directory."
       }
       else
       {
              #If a user does not exist then create a new user account
          
        #Account will be created in the OU listed in the $OU variable in the CSV file; don’t forget to change the domain name in the"-UserPrincipalName" variable
              New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@wli.dpn.gov.uk" `
            -Name "$Username" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -ChangePasswordAtLogon $True `
            -DisplayName "$Username" `
            -Path $OU `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force)


       }
}

