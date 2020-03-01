FROM ubuntu:18.04
MAINTAINER Adrián Domínguez <adrian.dominguez@seidor.es>

ENV NGINX_VERSION 1.17.8
ENV NGINX_STICKY_MODULE_VERSION 1.2.6-fix
ENV ZLIB_VERSION 1.2.11
ENV PCRE_VERSION 8.44


RUN apt-get update && \
    apt-get install -y \
    libpcre3-dev \
    build-essential \
    libssl-dev \
    libperl-dev \
    libxslt1-dev \
    libgd-dev \
    libgeoip-dev \
    git \
    wget \
    unzip && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /nginx-src
RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" && tar xzf nginx-${NGINX_VERSION}.tar.gz && rm -f nginx-${NGINX_VERSION}.tar.gz
RUN wget "http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz" && tar xzf zlib-${ZLIB_VERSION}.tar.gz && rm -f zlib-${ZLIB_VERSION}.tar.gz
RUN wget "https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz" && tar xzf pcre-${PCRE_VERSION}.tar.gz && rm -f pcre-${PCRE_VERSION}.tar.gz
RUN wget "https://github.com/eirisdg/nginx-sticky-module-ng/archive/${NGINX_STICKY_MODULE_VERSION}.zip" && unzip ${NGINX_STICKY_MODULE_VERSION}.zip && rm -f ${NGINX_STICKY_MODULE_VERSION}.zip

RUN useradd nginx

WORKDIR /nginx-src/nginx-${NGINX_VERSION}
RUN ./configure --with-cc-opt='-g -O2 -fstack-protector-strong --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2 -fPIC' \
    --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro' \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --lock-path=/var/run/nginx.lock \
    --pid-path=/var/run/nginx.pid \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-debug \
    --with-pcre-jit \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module \
    --with-http_gzip_static_module \
    --with-http_gunzip_module \
    --with-http_image_filter_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_sub_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_xslt_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --add-module=/nginx-src/nginx-sticky-module-ng-${NGINX_STICKY_MODULE_VERSION} \
    --with-pcre=/nginx-src/pcre-${PCRE_VERSION} \
    --with-zlib=/nginx-src/zlib-${ZLIB_VERSION}

RUN make && make install

# Extra settings to make nginx happier to work with
WORKDIR /etc/nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN mkdir -p /var/cache/nginx/client_temp && mkdir -p /var/cache/nginx/fastcgi_temp && mkdir -p /var/cache/nginx/proxy_temp && mkdir -p /var/cache/nginx/scgi_temp && mkdir -p /var/cache/nginx/uwsgi_temp
ENV PATH=/usr/sbin/nginx:$PATH

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN apt-get purge -y --auto-remove \
    && rm -rf "$tempDir" /etc/apt/sources.list.d/temp.list;

EXPOSE 80
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
