<#
    .NAME
        SFBFunctions.ps1

    .SYNAPSIS
        Functions container for SFBAdminMenu.ps1

    .DESCRIPTION
        Functions container for SFBAdminMenu.ps1

        How to use:
            Run script via SFBAdminMenu.ps1

        Requirements
            * SFBFunctions.ps1 to be in same directory as script.
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0.2
        Creation Date: 191223
        Modified Date: 191227

    .CHANGELOG
        v 1.0:      191223 - Started Changelog
        v 1.0.1:    191224 - Added Change User SFB Policy function
        v 1.0.2:    191227 - Corrected header comment to current standard 
        v 1.0.3:    200103 - Added Enable-EnterpriseVoice and Get-Help
        v 1.0.4:    200218 - Changed default voice policy in Migrate-User
#>

set-executionpolicy -scope currentuser unrestricted -force

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

Function Check-Status {
$User = Read-Host 'What is the username?'
get-csuser -identity $User@mitchellshire.vic.gov.au
}

Function Migrate-User {
$User = Read-Host 'What is the username? eg:firstname.lastname only'
$Value1 = Read-Host 'What is the external number? eg:+613xxxxx'
$Value2 = Read-Host 'What is the extension number? eg:63xx'
Move-CsUser -Identity $User@mitchellshire.vic.gov.au -Target SVR-BO-SFB1.msc.local -Credential $cred -HostedMigrationOverrideUrl https://adminau1.online.lync.com/HostedMigration/hostedmigrationService.svc -Confirm:$false
get-csuser -identity $User@mitchellshire.vic.gov.au | set-csuser -lineuri "tel:$Value1;ext=$Value2" -enterprisevoiceenabled $true
get-csuser -identity $User@mitchellshire.vic.gov.au | set-csuser -HostedVoicemail $True
get-csuser -identity $User@mitchellshire.vic.gov.au | grant-csdialplan -policyname "AU-03-User"
get-csuser -identity $User@mitchellshire.vic.gov.au | grant-csvoicepolicy -policyname "Broadford - National"
}

Function Fix-User {
$User = Read-Host 'What is the username? eg:firstname.lastname only'
Enable-CsUser -Identity $User@mitchellshire.vic.gov.au -SipAddress sip:$User@mitchellshire.vic.gov.au -RegistrarPool svr-bo-sfb1.msc.local
}

Function Disable-User {
$User = Read-Host 'What is the username? eg:firstname.lastname only'
disable-csuser -identity $User@mitchellshire.vic.gov.au
Get-ADUser $User | Set-ADUser -Clear msRTCSIP-ApplicationOptions,msRTCSIP-DeploymentLocator,msRTCSIP-Line,msRTCSIP-OwnerUrn,msRTCSIP-PrimaryUserAddress,msRTCSIP-UserEnabled,msRTCSIP-OptionFlags,msRTCSIP-PrimaryHomeServer
}

Function Change-User-Policy {
$user = Read-Host -Prompt 'Enter user name'
Write-Host 'Choose from one of the following policies. Enter your choice EXACTLY as it appears.' -ForegroundColor Green
Write-Host 'Broadford – National' -ForegroundColor Yellow
Write-Host 'Broadford – National (Masked)' -ForegroundColor Yellow
Write-Host 'Broadford – International' -ForegroundColor Yellow
Write-Host 'Broadford – International (Masked)' -ForegroundColor Yellow
$policy = Read-Host -Prompt 'Please enter your choice from above the above'
Grant-CsVoicePolicy -Identity “$user” -PolicyName “$Policy”
}

Function Enable-EnterpriseVoice {
$user = Read-Host -Prompt 'Enter user name'
Set-CsUser -Identity $user -EnterpriseVoiceEnabled $True
}

Function Get-Help {

Write-Host 'Each command will give a brief explanation prior to use.' -ForegroundColor Green
Write-Host 'To back out of a choice, simply press Ctrl+C. You will need to reopen the SFB Admin Menu.' -ForegroundColor Green
Write-Host '' -ForegroundColor Green
Write-Host 'Option 1 will provide some basic information about a user' -ForegroundColor Green
Write-Host 'Option 2 will migrate a user to SFB On Premises.' -ForegroundColor Green
Write-Host 'Option 3 will set a SIP account for the user.' -ForegroundColor Green
Write-Host 'Option 4 will disable a users SIP account.' -ForegroundColor Green
Write-Host 'Option 5 will change a users SFB Voice Policy. A list of options is provided.' -ForegroundColor Green
Write-Host 'Option 6 will enable Enterprise Voice if an extension is not required.' -ForegroundColor Green
Write-Host ''
Write-Host 'Option C will clear your screen.' -ForegroundColor Green
Write-Host 'Option H will display this help message.' -ForegroundColor Green
Write-Host 'Option Q will close the MSC SFB Admin Menu.' -ForegroundColor Green
Write-Host ''
Write-Host 'To onboard staff, run options 3, then either 2 or 6 depending on requirements.' -ForegroundColor Yellow
Write-Host 'To offboard staff, run option 4.' -ForegroundColor Yellow
}