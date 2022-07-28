<#
    .NAME
        Set-M365UserName.ps1

    .SYNAPSIS
        Change a M365 user account principal name.

    .DESCRIPTION
        Change a M365 user account principal name.

        How to use:
            Run script with admin credentials.

        Requirements
            * Admin rights
        
    .NOTES
        Creator:       Peter Arabatzis
        Maintainer:    Chris Clarke
        Version:       1.0
        Creation Date: 200721
        Modified Date: 200721

    .CHANGELOG
        v 1.0:      200721 - Started Changelog
#>

Connect-MsolService

$UserOld = Read-Host 'Enter M365 user name to be changed'
$UserNew = Read-Host 'Enter new M365 user name'

Set-MsolUserPrincipalName -UserPrincipalName "$UserOld@mitchellshire.vic.gov.au" -NewUserPrincipalName "$UserNew@mitchellshire.vic.gov.au" -Confirm -Whatif