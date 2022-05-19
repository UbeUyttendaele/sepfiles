#! /bin/bash
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

install () {
echo -e "${BLUE}Installing ${GREEN}bind${NC}"
    dnf install -y bind &> /dev/null
echo -e "${BLUE}Configuring ${GREEN}bind${NC}"
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


install
services