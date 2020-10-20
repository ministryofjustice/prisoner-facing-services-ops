
# PFS On-Site Automation Guidelines

## Prerequisites

Powershell V5 + and a client to run it.

### Standards

All PowerShell comitted to this repo must meet the following requirements:

1) All scripts need the header as documented [here](./PowerShell_Templates/Header.ps1). This must be present before commit and updated on each commit.


 2) It must be a single script for all Prisons. Variables are defined and discovered within the script. If this is not possible, it must be documented why and be agreed with the team. A example of this



```powershell
Get-ADComputer -SearchBase 'OU=Laptops,OU=Prisoners,OU=Workstations,OU=WLI,OU=Prisons,DC=WLI,DC=DPN,DC=GOV,DC=UK' -Property Name,lastLogonDate -Filter {lastLogonDate -lt $date} | Set-ADComputer -Enabled $false
```

Should be changed to 
```powershell

#What domain?

If (($env:USERDOMAIN) -eq "WLI")
{
    $Global:Domain = "WLI"
}
elseif (($env:USERDOMAIN) -eq "BWI")
{
    $Global:Domain = "BWI"
}

Get-ADComputer -SearchBase "OU=Laptops,OU=Prisoners,OU=Workstations,OU=$domain,OU=Prisons,DC=$domain,DC=DPN,DC=GOV,DC=UK" -Property Name,lastLogonDate -Filter {lastLogonDate -lt $date} | Set-ADComputer -Enabled $false
```

`NOTE` This becomes less and less of an issue as we move towards Azure Active Directory

3) Audit Audit Audit! - We have a requirement to audit as much as possible in a script. The following should be used to keep things consistent. 


```powershell
# PowerShell function - Add-Log
# Author: Rich Dakin
Function Add-Log
        {Param ([string]$logstring)
        $logfile = "D:\AD-Automation\Logfile.txt"
        $date = Get-date
        $Global:date = $date.ToString("dd-MM-yyyy-HH-mm")
        add-content $logfile -value "$date :: $logstring"
        }
```

Further examples of this is taking a one liner script that cannot be fully audited and breaking it out into more cleaner foreach

```powershell
Get-ADComputer -SearchBase "OU=Laptops,OU=Prisoners,OU=Workstations,OU=$domain,OU=Prisons,DC=$domain,DC=DPN,DC=GOV,DC=UK" -Property Name,lastLogonDate -Filter {lastLogonDate -lt $date} | Set-ADComputer -Enabled $false
```
Becomes

```powershell

$GetComputer  = Get-ADComputer -SearchBase "OU=Laptops,OU=Prisoners,OU=Workstations,OU=$domain,OU=Prisons,DC=$domain,DC=DPN,DC=GOV,DC=UK" -Property Name,lastLogonDate -Filter {lastLogonDate -lt $date}

Foreach ($Computer in $GetComputer)
{
    ###Audit
    Add-log "$Computer is being disabled"
    Set-ADComputer -Identity $Computer -Enabled $False
}

```

When using Azure Functions with PowerShell. 

| Functions logging level	        | Are                         | Note  |
| -------------                     |:-------------:              | -----:                                    |
| Error                             | Write-Error                 |                                           |
| Warning                           | Write-Warning               |                                           |
| Information                       | Write-Information 	      |   Writes to Information level logging.    |
| Information                       | Write-Host         	      |   Writes to Information level logging.    |
| Information                       | Write-Output 	              |                                           |
| Debug                             | Write-Debug 	              |   Writes to Information level logging.    |
| Trace                             | Write-Progress 	          |   Writes to Information level logging.    |
| Information                       | Write-Verbose      	      |   Writes to Information level logging.    |

In addition to these cmdlets, anything written to the pipeline is redirected to the Information log level and displayed with the default PowerShell formatting.

Configure the function app log level

Functions let you define the threshold level to make it easy to control the way Functions writes to the logs. To set the threshold for all traces written to the console, use the `logging.logLevel.default` property in the `host.json file`. This setting applies to all functions in your function app.

The following example sets the threshold to enable verbose logging for all functions, but sets the threshold to enable debug logging for a function named PFSFunction:


```vb
{
    "logging": {
        "logLevel": {
            "Function.MyFunction": "Debug",
            "default": "Trace"
        }
    }
}
```

This can be referenced at it's entirety at *[Microsoft Docs](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-powershell#logging)* 


Triggering the Metadata 
```powershell
Write-Verbose ($TriggerMetadata | Convertto-Json) -Verbose
```


4) Your script must be able to run everytime. Without throwing errors. Example


```powershell

New-Item -Path "c:\" -Name "logfiles" -ItemType "directory"

#The second time this script runs it will fail on the directory existing. Thus you must complete a test path and use a IF Statement.

If ((Test-path "c:\Logfiles") -ne $True)

{
    New-Item -path c:\Logfiles -ItemType Directory
}

###Now the script will not fail on the subsequent  runs.

```


5) All functions should be documented inline, as shown in point 3.

6) Code should be self documenting, with comments in the appropriate. 

7) Modules within functions over plain functions

    Where possible we should be using modules (psm) where possible and reference as required. Example;
    
    ```powershell
    #Import the external IIS module.
    import-module ".\IISStructure.psm1"
    ```