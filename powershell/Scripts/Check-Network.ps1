<#
    .NAME
        Check-Network.ps1

    .SYNAPSIS
        Function for checking network connectivity.

    .DESCRIPTION
        Function for checking network connectivity.

        How to use:
            Run script.

        Requirements
            *
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 201231
        Modified Date: 201231

    .CHANGELOG
        v 1.0:      201231 - Started Changelog
#>

$ComputerName = Read-Host 'Enter computer name'

Resolve-DnsName -Name $ComputerName
Test-Connection $ComputerName
Test-NetConnection $ComputerName
tracert $ComputerName
Read-Host 'Please press enter to complete this script'