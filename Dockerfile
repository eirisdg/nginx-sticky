FROM nginx:latest
MAINTAINER Adrián Domínguez <adrian.dominguez@seidor.es>

ENV NGINX_CONF_DIR /etc/nginx/conf.d

ADD files/jboss-proxy.conf $NGINX_CONF_DIR/default.conf
