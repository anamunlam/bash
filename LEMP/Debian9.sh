#!/bin/bash
#
# Description: LEMP Installer Script
#
# Copyright (C) 2017 Anam <anam@ahka.net>
#
# URL: http://ahka.net
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'

next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}

confnginx()
{
    GZIP="client_body_buffer_size 10K;\n\tclient_header_buffer_size 1k;\n\tclient_max_body_size 8m;\n\tlarge_client_header_buffers 4 16k;\n\tfastcgi_buffers 16 16k;\n\tfastcgi_buffer_size 32k;\n\n\tinclude \/etc\/nginx\/cloudflare.conf;"
    CFCONF=$(wget -qO- https://www.cloudflare.com/ips-v4)'\n'$(wget -qO- https://www.cloudflare.com/ips-v6)'\nreal_ip_header CF-Connecting-IP;'
    echo -e "${CFCONF}" > /etc/nginx/cloudflare.conf
    sed -i 's@\(^[^a-z]\)@set_real_ip_from \1@' /etc/nginx/cloudflare.conf
    sed -i 's@\([^;]$\)@\1;@' /etc/nginx/cloudflare.conf
    sed -i 's/# \(gzip_vary.*\)/\1/' /etc/nginx/nginx.conf
    sed -i 's/# \(gzip_proxied.*\)/\1/' /etc/nginx/nginx.conf
    sed -i 's/# \(gzip_comp_level.*\)/\1/' /etc/nginx/nginx.conf
    sed -i 's/# \(gzip_buffers 16.*\)/\1/' /etc/nginx/nginx.conf
    sed -i 's/# \(gzip_http_version.*\)/\1/' /etc/nginx/nginx.conf
    sed -i 's/# \(gzip_types.*\)/\1\n\n\t'"${GZIP}"'/' /etc/nginx/nginx.conf
    
    if [[ ! -f /etc/nginx/sites-available/default.bak ]]; then
        mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
    fi
    
    wget -qO /etc/nginx/sites-available/default http://lemp.sh.ahka.net/file/site_detault_php7.0.conf
}

confphp()
{
    sed -i 's/pm.max_children = .*/pm.max_children = 10/' /etc/php/7.0/fpm/pool.d/www.conf
    sed -i 's/pm.max_requests = .*/pm.max_requests = 200/' /etc/php/7.0/fpm/pool.d/www.conf
    
    sed -i 's/^;cgi.fix_pathinfo.*/cgi.fix_pathinfo = 0/' /etc/php/7.0/fpm/php.ini
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 8M/' /etc/php/7.0/fpm/php.ini
    sed -i 's/max_execution_time = .*/max_execution_time = 60/' /etc/php/7.0/fpm/php.ini
    sed -i 's/max_input_vars = .*/max_input_vars = 5000/' /etc/php/7.0/fpm/php.ini
    
    echo "zend_extension=opcache.so" > /etc/php/7.0/mods-available/opcache.ini
    echo "opcache.memory_consumption=128" >> /etc/php/7.0/mods-available/opcache.ini
    echo "opcache.max_accelerated_files=10000" >> /etc/php/7.0/mods-available/opcache.ini
    echo "opcache.max_wasted_percentage=10" >> /etc/php/7.0/mods-available/opcache.ini
    echo "opcache.validate_timestamps=0" >> /etc/php/7.0/mods-available/opcache.ini
}

echo -ne "${YELLOW}This will install Nginx, MariaDB and php7.0, ${RED}continue?${PLAIN}(Default: no) (Y/n): "
read CONFIRM
if [[ ${CONFIRM} == "Y" ]] || [[ ${CONFIRM} == "y" ]]; then
    clear
    next
    echo -e "${YELLOW}Updating...${PLAIN}"
    next
    apt-get update
    next
    echo -e "${YELLOW}Installing Nginx${PLAIN}"
    next
    apt-get install -y nginx
    next
    echo -e "${YELLOW}Installing php7.0${PLAIN}"
    next
    apt-get install -y php7.0-cli php7.0-curl php7.0-dev php7.0-zip php7.0-fpm php7.0-gd php7.0-xml php7.0-mysql php7.0-mcrypt php7.0-mbstring php7.0-opcache
    next
    echo -e "${YELLOW}Installing MariaDB${PLAIN}"
    next
    bash -c "DEBIAN_FRONTEND=noninteractive apt-get install mariadb-server mariadb-client -y"
    next
    echo -e "${YELLOW}Setting up...${PLAIN}"
    next
    echo "Setting Nginx ..."
    confnginx
    echo "Setting php7.0 ..."
    confphp
    echo "Setting MariaDB ..."
    mysql_secure_installation
    next
    echo -e "${YELLOW}Restarting service ...${PLAIN}"
    next
    /etc/init.d/mysql restart
    /etc/init.d/nginx restart
    /etc/init.d/php7.0-fpm restart
    next
    echo -e "${GREEN}DONE${PLAIN}"
fi
