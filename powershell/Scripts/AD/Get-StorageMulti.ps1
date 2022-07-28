$servers = @("TB-BA-CLS1", "TB-BA-CLS2", "TB-CCLARKE4")

Foreach ($server in $servers)
{
    $disks = Get-WmiObject Win32_LogicalDisk -ComputerName $server -Filter DriveType=3 | 
        Select-Object DeviceID, 
            @{'Name'='Size'; 'Expression'={[math]::truncate($_.size / 1GB)}}, 
            @{'Name'='Freespace'; 'Expression'={[math]::truncate($_.freespace / 1GB)}}

    $server

    foreach ($disk in $disks)
    {
        $disk.DeviceID + $disk.FreeSpace.ToString("N0") + "GB / " + $disk.Size.ToString("N0") + "GB"

     }
 }