#Requires -Version 5.1
#Requires -Modules AzureAD, Azure.Storage

param (

  [Parameter()]
  $storageAccountName = "unilinksqlbackup1",
  [Parameter()]
  $storageAccountKey = "*** In vault ****", # unilinksqlbackupstorageaccountkey
  [Parameter()]
  $storageAccountContainer = "useraccountscreation",
  [Parameter()]
  $tenantID = "c22fc3cd-0711-47f1-ab72-a5b70634ad1d",
  [Parameter()]
  $certThumbprint = "*** In vault ****", #AzureADAutomationAccountCertificateThumbprint
  [Parameter()]
  $appID = "*** In vault ****" #AzureADAutomationAccountAppID

)

# Use Richs Log function

If ((Test-path C:\Temp) -ne $True)
{ New-Item -path C:\Temp -ItemType Directory }

If ((Test-path C:\Temp\Archive) -ne $True)
{ New-Item -path C:\Temp\Archive -ItemType Directory }

# Set date at time of script start

Function Add-Log {
    Param ([string]$logstring)
    $date = Get-Date
    $Global:date = $date.ToString("dd-MM-yyyy-HH-mm")
    $Global:logfile = ("C:\Temp\AzureAD_Logfile.txt")
    $Global:archiveLogfile = ("C:\Temp\Archive\AzureAD_Logfile_$Global:date.txt")
    Add-Content $logfile -value "$date :: $logstring"
}

Function Cleanup-Log {
    Move-Item $logfile $archiveLogfile
}

$returnObject = @{
    Success = $true
    Data = $null
}

try
{

    Add-Log "###### Starting Import Users from SQL Script ######"

	try 
	{
        Add-Log ("Setting Azure storage context for " + $storageAccountName)

        $context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

        Add-Log ("Set Azure storage context to " + $storageAccountName)

	}

	catch [Exception]

	{
		$ExceptionDetail = $_.Exception
		Write-Error "Error setting Azure storage context - $ExceptionDetail."
        Add-Log "Error setting Azure storage context - $ExceptionDetail."
        $returnObject.Success = $false
        $returnObject.Data = $ExceptionDetail
	}

    if($returnObject.Success){
        
        try
        {

            Add-Log ("Getting Azure storage blobs from " + $storageAccountContainer)

            $blobs = Get-AzureStorageBlob -Container $storageAccountContainer -Blob *.txt -Context $context

            Add-Log ("Got Azure storage blobs from " + $storageAccountContainer)
        }

        catch [Exception]

        {
		    $ExceptionDetail = $_.Exception
		    Write-Error "Error getting Azure storage blobs - $ExceptionDetail."
            Add-Log "Error getting Azure storage blobs - $ExceptionDetail."
            $returnObject.Success = $false
            $returnObject.Data = $ExceptionDetail
	    }
    }

    if($returnObject.Success){
        
        try
        {

            Add-Log "Foreach loop on each blob"

            # foreach loop
            foreach ($blob in $blobs){
    
                Add-Log ("###### Starting blob foreach loop on " + $blob.Name + " ######")

                Add-Log ("Getting blob content of " + $blob.Name + " and saving it for use locally in C:\Temp")
                # Get the blob content and save it locally for use
                Get-AzureStorageBlobContent -Container $storageAccountContainer -Context $context -Blob $blob.Name -Destination C:\Temp -Force

                # Import blob as CSV

                Add-Log ("Importing users from C:\Temp\" + $blob.Name)

                $ADUsers = Import-csv ("C:\Temp\" + $blob.Name)

                Add-Log ("Creating Password profile")

                # Create password object
                $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile

                # switch statement to set variables based on blob name (sitename)
                switch ($blob.Name)
                {
                    # Add additional sites when needed
                    'cookham.txt' {$PasswordProfile.Password = "****"; $Department = "Cookham"; $ShortName = "CWI"} ## Vault SITEDefaultUserPassword
                    'wayland.txt' {$PasswordProfile.Password = "****"; $Department = "Wayland"; $Shortname = "WLI"} ## Vault SITEDefaultUserPassword
                    'berwyn.txt' {$PasswordProfile.Password = "****"; $Department = "Berwyn"; $Shortname = "BWI"} ## Vault SITEDefaultUserPassword
                }

                Add-Log ("Set site variable for $Department")

                # Need certificate imported on the VM we will be running from
                #Import-Certificate -FilePath C:\Temp\AzureAD_Automation_Account.pfx -CertStoreLocation Local

                Add-Log ("Connecting to AzureAD")

                # Connect to Azure AD
                Connect-AzureAD `
                       -TenantId $tenantID `
                       -CertificateThumbprint $certThumbprint `
                       -ApplicationId $appID

                Add-Log ("Getting $Department Administrative unit")

                $AdminUnit = Get-AzureADMSAdministrativeUnit -Filter "startswith(displayname, '$Shortname')"

                Add-Log ("Got Administrative Unit " + $AdminUnit.DisplayName)
    
                # Foreach loop to cycle through all users in the CSV and create them if they do not exist

                Add-Log ("Starting foreach loop for $Department Users")

                foreach ($User in $ADUsers) {
                    $Username = $User.prisonnumber
                    $Firstname = $User.forenames
                    $Lastname = $User.surname

                    # Check if the user account already exists in AzureAD
                    if ($ExistingUser = Get-AzureADUser -Filter "startswith(UserPrincipalName,'$Username')") {
                        # If user does exist, output a warning message
                        Add-Log "$Username already exists."
                        # Check if the user is already in the site administrative unit
                        if ($Members = Get-AzureADMSAdministrativeUnitMember -Id $AdminUnit.Id -All:$True | Where { $_.ID -match $ExistingUser.ObjectId }) {

                            Add-Log ("$Username already exists in the " + $AdminUnit.DisplayName + " Administrative Unit")

                        }
                        else {
                            # Add the user to the site adminitrative unit
                            Add-Log ("Adding $Username to the " + $AdminUnit.DisplayName + " Administrative Unit")
                            Add-AzureADMSAdministrativeUnitMember -Id $AdminUnit.Id -RefObjectId $ExistingUser.ObjectId
                            Add-Log ("$Username added to the " + $AdminUnit.DisplayName + " Administrative Unit")
                        }
                    }
                    else {

                        Add-Log ("Adding $Username to AzureAD")
                        #If a user does not exist then create a new user account
                        $NewUser = New-AzureADUser `
                            -UserPrincipalName "$Username@identity.prisoner.service.justice.gov.uk" `
                            -GivenName $Firstname `
                            -Surname $Lastname `
                            -DisplayName "$Firstname $Lastname" `
                            -Department $Department `
                            -AccountEnabled $True `
                            -PasswordProfile $PasswordProfile `
                            -UsageLocation "GB" `
                            -UserType "Member" `
                            -MailNickName "$Username" `
                            -PasswordPolicies "DisableStrongPassword"

                        Add-Log ("Added $Username to AzureAD")

                        # Check if the user is already in the site administrative unit

                        Add-Log ("Checking if $Username is a member of the administrative unit " + $AdminUnit.DisplayName)

                        if ($MemberExist = Get-AzureADMSAdministrativeUnitMember -Id $AdminUnit.Id -All:$True | Where { $_.ID -eq $NewUser.ObjectId }) {

                            Add-Log ("$Username already exists in the " + $AdminUnit.DisplayName + " Adminitrative Unit")
                        }
                        else {
                            # Add the user to the site adminitrative unit
                            Add-Log ("Adding $Username to the " + $AdminUnit.DisplayName + " Administrative Unit")
                            Add-AzureADMSAdministrativeUnitMember -Id $AdminUnit.Id -RefObjectId $NewUser.ObjectId
                        }
                    }
                }
                Add-Log ("Finished foreach loop for $Department Users")
                Add-Log ("###### Completed foreach loop for " + $blob.Name + " blob ######")
            }

            Add-Log "###### Completed foreach loop for all blobs ######"
        }

        catch [Exception]

        {
		    $ExceptionDetail = $_.Exception
		    Write-Error "Error in foreach - $ExceptionDetail."
            Add-Log "Error in foreach - $ExceptionDetail."
            $returnObject.Success = $false
            $returnObject.Data = $ExceptionDetail
	    }
    }
}

catch [Exception]

{
	$ExceptionDetail = $_.Exception
    Add-Log "Error in foreach - $ExceptionDetail."
	Write-Error "$ExceptionDetail"
    $returnObject.Success = $false
    $returnObject.Data = $ExceptionDetail
}

finally
{

Add-Log ("Moving log file $logfile to $archiveLogfile")

Cleanup-Log

$returnObject
}