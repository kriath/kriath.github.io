<#
    .NAME
        JobUpdater.ps1

    .SYNAPSIS
        User management script for Active Directory.

    .DESCRIPTION
        User management script for Active Directory.

        How to use:
            Run script via jumphost or admin account, then use ASCII menu interface.

        Requirements
            * JobUpdaterFunctions.ps1 to be in same directory as script.
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 200613
        Modified Date: 200615

    .CHANGELOG
        v 1.0:      200613 - Started Changelog
        v 1.0.1:    200615 - Added new functions to menu (Update/Change Request/Ticket Resolution)
#>

If (!(Test-path $PSScriptRoot\JobUpdaterFunctions.ps1)) { Write-Host "JobUpdaterFunctions.ps1 is required in the same directory!" -ForegroundColor Red; Pause; Break }
. $PSScriptRoot\JobUpdaterFunctions.ps1 #dot sourcing - functions 
set-executionpolicy -scope currentuser unrestricted -force

cls

$MenuItems = [ordered]@{
    "1" = @{
        Description = 'Update'
        Function = 'Job-Update'
    }
    "2" = @{
        Description = 'Service Request'
        Function = 'Service-Request'
    }
    "3" = @{
        Description = 'Change Request'
        Function = 'Change-Request'
    }
    "4" = @{
        Description = 'Attempted Contact'
        Function = 'Contact-Attempt'
    }
    "5" = @{
        Description = 'Ticket Resolution'
        Function = 'Job-Resolved'
    }
    "C" = @{
        Description = "Clear Screen"
        Function = 'Clear-Host'
    }
    "H" = @{
        Description = "Get Help"
        Function = 'Get-Help'
    }
    "Q" = @{
        Description = "Quit"
        Function = 'break'
    }
}

Function Init-Menu { #just to make it easier...
    Read-Menu $MenuItems -width 50 -Heading "MSC Job Updater Menu" -Loop -ExtraCommand 'Write-Host "Using: $($cred.username)" -ForeGroundColor Yellow'
}

Init-Menu #Start the Menu