﻿Import-Module ActiveDirectory
Get-ADUser -Filter * -SearchBase "OU=Directorates,OU=Users,OU=Mitchell Shire Council,DC=msc,DC=local" -Properties * | Select-Object SamAccountName, name, Department, Enabled, PasswordNeverExpires, PasswordLastSet, AccountExpirationDate, LastLogonDate, MemberOf | export-csv -path C:\Scripts\Output\userexport.csv