$OU=”OU=Service,OU=HPE,OU=Accounts,OU=RBAC,OU=WLI,OU=Prisons,DC=WLI,DC=DPN,DC=GOV,DC=UK”
$Group=”rSvc-FGPP-ServiceAccounts”

Get-ADGroupMember –Identity $Group | Where-Object {$_.distinguishedName –NotMatch $OU} | ForEach-Object {Remove-ADPrincipalGroupMembership –Identity $_ –MemberOf $Group –Confirm:$false}
Get-ADUser –SearchBase $OU –SearchScope OneLevel –LDAPFilter “(!memberOf=$Group)” | ForEach-Object {Add-ADPrincipalGroupMembership –Identity $_ –MemberOf $Group}