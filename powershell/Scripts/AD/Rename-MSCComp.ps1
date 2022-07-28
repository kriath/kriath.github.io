<#
    .NAME
        Rename-MSCComp.ps1

    .SYNAPSIS
        Function for remotely changing the name of a MSC computer object.

    .DESCRIPTION
        Function for remotely changing the name of a MSC computer object.

        How to use:
            Run script, then follow prompts. User will need to reboot device.

        Requirements
            * Admin access to ADUC.
            * Remote device active on MSC.LOCAL
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 200109
        Modified Date: 200109

    .CHANGELOG
        v 1.0:      200109 - Started Changelog
#>

Import-Module ActiveDirectory
Clear-Host
$remotename = Read-Host 'Please enter remote PC name'
$newname = Read-Host 'Please enter new PC name for remote device'
$cred = Read-Host 'Please enter your admin account name'
Rename-Computer -ComputerName "$remotename" -NewName "$newname" -DomainCredential "msc.local\$cred" -Force
Write-Host "PC name $remotename has been renamed to $newname by $cred. Remote user needs to reboot device for change to take effect." -ForegroundColor Green
Pause
Exit-PSSession