Set-ExecutionPolicy -ExecutionPolicy Bypass

    Write-Host = "Running Application Deployment Evaluation Cycle"

        Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000121}"

    Write-Host = "Running Discovery Data Collection Cycle"

        Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000003}"

    Write-Host = "Running File Collection Cycle"

	    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000010}"

    Write-Host = "Running Hardware Inventory Cycle"
       
	    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}"

    Write-Host = "Running Machine Policy Retrieval Cycle"

	    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"

    Write-Host = "Running Machine Policy Evaluation Cycle"

	    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}"

    Write-Host = "Running Software Inventory Cycle"

	    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000002}"

    Write-Host = "Running Software Metering Usage Report Cycle"

	    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000031}"

    Write-Host = "Running Software Update Deployment Evaluation Cycle"

	    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000114}"

    Write-Host = "Running Software Update Scan Cycle"

	    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000113}"

#Write-Host = "Running User Policy Retrieval Cycle"
#
#	Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000026}"
#
#Write-Host = "Running User Policy Evaluation Cycle"
#
#	Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000027}"
#
    Write-Host = "Running Windows Installers Source List Update Cycle"

	    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000032}"