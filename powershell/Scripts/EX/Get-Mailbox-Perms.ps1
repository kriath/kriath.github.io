<#
    .NAME
        Get-Mailbox-Perms.ps1

    .SYNAPSIS
        Output a list of every mailbox a user has access to.

    .DESCRIPTION
        Output a list of every mailbox a user has access to.

        How to use:
            Run script via Exchange Online Module

        Requirements
            * Exchange Online
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 191227
        Modified Date: 191227

    .CHANGELOG
        v 1.0:      191227 - Started Changelog
#>

$User = Read-Host 'Enter user name'
Get-Mailbox -RecipientTypeDetails UserMailbox,SharedMailbox -ResultSize Unlimited | Get-MailboxPermission -User $User