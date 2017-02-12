FROM alpine:3.5

# Runtime Dependencies
RUN apk add --no-cache python2 py2-pip                                 \
                       libgcc libstdc++                                \
                       boost-python boost-system geoip intltool libffi \
                       libjpeg-turbo tiff zlib openssl

ARG LIBTORRENT_VERSION=1.0.11
ARG LIBTORRENT_VERSION_UNDERSCORE=1_0_11
ARG DELUGE_VERSION=1.3.13

RUN apk add --no-cache --virtual .build-dependencies boost-dev ca-certificates gcc g++ libffi-dev libjpeg-turbo-dev make musl-dev openssl-dev tiff-dev python2-dev tar wget zlib-dev && \
    pip --no-cache-dir install chardet==2.3.0 Mako==1.0.6 Pillow==4.0.0 pyOpenSSL==16.2.0 python-geoip==1.2 pyxdg==0.25 service-identity==16.0.0 setproctitle==1.1.10 Twisted==17.1.0 && \
    wget --quiet -O /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz https://github.com/arvidn/libtorrent/releases/download/libtorrent-$LIBTORRENT_VERSION_UNDERSCORE/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz && \
    tar -xf /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz -C /tmp && \
    (cd /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION && ./configure --with-libiconv --enable-python-binding --prefix=/usr && make && make install) 1>/dev/null 2>&1 && \
    ldconfig /usr/local/lib && \
    rm -rf /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION && \
    wget --quiet -O /tmp/deluge-$DELUGE_VERSION.tar.gz http://download.deluge-torrent.org/source/deluge-$DELUGE_VERSION.tar.gz && \
    tar -xf /tmp/deluge-$DELUGE_VERSION.tar.gz -C /tmp && \
    ls -l /tmp && \
    (cd /tmp/deluge-$DELUGE_VERSION && ls -l && python setup.py build && python setup.py install --prefix=/usr) && \
    rm -rf /tmp/deluge-$DELUGE_VERSION.tar.gz /tmp/deluge-$DELUGE_VERSION && \
    apk del .build-dependencies

ENV LANG=C.UTF-8
