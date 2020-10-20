

Connect-AzureAD -TenantDomain "PrisonerIdentityServices.onmicrosoft.com"


$users = import-csv -path users.csv

foreach ($user in $users) {
    $invite = New-AzureADMSInvitation -InvitedUserDisplayName $user.name -InvitedUserEmailAddress $user.email -InviteRedirectURL https://myapps.microsoft.com -SendInvitationMessage $true

    #call
    $invite 

    Write-Output $invite.InvitedUserDisplayName
    Write-Output $invite.InvitedUserDisplayName
    write-Output $invite.InviteRedeemUrl

    <#
Could add a send email function here as the secondary address isn't set - Thinking something like an additional column
in the spreadsheet that was referenced by $var.secondary

Send-MailMessage -From $somesender -To $user.secondaryemail -Subject 'Sending your invite for Azure' -Body $invite.InviteRedeemUrl -Priority High -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer $somesmtp

#jobforlater

#>

}

#Example of tagging users using POSH. Planning to use later for Prisoner ID creation but this will suffice for DSO guinea pigs
##This should also really be in the above, another #jobforlater 

$ids = get-azureaduser | where usertype -eq "Guest" | where  displayname -like "*Studio*"
$ids = $ids.objectid

foreach ($id in $ids) {

    Set-AzureADUser -ObjectId $id -Department "DSO"
    Write-Output "Added Tag to user succesfully" -foregroundcolor green 
}

