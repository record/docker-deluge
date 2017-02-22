#!/bin/sh

set -e

wait_port () {
    for i in 1 2 3 4 5
    do
        if nc -z 127.0.0.1 $1; then
            return 0
        fi

        sleep 1
    done

    (>&2 echo "port is not opened: $1")
    exit 1
}

wait_proc () {
    kill -TERM $1

    for i in 1 2 3 4 5
    do
        if ! ps | grep "$2" | grep $1 1>/dev/null; then
            return 0
        fi

        sleep 1
    done

    (>&2 echo "not stopped: $2")
    exit 1
}

mkdir -p /mnt/deluge/config
mkdir -p /mnt/deluge/data/completes/default
mkdir -p /mnt/deluge/data/downloads/default
mkdir -p /mnt/deluge/data/torrents

/usr/bin/deluged --config /mnt/deluge/config -d &
DELUGED_PID=$!
wait_port 58846

/usr/bin/deluge-console --config /mnt/deluge/config config --set allow_remote True
/usr/bin/deluge-console --config /mnt/deluge/config config --set download_location /mnt/deluge/data/downloads/default
/usr/bin/deluge-console --config /mnt/deluge/config config --set move_completed_path /mnt/deluge/data/completes/default
/usr/bin/deluge-console --config /mnt/deluge/config config --set move_completed True
/usr/bin/deluge-console --config /mnt/deluge/config config --set torrentfiles_location /mnt/deluge/data/torrents/default
/usr/bin/deluge-console --config /mnt/deluge/config config --set listen_ports '(41250, 41259)'
/usr/bin/deluge-console --config /mnt/deluge/config config --set stop_seed_at_ratio True
/usr/bin/deluge-console --config /mnt/deluge/config plugin --enable AutoAdd
/usr/bin/deluge-console --config /mnt/deluge/config plugin --enable Execute
/usr/bin/deluge-console --config /mnt/deluge/config plugin --enable Label

wait_proc $DELUGED_PID "deluged"
echo "deluge:deluge:10" >> /mnt/deluge/config/deluge/auth

/usr/bin/deluge-web --config /mnt/deluge/config &
wait_port 8112
wait_proc $! "deluge-web"

sed -i 's/"https"\([ ]*\):\([ ]*\)false\([ ]*\)/"https"\1:\2true\3/' /mnt/deluge/config/web.conf
