$ComputerName = Read-Host 'Enter computer name'
$computer = Get-ADComputer $ComputerName
Get-ADObject -Filter 'objectClass -eq "msFVE-RecoveryInformation"' -SearchBase $computer.DistinguishedName -Properties whenCreated, msFVE-RecoveryPassword | `
  Sort whenCreated -Descending | Select whenCreated, msFVE-RecoveryPassword