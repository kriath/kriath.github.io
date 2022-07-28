<#
    .NAME
        Get-ADUser-Disabled-SIP-Enabled.ps1

    .SYNAPSIS
        Output a list of every user account this is disabled in AD but has an active SIP address.

    .DESCRIPTION
        Output a list of every user account this is disabled in AD but has an active SIP address.

        How to use:
            Run script with admin credentials.

        Requirements
            * Admin rights
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 191227
        Modified Date: 191227

    .CHANGELOG
        v 1.0:      191227 - Started Changelog
#>

Get-CsAdUser -ResultSize Unlimited | Where-Object {$_.UserAccountControl -match "AccountDisabled" -and $_.Enabled -eq $true} | Format-Table Name,Enabled,SipAddress -auto