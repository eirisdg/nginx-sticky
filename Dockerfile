FROM nginx:latest
MAINTAINER Adrián Domínguez <adrian.dominguez@seidor.es>

ADD files/jboss-proxy.conf ${HTTPD_MC_BUILD_DIR}/conf/extra/mod_cluster.conf
