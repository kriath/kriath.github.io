$remote_computer = Read-Host 'Enter computer name'
Get-CimInstance Win32_LogicalDisk -ComputerName $remote_computer -Filter DriveType=3 | Select-Object DeviceID, @{'Name'='Size (GB)'; 'Expression'={[math]::truncate($_.size / 1GB)}}, @{'Name'='Freespace (GB)'; 'Expression'={[math]::truncate($_.freespace / 1GB)}}
Pause