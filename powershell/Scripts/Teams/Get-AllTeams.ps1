<#
    .NAME
        Get-AllTeams.ps1

    .SYNAPSIS
        Exports a list of every team a user is a member of to CSV.

    .DESCRIPTION
        Exports a list of every team a user is a member of to CSV.

        How to use:
            Run script.

        Requirements
            * Powershell v7.1.1
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 210119
        Modified Date: 210119

    .CHANGELOG
        v 1.0:      191223 - Started Changelog
#>

#Requires -Version 7.1.1

Connect-MicrosoftTeams

$User = Read-Host 'Please enter user name'
Get-Team -User $User@mitchellshire.vic.gov.au | Select-Object DisplayName, MailNickName, Description, Archived | Export-CSV C:\Users\$env:UserName\Desktop\$User.csv
Write-Host "Please check C:\Users\$env:UserName\Desktop\ for your $User.csv!"