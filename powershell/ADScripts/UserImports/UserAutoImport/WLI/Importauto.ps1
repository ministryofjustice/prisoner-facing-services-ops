#Enter a path to your import CSV file

 $ADUsers = Import-csv "\\WLISMSSQ002\C$\1 SQL\jamie.txt"

# $ADUsers = Import-csv C:\Scripts\Tasks\jamie_temp.txt

foreach ($User in $ADUsers) {

    $Username = $User.prisonnumber
    $Password = "***Insert***"
    $Firstname = $User.forenames
    $Lastname = $User.surname
    $OU = 'OU=Prisoners,OU=WLI,OU=Accounts,OU=WLI,OU=Prisons,DC=WLI,DC=DPN,DC=GOV,DC=UK'

    #Check if the user account already exists in AD
    
    if (Get-ADUser -F { SamAccountName -eq $Username }) {
        
        #If user does exist, output a warning message
        Write-Warning "$Username already exists."
       

        # If in Disabled OU by cleanup script (But not moved due to breakages)

        if (Get-ADUser -F { SamAccountName -eq $Username } -searchbase 'OU=Prisoners,OU=Disabled,OU=WLI,OU=Accounts,OU=WLI,OU=Prisons,DC=WLI,DC=DPN,DC=GOV,DC=UK' -SearchScope OneLevel) {
            
            #If user does exist, output a warning message
            
            Write-Warning "$Username is disabled and being moved"

            #Move, Enable, Reset Password, Add correct groups, Clear logon workstations.
            
            get-aduser $Username | Move-ADObject -TargetPath $OU
            Enable-ADAccount -Identity $Username
            Set-ADAccountPassword -Identity $Username -NewPassword (convertto-securestring $Password -AsPlainText -Force)
            Set-ADUser -Identity $Username -ChangePasswordAtLogon 1 -LogonWorkstations $null -Department "Wayland"
            Add-ADGroupMember -Identity 'All Prisoners' -Members $Username
            Add-ADGroupMember -Identity 'Access to Prisoner Desktops' -Members $Username
            Add-ADGroupMember -Identity 'Access to Prisoner Laptops' -Members $Username
            Unlock-ADAccount -Identity $Username


        } 
    }


    else {
        #If a user does not exist then create a new user account
        #Account will be created in the OU listed in the $OU variable in the CSV file; dont forget to change the domain name in the"-UserPrincipalName" variable
        New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@identity.prisoner.service.justice.gov.uk" `
            -Name "$Username" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -ChangePasswordAtLogon $True `
            -DisplayName "$Username" `
            -Path $OU `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force)`
            -Description "$Firstname $Lastname"`
            -Department "Wayland"

        Add-ADGroupMember -Identity 'All Prisoners' -Members $Username
        Add-ADGroupMember -Identity 'Access to Prisoner Desktops' -Members $Username
        Add-ADGroupMember -Identity 'Access to Prisoner Laptops' -Members $Username

        Set-ADAccountPassword -Identity $Username -NewPassword (convertto-securestring $Password -AsPlainText -Force)
        Enable-ADAccount -Identity $Username #added because of fine grained policy
        Set-ADUser -Identity $Username -ChangePasswordAtLogon 1
        Write-Output "$Username Created Successfully"
    }




        
}

