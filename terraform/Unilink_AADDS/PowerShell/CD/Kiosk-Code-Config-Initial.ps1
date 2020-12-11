###Deployment script

param
(
    [Parameter(Mandatory)] [String]$codebase,
    [String]$IntLogSoapInput="false",
    [String]$IntCacheData="false",
    [Parameter(Mandatory)] [String]$IntUrl,
    [Parameter(Mandatory)] [String]$IntUserEnc,
    [Parameter(Mandatory)] [String]$IntUserPwdEnc,
    [String]$IntUserDomainEnc="",
    [Parameter(Mandatory)] [String]$CMSSQLInstance,
    [Parameter(Mandatory)] [String]$CMSSQLServerEnc,
    [Parameter(Mandatory)] [String]$CMSSQLDatabaseEnc,
    [Parameter(Mandatory)] [String]$CMSSQLUserEnc,
    [Parameter(Mandatory)] [String]$CMSSQLPasswordEnc,
    [String]$CMSSQLWinAuth="N",
    [String]$CMSSQLSSL="N",
    [Parameter(Mandatory)] [String]$CMSSITE,
    [Parameter(Mandatory)] [String]$Prison

)


$url = $codebase # download
$resourceFolder = "C:\Temp\"
$downloadFile = $resourceFolder + "CMSKioskWebServiceR24.zip" # file
$WebApplicationFolder = "E:\IISWebsites\$Prison\$WebApplicationName\"
$WebServiceConfigFile = $WebApplicationFolder + "\Web.SelfService.config"
$CMSConnectionConfigFile = $WebApplicationFolder + "\bin\kioskconnect.xml"

# Download and Extract the Web Service ZIP
if (-Not (Test-Path $WebApplicationFolder)) {
    MkDir $WebApplicationFolder
    if (-Not (Test-Path $resourceFolder)) {
        MkDir $resourceFolder
    }
    if (-Not (Test-Path $downloadFile)) {
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($url, $downloadFile)
    }
    ##Updated to use the latest PS
    Expand-Archive -LiteralPath $downloadFile -DestinationPath $WebApplicationFolder
}


# Populate Web Service config
# Get the file content
$TextFileContent = Get-Content $WebServiceConfigFile

# Replace the Interface tokens with Parameters
$TextFileContent = $TextFileContent.replace('###IntLogSoapInput###', $IntLogSoapInput)
$TextFileContent = $TextFileContent.replace('###IntCacheData###', $IntCacheData)
$TextFileContent = $TextFileContent.replace('###IntUrl###', $IntUrl)
$TextFileContent = $TextFileContent.replace('###IntUser###', $IntUserEnc)
$TextFileContent = $TextFileContent.replace('###IntUserPwd###', $IntUserPwdEnc)
$TextFileContent = $TextFileContent.replace('###IntUserDomain###', $IntUserDomainEnc)

# Write the updated content
$TextFileContent | Out-File $WebServiceConfigFile -Encoding "ascii"

# Popluate CMS Connection config
# Get the file content
$TextFileContent = Get-Content $CMSConnectionConfigFile

# Replace the Connection tokens with Parameters
$TextFileContent = $TextFileContent.replace('###CMSSQLInstance###', $CMSSQLInstance)
$TextFileContent = $TextFileContent.replace('###CMSSQLServer###', $CMSSQLServerEnc)
$TextFileContent = $TextFileContent.replace('###CMSSQLDatabase###', $CMSSQLDatabaseEnc)
$TextFileContent = $TextFileContent.replace('###CMSSQLUser###', $CMSSQLUserEnc)
$TextFileContent = $TextFileContent.replace('###CMSSQLPassword###', $CMSSQLPasswordEnc)
$TextFileContent = $TextFileContent.replace('###CMSSQLWinAuth###', $CMSSQLWinAuth)
$TextFileContent = $TextFileContent.replace('###CMSSQLSSL###', $CMSSQLSSL)

# Write the updated content
$TextFileContent | Out-File $CMSConnectionConfigFile -Encoding "ascii"
