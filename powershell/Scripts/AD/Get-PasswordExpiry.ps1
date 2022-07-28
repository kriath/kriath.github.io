Import-Module ActiveDirectory
$filepath = "C:\Scripts\Output\passwordexpiry0.txt"
Start-Transcript -Path $filepath -NoClobber
$MaxPwdAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days
$expiredDate = (Get-Date).addDays(-$MaxPwdAge)
#Set the number of days until you would like to begin notifing the users. -- Do Not Modify --
#Filters for all users who's password is within $date of expiration.
$ExpiredUsers = Get-ADUser -Filter {(PasswordLastSet -gt $expiredDate) -and (PasswordNeverExpires -eq $false) -and (Enabled -eq $true)} -Properties PasswordNeverExpires, PasswordLastSet, Mail | select samaccountname, PasswordLastSet, @{name = "DaysUntilExpired"; Expression = {$_.PasswordLastSet - $ExpiredDate | select -ExpandProperty Days}} | Sort-Object PasswordLastSet
Write-Host = $ExpiredUsers
Write-Host = "Results of this session have been exported to $filepath."
Stop-Transcript
Read-Host = "Please press enter to close this window"