#! /bin/bash
echo "Cheching interface file type and configuring it"
echo "Determening interface name"
ifconfig -a > interfacenaam
interface=$(cut -d : -f 1 interfacenaam | head -n 1)
rm interfacenaam
echo "Interface name found: $interface"
echo "Configuring interface: $interface"
FILE=/etc/sysconfig/network-scripts/ifcfg-$interface

    echo "DEVICE=$interface" > "$FILE.test"
    echo "BOOTPROTO=none" >> "$FILE.test"
    echo "ONBOOT=yes" >> "$FILE.test"
    echo "IPADDR=192.168.1.34" >> "$FILE.test"
    echo "PREFIX=29" >> "$FILE.test"
    echo "GATEWAY=192.168.1.33" >> "$FILE.test"
echo "interface file configured"