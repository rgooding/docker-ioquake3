#!/bin/bash

set -e

# The Quake 3 server will listen on this UDP port
Q3_PORT=27960
# HTTP port to serve maps and mods
HTTP_PORT=27980
# The hostname as seen by clients. Used for downloading maps and mods over HTTP
WAN_HOSTNAME="example.com"
# Quake 3 server password
Q3_PASSWORD="mysecretpassword"



BASEDIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

IMG=ioq3ded

cd $BASEDIR
docker build -t $IMG .

docker run -it --rm --name ioquake3 \
  -v $BASEDIR/data/baseq3:/baseq3:ro \
  -v $BASEDIR/data/missionpack:/missionpack:ro \
  -v $BASEDIR/data/maps:/maps:ro \
  -v $BASEDIR/data/mods:/mods:ro \
  -p $Q3_PORT:$Q3_PORT/udp \
  -p $HTTP_PORT:$HTTP_PORT \
  -e Q3_PASSWORD="$Q3_PASSWORD" \
  -e Q3_PORT=$Q3_PORT \
  -e Q3_HTTP_PORT=$HTTP_PORT \
  -e Q3_DOWNLOAD_URL=http://$WAN_HOSTNAME:$HTTP_PORT/ \
  $IMG +set g_spskill 3 +set g_doWarmup 1 +exec deathmatch.cfg
