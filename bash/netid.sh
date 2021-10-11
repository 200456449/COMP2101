#!/bin/bash

verbosetest=$(echo "$@"|grep -e "-v")
if [[ $verbosetest = *"-v"* ]]; then verbose="yes" ; fi

function simplereport {
[ "$verbose" = "yes" ] && echo "Gathering host information"
myhostname=$(hostname)
lan_ipaddress=$(ip a s $interface | awk '/inet /{gsub(/\/.*/,"");print $2}')
lan_hostname=$(getent hosts $lan_ipaddress | awk '{print $2}')
[ "$verbose" = "yes" ] && echo "Checking for external IP address and hostname"
external_ip=$(curl -s icanhazip.com)
external_name=$(getent hosts $external_ip | awk '{print $2}')
[ "$verbose" = "yes" ] && echo "Identifying default route"
router_address=$(ip r s default| cut -d ' ' -f 3)
router_hostname=$(getent hosts $router_address|awk '{print $2}')
cat <<EOF
Hostname        : $myhostname
LAN Address     : $lan_ipaddress
LAN Hostname    : $lan_hostname
External IP     : $external_ip
External Name   : $external_name
Router Address  : $router_address
Router Hostname : $router_hostname
EOF
}

function interfacemultiple {
count=$(lshw -class network | awk '/logical name:/{print $3}' | wc -l)

for((w=1;w<=$count;w+=1));
do
  interface=$(lshw -class network |
    awk '/logical name:/{print $3}' |
      awk -v z=$w 'NR==z{print $1; exit}')
  if [[ $interface = lo* ]] ; then continue ; fi
  [ "$verbose" = "yes" ] && echo "Reporting on interface(s): $interface"
  [ "$verbose" = "yes" ] && echo "Getting IPV4 address and name for interface $interface"
  ipv4_address=$(ip a s $interface|awk -F '[/ ]+' '/inet /{print $3}')
  ipv4_hostname=$(getent hosts $ipv4_address | awk '{print $2}')
  [ "$verbose" = "yes" ] && echo "Getting IPV4 network block info and name for interface $interface"
  network_address=$(ip route list dev $interface scope link|cut -d ' ' -f 1)
  network_number=$(cut -d / -f 1 <<<"$network_address")
  network_name=$(getent networks $network_number|awk '{print $1}')
  echo Interface $interface:
  echo ================
  echo Address         : $ipv4_address
  echo Name            : $ipv4_hostname
  echo Network Address : $network_address
  echo Network Number	: $network_number
  echo Network Name    : $network_name
done
}

while [ $# -gt 0 ]; do
	case $1 in
		-v | --verbose )
			verbose="yes"
			;;
		* )
			interface=$1
			simplereport
			;;
	esac
	shift
done

interfacemultiple
