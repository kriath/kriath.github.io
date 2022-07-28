<#
    .NAME
        SFBAdminMenu.ps1

    .SYNAPSIS
        User management script for Skype For Business.

    .DESCRIPTION
        User management script for Skype For Business.

        How to use:
            Run script via jumphost or admin account, then use ASCII menu interface.

        Requirements
            * SFBFunctions.ps1 to be in same directory as script.
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.1
        Creation Date: 191223
        Modified Date: 220616

    .CHANGELOG
        v 1.0:      191223 - Started Changelog
        v 1.0.1:    191224 - Added Change User SFB Policy function
        v 1.0.2:    191227 - Corrected header comment to current standard
        v 1.0.3:    200103 - Added Enable-EnterpriseVoice and Get-Help
        v 1.1:      220616 - Cleaned up admin menu
#>

If (!(Test-path $PSScriptRoot\SFBFunctions.ps1)) { Write-Host "SFBFunctions.ps1 is required in the same directory!" -ForegroundColor Red; Pause; Break }
. $PSScriptRoot\SFBFunctions.ps1 #dot sourcing - functions 
set-executionpolicy -scope currentuser unrestricted -force
Import-Module SkypeForBusiness

Write-Host 'Please enter your admin account alias. Full email address is not required.' -ForegroundColor Green
$username = Read-Host 'Admin account required'
$cred = Get-Credential -Credential $username@mitchellshire.vic.gov.au

Start-Sleep -Seconds 5
Clear-Host

$MenuItems = [ordered]@{
    "1" = @{
        Description = 'Check User Status'
        Function = 'Check-Status'
    }
    "2" = @{
        Description = 'Create New SFB User'
        Function = 'Fix-User'
    }
        "3" = @{
        Description = 'Migrate User from SFB Online To On-Premises'
        Function = 'Migrate-User'
    }
    "4" = @{
        Description = 'Disable SFB User'
        Function = 'Disable-User'
    }
    "5" = @{
        Description = 'Change User SFB Policy'
        Function = 'Change-User-Policy'
    }
    "6" = @{
        Description = 'Enable Enterprise Voice w/o extension'
        Function = 'Enable-EnterpriseVoice'
    }
    "C" = @{
        Description = "Clear Screen"
        Function = 'Clear-Host'
    }
    "H" = @{
        Description = "Help"
        Function = 'Get-Help'
    }
    "Q" = @{
        Description = "Quit"
        Function = 'break'
    }
}

Function Init-Menu { #just to make it easier...
    Read-Menu $MenuItems -width 50 -Heading "MSC Skype For Business Admin Menu" -Loop -ExtraCommand 'Write-Host "Using: $($cred.username)" -ForeGroundColor Yellow'
}

Init-Menu #Start the Menu