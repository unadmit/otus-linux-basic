#!/bin/bash
targetlist="backup elk prometheus apache-mysql-slave nginx-apache-mysql"
read -p "enter target[backup/elk/prometheus/apache-mysql-slave/nginx-apache-mysql]" target
if echo $targetlist | grep -w $target > /dev/null
then
    setenforce 0
    sed -i "s/=enforcing/=permissive/" /etc/selinux/config
    systemctl stop firewalld
    systemctl disable firewalld
    yum -y install iptables-services.x86_64
    systemctl enable --now iptables.service
    iptables -F
    iptables-restore < ./otus-linux-basic/$target/iptables
    iptables-save
    service iptables save
    rsync -vrp -e "ssh -i $HOME/.ssh/id_rsa" root@192.168.1.100:/root/otus-linux-basic/$target /root/otus-linux-basic 
    yes | cp -rf ./otus-linux-basic/$target/ifcfg-enp0s3 /etc/sysconfig/network-scripts/ifcfg-enp0s3
    systemctl restart network
    hostnamectl set-hostname $target
    systemctl reboot
else
    echo "unknown input"
    exit 1
fi