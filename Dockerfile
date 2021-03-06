## Modified by Sam KUON - 10/09/18
FROM centos:latest
MAINTAINER Sam KUON "sam.kuonssp@gmail.com"

# System timezone
ENV TZ=Asia/Phnom_Penh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# phpIPAM version
ENV IPAM_VER 1.3.2

# Repositories and packages
RUN yum -y install epel-release && \
    curl -s https://setup.ius.io/ | bash

RUN yum -y update && \
    yum -y install \
	php70u \
	php70u-cli \
	php70u-gd \
	php70u-pdo \
	php70u-common \
	php70u-pear \
	php70u-snmp \
	php70u-xml \
	php70u-mysqlnd \
	php70u-ldap \
        php70u-json \
        php70u-mbstring \
        php70u-gmp \
	php70u-mcrypt \
	httpd \
	wget && \
    yum clean all

# Set PHP timezone
RUN sed -i "s/^;date.timezone =$/date.timezone = \"Asia\/Phnom_Penh\"/" /etc/php.ini

# Secure Apache server
## Disable CentOS Welcome Page
RUN sed -i 's/^\([^#]\)/#\1/g' /etc/httpd/conf.d/welcome.conf

## Turn off directory listing, Disable Apache's FollowSymLinks, Turn off server-side includes (SSI) and CGI execution
RUN sed -i 's/^\([^#]*\)Options Indexes FollowSymLinks/\1Options -Indexes +SymLinksifOwnerMatch -ExecCGI -Includes/g' /etc/httpd/conf/httpd.conf

## Hide the Apache version, secure from clickjacking attacks, disable ETag, secure from XSS attacks and protect cookies with HTTPOnly flag
RUN echo $'\n\
ServerSignature Off\n\
ServerTokens Prod\n\
Header append X-FRAME-OPTIONS "SAMEORIGIN"\n\
FileETag None\n\
<IfModule mod_headers.c>\n\
    Header set X-XSS-Protection "1; mode=block"\n\
</IfModule>\n'\
>> /etc/httpd/conf/httpd.conf

# Disable unnecessary modules in /etc/httpd/conf.modules.d/00-base.conf
RUN sed -i '/mod_cache.so/ s/^/#/' /etc/httpd/conf.modules.d/00-base.conf && \
    sed -i '/mod_cache_disk.so/ s/^/#/' /etc/httpd/conf.modules.d/00-base.conf && \
    sed -i '/mod_substitute.so/ s/^/#/' /etc/httpd/conf.modules.d/00-base.conf && \
    sed -i '/mod_userdir.so/ s/^/#/' /etc/httpd/conf.modules.d/00-base.conf

# Disable everything in /etc/httpd/conf.modules.d/00-dav.conf, 00-lua.conf, 00-proxy.conf and 01-cgi.conf
RUN sed -i 's/^/#/g' /etc/httpd/conf.modules.d/00-dav.conf && \
    sed -i 's/^/#/g' /etc/httpd/conf.modules.d/00-lua.conf && \
    sed -i 's/^/#/g' /etc/httpd/conf.modules.d/00-proxy.conf && \
    sed -i 's/^/#/g' /etc/httpd/conf.modules.d/01-cgi.conf

# Download phpipam
RUN cd /tmp/ && wget https://nchc.dl.sourceforge.net/project/phpipam/phpipam-$IPAM_VER.tar && \
	tar -xvf phpipam-$IPAM_VER.tar -C /usr/src/ && \
	rm -rf /tmp/*

# Copy run-httpd script to image
ADD ./conf.d/run-httpd.sh /run-httpd.sh
ADD ./conf.d/apache_state.conf /etc/httpd/conf.d/apache_state.conf
RUN chmod -v +x /run-httpd.sh

EXPOSE 80 443

CMD ["/run-httpd.sh"]

