<#
    .NAME
        ADAdminMenu.ps1

    .SYNAPSIS
        User management script for Active Directory.

    .DESCRIPTION
        User management script for Active Directory.

        How to use:
            Run script via jumphost or admin account, then use ASCII menu interface.

        Requirements
            * ADFunctions.ps1 to be in same directory as script.
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0.2
        Creation Date: 191223
        Modified Date: 200615

    .CHANGELOG
        v 1.0:      191223 - Started Changelog
        v 1.0.1:    191224 - Added Move-ADuser and User-Exit
        v 1.0.2:    191227 - Corrected header comment to current standard
        v 1.0.4:    200211 - Added Get-RandomPassword as a function
        v 1.0.5:    200615 - Added Get-PasswordInfo as a function
#>

If (!(Test-path $PSScriptRoot\ADFunctions.ps1)) { Write-Host "ADFunctions.ps1 is required in the same directory!" -ForegroundColor Red; Pause; Break }
. $PSScriptRoot\ADFunctions.ps1 #dot sourcing - functions 
set-executionpolicy -scope currentuser unrestricted -force

import-module activedirectory
Write-Host 'Confirming PowerShell AD commands have been installed...' -ForegroundColor Green
Get-Module ActiveDirectory
Start-Sleep -Seconds 2
Clear-Host

$MenuItems = [ordered]@{
    "1" = @{
        Description = 'Check User Status'
        Function = 'User-Status'
    }
    "2" = @{
        Description = 'Enable User Account'
        Function = 'User-Enable'
    }
    "3" = @{
        Description = 'Unlock User Account'
        Function = 'User-Unlock'
    }
    "4" = @{
        Description = 'Reset User Password'
        Function = 'Password-Reset'
    }
    "5" = @{
        Description = 'Set User expiry date'
        Function = 'User-Expiry'
    }
    "6" = @{
        Description = 'Clear User expiry date'
        Function = 'User-Expiry-Clear'
    }
    "7" = @{
        Description = 'Disable User Account'
        Function = 'User-Disable'
    }
    "8" = @{
        Description = 'AD User Exit'
        Function = 'User-Exit'
    }
    "9" = @{
        Description = 'Move AD User to New OU'
        Function = 'Move-ADuser'
    }
    "A" = @{
        Description = 'Check User AD Groups'
        Function = 'Get-UserGroups'
    }
    "B" = @{
        Description = 'Check Password Expiry'
        Function = 'Get-PasswordInfo'
    }
    "C" = @{
        Description = "Clear Screen"
        Function = 'Clear-Host'
    }
    "H" = @{
        Description = "Get Help"
        Function = 'Get-Help'
    }
    "P" = @{
        Description = 'Generate Random Password'
        Function = 'Get-RandomPassword'
    }
    "Q" = @{
        Description = "Quit"
        Function = 'break'
    }
}

Function Init-Menu { #just to make it easier...
    Read-Menu $MenuItems -width 50 -Heading "MSC Active Directory Admin Menu" -Loop -ExtraCommand 'Write-Host "Using: $($cred.username)" -ForeGroundColor Yellow'
}

Init-Menu #Start the Menu