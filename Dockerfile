FROM nginx:latest
MAINTAINER Adrián Domínguez <adrian.dominguez@seidor.es>

ADD files/jboss-proxy.conf /etc/nginx/conf.d/jboss-proxy.conf
