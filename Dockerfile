# Usamos la última imagen de NGINX
FROM nginx:latest
MAINTAINER Adrián Domínguez <adrian.dominguez@seidor.es>

ENV NGINX_CONF_DIR /etc/nginx/conf.d
ENV NGINX_STICKY_MODULE_VERSION 1.2.6

CMD apt update && \
    apt install -y \
    wget \
    gcc \
    make \
    libc-dev \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    curl \
    gnupg \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    unzip && \
    rm -rf /var/lib/apt/lists/* && \
    wget -O /tmp/nginx.tar.gz "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" && \
    wget -O /tmp/sticky.zip https://github.com/Refinitiv/nginx-sticky-module-ng/archive/$NGINX_STICKY_MODULE_VERSION.zip && \
    unzip /tmp/sticky.zip -d /tmp && \
    CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') && \
    tar -zxC /usr/src -f /tmp/nginx.tar.gz && \
    cd /usr/src/nginx-$NGINX_VERSION && \
    ./configure --with-compat $CONFARGS --add-module=/tmp/nginx-sticky-module-ng-$NGINX_STICKY_MODULE_VERSION && \
    make && \
    make install

# Añadimos a la ruta de configuración por defecto el fichero de configuración de NGINX
ADD files/jboss-proxy.conf $NGINX_CONF_DIR/default.conf
