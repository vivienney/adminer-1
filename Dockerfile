FROM alpine:3.11

LABEL description "Adminer is a full-featured database management tool" \
      maintainer="Hardware <contact@meshup.net>"

ARG VERSION=4.7.6
ARG SHA256_HASH="78f718f3b60faa1d1765af6c0010465f8d780fcaf8990a9e9223ce9c716de2d2"
ARG THEME=pepa-linha

ENV GID=991 UID=991

RUN echo "@community https://nl.alpinelinux.org/alpine/v3.11/community" >> /etc/apk/repositories \
 && apk -U upgrade \
 && apk add -t build-dependencies \
    ca-certificates \
    openssl \
 && apk add \
    su-exec \
    tini@community \
    php7@community \
    php7-session@community \
    php7-pdo_mysql@community \
    php7-pdo_pgsql@community \
    php7-pdo_sqlite@community \
 && cd /tmp \
 # Download and install adminer and alternative design
 && ADMINER_FILE="adminer-${VERSION}.php" \
 && wget -q https://github.com/vrana/adminer/releases/download/v${VERSION}/${ADMINER_FILE} \
 && CHECKSUM=$(sha256sum ${ADMINER_FILE} | awk '{print $1}') \
 && if [ "${CHECKSUM}" != "${SHA256_HASH}" ]; then echo "ERROR: Checksum does not match!" && exit 1; fi \
 && mkdir /adminer && mv ${ADMINER_FILE} /adminer/index.php \
 && wget -q https://raw.githubusercontent.com/vrana/adminer/master/designs/${THEME}/adminer.css -P /adminer \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/* /tmp/*

COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

EXPOSE 8888

CMD ["/sbin/tini", "--", "run.sh"]
