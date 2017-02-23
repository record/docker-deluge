#!/bin/sh

set -e

./deluge.setup.sh
exec /usr/bin/supervisord -n
