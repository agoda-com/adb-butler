FROM alpine:3.4

MAINTAINER Anton Malinskiy <anton.malinskiy@agoda.com>

ENV PATH $PATH:/opt/platform-tools

RUN set -xeo pipefail && \
    mkdir -m 0750 /root/.android   && \
    mkdir /etc/supervisord.d && \
    apk update && \
    apk add wget ca-certificates nodejs supervisor dcron bash curl && \
    wget -O "/etc/apk/keys/sgerrand.rsa.pub" \
      "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub" && \
    wget -O "/tmp/glibc.apk" \
      "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk" && \
    wget -O "/tmp/glibc-bin.apk" \
      "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-bin-2.23-r3.apk" && \
    apk add "/tmp/glibc.apk" "/tmp/glibc-bin.apk" && \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    rm "/root/.wget-hsts" && \
    rm "/tmp/glibc.apk" "/tmp/glibc-bin.apk" && \
    curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    mkdir -p /opt && \
    rm -r /var/cache/apk/APKINDEX.* && \
    npm install rethinkdb

COPY adb/* /root/.android/
COPY bin/* /
COPY supervisor/supervisord.conf /etc
COPY cron/root /var/spool/cron/crontabs/root

RUN chmod +x /*.sh /clean.js /label.js /root/.android/update-platform-tools.sh && \
    /root/.android/update-platform-tools.sh

EXPOSE 5037

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
