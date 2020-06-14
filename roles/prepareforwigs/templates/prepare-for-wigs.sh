#!/usr/bin/env bash
set -e

function CLEAN_CLOUD_INIT() {
    # This removes all of the cloud-init settings on the system.
    rm -rf /var/lib/cloud/
}

function RESET_HOSTNAME_CTL() {
    # This resets the hostname on Enterprise Linux 7 based operating systems.
    logger "Setting hostname to 'ip-' via hostnamectl command"
    hostnamectl set-hostname ip-
}

function RESET_HOSTNAME_LEGACY() {
    # This resets the hostname Enterprise Linux 6 based operating systems.
    logger "Setting hostname to 'ip-' via hostname command"
    hostname ip-
    logger "Recording 'ip-' in the /etc/hostname file"
    logger ip- > /etc/hostname
}
function REMOVE_SYSCONFIG_HOSTNAME() {
    # This stops the instance from using the cached sysconfig setting.
    logger "Removing the /etc/sysconfig HOSTNAME Entry"
    sed -i '/HOSTNAME/d' /etc/sysconfig/network
}

function REMOVE_INSTANCE_FROM_DOMAIN() {
    # This is required to avoid a dirty cache on pbis causing domain join issues.
    logger "Leaving the domain in pbis"
    /opt/pbis/bin/domainjoin-cli leave 2>&1 | logger
}

function SHUTDOWN_INSTANCE() {
    shutdown now -P
}

function IS_AMAZON_LINUX_1() {
    if [[ -f /etc/os-release ]] ; then
        source /etc/os-release
        if [[ "$ID" == 'amzn' ]] && [[ "$VERSION_ID" == '2018.03' ]]; then
            logger "Detected AMAZON Linux 1"
            return 0
        fi
    fi
    return 1
}

function IS_AMAZON_LINUX_2() {
    if [[ -f /etc/os-release ]] ; then
        source /etc/os-release
        if [[ "$ID" == 'amzn' ]] && [[ "$VERSION_ID" == '2' ]]; then
            logger "Detected AMAZON Linux 2"
            return 0
        fi
    fi
    return 1
}

function IS_RED_HAT_7() {
    if [[ -f /etc/os-release ]] ; then
        source /etc/os-release
        if [[ "$ID" == 'rhel' ]] && [[ "$VERSION_ID" =~ ^7.* ]]; then
            logger "Detected RHEL 7"
            return 0
        fi
    fi
    return 1
}

function IS_CENTOS_6() {
     if [[ -f /etc/redhat-release ]] ; then
        DIST=`cat /etc/redhat-release`
        PATTERN='^CentOS release 6.*'
        if [[ "$DIST" =~ $PATTERN ]]; then
            logger "Detected CENTOS 6"
            return 0
        fi
     fi
     return 1
}

function IS_CENTOS_7() {
    if [[ -f /etc/os-release ]] ; then
        source /etc/os-release
        if [[ "$ID" == 'centos' ]] && [[ "$VERSION_ID" =~ ^7.* ]]; then
            logger "Detected CENTOS 7"
            return 0
        fi
    fi
    return 1
}

function IS_RED_HAT_6() {
     if [[ -f /etc/redhat-release ]] ; then
        DIST=`cat /etc/redhat-release`
        PATTERN='^Red Hat Enterprise Linux Server release 6.*'
        if [[ "$DIST" =~ $PATTERN ]]; then
            logger "Detected RHEL 6"
            return 0
        fi
     fi
     return 1
}

function IS_SUSE_LINUX_ENTERPRISE_SERVER_12() {
    if [[ -f /etc/os-release ]] ; then
        source /etc/os-release
        if [[ "$ID" == 'sles' ]] && [[ "$VERSION_ID" =~ ^12.* ]]; then
            logger "Detected SLES 12"
            return 0
        fi
    fi
    return 1
}

function SET_KEY() {
    local key=$1
    local value=$2
    local file=$3
    sed -i "s/^${key} = .*/${key} = ${value}/g" $file
    return $?
}

function RESET_AMS_CONFIG() {
    if SET_KEY "first_boot" "true" "/opt/aws/ams/etc/ams.conf.d/state.ini"; then
        return 0
    fi
    return 1
}

function RESET_HOSTNAME() {
    # Reset the hostname depending on the operating system.
    if IS_AMAZON_LINUX_1; then
        RESET_HOSTNAME_LEGACY
        REMOVE_SYSCONFIG_HOSTNAME
        return
    fi
    if IS_AMAZON_LINUX_2; then
        RESET_HOSTNAME_CTL
        return
    fi

    if IS_CENTOS_7; then
        RESET_HOSTNAME_CTL
        return
    fi

    if IS_RED_HAT_7; then
        RESET_HOSTNAME_CTL
        return
    fi

    if IS_RED_HAT_6; then
        RESET_HOSTNAME_LEGACY
	REMOVE_SYSCONFIG_HOSTNAME
        return
    fi

    if IS_CENTOS_6; then
        # Hostname reset to 'ip-' not required
        # Setting 'first_boot' to 'true'
        RESET_AMS_CONFIG
        return
    fi

    if IS_SUSE_LINUX_ENTERPRISE_SERVER_12; then
        # Hostname reset to 'ip-' not required
        # Setting 'first_boot' to 'true'
        RESET_AMS_CONFIG
        return
    fi
    logger "Failed to recognize operating system, exiting."
    exit 1
}

function ENSURE_USER_IS_ROOT() {
    if [[ "$EUID" -ne 0 ]]; then
        logger -s "This script requires root permissions. Please execute with sudo or as root user"
        exit 1
    fi
}

ENSURE_USER_IS_ROOT
logger "Starting to configure instance for AMI creation"
RESET_HOSTNAME
REMOVE_INSTANCE_FROM_DOMAIN
CLEAN_CLOUD_INIT
logger "Successfully configured instance for AMI creation, shutting down"
#SHUTDOWN_INSTANCE


# The script/code shared is copyright AWS or its affiliates and is AWS Content subject to the terms of the Customer Agreement - https://aws.amazon.com/agreement/

