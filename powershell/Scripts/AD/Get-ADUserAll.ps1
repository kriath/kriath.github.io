Import-Module ActiveDirectory
Get-ADUser -Filter * -SearchBase "OU=Users,DC=msc,DC=local"|Select DisplayName,Emailaddress,Officephone|export-csv -path C:\Scripts\Output\ADUsersRecord.csv