ARG ALPINE_IMAGE="alpine:3.5"
FROM ${ALPINE_IMAGE}
MAINTAINER Unimock <unimock@gate-m.de>

ENV SYNCTHING_USERID=1027 \
    STNOUPGRADE=true

RUN cd /tmp &&\
    apk -U add openssl gnupg && \
    echo "Getting GPG keys for gosu and Syncthing" && \
    gpg-agent --daemon && \
    gpg --quiet --keyserver hkp://keyserver.ubuntu.com:80  --recv-keys 37C84554E7E0A261E4F76E1ED26E6ED000654A3E B42F6819007F00F88E364FD4036A9C25BF357DD4
ARG GOSU_VERSION="1.10"
RUN echo "Getting gosu: ${GOSU_VERSION} and its signature" && \
    wget -q https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc && \
    wget -q https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 &&\
    echo "Checking gosu signature" && \
    gpg --quiet --verify gosu-amd64.asc && \
    echo "Installing gosu" && \
    chmod +x gosu-amd64 && mv gosu-amd64 /bin/gosu
ARG SYNCTHING_VERSION="0.14.26"
RUN echo "Getting Syncthing ${SYNCTHING_VERSION} and its signature" && \
    wget -q https://github.com/syncthing/syncthing/releases/download/v${SYNCTHING_VERSION}/sha1sum.txt.asc && \
    wget -q https://github.com/syncthing/syncthing/releases/download/v${SYNCTHING_VERSION}/syncthing-linux-amd64-v${SYNCTHING_VERSION}.tar.gz && \
    echo "Checking gosu sha1 sum signature" && \
    gpg --quiet --verify sha1sum.txt.asc && \
    echo "Checking gosu sha1 checksum" && \
    grep syncthing-linux-amd64-v${SYNCTHING_VERSION}.tar.gz sha1sum.txt.asc | sha1sum -c - && \
    echo "Installing syncthing" && \
    tar -xzf syncthing-linux-amd64-v${SYNCTHING_VERSION}.tar.gz syncthing-linux-amd64-v${SYNCTHING_VERSION}/syncthing && \
    mv syncthing-linux-amd64-v${SYNCTHING_VERSION}/syncthing /bin/ && \
    echo "Cleaning up" && \
    rm -rf /tmp/* && \
    rm -rf /root/* && \
    apk del gnupg openssl && \
    rm -rf /var/lib/apt/lists/*

ADD ./start.sh /srv/start.sh

RUN chmod +x /srv/start.sh && mkdir -p /srv/config /srv/data

EXPOSE 8384 22000 21027/udp

VOLUME ["/srv/data", "/srv/config"]

ENTRYPOINT ["/srv/start.sh"]
