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

install () {
echo -e "${BLUE}Installing ${RED}bind${NC}"
    dnf install -y bind &> /dev/null
echo -e "${BLUE}Configuring ${RED}bind${NC}"
    rm /etc/named.conf
    wget -qO /var/named/1.168.192.in-addr.arpa https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/morpheus/Files/1.168.192.in-addr.arpa
    wget -qO /var/named/_msdcs.thematrix.local https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/morpheus/Files/msdcs.thematrix.local
    wget -qO /var/named/thematrix.local https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/morpheus/Files//thematrix.local
    wget -qO /etc/named.conf https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/morpheus/Files//named.conf
    wget -qO /var/named/0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.e.f.ip6.arpa https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/morpheus/Files/0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.e.f.ip6.arpa
}
services () {
echo -e "${BLUE}Restarting services${NC}"
    systemctl stop named &> /dev/null
    systemctl stop firewalld &> /dev/null
    systemctl enable --now named &> /dev/null
    systemctl enable --now firewalld &> /dev/null
echo -e "${BLUE}Changing firewall setting to allow dns${NC}"
    firewall-cmd --add-service=dns --permanent &> /dev/null
    firewall-cmd --reload &> /dev/null
}


deviceConfig "192.168.1.34" "Morpheus"
install
services


