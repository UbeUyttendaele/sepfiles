#! /bin/bash
echo "Checking interface file type and configuring it"
echo "Determening interface name"
    ifconfig -a > interfacenaam
    interface=$(cut -d : -f 1 interfacenaam | head -n 1)
    rm interfacenaam
echo "Interface name found: $interface"
echo "Configuring interface: $interface"
    FILE=/etc/sysconfig/network-scripts/ifcfg-$interface
    echo "DEVICE=$interface" > "$FILE"
    echo "BOOTPROTO=none" >> "$FILE"
    echo "ONBOOT=yes" >> "$FILE"
    echo "IPADDR=192.168.1.34" >> "$FILE"
    echo "PREFIX=29" >> "$FILE"
    echo "GATEWAY=192.168.1.33" >> "$FILE"
echo "interface file configured"
    ifdown $interface
    ifup $interface
echo "Installing bind"
    dnf install -y bind &> /dev/null
echo "Bind installed"
echo "Disabling bind in case it was running"
    systemctl stop named
echo "removing current /etc/named.conf file. "
    rm /etc/named.conf
echo "Getting relevant files from the github repository. (https://github.com/UbeUyttendaele/sepfiles)"
    wget -qO /var/named/1.168.192.in-addr.arpa https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/morpheus/1.168.192.in-addr.arpa
    wget -qO /var/named/_msdcs.thematrix.local https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/morpheus/msdcs.thematrix.local
    wget -qO /var/named/thematrix.local https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/morpheus/thematrix.local
    wget -qO /etc/named.conf https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/morpheus/named.conf
    wget -qO /var/named/0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.e.f.ip6.arpa https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/morpheus/0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.e.f.ip6.arpa
echo "Relevant files downloaded from the github repository."
echo "Changing firewall setting to allow dns"
    firewall-cmd --add-service=dns --permanent &> /dev/null
    firewall-cmd --reload &> /dev/null
echo "Firewall settings changed"

echo "Enabling bind"
    systemctl enable --now named &> /dev/null
echo "Bind succesfully configured"

hostnamectl set-hostname Morpheus --pretty --static --transient


