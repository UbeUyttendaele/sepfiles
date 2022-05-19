#! /bin/bash
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Configuring ${GREEN}ssh ${BLUE}security${NC}"
echo -e "${BLUE}Stopping ${GREEN}sshd ${BLUE}service.${NC}"
systemctl stop sshd
echo -e "${BLUE}Changing config file.${NC}"
sed -i '/PermitRootLogin yes/c\PermitRootLogin no' /etc/ssh/sshd_config
sed -i '/PasswordAuthentication yes/c\PasswordAuthentication no' /etc/ssh/sshd_config
sed -i '/ChallengeResponseAuthentication yes/c\ChallengeResponseAuthentication no' /etc/ssh/sshd_config

echo -e "${BLUE}Getting ${GREEN}public ssh ${BLUE}keys${NC}"
wget -qO "/home/${SUDO_USER:-$USER}/.ssh/authorized_keys.WGet" https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/morpheus/id_rsa.pub
cat "/home/${SUDO_USER:-$USER}/.ssh/authorized_keys.WGet" >> "/home/${SUDO_USER:-$USER}/.ssh/authorized_keys"

echo -e "${BLUE}Enabling ${GREEN}sshd ${BLUE}service.${NC}"
systemctl enable sshd --now