<#
    .NAME
        Get-BootTime.ps1

    .SYNAPSIS
        Return total uptime of a remote computer.

    .DESCRIPTION
        Return total uptime of a remote computer.

        How to use:
            Run script with admin credentials.

        Requirements
            * Admin rights
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 200710
        Modified Date: 200710

    .CHANGELOG
        v 1.0:      200710 - Started Changelog
#>

$Computer = Read-Host 'Enter remote computer name'
SystemInfo /s $Computer | find "Boot Time:"
Pause