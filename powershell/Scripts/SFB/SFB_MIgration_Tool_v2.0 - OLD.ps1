Do {  
    $input = Read-Host  "Skype for Bussiness Migration Troubleshooting Tool Please Read Options Carefully 
                        `n1) Connect to Skype for Bussiness Online PowerShell 
                        `n2) Migrate User from SFB online To On-Premise (If this is your first run Please chose option 1)
                        `n3) Check User Status (User Number, Where is the user Located?) (If this is your first run Please chose option 1)
                        `n4) Fix Skype For Bussiness Connection Problem (If result says user is Legacy use option 5 first then use this option) (If this is your first run Please chose option 1)
			`n5) Disable User on Skype for Bussiness (This option will not affect AD user account) (If this is your first run Please chose option 1)
			`nQ) Quit
                        `n * what is your choice?" 
                   
    Switch ($input) {
     "1" {
	 Import-Module SkypeForBusiness
	 $username = Read-Host 'Pleaseput your username eg.firstname.lastname'
	 $cred = Get-Credential -Credential $username@mitchellshire.vic.gov.au
          
         } 
     "2" {$User = Read-Host 'What is the username? eg:firstname.lastname only'
          $Value1 = Read-Host 'What is the external number? eg:+613xxxxx'
          $Value2 = Read-Host 'What is the extension number? eg:63xx'
          Move-CsUser -Identity $User@mitchellshire.vic.gov.au -Target SVR-BO-SFB1.msc.local -Credential $cred -HostedMigrationOverrideUrl https://adminau1.online.lync.com/HostedMigration/hostedmigrationService.svc -Confirm:$false
          get-csuser -identity $User@mitchellshire.vic.gov.au | set-csuser -lineuri "tel:$Value1;ext=$Value2" -enterprisevoiceenabled $true
          get-csuser -identity $User@mitchellshire.vic.gov.au | set-csuser -HostedVoicemail $True
          get-csuser -identity $User@mitchellshire.vic.gov.au | grant-csdialplan -policyname "AU-03-User"
          get-csuser -identity $User@mitchellshire.vic.gov.au | grant-csvoicepolicy -policyname "Broadford - National (Masked)"
          }
     "3" {$User = Read-Host 'What is the username?'
          get-csuser -identity $User@mitchellshire.vic.gov.au
         }
     "4" {
	  $User = Read-Host 'What is the username? eg:firstname.lastname only'
	  Enable-CsUser -Identity $User@mitchellshire.vic.gov.au -SipAddress sip:$User@mitchellshire.vic.gov.au -RegistrarPool svr-bo-sfb1.msc.local
	  }
     "5" {
	  $User = Read-Host 'What is the username? eg:firstname.lastname only'
	  disable-csuser -identity $User@mitchellshire.vic.gov.au
	 }
     "Q" {Write-Host "Goodbye" -ForegroundColor Cyan
        sleep -milliseconds 2000
	Return
         }
     Default {Write-Warning "Invalid Choice. Try again."
              sleep -milliseconds 750}
    } #switch

} While ($True)
	