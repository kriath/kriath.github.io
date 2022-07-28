Import-Module ActiveDirectory
$name = Read-Host -Prompt 'Please enter username'
get-aduser $name -properties * | Select Name, PasswordLastSet, PasswordExpired, LockedOut, AccountExpires | Format-list

#Warning for the click happy people
Write-Warning "This next step will reset the date of PwdLastSet. Do you want to continue?"-WarningAction Inquire
Set-ADUser -Identity $name -Replace @{pwdlastset="0"}
Set-ADUser -Identity $name -Replace @{pwdlastset="-1"}
$date = get-aduser $name -Properties PasswordLastSet
#Write-Host = "The account for $name has had the PasswordLastSet changed to current time."
get-aduser $name -properties * | Select Name, PasswordLastSet, PasswordExpired, LockedOut, AccountExpires | Format-list