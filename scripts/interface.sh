#! /bin/bash
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
#example: echo -e "I ${RED}love${NC} Stack Overflow"

deviceConfig () {
echo -e "${BLUE}Configuring interface${NC}"
echo -e "${BLUE}Determening interface name${NC}"
ifconfig -a > interfacenaam
interface=$(cut -d : -f 1 interfacenaam | head -n 1)
rm interfacenaam
echo -e "${BLUE}Interface name found: ${GREEN}$interface${NC}"
echo -e "${BLUE}Configuring interface: ${GREEN}$interface${NC}"
FILE=/etc/sysconfig/network-scripts/ifcfg-$interface

    echo "DEVICE=$interface" > "$FILE"
    echo "BOOTPROTO=none" >> "$FILE"
    echo "ONBOOT=yes" >> "$FILE"
    echo "IPADDR=$1" >> "$FILE"
    echo "PREFIX=29" >> "$FILE"
    echo "GATEWAY=192.168.1.33" >> "$FILE"
    echo "DNS1=192.168.1.34" >> "$FILE"

echo -e "${BLUE}Setting hostname${NC}"
    hostnamectl set-hostname $2 --pretty --static --transient
}


if [ $# -eq 0 ]; then
    echo -e "${BLUE}No parameters supplied, use parameter dns or web.${NC}"
    exit 22
fi

if [[ $1 == dns ]]; then
    deviceConfig "192.168.1.34" "Morpheus"
    echo "DNS2=1.1.1.1" >> "$FILE"
    echo -e "${BLUE}Server wil reboot in ${GREEN}5 seconds ${BLUE}with interface configuration ${GREEN}web${NC}"
    sleep 5
    reboot
fi

if [[ $1 == web ]]; then
    deviceConfig "192.168.1.36" "Trinity"
    echo -e "${BLUE}Server wil reboot in ${GREEN}5 seconds ${BLUE}with interface configuration ${GREEN}web${NC}"
    sleep 5
    reboot
else
echo -e "${BLUE}Wrong parameters supplied, use parameter dns or web.${NC}"
    exit 22
fi

    