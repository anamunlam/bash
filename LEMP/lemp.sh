#!/bin/bash
#
# Description: LEMP Installer Script
#
# Copyright (C) 2017 Anam <anam@ahka.net>
#
# URL: http://ahka.net
#

OS=$(head -n1 /etc/issue | cut -f 1 -d ' ')
VER=$(cat /etc/debian_version|grep -o [0-9]|head -n1)
clear
echo "$OS $VER"
exit
