<#
    .NAME
        Get-Serial.ps1

    .SYNAPSIS
        Provides the units serial number.

    .DESCRIPTION
        Provides the units serial number.

        How to use:
            Run script with admin rights.

        Requirements
            Admin
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 191230
        Modified Date: 200213

    .CHANGELOG
        v 1.0:      191230 - Started Changelog
        v 1.0.1:    200213 - Corrected oversight in display of the serialnumber parameter
#>

<#
$Computer = Read-Host 'Enter remote computer name'
Get-WmiObject win32_bios -computername $Computer | format-list Manufacturer, SerialNumber
Get-WmiObject -class:Win32_ComputerSystem.Mode1

$computerSystem = (Get-WmiObject -Class:Win32_ComputerSystem)
Write-Host $computerSystem.Manufacturer
Write-Host $computerSystem.Model
Get-WmiObject Win32_BIOS 
#>

$computers = Read-Host 'Enter remote computer name'

Get-WmiObject Win32_ComputerSystem -ComputerName $computers | select name,serialnumber,model
Get-WmiObject Win32_BIOS -ComputerName $computers | select serialnumber