#! /bin/bash
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color
#example: echo -e "I ${RED}love${NC} Stack Overflow"

echo -e "${BLUE}Installing ${RED}nginx${BLUE} & ${RED}postgresql${NC}"

    dnf install postgresql-server vim nginx -y
echo -e "${BLUE}Initializing database"
    postgresql-setup --initdb &> /dev/null
    systemctl enable --now postgresql

    wget -qO /tmp/database.sh https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/database.sh
    chmod +x /tmp/database.sh
    sudo -u postgres /tmp/database.sh
echo -e "${BLUE}Installing ${RED}php-fpm v7.2${NC}"
    yum install epel-release yum-utils -y
    yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
    yum-config-manager --enable remi-php72 -y
    yum install -y php-cli php-fpm php-pdo php-json php-opcache php-mbstring php-xml php-gd php-curl php-pgsql git

    wget -qO /etc/php-fpm.d/www.conf https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/www.conf
    chown -R root:nginx /var/lib/php
    
    systemctl enable --now php-fpm
echo -e "${BLUE}Installing ${RED}composer${NC}"
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin --filename=composer
    rm ./composer-installer.php
echo -e "${BLUE}Installing ${RED}drupal using composer${NC}"
    composer create-project drupal-composer/drupal-project:8.x-dev /var/www/my_drupal --stability dev --no-interaction
echo -e "${BLUE}Configuring ${RED}nginx${BLUE} & ${RED}drupal${NC}"
    wget -qO /etc/nginx/conf.d/192.168.1.35.conf https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/nginxdrupal.conf
    chown nginx:nginx /etc/nginx/conf.d/192.168.1.35.conf
    wget -qO /var/lib/pgsql/data/pg_hba.conf https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/pg_hba.conf
    wget -qO /etc/nginx/nginx.conf https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/trinity/Files/nginx.conf

    chown -R nginx: /var/www/my_drupal
echo -e "${BLUE}Restarting services${NC}"
    systemctl restart nginx
    systemctl restart php-fpm
    systemctl restart postgresql
echo -e "${BLUE}Setting hostname${NC}"
    hostnamectl set-hostname Trinity --pretty --static --transient

    