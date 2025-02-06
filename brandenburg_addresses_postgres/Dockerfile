FROM docker.io/postgis/postgis:16-3.5
LABEL maintainer="openstreetmap.org@knackich.de"

RUN echo "deb http://deb.debian.org/debian bullseye-backports main" > /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get -y install --no-install-recommends pgxnclient build-essential git cmake/bullseye-backports postgresql-server-dev-16 && \
    pgxn install h3 && \
    pgxn install kmeans && \
    apt-get -y remove pgxnclient build-essential git cmake/bullseye-backports postgresql-server-dev-16 && \
    apt-get autoremove -y && \
    apt-get clean
