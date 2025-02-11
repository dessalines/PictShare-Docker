FROM shito/alpine-nginx:edge
MAINTAINER Christian Haschek <office@haschek-solutions.com>

# Add PHP 7
RUN set -x \
    && apk upgrade -U \
    && apk --update --repository=http://dl-4.alpinelinux.org/alpine/edge/testing add \
        openssl \
        nano \
        ffmpeg \
        unzip \
        php7 \
        php7-pdo \
        php7-exif \
        php7-mcrypt \
        php7-curl \
        php7-gd \
        php7-json \
        php7-fpm \
        php7-openssl \
        php7-ctype \
        php7-opcache \
        php7-mbstring \
        php7-session \
        php7-fileinfo \
        php7-pcntl \
        file \
    && rm -rf /var/cache/apk/*

COPY /rootfs /

RUN set -x \
    && rm /usr/bin/php \
    && ln -s /etc/php7 /etc/php \
    && ln -s /usr/bin/php7 /usr/bin/php \
    && ln -s /usr/sbin/php-fpm7 /usr/bin/php-fpm \
    && ln -s /usr/lib/php7 /usr/lib/php \
    && ln -s /dev/stdout /var/log/nginx/access.log \
    && ln -s /dev/stderr /var/log/nginx/error.log \
    && mkdir -p /var/log/php-fpm \
    && ln -s /dev/stderr /var/log/php-fpm/fpm-error.log

# Enable default sessions
RUN set -x \
    && mkdir -p /var/lib/php7/sessions \
    && chown nginx:nginx /var/lib/php7/sessions

# ADD SOURCE
RUN set -x \
    && mkdir -p /usr/share/nginx/html

WORKDIR /usr/share/nginx/html

RUN set -x \
    && curl --silent --remote-name https://codeload.github.com/HaschekSolutions/pictshare/zip/master \
    && unzip -q master \
    && mv pictshare-master/* . \
    && rm -r master pictshare-master \
    && mv inc/example.config.inc.php inc/config.inc.php \
    && chown -R nginx:nginx /usr/share/nginx/html \
    && chmod +x bin/ffmpeg

VOLUME /usr/share/nginx/html/data

EXPOSE 80

ENTRYPOINT ["bash", "/pictshare.sh"]
