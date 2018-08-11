FROM alpine:3.8

ARG LIBTORRENT_VERSION=1.1.9
ARG LIBTORRENT_VERSION_UNDERSCORE=1_1_9
ARG DELUGE_VERSION=1.3.15

ENV LANG=C.UTF-8

RUN apk add --no-cache \
        boost-python \
        boost-system \
        geoip \
        intltool \
        libffi \
        libgcc \
        libjpeg-turbo \
        libstdc++ \
        openssl \
        netcat-openbsd \
        py2-pip \
        python2 \
        supervisor \
        tiff \
        zlib && \
    apk add --no-cache --virtual .build-deps \
        boost-dev \
        ca-certificates \
        gcc \
        g++ \
        libffi-dev \
        libjpeg-turbo-dev \
        make \
        musl-dev \
        openssl-dev \
        python2-dev \
        tar \
        tiff-dev \
        wget \
        zlib-dev && \
    pip --no-cache-dir install \
        chardet==3.0.4 \
        Mako==1.0.7 \
        Pillow==5.2.0 \
        pyOpenSSL==18.0.0 \
        python-geoip==1.2 \
        pyxdg==0.26 \
        service-identity==17.0.0 \
        setproctitle==1.1.10 \
        Twisted==18.7.0 && \
    ( \
        wget --quiet -O /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz https://github.com/arvidn/libtorrent/releases/download/libtorrent-$LIBTORRENT_VERSION_UNDERSCORE/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz && \
        tar -xf /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz -C /tmp && \
        (cd /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION && ./configure --with-libiconv --enable-python-binding --prefix=/usr && make && make install) && \
        rm -rf /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION \
    ) && \
    ( \
        wget --quiet -O /tmp/deluge-$DELUGE_VERSION.tar.gz http://download.deluge-torrent.org/source/deluge-$DELUGE_VERSION.tar.gz && \
        tar -xf /tmp/deluge-$DELUGE_VERSION.tar.gz -C /tmp && \
        (cd /tmp/deluge-$DELUGE_VERSION && ls -l && python setup.py build && python setup.py install --prefix=/usr) && \
        rm -rf /tmp/deluge-$DELUGE_VERSION.tar.gz /tmp/deluge-$DELUGE_VERSION \
    ) && \
    apk del .build-deps

ADD supervisor.deluge.ini /etc/supervisor.d/deluge.ini
ADD deluge.setup.sh /

EXPOSE 58846 8112
EXPOSE 41250-41259/tcp
EXPOSE 41250-41259/udp

ENTRYPOINT ["/bin/sh", "-c", "set -e; /deluge.setup.sh && exec /usr/bin/supervisord -n"]
