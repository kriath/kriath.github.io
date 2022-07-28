<#
    .NAME
        Get-ADUser-Groups.ps1

    .SYNAPSIS
        Function for checking users password information.

    .DESCRIPTION
        Function for checking users password information. Does NOT give you their password.

        How to use:
            Run script, then enter Get-Password-Info in PS Session

        Requirements
            *
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 200103
        Modified Date: 200103

    .CHANGELOG
        v 1.0:      200103 - Started Changelog
#>

Function Get-Password-Info {

[CmdletBinding()]
param (
[Parameter (Mandatory=$true)]
[string]$UserName
)

$query = Get-ADUser $UserName -Properties PasswordExpired, PasswordNeverExpires

   if ($query.PasswordExpired -eq $false) {
    Write-Host -ForegroundColor Green "Account's Password is still valid"
        if ($query.PasswordNeverExpires -eq $false) {
            Write-Host -ForegroundColor Green "Password is set to Expire"
        }
        else {
            Write-Host -ForegroundColor Yellow  -BackgroundColor Black "Password is set to NEVER Expire"
        }
   }
else {
    Write-Host -ForegroundColor Red -BackgroundColor Black "Password has expired. Time for a change"
}
}