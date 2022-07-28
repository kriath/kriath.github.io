<#
    .NAME
        Get-ADUserAllAudit.ps1

    .SYNAPSIS
        Extracts data about all users in Active Directory.

    .DESCRIPTION
        Extracts data about all users in Active Directory. You can add additional properties after "Select-Object" in order to extract more data. Potential future options could be 'email', 'manager', 'telephone', etc.

        How to use:
            Run script with elevated permissions. Comment out the Export-CSV command if you want results to display in terminal.

        Requirements
            Active Directory module in Powershell (attempts import as first action).
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 220411
        Modified Date: 220411

    .CHANGELOG
        v 1.0:      220411 - Started Changelog

#>

Import-Module ActiveDirectory
Get-ADUser -Filter * -SearchBase "OU=Directorates,OU=Users,OU=Mitchell Shire Council,DC=msc,DC=local" -Properties * | Select-Object SamAccountName, name, Department, Enabled, PasswordNeverExpires, PasswordLastSet, AccountExpirationDate, LastLogonDate, MemberOf | export-csv -path C:\Scripts\Output\userexport.csv