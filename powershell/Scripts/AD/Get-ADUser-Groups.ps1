<#
    .NAME
        Get-ADUser-Groups.ps1

    .SYNAPSIS
        Function for viewing group memberships in AD.

    .DESCRIPTION
        Function for viewing group memberships in AD. Script outputs a CSV file of every user account as well as what security groups they are a member of.

        How to use:
            Run script.

        Requirements
            *
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 191227
        Modified Date: 191227

    .CHANGELOG
        v 1.0:      191227 - Started Changelog
#>

$users = Get-ADUser -Filter * -Properties memberOf
$results = ForEach ($user in $users) {
    ForEach ($group in ($user.memberOf)) {
        [pscustomobject]@{
            User = $user.SamAccountName
            Group = $group
        }
    }
}
return $results | Export-CSV C:\Scripts\Output\ADGroups.csv