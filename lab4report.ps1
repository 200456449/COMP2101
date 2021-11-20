function get-hardwarei {
Write-Host "System hardware description:"
get-CimInstance -ClassName win32_computersystem | Format-List
}

function get-osinf {
Write-Host "OS description:"
get-CimInstance -ClassName win32_operatingsystem | Format-List Name, Version
}

function get-CPU {
Write-Host "Processor Information:"
get-CimInstance -ClassName win32_processor | fl Description,
MaxClockSpeed,
NumberOfCores,
@{n="L1CacheSize";e={switch($_.L1CacheSize){$Null{$myvar="No information found here."; $myvar}};if($Null -ne $_.L1CacheSize){$_.L1CacheSize}}},
@{n="L2CacheSize";e={switch($_.L2CacheSize){$Null{$myvar="No information found here."; $myvar}};if($Null -ne $_.L2CacheSize){$_.L2CacheSize}}},
@{n="L3CacheSize";e={switch($_.L3CacheSize){$Null{$myvar="No information found here."; $myvar}};if($Null -ne $_.L3CacheSize){$_.L3CacheSize}}}
}

function get-raminf {
Write-Host "Summary of the RAM installed:"
$Capacity = 0
get-CimInstance -ClassName win32_physicalmemory |
foreach {
new-object -TypeName psobject -Property @{
Manufacturer = $_.manufacturer
Description = $_.Description
"Size(GB)" = $_.capacity/1gb
Bank = $_.Banklabel
Slot = $_.devicelocator
}
$Capacity += $_.capacity/1gb
} |
Format-Table -auto Manufacturer, Description, "Size(GB)", Bank, Slot
"Total RAM: ${Capacity}GB"
}

function get-mydisks {
Write-Host "Physical drive info:"
Get-WmiObject -classname Win32_DiskDrive |
where-object DeviceID -ne $NULL |
Foreach-Object {
                $drive = $_
                $drive.GetRelated("Win32_DiskPartition") |
                foreach {$logicaldisk =$_.GetRelated("win32_LogicalDisk");
                        if($logicaldisk.size) {
                                New-Object -TypeName PSobject -Property @{
                                    Manufacturer = $drive.Manufacturer
                                    DriveLetter = $logicaldisk.DeviceID
                                    Model = $drive.model
                                    Size = [String]($logicaldisk.size/1gb -as [int])+"GB"
                                    Free = [string]((($logicaldisk.freespace / $logicaldisk.size) * 100) -as [int])+ "%"
                                    FreeSpace = [string]($logicaldisk.freespace / 1gb -as [int]) +"GB"
                                        }|
                                            Format-Table -AutoSize Manufacturer, Model, size, Free, FreeSpace
                                }
                         }
                 }
            }

function get-networks {
Write-Host "Network information:"
get-ciminstance Win32_NetworkAdapterconfiguration |
where {$_.ipenabled -eq "True" } | 
Format-Table Description,
Index,
IPAddress,
IPSubnet,
@{n="DNSHostName";e={switch($_.DNSDomain){$Null{$myvar="No information found here."; $myvar}};if($Null -ne $_.DNSDomain){$_.DNSDomain}}},
@{n="DNSServerOrder";e={switch($_.DNSServersearchorder){$Null{$myvar="No information found here."; $myvar}};if($Null -ne $_.DNSServersearchorder){$_.DNSServersearchorder}}}
}

function get-gpu {
Write-Host "GPU Information:"
$H=(get-wmiobject -class win32_videocontroller).CurrentHorizontalResolution -as [string]
$V=(get-wmiobject -class Win32_Videocontroller).CurrentVerticalResolution -as [string]
$Bit=(get-wmiobject -class Win32_Videocontroller).CurrentBitsperPixel -as [string]
$sum= $H + " x " + $V + " and " + $Bit + " bit"
get-wmiobject -class win32_videocontroller |
Format-List @{n="Video Card Vendor"; e={$_.AdapterCompatibility}}, Description, @{n="Resolution"; e={$sum -as [string]}}
}

get-hardwarei
get-osinf
get-CPU
get-raminf
get-mydisks
get-networks
get-gpu
