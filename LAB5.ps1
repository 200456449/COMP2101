Param ( [switch]$System, 
        [switch]$Disks,
        [switch]$Network
)

import-module Kamaljotkaur

if ($System -eq $false -and $Disks -eq $false -and $Network -eq $false) {
 Write-Host "Insert command line arguments or it will display everything."
 Write-Host "............................................................"
 Kamaljotkaur-System;
 Kamaljotkaur-Disks;
 Kamaljotkaur-Network;
} else {
 if ($System) {
     Kamaljotkaur-System }
 if ($Disks) {
     Kamaljotkaur-Disks; }
 if ($Network) {
     Kamaljotkaur-Network }
}