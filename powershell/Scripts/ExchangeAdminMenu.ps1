<#
    .NAME
        ExchangeAdminMenu.ps1

    .SYNAPSIS
        User management script for Exchange / Exchange Online.

    .DESCRIPTION
        User management script for Exchange / Exchange Online.

        How to use:
            Open Exchange Online Powershell module, then run script.

        Requirements
            * EXFunctions.ps1 to be in same directory as script.
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.1
        Creation Date: 191223
        Modified Date: 220616

    .CHANGELOG
        v 1.0:      191223 - Started Changelog
        v 1.0.1:    191227 - Corrected header comment to current standard
        v 1.0.2:    200109 - Added Clear-Host function and disabled CreateNewMailbox. Also added Clear-Host to run prior to menu being initiated so menu starts with clean slate.
        v 1.1:      220616 - Tidied up, added Set-SharedMailboxCopy function.
#>

If (!(Test-path $PSScriptRoot\EXFunctions.ps1)) { Write-Host "EXFunctions.ps1 is required in the same directory!" -ForegroundColor Red; Pause; Break }
. $PSScriptRoot\EXFunctions.ps1 #dot sourcing - functions 

$cred = Read-Host -Prompt 'Admin account required'

Connect-EXOPSSession -UserPrincipalName $cred@mitchellshire.vic.gov.au

Clear-Host

$MenuItems = [ordered]@{
    "1" = @{
        Description = 'Enable Public Calendar for User'
        Function = 'EnablePublicCalendar'
    }
    "2" = @{
        Description = 'Remove Automapping'
        Function = 'AutomapRemove'
    }
    "3" = @{
        Description = 'Set shared mailbox to save copy'
        Function = 'Set-SharedMailboxCopy'
    }
    "4" = @{
        Description = 'Mailboxes Unused for >30 Days (Slow)'
        Function = 'MoreThan30Days'
    }
    "5" = @{
        Description = 'Retrieve All Mailboxes For 1x User (Slow)'
        Function = 'Get-Mailbox-Perms'
    }
    "C" = @{
        Description = "Clear Screen"
        Function = 'Clear-Host'
    }
    "Q" = @{
        Description = "Quit"
        Function = 'break'
    }
}

Function Init-Menu { #just to make it easier...
    Read-Menu $MenuItems -width 50 -Heading "MSC Exchange Online Admin Menu" -Loop -ExtraCommand 'Write-Host "Using: $($cred.username)" -ForeGroundColor Yellow'
}

Init-Menu #Start the Menu