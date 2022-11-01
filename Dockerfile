FROM docker.io/debian:testing
LABEL maintainer="openstreetmap.org@knackich.de"

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install --no-install-recommends moreutils unzip curl wget \
        osm2pgsql osmium-tool postgresql-client-14 gdal-bin pv && \
    apt-get clean
RUN wget "https://postgisftw.s3.amazonaws.com/pg_tileserv_latest_linux.zip" -O /tmp/pg_tileserv.zip && cd /usr/local/bin && unzip /tmp/pg_tileserv.zip && rm /tmp/pg_tileserv.zip

WORKDIR /app
ENTRYPOINT ["/bin/bash"]
