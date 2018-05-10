#! /bin/bash
chmod -R 777 /nested
cd /nested
cp beaker-RHEL-AppStream.repo /etc/yum.repos.d/
yum install net-tools nmap wget -y&&yum module install virt -y
cp qemu* /etc/
cp ifcfg* /etc/sysconfig/network-scripts/
cd /etc/sysconfig/network-scripts/
nic=$(ip addr|grep -o "2: \<e.*\: "|awk -F: '{print $2}'|sed "s/ //g")
sed -i "s/enp4s0f0/$nic/g" ifcfg-enp4s0f0
rm -rf ifcfg-$nic
cp  ifcfg-enp4s0f0 ifcfg-$nic
systemctl restart network

