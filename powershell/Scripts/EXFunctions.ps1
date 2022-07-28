<#
    .NAME
        EXFunctions.ps1

    .SYNAPSIS
        Functions container for ExchangeAdminMenu.ps1

    .DESCRIPTION
        Functions container for ExchangeAdminMenu.ps1

        How to use:
            Run script via ExchangeAdminMenu.ps1

        Requirements
            * EXFunctions.ps1 to be in same directory as script.
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0.1
        Creation Date: 191223
        Modified Date: 191227

    .CHANGELOG
        v 1.0:      191223 - Started Changelog
        v 1.0.1:    191227 - Corrected header comment to current standard 
        v 1.0.2:    200109 - Disabled CreateNewMailbox  
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

<#

# This function has been disabled as it only works for On Premises Exchange

Function CreateNewMailbox {
$User = Read-Host -Prompt 'Please input new mailbox alias'
Start-Sleep -Second 1

Write-Host "Creating mailbox for user $User..." -ForegroundColor Green
Start-Sleep -Second 3

Enable-RemoteMailbox "$User" -RemoteRoutingAddress "$User@mitchellshire.mail.onmicrosoft.com"
Start-Sleep -Seconds 3

Set-RemoteMailbox "$User" -Emailaddresses @{Add="$User@mitchellshire.mail.onmicrosoft.com"}
Start-Sleep -Seconds 3

Write-Host "If no errors have shown, new user $User@mitchellshire.vic.gov.au has had their mailbox created and assigned!" -ForegroundColor Green
Start-Sleep -Seconds 3

Write-Host "If errors have shown, Active Directory has not finished replicating." -ForegroundColor Red
Write-Host "Please try running this script again at a later time." -ForegroundColor Red
Start-Sleep -Seconds 5
}

#>

Function AutomapRemove {
$Alias = Read-Host -Prompt 'Please input alias of mailbox that is auto-mapping'
$User = Read-Host -Prompt 'Please input username that needs the mailbox removed'
Add-MailboxPermission -Identity $Alias -User $User -AccessRights FullAccess -InheritanceType All -Automapping $false
Write-Host "Mailbox $Alias has been removed from $User!" -ForegroundColor Green
}

Function EnablePublicCalendar {
$User = Read-Host 'Enter user name'
Get-Mailbox “$User" | % { Set-MailboxFolderPermission -Identity "$($_.UserPrincipalName):\Calendar" -User "Default" -AccessRights "Reviewer"}
#check
Get-Mailbox "$User" | % { Get-MailboxFolderPermission -Identity "$($_.UserPrincipalName):\Calendar" }
Write-Host = "Calendar $User is now viewable by all company!" -ForegroundColor Green
}

Function MoreThan30Days {
Get-Mailbox –RecipientType 'UserMailbox' | Get-MailboxStatistics | Sort-Object LastLogonTime | Where {$_.LastLogonTime –lt ([DateTime]::Now).AddDays(-30) } | Format-Table DisplayName, LastLogonTime
}

Function Get-Mailbox-Perms {
$User = Read-Host 'Enter user name'
Get-Mailbox -RecipientTypeDetails UserMailbox,SharedMailbox -ResultSize Unlimited | Get-MailboxPermission -User $User
}

Function Set-SharedMailboxCopy {
$mailbox = Read-Host 'Enter shared mailbox alias'
Set-Mailbox $mailbox -MessageCopyForSentAsEnabled $True
}