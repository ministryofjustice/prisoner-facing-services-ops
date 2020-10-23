Get-ADUser -SearchBase 'OU=Prisoners,OU=WLI,OU=Accounts,OU=WLI,OU=Prisons,DC=WLI,DC=DPN,DC=GOV,DC=UK' -Filter * | ForEach-Object {
Set-ADUser -LogonWorkstations $null $_}