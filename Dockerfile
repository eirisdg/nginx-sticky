# Usamos la última imagen de NGINX
FROM nginx:latest
MAINTAINER Adrián Domínguez <adrian.dominguez@seidor.es>

ENV NGINX_CONF_DIR /etc/nginx/conf.d
ENV NGINX_STICKY_MODULE_VERSION 1.2.6

CMD apt update 

# Añadimos a la ruta de configuración por defecto el fichero de configuración de NGINX
ADD files/jboss-proxy.conf $NGINX_CONF_DIR/default.conf
