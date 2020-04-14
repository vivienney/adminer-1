FROM alpine:edge

LABEL description "Adminer is a full-featured database management tool"

ENV ADMINER_PM_VERION=1.8
ENV MEMORY=256M
ENV UPLOAD=2048M

RUN echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    echo '@community http://nl.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk add \
        wget \
        ca-certificates \
        php7@testing \
        php7-session@testing \
        php7-mysqli@community \
        php7-pgsql@testing \
        php7-json@testing \
        php7-pecl-mongodb@testing \
        dumb-init && \
    wget https://github.com/pematon/adminer-custom/archive/v$ADMINER_PM_VERION.tar.gz -O /srv/adminer.tgz && \
    tar zxvf /srv/adminer.tgz --strip-components=1 -C /srv && \
    rm /srv/adminer.tgz && \
    apk del wget ca-certificates && \
    rm -rf /var/cache/apk/*

WORKDIR /srv
EXPOSE 80

ENTRYPOINT ["dumb-init", "--"]

CMD /usr/bin/php \
    -d memory_limit=$MEMORY \
    -d upload_max_filesize=$UPLOAD \
    -d post_max_size=$UPLOAD \
    -S 0.0.0.0:80
