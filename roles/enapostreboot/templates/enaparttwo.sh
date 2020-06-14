#!/bin/bash
echo "Fetching Platform Information..."
if [ -f /etc/redhat-release ] && [ `cat /etc/redhat-release | cut -d" " -f7 | cut -d "." -f1` = 6 ]; then

   platform=el6

elif [ -f /etc/redhat-release ] && [ `cat /etc/redhat-release | cut -d" " -f7 | cut -d "." -f1` = 7 ]; then

   platform=el7

else

   echo -e "OS version not supported!"

   exit 2

fi

if [ "$platform" = "el6" ]; then

	yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm >/dev/null 2>&1

elif [ "$platform" = "el7" ]; then

	yum install -y https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-12.noarch.rpm >/dev/null 2>&1

fi


yum install dkms -y
VER=$( grep ^VERSION /root/amzn-drivers-master/kernel/linux/rpm/Makefile | cut -d' ' -f2 )
sudo cp -a /root/amzn-drivers-master /usr/src/amzn-drivers-${VER}
cat > /usr/src/amzn-drivers-${VER}/dkms.conf <<EOM
PACKAGE_NAME="ena"
PACKAGE_VERSION="$VER"
CLEAN="make -C kernel/linux/ena clean"
MAKE="make -C kernel/linux/ena/ BUILD_KERNEL=\${kernelver}"
BUILT_MODULE_NAME[0]="ena"
BUILT_MODULE_LOCATION="kernel/linux/ena"
DEST_MODULE_LOCATION[0]="/updates"
DEST_MODULE_NAME[0]="ena"
AUTOINSTALL="yes"
EOM
dkms add -m amzn-drivers -v $VER
yum install "kernel-devel-uname-r == $(uname -r)" -y
dkms build -m amzn-drivers -v $VER
dkms install -m amzn-drivers -v $VER
modinfo ena


if [ "$platform" = "el7" ]; then
        echo "Platform is : "$platform
	echo "Adding net.ifnames=0 to grub config ..."
	sudo sed -i '/^GRUB\_CMDLINE\_LINUX/s/\"$/\ net\.ifnames\=0\"/' /etc/default/grub
	if [ $? -eq 0 ]; then
		echo "Regenerating configuration files for grub2..."
		grub2-mkconfig -o /boot/grub2/grub.cfg
		if [ $? -eq 0 ]; then
			echo "grub-mkconfig ran successfully..."
		else
			echo "grub2-mkconfig failed...."
                fi
        else
		echo "sed for grub config failed..."
	fi
            
fi



