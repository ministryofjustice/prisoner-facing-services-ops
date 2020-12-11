#Application Pool 
#Variables with GLOBAL scope
[String]$Global:Seperator = "$('*' * 25)"
[Boolean]$Global:Logging = $True
[String]$Global:ConfigDir = '' #Set by Invoke-MapConfigShare and Invoke-RemoveConfigShare functions in ConfigShare.psm1
[Boolean]$Global:RebootPending = $False #Set by Invoke-CopyFolder, Invoke-RestoreFolder, Invoke-MSI and Invoke-Cmd
[hashtable]$Global:ComputerInfo = @{} #Set by Get-ComputerInfo function
[hashtable]$Global:PackageInfo = @{} #Set by Get-PackageInfo function
[String]$Global:LogDir = ''
[int]$Global:InvokeCmdRet = 0 #Set by Invoke-Cmd function
[STRING]$SCRIPT:DirWebSites = 'E:\IISWebsites'
[STRING]$SCRIPT:DirLogfiles = 'E:\IISLogfiles'
[STRING]$SCRIPT:DirTemp = 'E:\IISTempFiles'
[STRING]$SCRIPT:AppPool = 'IIS:\AppPools\'
[STRING]$SCRIPT:DirASPCache = $SCRIPT:DirTemp +'\ASPCache'
[STRING]$SCRIPT:DirASPDotNet = $SCRIPT:DirTemp +'\TempASPDotNet'
[STRING]$SCRIPT:DirHTTPComp = $SCRIPT:DirTemp +'\HTTPCompression'
[STRING]$GLOBAL:inetsrv = "$env:windir\System32\inetsrv"

# PowerShell function - Add-Log
# Author: Rich Dakin
Function Add-Log
        {Param ([string]$logstring)
        $logfile = "D:\Logfile.txt"
        $date = Get-date
        $Global:date = $date.ToString("dd-MM-yyyy-HH-mm")
        add-content $logfile -value "$date :: $logstring"
        }

function New-IISAppPool
{

<#
.SYNOPSIS
This function will create an application pool on a local instance of IIS from the variables passed into it.
.DESCRIPTION
.EXAMPLE
New-IISAPPPool -Name 'Uniink' -Dotnet 'v4.0' -Pipeline 'Integrated' -Username 'BWI\UNILINKSERV01' -Password $Password
.EXAMPLE
New-IISAPPPool -Name 'AP_Unilink' -Dotnet 'v2.0' -Pipeline 'Integrated' -Flag $True -TimeOut '00:00:00' -Processes 1
.NOTES
.VERSION CONTROL
01/05/2020 - First edition - Created by Rich Dakin - PFS
#>

#$Name $DotNet $Pipeline $Flag $TimeOut $Processes $Username $Password $RecycleTime $Logging

    [CmdletBinding()]

    param(
        #Name of the application pool
        [parameter(Mandatory=$True, ValueFromPipeline=$False)]
        [string]$Name, 
        
        #This is the .Net version to be used.
        [parameter(Mandatory=$True, ValueFromPipeline=$False)]
        [string]$DotNet, 

        #Can be Classic or Integrated.
        [parameter(Mandatory=$True, ValueFromPipeline=$False)]
        [ValidateSet('Classic', 'Integrated')]
        [string]$Pipeline,
        
        #Enable 32bit?
        [parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [boolean]$Flag,
        
        #This is the idleTimeout value for the application pool and should be in the format: '00:20:00'
        [parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [ValidatePattern('\d{2}:\d{2}:\d{2}')]
        [string]$TimeOut,
        
        #The number of worker processes (also known as 'Gardens' from previous IIS versions).
        [parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [int]$Processes,
        
        #Username
        [parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [string]$Username,
        
        #Password
        [parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [string]$Password,
        
        #Recycle time
        [parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [string]$RecycleTime,
        
        #Do you want the function to log?
        [Parameter(Mandatory = $false, ValueFromPipeline=$False)]
        [boolean]$Logging = $True
    )

    try
    {
        $OldLogging = $Global:Logging
        $Global:Logging = $Logging
        Add-Log ' '
        Add-Log $Global:Seperator
        Add-Log '* Starting Function: New-IISAppPool'
        Add-Log "* Name: $Name"
        Add-Log "* DotNet: $DotNet"
        Add-Log "* Pipeline: $Pipeline"
        If ($PSBoundParameters.containskey('Flag')) {Add-Log "* Flag: $Flag"}
        If ($PSBoundParameters['TimeOut']) {Add-Log "* TimeOut: $TimeOut"}
        If ($PSBoundParameters['Processes']) {Add-Log "* Processes: $Processes"}
        If ($PSBoundParameters['Username'])
        {
            Add-Log "* Username: $Username"
            Add-Log "* Password: WILL NOT BE ECHOED"
        }
        If ($PSBoundParameters['RecycleTime']) {Add-Log "* RecycleTime: $RecycleTime"}
        Add-Log $Global:Seperator

        #Garbage collection.  Fix to Write-Host problem.
        [GC]::Collect()
    
        #Import Web Administration module
        Add-Log 'Import Web Administration module'
        Import-Module -Name 'WebAdministration'

        #Trim parameters
        $Name = $Name -replace " ", ""

            
        #Create our application pool
 
        #Trim parameters
        $Name = $Name -replace " ", ""


        if ((Test-path IIS:\AppPools\$Name) -eq $false)
        {
            New-WebAppPool -Name $Name | Out-Null 
        }
        else
        {
            Add-Log "Application Pool $Name already exists - continuing with settings"
        }

        
        #Applying application pool settings    
        Add-Log "Applying application pool settings"
        $appPoolPath = $SCRIPT:AppPool +$Name
        $applicationPool = Get-Item $appPoolPath
        $applicationPool.managedPipelineMode = "$Pipeline"
        $applicationPool.managedRuntimeVersion = "$DotNet"
        If ($PSBoundParameters.containskey('Flag'))
        {
            $Temp = $Flag -as [String]
            $applicationPool.enable32BitAppOnWin64 = $Temp
        }
        If ($PSBoundParameters['Username'])
        {
            $applicationPool.processModel.username = "$Username"
            $applicationPool.processModel.password = "$Password"
            $applicationPool.processModel.identityType = 'SpecificUser'
        }
        $applicationPool | Set-Item

        #Setting recycle time
        If ($PSBoundParameters['RecycleTime'])
        {
            Add-Log 'Setting the recycle time'
            remove-webconfigurationProperty "/system.applicationHost/applicationPools/add[@name='$Name']/recycling/periodicRestart" -Name Schedule.collection
            set-webconfiguration "/system.applicationHost/applicationPools/add[@name='$Name']/recycling/periodicRestart/schedule" -value $RecycleTime
        }
        
        #Setting the time out
        If ($PSBoundParameters['TimeOut'])
        {
            Add-Log 'Setting the time out'
            & "$env:windir\system32\inetsrv\appcmd.exe" set apppool "$Name" /processModel.idleTimeout:"$TimeOut" | Out-Null # Sure there is a better way of doing this, will investigate for V1.1
        }
        
        #Setting max processes
        If ($PSBoundParameters['Processes'])
        {
            Add-Log 'Setting max processes'
            $Temp = $Processes -as [String]
            & "$env:windir\system32\inetsrv\appcmd.exe" set apppool "$Name" /processModel.maxProcesses:"$Temp" | Out-Null  # Sure there is a better way of doing this, will investigate for V1.1
        }
    }
    catch
    {
        Add-Log "ERROR in New-IISAppPool function" 1603 $_
    }
    finally
    {
        Add-Log $Global:Seperator
        Add-Log '* Leaving Function: New-IISAppPool'
        Add-Log $Global:Seperator
        $Global:Logging = $OldLogging
    }
}


function New-IISSite
{

<#
.SYNOPSIS
Creates an IIS website using the passed variables from the caller.
.DESCRIPTION
.EXAMPLE
New-IISSite -ID 1000115 -Name 'Unilink' -Port 80 -AppPool 'ASP.NET v4.0' -HostHeader 'Unilink.wli.dpn.gov.uk'
.EXAMPLE
New-IISSite -ID 1000099 -Name 'Unilink' -PhysicalDir 'PolarisWS' -Port 80 -AppPool 'AP_Unilink' -HostHeader 'Unilink.wli.dpn.gov.uk'
.NOTES
01/05/2020 - First edition - Created by Rich Dakin - PFS
#>

    [CmdletBinding()]

    param(
        #Unique Website ID  - Used for monitoring purposes in Azure - Can be anything from 1 to 999999.
        [parameter(Mandatory=$True, ValueFromPipeline=$False)]
        [int]$ID, 
        
        #Website name
        [parameter(Mandatory=$True, ValueFromPipeline=$False)]
        [string]$Name, 

		#Website Physical Directory
        [parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [string]$PhysicalDir=$Name, 
        
        #Website port
        [parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [int]$Port=80,
        
        #Application pool
        [parameter(Mandatory=$True, ValueFromPipeline=$False)]
        [string]$AppPool,      
        
        #Host header.  Alternatively this can be set using the New-IISWebBinding function.
        [parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [string]$HostHeader,
        
        #Do you want the function to log?
        [Parameter(Mandatory = $False, ValueFromPipeline=$False)]
        [boolean]$Logging = $True
    )

    try
    {
	
        #Trim parameters
        $WSShortName = $PhysicalDir -replace " ", ""

        $OldLogging = $Global:Logging
        $Global:Logging = $Logging
        Add-Log ' '
        Add-Log $Global:Seperator
        Add-Log '* Starting Function: New-IISSite'
        Add-Log "* ID: $ID"
        Add-Log "* Name: $Name"
		Add-Log "* Physical Path: $SCRIPT:DirWebSites\$WSShortName"
        Add-Log "* Port: $Port"
        Add-Log "* AppPool: $AppPool"
        If ($PSBoundParameters['HostHeader']) {Add-Log "* HostHeader: $HostHeader"}
        Add-Log $Global:Seperator

        #Import Web Administration module
        Add-Log 'Import Web Administration module'
        Import-Module -Name 'WebAdministration'
        $Site = $Null
    	$Site = get-website | where-object {$_.Name -eq $Name}
    	If ($Site -ne $Null)
    	{
    		Throw "$Name website already exists"
    	}
        Else
        {
               Add-Log 'Create website'
               New-Website -ID $ID -Name $Name -Port $Port -PhysicalPath "$SCRIPT:DirWebSites\$WSShortName" | Out-Null
               }
    
        #See if we need to create the website directory
        if (-Not (Test-Path -Path "$SCRIPT:DirWebSites\$WSShortName" -PathType 'Container'))
        {
            Add-Log "Creating directory: $SCRIPT:DirWebSites\$WSShortName"
            New-Item -Path "$SCRIPT:DirWebSites\$WSShortName" -Type Directory | Out-Null
        }
    
        #See if we need to create the website http compression directory
        if (-Not (Test-Path -Path "$SCRIPT:DirHTTPComp\$WSShortName" -PathType 'Container'))
        {
            Add-Log "Creating compression directory: $SCRIPT:DirHTTPComp\$WSShortName"
            New-Item -Path "$SCRIPT:DirHTTPComp\$WSShortName" -Type Directory | Out-Null
        }
        
                #Create website

 

        
        #Set website application pool
        Add-Log 'Set website application pool'
        Set-ItemProperty -Path "IIS:\Sites\$Name" -Name ApplicationPool -Value $AppPool
        
        #Set website hostheader bindings
        If ($PSBoundParameters['HostHeader'])
        {
            Add-Log 'Set website hostheader bindings'
            Set-WebBinding -Name $Name -BindingInformation *:""$Port":" -PropertyName HostHeader -value $HostHeader
        }   

    	#Check website has been created
    	$Site = $Null
    	$Site = get-website | where-object {$_.Name -eq $Name}
    	If ($Site -eq $Null)
    	{
    		Throw "$Name website does not exist"
    	}   
    }
    catch
    {
        Add-Log "ERROR in New-IISSite function" 1603 $_
    }
    finally
    {
        Add-Log $Global:Seperator
        Add-Log '* Leaving Function: New-IISSite'
        Add-Log $Global:Seperator
        $Global:Logging = $OldLogging
    }
}
#**************************************************************************************************
#**************************************************************************************************




function New-IISApplication
{

<#
.SYNOPSIS
Creates an application under a website.
.DESCRIPTION
.EXAMPLE
New-IISApplication -Name 'Unilink' -Website 'GMTPlanet' -Path 'E:\IISWebsites\Unilink\Unilink' -AppPool 'Unilink'
Creates Unilink application under $
#>

    [CmdletBinding()]

    param(
        #Application name
        [parameter(Mandatory=$True, ValueFromPipeline=$False)]
        [string]$Name, 
        
        #Website name
        [parameter(Mandatory=$True, ValueFromPipeline=$False)]
        [string]$Website, 
        
        #Local directory for application
        [parameter(Mandatory=$True, ValueFromPipeline=$False)]
        [string]$Path, 
        
        #Application pool
        [parameter(Mandatory=$True, ValueFromPipeline=$False)]
        [string]$AppPool,
        
        #Do you want the function to log?
        [Parameter(Mandatory = $False, ValueFromPipeline=$False)]
        [boolean]$Logging = $True
    )

    try
    {
        $OldLogging = $Global:Logging
        $Global:Logging = $Logging
        Add-Log ' '
        Add-Log $Global:Seperator
        Add-Log '* Starting Function: New-Application'
        Add-Log "* Name: $Name"
        Add-Log "* Website: $Website"
        Add-Log "* Path: $Path"
        Add-Log "* AppPool: $AppPool"
        Add-Log $Global:Seperator
    
        #Import Web Administration module
        Add-Log 'Import Web Administration module'
        Import-Module -Name 'WebAdministration'

        #Trim parameters
        $Name = $Name -replace " ", ""
        $WebSite = $WebSite -replace " ", ""
        $AppPool = $AppPool -replace " ", ""
        
        #Validate $Name
        $App = Get-WebApplication -Site $Website -Name $Name 
        If (-Not ($App -eq $null))
        {
            Throw "Application $Name already exists"
        }
        
        #Create directory
        Add-Log "Creating $Path"
        If (-not (Test-Path -path $Path -pathtype 'Container'))
        {
    	   New-Item -Path $Path -type Directory | Out-Null
        }
        Else
        {
        	Add-Log "$Path already exists"
        }
        
        #Create application
    	New-WebApplication -Name "$Name" -Site "$WebSite" -PhysicalPath "$Path" -ApplicationPool "$AppPool" | Out-Null

    }
    catch
    {
        Add-Log "ERROR in New-IISApplication function" 1603 $_
    }
    finally
    {
        Add-Log $Global:Seperator
        Add-Log '* Leaving Function: New-IISApplication'
        Add-Log $Global:Seperator
        $Global:Logging = $OldLogging
    }
}
#**************************************************************************************************
#**************************************************************************************************



####Pass section #### 



