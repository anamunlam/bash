#!/bin/bash
#
# Description: LEMP Installer Script
#
# Copyright (C) 2017 Anam <anam@ahka.net>
#
# URL: http://ahka.net
#

get_os() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

GETOS=$( get_os )

OS=$(echo $GETOS | sed 's/\([a-zA-Z]\)\s.*/\1/')
VER=$(echo $GETOS | grep -o [0-9]|head -n1)
INSTALL=$(wget -qO- --no-check-certificate "https://github.com/anamunlam/bash/edit/master/LEMP/${OS}${VER}.sh")
if [ "$?" -eq '0' ]; then
    bash -c "${INSTALL}"
else
    echo "OS or version not supported yet"
    exit 1
fi
exit
