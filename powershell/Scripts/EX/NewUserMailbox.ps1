<#

Exchange Mailbox Creation Script
Version 1.0

Last modified: 11/12/2019

Created by: Chris Clarke
Maintained by: Chris Clarke

#>

<#

/ --------------------------------- \ 
|                                   |
|  Exchange Mailbox Creation Script | 
|  Version 1.0                      |
|                                   |
|  Last modified: 11/12/2019        |
|                                   |
|  Created by: Chris Clarke         |
|  Maintained by: Chris Clarke      |
|                                   |
\ --------------------------------- /

#>

Write-Host ""
Write-Host "/===================================================\" -ForegroundColor yellow 
Write-Host "*========= Enable Exchange Mailbox Script  =========*" -ForegroundColor yellow 
Write-Host "\===================================================/" -ForegroundColor yellow 
Write-Host ""
 
$User = Read-Host -Prompt 'Please input new mailbox alias'

Start-Sleep -Second 1

Write-Host "Creating mailbox for user $User..." -ForegroundColor Yellow

Start-Sleep -Second 3

Enable-RemoteMailbox "$User" -RemoteRoutingAddress "$User@mitchellshire.mail.onmicrosoft.com"

Start-Sleep -Seconds 3

Set-RemoteMailbox "$User" -Emailaddresses @{Add="$User@mitchellshire.mail.onmicrosoft.com"}

Start-Sleep -Seconds 3

Write-Host "If no errors have shown, new user $User@mitchellshire.vic.gov.au has had their mailbox created and assigned!" -ForegroundColor Yellow

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "If errors have shown, Active Directory has not finished replicating." -ForegroundColor Red
Write-Host ""
Write-Host "Please try running this script again at a later time." -ForegroundColor Red
Start-Sleep -Seconds 5
Write-Host ""
Write-Host "/======================================\" -ForegroundColor yellow 
Write-Host "*=========  Script Complete  ==========*" -ForegroundColor yellow 
Write-Host "\======================================/" -ForegroundColor yellow 
Write-Host ""