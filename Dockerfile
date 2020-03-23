FROM alpine:3.8

MAINTAINER Anton Malinskiy <anton.malinskiy@agoda.com>

ENV PATH $PATH:/opt/platform-tools

RUN set -xeo pipefail && \
    mkdir -m 0750 /root/.android   && \
    mkdir /etc/supervisord.d && \
    apk update && \
    apk add wget ca-certificates nodejs npm supervisor dcron bash && \
    wget -O "/etc/apk/keys/sgerrand.rsa.pub" \
      "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub" && \
    wget -O "/tmp/glibc.apk" \
      "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk" && \
    wget -O "/tmp/glibc-bin.apk" \
      "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-bin-2.28-r0.apk" && \
    apk add "/tmp/glibc.apk" "/tmp/glibc-bin.apk" && \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    rm "/root/.wget-hsts" && \
    rm "/tmp/glibc.apk" "/tmp/glibc-bin.apk" && \
    rm -r /var/cache/apk/APKINDEX.* && \
    npm install rethinkdb

COPY adb/* /root/.android/
COPY bin/* /
COPY supervisor/supervisord.conf /etc
COPY cron/root /var/spool/cron/crontabs/root

RUN chmod +x /bootstrap.sh /clean.js /label.js /root/.android/update-platform-tools.sh && \
    /root/.android/update-platform-tools.sh

EXPOSE 5037

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
