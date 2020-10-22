#Requires -Module SqlServer
Invoke-Sqlcmd -Query "SELECT surname, forenames, prisonnumber, arriveddate FROM KioskInmateView WHERE arriveddate BETWEEN DATEADD(DD,-7,GETDATE()) AND GETDATE () ORDER BY arriveddate asc;" `
    -Database CookhamWood `
    -Server DB-PROD-1 |
Export-Csv -NoTypeInformation `
    -Path "C:\CookhamWoodNewPrisoners.csv" `
    -Encoding UTF8
#Our source File:
$file = "C:\CookhamWoodNewPrisoners.csv"
#Get the File-Name without path
$name = (Get-Item $file).Name
#The target URL wit SAS Token
$uri = *** In vault ****
#Define required Headers
$headers = @{
    'x-ms-blob-type' = 'BlockBlob'
}
#Upload File...
Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -InFile $file