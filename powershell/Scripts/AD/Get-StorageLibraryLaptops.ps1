$servers = @("TB-BA-CLS1", "TB-BA-CLS2", "TB-BA-CLS3", "TB-BA-CLS5", "TB-BA-CLS6", "TB-BA-CLS7", "TB-KLI-STF1", "TB-KLI-STF2", "TB-KLI-STF3", "TB-SLI-STF1", "TB-SLI-STF2", "TB-WLI-STF1", "TB-WLI-STF2", "TB-WLI-STF3", "TB-BVLI-STF1", "TB-BVLI-STF2")

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
Pause