#! /bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color
#example: echo -e "I ${RED}love${NC} Stack Overflow"
echo -e "Cheching interface file type and configuring it"
echo -e "Determening interface name"
ifconfig -a > interfacenaam
interface=$(cut -d : -f 1 interfacenaam | head -n 1)
rm interfacenaam
echo -e "Interface name found: ${RED}$interface${NC}"
echo -e "Configuring interface: ${RED}$interface${NC}"
FILE=/etc/sysconfig/network-scripts/ifcfg-$interface

    echo "DEVICE=$interface" > "$FILE.test"
    echo "BOOTPROTO=none" >> "$FILE.test"
    echo "ONBOOT=yes" >> "$FILE.test"
    echo "IPADDR=192.168.1.34" >> "$FILE.test"
    echo "PREFIX=29" >> "$FILE.test"
    echo "GATEWAY=192.168.1.33" >> "$FILE.test"
    systemctl restart NetworkManager
echo -e "interface ${RED}$interface${NC} configured"