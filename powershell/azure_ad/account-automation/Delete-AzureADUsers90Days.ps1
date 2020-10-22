#Requires -Version 5.1
#Requires -Modules AzureAD, AzureADPreview

param (

  [Parameter()]
  $tenantID = "c22fc3cd-0711-47f1-ab72-a5b70634ad1d",
  [Parameter()]
  $certThumbprint = "*** In vault ****",
  [Parameter()]
  $appID = "*** In vault ****"

)

# Module needed for Get-AzureAdAuditSigninLogs function
Import-Module AzureADPreview -Force

# Need certificate imported on the VM we will be running from
#Import-Certificate -FilePath C:\Temp\AzureAD_Automation_Account.pfx -CertStoreLocation Local

# Use Richs Log function

If ((Test-path C:\Temp) -ne $True)
{ New-Item -path C:\Temp -ItemType Directory }

If ((Test-path C:\Temp\Archive) -ne $True)
{ New-Item -path C:\Temp\Archive -ItemType Directory }

Function Add-Log {
    Param ([string]$logstring)
    $date = Get-Date
    $Global:date = $date.ToString("dd-MM-yyyy-HH-mm")
    $Global:logfile = ("C:\Temp\AzureADDeletion_Logfile.txt")
    $Global:archiveLogfile = ("C:\Temp\Archive\AzureADDeletion_Logfile_$Global:date.txt")
    Add-Content $logfile -value "$date :: $logstring"
}

Function Cleanup-Log {
    Move-Item $logfile $archiveLogfile
}

$returnObject = @{
    Success = $true
    Data = @{
        Users = @()
    }
}

try
{

    try
    {
        Add-Log "###### Starting Delete Users who have not logged in for 90 Days or more Script ######"

        Add-Log ("Connecting to AzureAD")

        # Connect to Azure AD
        Connect-AzureAD `
                -TenantId $tenantID `
                -CertificateThumbprint $certThumbprint `
                -ApplicationId $appID

    }
	catch [Exception]

	{
		$ExceptionDetail = $_.Exception
		Write-Error "Error connecting to AzureAD - $ExceptionDetail."
        Add-Log "Error connecting to AzureAD - $ExceptionDetail."
        $returnObject.Success = $false
        $returnObject.Data = $ExceptionDetail
	}

    if($returnObject.Success){
        
        try
        {

            Add-Log ("Getting all Users from AzureAD")

            $Users = Get-AzureADUser -All:$True
        }
        catch [Exception]

	    {
		    $ExceptionDetail = $_.Exception
		    Write-Error "Error Getting users from AzureAD - $ExceptionDetail."
            Add-Log "Error Getting users from AzureAD - $ExceptionDetail."
            $returnObject.Success = $false
            $returnObject.Data = $ExceptionDetail
	    }

        # Setting run count for Graph throttling
        $RunCount = 0
    }

    if($returnObject.Success){

        try
        {

            $loginDate = (Get-Date).AddDays(-90)
            $90Days = Get-Date $loginDate -Format yyyy-MM-dd

            Add-Log ("Starting foreach loop to delete users who have not logged in since before $90Days")

            ForEach ($User in $Users)
            {

                if(++$RunCount % 100 -eq 0) 
                {
                    Start-Sleep -Seconds 10
                }

                $UPN = $User.UserPrincipalName
                $LoginTime = Get-AzureAdAuditSigninLogs -Top 1 -filter "userprincipalname eq '$UPN'"

                switch -regex ($User.UserPrincipalName)
                {
                    '^[aA]\d{4}[Q-ZA-Z]{2}@' {$UserType = 'Prisoner'}
                    '^[a-zA-Z0-9]{6,6}@.*$' {$UserType = 'Staff'}
                    '^.*\#EXT\#@.*$' {$UserType = 'External'}
                    Default {$UserType = 'Unknown'}
                }

                if(-not ([String]::IsNullOrEmpty($LoginTime.CreatedDateTime))){

                    if($LoginTime.CreatedDateTime.Split('T')[0] -le $90Days){

                        $UserLastLogon = [PSCUSTOMOBJECT]@{DisplayName=$User.DisplayName;UserPrincipalName=$UPN;Location=$User.Department;UserType=$UserType;LastLogonTime=$LoginTime.CreatedDateTime;Deleted="Yes"}
                    
                        #Remove-AzureADUser -ObjectID $UPN

                        Add-Log ("$UserType User " + $UPN + " has been deleted from " + $User.Department)
                    }
                }

                $returnObject.Data.Users += $UserLastLogon
                $UserLastLogon = $null
            }

            Add-Log ("Finished removing users, " + $returnObject.Data.Users.DisplayName.Count + " users have been deleted.")

        }
        catch [Exception]

	    {
		    $ExceptionDetail = $_.Exception
		    Write-Error "Error getting and deleting $UPN  - $ExceptionDetail."
            Add-Log "Error getting and deleting $UPN - $ExceptionDetail."
            $returnObject.Success = $false
            $returnObject.Data = $ExceptionDetail
	    }

    }
}
catch [Exception]

{
	$ExceptionDetail = $_.Exception
	Write-Error "Error deleting users - $ExceptionDetail."
    Add-Log "Error deleting users - $ExceptionDetail."
    $returnObject.Success = $false
    $returnObject.Data = $ExceptionDetail
}
finally
{

Add-Log ("Exporting All deleted users to CSV for reference C:\Temp\Archive\AzureADDeletion_Spreadsheet_$Global:date.csv")

$returnObject.Data.Users | Where {$_} | Export-Csv ("C:\Temp\Archive\AzureADDeletion_Spreadsheet_$Global:date.csv") -NoTypeInformation

Add-Log ("Moving log file $logfile to $archiveLogfile")

Cleanup-Log

$returnObject
}