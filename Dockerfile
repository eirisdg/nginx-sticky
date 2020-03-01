FROM nginx:alpine
MAINTAINER Adrián Domínguez <adrian.dominguez@seidor.es>

ENV NGINX_STICKY_MODULE_VERSION 1.2.6

# Download sources
RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
  wget -O /tmp/sticky.zip https://github.com/Refinitiv/nginx-sticky-module-ng/archive/$NGINX_STICKY_MODULE_VERSION.zip && \
  unzip /tmp/sticky.zip -d /tmp

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN apk add --no-cache --virtual .build-deps \
  gcc \
  libc-dev \
  make \
  openssl-dev \
  pcre-dev \
  zlib-dev \
  linux-headers \
  curl \
  gnupg \
  libxslt-dev \
  gd-dev \
  geoip-dev

# Reuse same cli arguments as the nginx:alpine image used to build
RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
	tar -zxC /usr/src -f nginx.tar.gz && \
  cd /usr/src/nginx-$NGINX_VERSION && \
  ./configure --with-compat $CONFARGS --add-module=/tmp/nginx-sticky-module-ng-$NGINX_STICKY_MODULE_VERSION && \
  make && make install


# Añadimos a la ruta de configuración por defecto el fichero de configuración de NGINX
ADD files/jboss-proxy.conf $NGINX_CONF_DIR/default.conf

EXPOSE 80
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
