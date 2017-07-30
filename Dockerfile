## Modified by Sam KUON - 29/07/17
FROM centos:latest
MAINTAINER Sam KUON "sam.kuonssp@gmail.com"

# System timezone
ENV TZ=Asia/Phnom_Penh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Repositories and packages
RUN yum -y install epel-release && \
    rpm -Uvh https://dl.iuscommunity.org/pub/ius/stable/CentOS/7/x86_64/ius-release-1.0-14.ius.centos7.noarch.rpm

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
	httpd \
	git \
	wget && \
    yum clean all

# Set PHP timezone

# Download phpipam
RUN mkdir /usr/src/phpipam && \
    cd /usr/src/phpipam && \
    git clone https://github.com/phpipam/phpipam.git .

# Copy run-httpd script to image
ADD ./conf.d/run-httpd.sh /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

EXPOSE 80 443

CMD ["/run-httpd.sh"]

