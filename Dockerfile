FROM alpine:3.8

MAINTAINER Anton Malinskiy <anton.malinskiy@agoda.com>

ENV PATH $PATH:/opt/platform-tools:/opt/gnirehtet-rust-linux64

RUN set -xeo pipefail && \
    mkdir -m 0750 /root/.android   && \
    mkdir /etc/supervisord.d && \
    apk update && \
    apk add wget ca-certificates nodejs npm supervisor dcron bash curl && \
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
    curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    curl -sL -o gnirehtet.zip https://github.com/Genymobile/gnirehtet/releases/download/v2.3/gnirehtet-rust-linux64-v2.3.zip && \
    echo "561d77e94d65ecf2d919053e5da6109b8cceb73bffedea71cd4e51304ccaa3d3  gnirehtet.zip" | sha256sum -c && \
    mkdir -p /opt && \
    unzip gnirehtet.zip -d /opt && \
    chmod +x /opt/gnirehtet-rust-linux64/gnirehtet && \
    mv /opt/gnirehtet-rust-linux64/* / && \
    rm -R /opt/gnirehtet-rust-linux64 && \
    rm gnirehtet.zip && \
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
