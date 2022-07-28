<#
    .NAME
        Get-ADUser-Groups.ps1

    .SYNAPSIS
        Function return a list of all users with the -LockedOut parameter as $true.

    .DESCRIPTION
        Function return a list of all users with the -LockedOut parameter as $true.

        How to use:
            Run script.

        Requirements
            * PS Admin
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 200213
        Modified Date: 200213

    .CHANGELOG
        v 1.0:      200213 - Started Changelog
#>

Search-ADAccount -LockedOut | Select Name, Enabled, LastLogonDate, ObjectClass
Write-Host 'Searching for accounts with the "LockedOut" parameter as $true...' -ForegroundColor Green
Write-Host '' -ForegroundColor Green