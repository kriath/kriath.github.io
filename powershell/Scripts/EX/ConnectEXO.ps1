<#
    .NAME
        ConnectEXO.ps1

    .SYNAPSIS
        Prompts for credentials, then connects POSH session to Exchange Online.

    .DESCRIPTION
        Prompts for credentials, then connects POSH session to Exchange Online.

        How to use:
            Open Powershell Online module, then run ConnectEXO.ps1

        Requirements
            * POSH Online module
        
    .NOTES
        Author:        Chris Clarke
        Version:       1.0
        Creation Date: 191227
        Modified Date: 191227
#>


function Connect-ExchangeOnline {
    param
    (
        [system.string]$ConnectionUri = 'https://ps.outlook.com/powershell/',
        [Parameter(Mandatory)]
        [Alias('RunAs')]
        [pscredential]
        [System.Management.Automation.Credential()]
        $Credential
    )
    PROCESS {
        TRY {
            # Make sure the credential username is something like admin@domain.com
            if ($Credential.username -notlike '*@*') {
                Write-Error 'Must be email format'
                break
            }

            $Splatting = @{
                ConnectionUri     = $ConnectionUri
                ConfigurationName = 'microsoft.exchange'
                Authentication    = 'Basic'
                AllowRedirection  = $true
            }
            IF ($PSBoundParameters['Credential']) { $Splatting.Credential = $Credential }

            # Load Exchange cmdlets (Implicit remoting)
            Import-PSSession -Session (New-PSSession @Splatting -ErrorAction Stop) -ErrorAction Stop
        }
        CATCH {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}


<#
$User = Read-Host 'Please enter Exchange Online admin account'
Connect-EXOPSSession -UserPrincipalName $User@mitchellshire.onmicrosoft.com
#>