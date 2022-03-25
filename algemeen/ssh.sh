#! /bin/bash
echo "Configuring ssh security"
echo "Stopping sshd service."
systemctl stop sshd
echo "Changing config file."
sed -i '/PermitRootLogin yes/c\PermitRootLogin no' /etc/ssh/sshd_config
sed -i '/PasswordAuthentication yes/c\PasswordAuthentication no' /etc/ssh/sshd_config
sed -i '/ChallengeResponseAuthentication yes/c\ChallengeResponseAuthentication no' /etc/ssh/sshd_config

echo "Getting public ssh keys"
wget -qO "/home/${SUDO_USER:-$USER}/.ssh/authorized_keys.WGet" https://raw.githubusercontent.com/UbeUyttendaele/sepfiles/main/morpheus/id_rsa.pub
cat "/home/${SUDO_USER:-$USER}/.ssh/authorized_keys.WGet" >> "/home/${SUDO_USER:-$USER}/.ssh/authorized_keys"

echo "Enabling sshd service."
systemctl enable sshd --now