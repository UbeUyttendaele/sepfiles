#! /bin/bash
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

deviceConfig () {
echo -e "${BLUE}Configuring interface${NC}"
echo -e "${BLUE}Determening interface name${NC}"
ifconfig -a > interfacenaam
interface=$(cut -d : -f 1 interfacenaam | head -n 1)
rm interfacenaam
echo -e "${BLUE}Interface name found: ${RED}$interface${NC}"
echo -e "${BLUE}Configuring interface: ${RED}$interface${NC}"
FILE=/etc/sysconfig/network-scripts/ifcfg-$interface

    echo "DEVICE=$interface" > "$FILE"
    echo "BOOTPROTO=none" >> "$FILE"
    echo "ONBOOT=yes" >> "$FILE"
    echo "IPADDR=$1" >> "$FILE"
    echo "PREFIX=29" >> "$FILE"
    echo "GATEWAY=192.168.1.33" >> "$FILE"
    systemctl restart NetworkManager

echo -e "${BLUE}Setting ${RED}hostname${NC}"
    hostnamectl set-hostname $2 --pretty --static --transient
}