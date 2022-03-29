#! /bin/bash
GREEN='\033[0;32m'
RED='\033[1;31m'
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
    systemctl restart NetworkManager

echo -e "${BLUE}Setting hostname${NC}"
    hostnamectl set-hostname $2 --pretty --static --transient
}

install1 () {
echo -e "${BLUE}Installing ${GREEN}nginx${BLUE} & ${GREEN}postgresql ${BLUE}#this may take a while#${NC}"

    dnf install postgresql-server vim nginx -y &> /dev/null
echo -e "${BLUE}Initializing database"
    postgresql-setup --initdb &> /dev/null
    systemctl enable --now postgresql &> /dev/null

    wget  -qO /tmp/database.sh https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/database.sh
    chmod +x /tmp/database.sh &> /dev/null
    sudo -u postgres /tmp/database.sh &> /dev/null
    
echo -e "${BLUE}Installing ${GREEN}php-fpm v7.2 ${BLUE}#this may take a while#${NC}"
    yum install epel-release yum-utils -y &> /dev/null
    yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y &> /dev/null
    yum-config-manager --enable remi-php72 -y &> /dev/null
    yum install -y php-cli php-fpm php-pdo php-json php-opcache php-mbstring php-xml php-gd php-curl php-pgsql git &> /dev/null

    wget -qO /etc/php-fpm.d/www.conf https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/www.conf &> /dev/null
    chown -R root:nginx /var/lib/php &> /dev/null
    
    systemctl enable --now php-fpm &> /dev/null
    }


certificate() {
echo -e "${BLUE}Creating ${GREEN}ssl certificate${RED}#Manual input required#${NC}"
    path="/etc/nginx/ssl/thematrix.local"
    mkdir -p $path &> /dev/null
    openssl genrsa -des3 -out $path/self-ssl.key 2048
    
    cp -v $path/self-ssl.{key,original} &> /dev/null
    openssl rsa -in $path/self-ssl.original -out $path/self-ssl.key
    rm -v $path/self-ssl.original  &> /dev/null

    openssl req -new -key $path/self-ssl.key -out $path/self-ssl.csr 
    openssl x509 -req -days 365 -in $path/self-ssl.csr -signkey $path/self-ssl.key -out $path/self-ssl.crt 
}

install2 () {
echo -e "${BLUE}Installing ${GREEN}composer ${NC}"
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin --filename=composer &> /dev/null
echo -e "${BLUE}Installing ${GREEN}drupal using composer ${BLUE}#this may take a while#${NC}"
    composer create-project --no-progress drupal-composer/drupal-project:8.x-dev /var/www/my_drupal --stability dev --no-interaction &> /dev/null
    wget -qO /etc/nginx/conf.d/thematrix.local.conf https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/nginxdrupal.conf
    chown nginx:nginx /etc/nginx/conf.d/thematrix.local.conf
    wget -qO /var/lib/pgsql/data/pg_hba.conf https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/pg_hba.conf
    wget -qO /etc/nginx/nginx.conf https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/nginx.conf
    mkdir -p /var/www/my_drupal/config/sync
    chown -R nginx: /var/www/my_drupal
}

services () {
echo -e "${BLUE}Restarting services${NC}"
    systemctl restart nginx
    systemctl restart php-fpm
    systemctl restart postgresql 
echo -e "${BLUE}Configuring ${GREEN}firewall & SELinux${NC}"
    setenforce 1

    semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/my_drupal/web(/.*)?"  &> /dev/null
    semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/my_drupal/web/sites/default/settings.php'  &> /dev/null
    semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/my_drupal/web/sites/default/files'  &> /dev/null
    restorecon -Rv /var/www/my_drupal/web/  &> /dev/null
    restorecon -v /var/www/my_drupal/web/sites/default/settings.php  &> /dev/null
    restorecon -Rv /var/www/my_drupal/web/sites/default/files  &> /dev/null

    setsebool httpd_can_network_connect 1
    setsebool httpd_graceful_shutdown 1
    setsebool httpd_can_network_relay 1
    setsebool nis_enabled 1
    setsebool httpd_can_network_connect_db 1
    setsebool httpd_execmem 1
    setsebool domain_can_mmap_files 1

    semodule -i httpd-vboxsf.pp


    systemctl enable --now firewalld &> /dev/null
    firewall-cmd --permanent --add-service=http &> /dev/null
    firewall-cmd --permanent --add-service=https &> /dev/null
    firewall-cmd --reload &> /dev/null
}



#deviceConfig "192.168.1.35" "Trinity"
install1
install2
certificate
services