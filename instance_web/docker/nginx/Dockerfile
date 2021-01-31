FROM nginx:alpine AS builder

# nginx:alpine contains NGINX_VERSION environment variable
ENV NGINX_VERSION=1.19.6

# ngx_cache_purge version
ENV NGX_CACHE_PURGE_VERSION=2.4.3

# Download sources
RUN wget -q "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
    wget -q "https://github.com/nginx-modules/ngx_cache_purge/archive/${NGX_CACHE_PURGE_VERSION}.tar.gz" -O ngx_cache_purge.tar.gz

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
    CONFARGS=${CONFARGS/-Os -fomit-frame-pointer/-Os} && \
    rm -rf /usr/src/nginx /usr/src/extra_module && \
    mkdir -p /usr/src/nginx /usr/src/extra_module && \
	tar -zxC /usr/src/nginx -f nginx.tar.gz && \
    tar -zxC /usr/src/extra_module -f ngx_cache_purge.tar.gz && \
    cd /usr/src/nginx/nginx-${NGINX_VERSION} && \
    ./configure \
        --with-compat $CONFARGS \
        --add-dynamic-module=/usr/src/extra_module/ngx_cache_purge-${NGX_CACHE_PURGE_VERSION} && \
    make modules

FROM nginx:alpine
# Extract the dynamic module ngx_cache_purge from the builder image
COPY --from=builder /usr/src/nginx/nginx-${NGINX_VERSION}/objs/ngx_http_cache_purge_module.so /etc/nginx/modules/ngx_http_cache_purge_module.so

# Copy script to get real-ip from Cloudflare
COPY ./cloudflare-sync-ips.sh /etc/periodic/daily/cloudflare-sync-ips

# Copy script to start crond
COPY ./30-crond.sh /docker-entrypoint.d/

ARG uid
ARG gid

# Create user and group 'www-data'
RUN if [ ${uid:-0} -ne 0 ] && [ ${gid:-0} -ne 0 ]; then \
        if getent group www-data ; then delgroup www-data; fi \
        && addgroup -g ${gid} -S www-data \
        && adduser -u ${uid} www-data -S -G www-data; \
    fi

EXPOSE 80
STOPSIGNAL SIGQUIT
CMD ["nginx", "-g", "daemon off;"]