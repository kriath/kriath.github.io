<#
    .NAME
        ADFunctions.ps1

    .SYNAPSIS
        Functions container for ADAdminMenu.ps1

    .DESCRIPTION
        Functions container for ADAdminMenu.ps1

        How to use:
            Run script via ADAdminMenu.ps1

        Requirements
            * ADFunctions.ps1 to be in same directory as script.
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0.7
        Creation Date: 191223
        Modified Date: 210803

    .CHANGELOG
        v 1.0:      191223 - Started Changelog
        v 1.0.1:    191224 - Added Move-ADuser and User-Exit
        v 1.0.2:    191227 - Corrected header comment to current standard
        v 1.0.3:    191230 - Updated User-Status to provide better information regarding user
        v 1.0.4:    200211 - Added Get-RandomPassword as a function
        v 1.0.5:    200615 - Added Get-PasswordInfo as a function
        v 1.0.6:    210727 - Cleared manager property as part of function User-Exit.
        v 1.0.7:    210803 - Cleared department property as part of function User-Exit.
#>

Function Write-Menu {
<#
.SYNOPSIS
Draws a text-based table using Write-Host for use in menus. Designed for use by Read-Menu.

.DESCRIPTION
Draws a text-based table for menus. No output is given other than to the console host.

.PARAMETER MenuItems
Must be a hashtable eg:

    @{
        "1" = @{
            Description = "Item 1"
            Function = "Do-Something"
        }
        "2" = @{
            Description = "Item 2 Long Description Length"
            Function = "Do-AnotherFunction"
        }
        "Q" = @{
            Description = "Quit"
            Function = "Break"
        }
    }

Descriptions will be trimmed to fit inside the table. Functions are not used in Write-Menu,
but if Read-Menu is used, the functions will be run when the choice is selected.

.PARAMETER Heading
An optional heading for the menu.

.PARAMETER Width
Width of the table between 20-100. (Default 42) Descriptions and the Heading will be trimmed to fit.

.EXAMPLE
Write-Menu -Menu $MenuItems -Heading "My Cool Menu" -Width 50

,==================My Cool Menu===================,
| [ 1] Item 1                                     |
| [ 2] Item 2 Description                         |
| [ Q] Quit                                       |
`=================================================`

#>
Param (
    [Parameter(Mandatory=$True,Position=1,
        HelpMessage='Must be a Hashtable - Nested as [ordered]@{ "1" = @{ Description = "Etc" Function = "Do-Function" }} ')]
    [Alias("Menu,HashTable")]
    [hashtable]$MenuItems,
    [string]$Heading = "",
    [ValidateRange(20,100)] #minimum and maximum width of menu
    [int]$Width = 42
)
    If ($width % 2 -eq 1) { [int]$width += 1 } #Keep the Width even
    $heading = $heading[0..($width-2)] -join "" #trim the Heading to fit
    If ($heading.Length % 2 -eq 0) {  $heading = $heading.PadRight($heading.Length+1,"=") } # Pads the heading so it's centered correctly
    Write-Host #Blank line
    Write-Host ("{0}{1}{2}{1}{0}" -f ",",("="*([math]::Ceiling(($width-$heading.Length-1)/2))),$heading) #Draws the heading: ",===Heading===,"
    foreach ($item in $MenuItems.Keys | Sort) {  #iterate each item from the hashtable
        Write-Host ("{0,-2}[{1,2}] {2,-$($width-7)}{0,1}" -f "|",$item,$($menuitems[$item].Description[0..$($width-9)] -join "")) # "| [ 0] Description |"
    }
    Write-Host ('`' + "="*($width-1) + '`') #draws the bottom line

}

Function Read-Menu {
<#
.SYNOPSIS
Draws a text-based table using Write-Menu and then executes selections.

.DESCRIPTION
Using a hashtable to make a menu tree, you can draw a simple menu to execute common commands/functions/cmdlets.
If functions/commands don't explicitly output to host (if required), text may not display until menu loop is exited.
Most options used in Read-Menu are passed to Write-Menu (including the hash table).

.PARAMETER MenuItems
    Must be a hashtable eg:
    @{
        "1" = @{
            Description = "Item 1"
            Function = "Do-Something"
        }
        "2" = @{
            Description = "Item 2 Description"
            Function = "Do-AnotherFunction"
        }
        "Q" = @{
            Description = "Quit"
            Function = "Break"
        }
    }
Functions will be run as-is using Invoke-Expression. Menu will be sorted by key.

.PARAMETER Heading
An optional heading for the menu.

.PARAMETER Width
Width of the table between 20-100. (Default 42) Descriptions and the Heading will be trimmed to fit.

.PARAMETER Loop
If set, The menu will not quit after selecting an option. Use a Break command in one of the menu lines to quit if this is used.

.PARAMETER ExtraCommand
Can display extra text or run a command after the menu is displayed but before the prompt.

.EXAMPLE
Read-Menu -Menu $MenuItems -Heading "My Cool Menu" -Width 50 -Loop -ExtraCommand 'Write-Host "Using: $($cred.username)" -ForeGroundColor Yellow'

,==================My Cool Menu===================,
| [ 1] Item 1                                     |
| [ 2] Item 2 Description                         |
| [ Q] Quit                                       |
`=================================================`
Using: DOMAIN\UserName

Select the Menu option: 
#>
Param (
    [Parameter(Mandatory=$True,Position=1,
        HelpMessage='Must be a Hashtable - Nested as [ordered]@{ "1" = @{ Description = "Etc" Function = "Do-Function" }} ')]
    [Alias("Menu,HashTable")]
    [hashtable]$MenuItems,
    [string]$Heading = "",
    [ValidateRange(20,100)] #minimum and maximum width of menu
    [int]$Width = 42,
    [switch]$Loop,
    [string]$ExtraCommand 
)
        $oldtitle = $host.ui.rawui.WindowTitle
    Do {
        If ($heading) { $host.ui.rawui.WindowTitle = $Heading }
        $count = 0    
        $choice = $null
        
        while ($choice -notin $MenuItems.Keys) {
            if ($count % 3 -eq 0) { #Display the menu and then every 3 prompts (unless a correct option is selected)
                Write-Menu -MenuItems $MenuItems -Heading $heading -Width $width
                If ($ExtraCommand) { Invoke-Expression $ExtraCommand }
                } 
            $choice = Read-Host "`nSelect the Menu option"
            $count += 1
        }
        $host.ui.rawui.WindowTitle = '{0} - {1}' -f $Heading,$MenuItems[$choice.ToUpper()].Description
        Invoke-Expression ($MenuItems[$choice.ToUpper()].Function) #Run the function/command inside the HashTable. 
        $host.ui.rawui.WindowTitle = $oldtitle
    }
    Until ($Loop -eq $false) #if -Loop is set, continue asking for choices
    #If ($choice -eq "Q") { break } #quit


}

Function User-Status {
Write-Host "This command will provide some basic information about a specified user." -ForegroundColor Green
$User = Read-Host 'Enter user name'
Get-ADUser -Identity $User -Properties DistinguishedName, Name, DisplayName, UserPrincipalName, Title, Manager, Enabled, LockedOut, AccountExpirationDate, Created, LastLogonDate | Select DistinguishedName, Name, DisplayName, UserPrincipalName, Title, @{Name='Manager';Expression={(Get-ADUser $_.Manager).sAMAccountName}}, Enabled, LockedOut, AccountExpirationDate, Created, LastLogonDate, lastLogoff, PasswordExpired, PasswordLastSet, PasswordNeverExpires
}

Function User-Enable {
Write-Host 'This command will only enable a users disabled account, not reset their password.' -ForegroundColor Green
$User = Read-Host 'Enter user name'
Enable-ADAccount -Identity $User
Write-Host "$User has been enabled." -ForegroundColor Green
Start-Sleep -Seconds 5
}

Function User-Expiry {
Write-Host 'Please use the date format "mm/dd/yyyy" for entering expiry date.' -ForegroundColor Green
$User = Read-Host 'Enter user name'
$Date = Read-Host 'Enter expiry date'
Set-ADAccountExpiration -Identity $User -DateTime "$Date"
Write-Host "$User now has an expiry date of $Date (mm/dd/yy)." -ForegroundColor Green
Start-Sleep -Seconds 5
}

Function User-Expiry-Clear {
Write-Host 'This command will set a users expiry date to NEVER.' -ForegroundColor Green
$User = Read-Host 'Enter user name'
Clear-ADAccountExpiration -Identity $User
Write-Host 'Users account now has an expiry date of NEVER.' -ForegroundColor Green
Start-Sleep -Seconds 5
}

Function User-Disable {
Write-Host 'This command will only disable a users account, not remove their permissions.' -ForegroundColor Green
$User = Read-Host 'Enter user name'
Disable-ADAccount -Identity $User
Write-Host "$User has been disabled." -ForegroundColor Green
Write-Host 'Please ensure to move users account to Offline (and remove perms) if not being utilised as a shared mailbox.' -ForegroundColor Green
Start-Sleep -Seconds 5
}

Function User-Unlock {
Write-Host 'Note that running this command will NOT reset users password.' -ForegroundColor Green
$User = Read-Host 'Enter user name'
Unlock-ADAccount –Identity $User
Write-Host "$User has been unlocked." -ForegroundColor Green
Start-Sleep -Seconds 5
}

Function Password-Reset {
Write-Host "This command resets a users password to Mitchell123#, unlocks their account" -ForegroundColor Green
Write-Host "and ensures they MUST change their password at next login." -ForegroundColor Green
$User = Read-Host 'Enter user name'
Set-ADAccountPassword $User -Reset -NewPassword (ConvertTo-SecureString -AsPlainText “Mitchell123#” -Force -Verbose) –PassThru
Unlock-ADAccount -Identity $User
Set-ADUser -Identity $User -ChangePasswordAtLogon $true
Write-Host "User account $User has had their password reset to Mitchell123#, their account unlocked and they MUST" -ForegroundColor Green
Write-Host "change their password at next login." -ForegroundColor Green
Start-Sleep -Seconds 10
}

Function Get-Help {

Write-Host 'Each command will give a brief explanation prior to use.' -ForegroundColor Green
Write-Host 'To back out of a choice, simply enter an invalid variable, like "q".' -ForegroundColor Green
Write-Host '' -ForegroundColor Green
Write-Host 'Option 1 will provide some basic information about a user, such as account status [enabled/disabled].' -ForegroundColor Green
Write-Host 'Option 2 will enable a users account.' -ForegroundColor Green
Write-Host 'Option 3 will unlock a users account.' -ForegroundColor Green
Write-Host 'Option 4 will reset a users password, unlock their account, and force them to set a new password upon login.' -ForegroundColor Green
Write-Host 'Option 5 will set an expiry date.' -ForegroundColor Green
Write-Host 'Option 6 will remove an expiry date.' -ForegroundColor Green
Write-Host ''
Write-Host 'Option 7 will disable a users account.' -ForegroundColor Green
Write-Host 'Option 8 will strip an AD users security groups, and export a text file of all removed permissions.' -ForegroundColor Green
Write-Host 'Option 9 will allow you to move an AD Object between OUs. Useful for moving users to offline.' -ForegroundColor Green
Write-Host ''
Write-Host 'Option C will clear your screen.' -ForegroundColor Green
Write-Host 'Option H will display this help message.' -ForegroundColor Green
Write-Host 'Option Q will close the MSC Active Directory Admin Menu.' -ForegroundColor Green
Write-Host ''
Write-Host 'To offboard staff, run options 7, 8 and 9, in that order.' -ForegroundColor Yellow
Write-Host 'Then, from the SFB Admin Menu, run option 4 to disable their SIP account.' -ForegroundColor Yellow
}

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

Function User-Exit {
$UserToDisable = Read-Host 'Please input username to remove all permissions from'
$OutFile = "C:\Scripts\Output\$UserToDisable.txt"
Get-ADPrincipalGroupMembership -Identity $UserToDisable | select name | Out-File -FilePath $OutFile
$users = (Get-ADUser $UserToDisable -properties memberof).memberof
$users | Remove-ADGroupMember -Members $UserToDisable -Confirm:$false
Set-ADUser $UserToDisable -manager $null -department $null
Write-Host "User's department and manager have been cleared." -ForegroundColor Green
Write-Host "A text file of all removed permissions is now located at C:\Scripts\Output\$UserToDisable.txt!" -ForegroundColor Green
}

Function Get-UserGroups {
$User = Read-Host 'Enter user name'
Get-ADPrincipalGroupMembership $User -server msc.local | select name 
}

Function Get-RandomPassword {
$password = -join(33..126|%{[char]$_}|Get-Random -C 10)
Write-Host "New password is $password" -ForegroundColor Green
}

Function Get-PasswordInfo {

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