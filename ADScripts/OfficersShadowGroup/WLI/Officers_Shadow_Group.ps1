$OU=”OU=Officers,OU=WLI,OU=Accounts,OU=WLI,OU=Prisons,DC=WLI,DC=DPN,DC=GOV,DC=UK”
$Group=”All Officers”

Get-ADGroupMember –Identity $Group | Where-Object {$_.distinguishedName –NotMatch $OU} | ForEach-Object {Remove-ADPrincipalGroupMembership –Identity $_ –MemberOf $Group –Confirm:$false}
Get-ADUser –SearchBase $OU –SearchScope OneLevel –LDAPFilter “(!memberOf=$Group)” | ForEach-Object {Add-ADPrincipalGroupMembership –Identity $_ –MemberOf $Group}