$Mailbox = Read-Host "Enter User to check"
$DN = (Get-Mailbox -Identity $Mailbox).DistinguishedName
$Groups = (Get-Recipient -RecipientTypeDetails GroupMailbox -Filter "Members -eq '$DN'" | Select DisplayName, Alias)
Write-Host $Mailbox "is a member of" $Groups.count "Groups"
$Groups | Select DisplayName, Alias