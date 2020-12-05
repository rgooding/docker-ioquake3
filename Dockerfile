FROM debian:buster AS builder

RUN apt-get -y update && apt-get -y install wget build-essential git
RUN mkdir /build && cd /build && \
  wget https://raw.githubusercontent.com/ioquake/ioq3/master/misc/linux/server_compile.sh && \
  chmod 0755 server_compile.sh

WORKDIR /build
ENV COPYDIR /build
RUN echo "y" | /build/server_compile.sh


FROM debian:buster

# The UDP port to listen on
ENV Q3_PORT 27960
# The friendly name of the server
ENV Q3_SERVERNAME "ioquake3 Server"
# The port to listen on for HTTP connections (for downloading maps and mods)
ENV Q3_HTTP_PORT 80
# The base HTTP URL for clients to download maps and mods
ENV Q3_DOWNLOAD_URL ""
# The user to run as
ENV Q3_USER q3

RUN apt-get -y update && \
  apt-get -y install gosu nginx gettext-base && \
  apt-get -y clean

RUN useradd -m $Q3_USER

RUN mkdir /ioquake3
COPY --from=builder /build/baseq3 /ioquake3/baseq3
COPY --from=builder /build/missionpack /ioquake3/missionpack
COPY --from=builder /build/ioq3ded.x86_64 /ioquake3/ioq3ded.x86_64

COPY files/nginx.conf /etc/nginx/nginx.conf.tpl
COPY files/deathmatch.cfg.tpl /ioquake3/baseq3/deathmatch.cfg.tpl
COPY files/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
