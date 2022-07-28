<#
    .NAME
        Decom-User.ps1

    .SYNAPSIS
        Decommission a user account.

    .DESCRIPTION
        Decommission a user account.

        How to use:
            Run script and enter user name

        Requirements
            * Active Directory Admin permissions
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 200707
        Modified Date: 200707

    .CHANGELOG
        v 1.0:      200707 - Started Changelog
#>

Function Move-ADuser {
 
[cmdletbinding(SupportsShouldProcess)]
Param(
[Parameter(Position=0,Mandatory=$True,
HelpMessage="Enter a user's samAccountname",
ValueFromPipeline=$True)]
[ValidateNotNullorEmpty()]
[Alias("samaccountname","name")]
[string]$Username,
 
[Parameter(Position=1,Mandatory=$True,
HelpMessage="Enter the name of an OU")]
[ValidateNotNullorEmpty()]
[string]$TargetOU,
 
[switch]$Passthru
 
)
Begin {
 #get the OU
 Write-Verbose "Getting OU $TargetOU"
 $OU = Get-ADOrganizationalUnit -filter "Name -eq '$TargetOU'"
 
 #define a hash table of parameters to splat to Move-ADObject
 $moveParams=@{
   TargetPath=$OU
   Identity=$Null
 }
 if ($Passthru) {
    $moveParams.Add("Passthru",$True)
 }
}
Process {
 $User = Get-ADUser -identity $username
 $moveParams.Identity=$User
 Write-Verbose "Moving $username to $($OU.Distinguishedname)"
 
 Move-ADObject @moveParams
}
 
End {
 Write-Verbose "Finished moving user accounts"
}
 
} #end function

$User = Read-Host 'Please input username to decommission'
$OutFile = "C:\Scripts\Output\$User.txt"
Disable-ADAccount -Identity $User
Get-ADPrincipalGroupMembership -Identity $User | select name | Out-File -FilePath $OutFile
$users = (Get-ADUser $User -properties memberof).memberof
$users | Remove-ADGroupMember -Members $User -Confirm:$false
Move-ADuser