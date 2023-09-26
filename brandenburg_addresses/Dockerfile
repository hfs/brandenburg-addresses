FROM docker.io/debian:testing AS tippecanoe-builder

RUN apt-get update \
  && apt-get -y install build-essential libsqlite3-dev zlib1g-dev wget

RUN mkdir -p /workdir/tippecanoe-src
WORKDIR /workdir
RUN wget "https://github.com/felt/tippecanoe/archive/refs/tags/2.32.1.tar.gz" -O tippecanoe.tar.gz
RUN tar -xf tippecanoe.tar.gz --strip-components=1 -C tippecanoe-src
WORKDIR /workdir/tippecanoe-src
# Should RUN make test, but that fails at the moment
RUN make
CMD make

# Using multistage build reduces the docker image size by a lot by only copying the needed binaries
FROM docker.io/debian:testing
LABEL maintainer="openstreetmap.org@knackich.de"

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install --no-install-recommends moreutils unzip curl wget \
        osm2pgsql osmium-tool postgresql-client-15 gdal-bin pv \
        libsqlite3-0 zlib1g && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY --from=tippecanoe-builder /workdir/tippecanoe-src/tippecanoe* /usr/local/bin/
COPY --from=tippecanoe-builder /workdir/tippecanoe-src/tile-join /usr/local/bin/

WORKDIR /app
ENTRYPOINT ["/bin/bash"]
