#!/bin/bash
yum -y install kernel-devel-$(uname -r) gcc git patch rpm-build wget
wget https://github.com/amzn/amzn-drivers/archive/master.zip
unzip master.zip
cd amzn-drivers-master/kernel/linux/ena
make
cp ena.ko /lib/modules/$(uname -r)/
insmod ena.ko
depmod
echo 'add_drivers+=" ena "' >> /etc/dracut.conf.d/ena.conf
dracut -f -v
ls -lrt /boot/
