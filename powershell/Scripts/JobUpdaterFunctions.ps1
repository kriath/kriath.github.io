<#
    .NAME
        JobUpdaterFunctions.ps1

    .SYNAPSIS
        Functions container for JobUpdater.ps1

    .DESCRIPTION
        Functions container for JobUpdater.ps1

        How to use:
            Run script via JobUpdater.ps1

        Requirements
            * JobUpdaterFunctions.ps1 to be in same directory as script.

    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 200613
        Modified Date: 200625

    .CHANGELOG
        v 1.0:      200613 - Started Changelog.
        v 1.0.1:    200615 - Added new function (Update) and added Set-Clipboard to all existing functions.
        v 1.0.2:    200625 - Added title of update to the beginning of each $template result.
        v 1.0.3:    210108 - Added "$vendorref" to the Job-Update function.
        v 1.0.4:    210113 - Updated Get-Help function.
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

Function Get-Help {

Write-Host 'Each command will give a brief explanation prior to use.' -ForegroundColor Green
Write-Host 'To back out of a choice, simply enter an invalid variable, like "q".' -ForegroundColor Green
Write-Host 'Every choice will place an output into your clipboard for pasting into a ticket.' -ForegroundColor Blue
Write-Host ''
Write-Host 'Option 1 will ask for some information for a ticket update.'
Write-Host 'Option 2 will ask for some information for a new Service Request.'
Write-Host 'Option 3 will ask for some information for a new Change Request.'
Write-Host 'Option 4 will ask for some information regarding an attempted contact attempt.'
Write-Host 'Option 5 will ask for some information regarding ticket resolution.'
Write-Host ''
Write-Host 'Option C will clear your screen.'
Write-Host 'Option H will display this help message.'
Write-Host 'Option Q will close the MSC Job Updated menu.'
}

Function Service-Request {
$contact = Read-Host 'Contact method (Call / Walk-In)'
$requestor = Read-Host 'Requesting user'
$department = Read-Host 'Users department'
$location = Read-Host 'Location of issue'
$bpoc = Read-Host 'Best point of contact'
$details = Read-Host 'Details of request'

Write-Host ''
Write-Host 'Compiling into template...'
Write-Host ''

$template = Write-Host "**Service Request** `n`n**Contact Method:** $contact `n**Requestor:** $requestor `n**Department:** $department `n**Location:** $location `n**BPOC:** $bpoc `n`n**Request Details:** $details"
                       "**Service Request** `n`n**Contact Method:** $contact `n**Requestor:** $requestor `n**Department:** $department `n**Location:** $location `n**BPOC:** $bpoc `n`n**Request Details:** $details" | Set-Clipboard
Write-Host $template
Write-Host ''
Write-Host 'Your results have been placed into your clipboard.'
}

Function Contact-Attempt {

$number = Read-Host 'Contact attempt number */3'
$type = Read-Host 'Method of contact'
$details = Read-Host 'Please enter details of contact'
$followup = Read-Host 'Scheduled time to follow up (hh:mm - dd/mm/yy)'
$time = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

Write-Host ''
Write-Host 'Compiling into template...'
Write-Host ''

$template = Write-Host "**Contact Attempt** `n`n**Attempt No.:** $number/3 `n**Method of contact:** $type `n**Details:** $details `n `n**Follow-up:** $followup `n**Timestamp:** $time"
                       "**Contact Attempt** `n`n**Attempt No.:** $number/3 `n**Method of contact:** $type `n**Details:** $details `n `n**Follow-up:** $followup `n**Timestamp:** $time" | Set-Clipboard

Write-Host "$template"
Write-Host ''
Write-Host 'Your results have been placed into your clipboard.'
}

Function Change-Request {

$user = Read-Host 'Requesting user'
$department = Read-Host 'Department'
$location = Read-Host 'Location'
$bpoc = Read-Host 'Best point of contact'
$device = Read-Host 'Affected device'
$service = Read-Host 'Affected service'
$authority = Read-Host 'Change Authority'
$details = Read-Host 'Request Details'
$risk = Read-Host 'Risk assessment'
$inaction = Read-Host 'Result of inaction'
$plan = Read-Host 'Back-out Plan'
$time = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

Write-Host ''
Write-Host 'Compiling into template...'
Write-Host ''

$template = Write-Host "**Change Request** `n`n**Requesting user:** $user `n**Department:** $department `n**Location:** $location `n**BPOC:** $bpoc `n**Affected Device:** $device `n**Affected Service:** $service `n**Change Authority:** $authority `n`n**Request Details:** $details `n`n**Risk assessment:** $risk `n**Result of inaction:** $inaction `n**Back-out Plan:** $plan `n**Timestamp:** $time"
                       "**Change Request** `n`n**Requesting user:** $user `n**Department:** $department `n**Location:** $location `n**BPOC:** $bpoc `n**Affected Device:** $device `n**Affected Service:** $service `n**Change Authority:** $authority `n`n**Request Details:** $details `n`n**Risk assessment:** $risk `n**Result of inaction:** $inaction `n**Back-out Plan:** $plan `n**Timestamp:** $time" | Set-Clipboard
Write-Host "$template"
Write-Host ''
Write-Host 'Your results have been placed into your clipboard.'
}

Function Job-Resolved {

$comments = Read-Host 'Comments on resolution'
$follow = Read-Host 'Is a follow up ticket required? Enter ticket no. if already raised'
$time = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

Write-Host ''
Write-Host 'Compiling into template...'
Write-Host ''

$template = Write-Host "**Ticket Resolved** `n`n**Comments:** $comments `n `n**Follow-up:** $follow `n**Timestamp:** $time"
                       "**Ticket Resolved** `n`n**Comments:** $comments `n `n**Follow-up:** $follow `n**Timestamp:** $time" | Set-Clipboard
Write-Host "$template"
Write-Host ''
Write-Host 'Your results have been placed into your clipboard.'
}

Function Job-Update {
$comments = Read-Host 'Update'
$status = Read-Host 'Job Status'
$vendor = Read-Host 'Vendor (if applicable)'
$vendorref = Read-Host 'Vendor Reference (if applicable)'
$time = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

Write-Host ''
Write-Host 'Compiling into template...'
Write-Host ''

$template = Write-Host "**Ticket Update** `n`n**Comments:** $comments `n `n**Current Status:** $status `n**Vendor:** $vendor `n**Vendor Reference:** $vendorref `n**Timestamp:** $time"
                       "**Ticket Update** `n`n**Comments:** $comments `n `n**Current Status:** $status `n**Vendor:** $vendor `n**Vendor Reference:** $vendorref `n**Timestamp:** $time" | Set-Clipboard

Write-Host "$template"
Write-Host ''
Write-Host 'Your results have been placed into your clipboard.'

}