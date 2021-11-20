Write-Host "Network information:"
get-ciminstance Win32_NetworkAdapterconfiguration |
where {$_.ipenabled -eq "True" } | 
Format-Table Description,
Index,
IPAddress,
IPSubnet,
@{n="DNSHostName";e={switch($_.DNSDomain){$Null{$myvar="No information found here."; $myvar}};if($Null -ne $_.DNSDomain){$_.DNSDomain}}},
@{n="DNSServerOrder";e={switch($_.DNSServersearchorder){$Null{$myvar="No information found here."; $myvar}};if($Null -ne $_.DNSServersearchorder){$_.DNSServersearchorder}}}