

$VMName = "{VM Host}"
$NewVMName = "$($VMName)-New"

$VMProcessor = Get-VMProcessor -VMName $VMName | Select-Object *

$VMProcCount = $VMProcessor.Count



$CurrentVM = Get-VM -Name $VMName | Select-Object *

$NewVMRAM = $CurrentVM.MemoryStartup
$NewVMGen = $CurrentVM.Generation




$VMNetwork = Get-VMNetworkAdapter -VMName $VMName | Select-Object SwitchName




New-VM -Name $NewVMName -MemoryStartupBytes $NewVMRAM -Generation $NewVMGen -NoVHD
Set-VMProcessor -VMName $NewVMName -Count $VMProcCount
Get-VM -Name $NewVMName | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName $VMNetwork.SwitchName
