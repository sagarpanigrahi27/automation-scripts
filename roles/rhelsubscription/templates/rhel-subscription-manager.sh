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
echo "Platform is : "$platform

echo "Checking if rhsm.conf.kat-backup is present.."
#backup_file=/etc/rhsm/rhsm.conf.kat-backup
if [ -f /etc/rhsm/rhsm.conf.kat-backup ]; then
        echo "rhsm config backup was found. taking original back up .."
        mv /etc/rhsm/rhsm.conf /etc/rhsm/rhsm.conf.orig
        mv /etc/rhsm/rhsm.conf.kat-backup /etc/rhsm/rhsm.conf
fi
echo "Unregistering ...."
subscription-manager unregister >/dev/null 2>&1
echo "Cleaning subscription manager..."
subscription-manager clean >/dev/null 2>&1
echo "Running yum clean ..."
yum clean all >/dev/null 2>&1
echo "Refreshing Subcription Manager..."
subscription-manager refresh >/dev/null 2>&1
echo "Registering...."
subscription-manager register --username <Rhel subscription Username> --password <Rhel Subcription Password>
echo "Attach and enable auto attach...."
subscription-manager auto-attach
subscription-manager attach

if [ "$platform" = "el6" ]; then
        echo "Enabling required repos for : " $platform
        yum-config-manager --enable rhel-server-rhscl-6-eus-rpms >/dev/null 2>&1
        yum-config-manager --add-repo https://download.fedoraproject.org/pub/epel/6/x86_64/ >/dev/null 2>&1
        rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
        subscription-manager repos --enable rhel-6-server-optional-rpms --enable rhel-server-rhscl-6-rpms
elif [ "$platform" = "el7" ]; then
        echo "Enabling required repos for : " $platform
        yum-config-manager --enable rhel-server-rhscl-7-eus-rpms >/dev/null 2>&1
        yum-config-manager --add-repo https://download.fedoraproject.org/pub/epel/7/x86_64/ >/dev/null 2>&1
        rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
        subscription-manager repos --enable rhel-7-server-optional-rpms --enable rhel-server-rhscl-7-rpms
fi



