#! /bin/bash
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'
#example: echo -e "I ${RED}love${NC} Stack Overflow"

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

echo -e "${BLUE}Setting hostname${NC}"
    hostnamectl set-hostname $2 --pretty --static --transient
}

install1 () {
echo -e "${BLUE}Installing ${RED}nginx${BLUE} & ${RED}postgresql ${BLUE}#this may take a while#${NC}"

    dnf install postgresql-server vim nginx -y &> /dev/null
echo -e "${BLUE}Initializing database"
    postgresql-setup --initdb &> /dev/null
    systemctl enable --now postgresql

    wget  -qO /tmp/database.sh https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/database.sh
    chmod +x /tmp/database.sh &> /dev/null
    sudo -u postgres /tmp/database.sh &> /dev/null
    
echo -e "${BLUE}Installing ${RED}php-fpm v7.2 ${BLUE}#this may take a while#${NC}"
    yum install epel-release yum-utils -y &> /dev/null
    yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y &> /dev/null
    yum-config-manager --enable remi-php72 -y &> /dev/null
    yum install -y php-cli php-fpm php-pdo php-json php-opcache php-mbstring php-xml php-gd php-curl php-pgsql git &> /dev/null

    wget -qO /etc/php-fpm.d/www.conf https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/www.conf &> /dev/null
    chown -R root:nginx /var/lib/php &> /dev/null
    
    systemctl enable --now php-fpm
    }

install2 () {
echo -e "${BLUE}Installing ${RED}composer ${NC}"
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin --filename=composer &> /dev/null
echo -e "${BLUE}Installing ${RED}drupal using composer ${BLUE}#this may take a while#${NC}"
    composer create-project --no-progress drupal-composer/drupal-project:8.x-dev /var/www/my_drupal --stability dev --no-interaction &> /dev/null
echo -e "${BLUE}Configuring ${RED}nginx${BLUE} & ${RED}drupal${NC}"
    wget -qO /etc/nginx/conf.d/192.168.1.35.conf https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/nginxdrupal.conf
    chown nginx:nginx /etc/nginx/conf.d/192.168.1.35.conf
    wget -qO /var/lib/pgsql/data/pg_hba.conf https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/pg_hba.conf
    wget -qO /etc/nginx/nginx.conf https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/nginx.conf

    chown -R nginx: /var/www/my_drupal
}

reloadServices () {
echo -e "${BLUE}Restarting services${NC}"
    systemctl restart nginx
    systemctl restart php-fpm
    systemctl restart postgresql
}



deviceConfig "192.168.1.35" "Trinity"
install1
install2
reloadServices


    