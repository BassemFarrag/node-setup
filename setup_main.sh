#!/bin/bash

# تحديث النظام
sudo apt update && sudo apt upgrade -y

# تمكين التوجيه على مستوى الشبكة
sudo sysctl -w net.ipv4.ip_forward=1

# ضبط قواعد iptables
sudo iptables -P FORWARD ACCEPT
sudo iptables -P INPUT ACCEPT

# تمكين جدار الحماية وفتح البورتات المطلوبة
sudo ufw enable
sudo ufw allow 22
sudo ufw allow 4449
sudo ufw allow 10000:60000/udp
sudo ufw reload
sudo ufw status

# تثبيت Mysterium Node
sudo -E bash -c "$(curl -s https://raw.githubusercontent.com/mysteriumnetwork/node/master/install.sh)"

# تمكين خدمة Mysterium Node
sudo systemctl enable mysterium-node.service

# متابعة حالة الخدمة
sudo journalctl -fu mysterium-node.service
