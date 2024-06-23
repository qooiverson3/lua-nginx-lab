FROM nginx:1.24

# required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    wget \
    curl \
    git \
    luarocks \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install LuaJIT
RUN cd /usr/local/src && \
    git clone https://github.com/openresty/luajit2.git && \
    cd luajit2 && \
    make && \
    make install

# set LuaJIT env
ENV LUAJIT_LIB=/usr/local/lib
ENV LUAJIT_INC=/usr/local/include/luajit-2.1

# download modules
RUN cd /usr/local/src && \
    git clone https://github.com/vision5/ngx_devel_kit.git && \
    git clone https://github.com/openresty/lua-nginx-module.git && \
    git clone https://github.com/openresty/lua-resty-core.git && \
    git clone https://github.com/openresty/lua-resty-lrucache.git

# download Nginx
RUN cd /usr/local/src && \
    wget http://nginx.org/download/nginx-$(nginx -v 2>&1 | cut -d/ -f2).tar.gz && \
    tar -xzvf nginx-*.tar.gz && \
    cd nginx-* && \
    ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --add-module=/usr/local/src/ngx_devel_kit \
    --add-module=/usr/local/src/lua-nginx-module && \
    # --add-module=/usr/local/src/lua-resty-lrucache && \
    # --add-module=/usr/local/src/lua-resty-core && \
    make && \
    make install

RUN ls /usr/local/src && \
    cd /usr/local/src/lua-resty-core && \
    make && \
    make install LUA_LIB_DIR=/usr/local/src/lua/5.1

RUN ls /usr/local/src && \
    cd /usr/local/src/lua-resty-lrucache && \
    make && \
    make install LUA_LIB_DIR=/usr/local/src/lua/5.1

# clean up
RUN apt-get remove -y \
    build-essential \
    wget \
    curl \
    git && \
    apt-get autoremove -y && \
    apt-get clean
    # rm -rf /var/lib/apt/lists/* /usr/local/src/*

# cp Nginx config
COPY nginx.conf /etc/nginx/nginx.conf

RUN cat /etc/nginx/nginx.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
