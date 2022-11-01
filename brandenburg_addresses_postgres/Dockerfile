FROM docker.io/postgis/postgis:14-3.3
LABEL maintainer="openstreetmap.org@knackich.de"

RUN echo "deb http://deb.debian.org/debian bullseye-backports main" > /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get -y install --no-install-recommends pgxnclient build-essential git cmake/bullseye-backports postgresql-server-dev-14 && \
    pgxn install h3 && \
    pgxn install kmeans && \
    apt-get -y remove pgxnclient build-essential git cmake/bullseye-backports postgresql-server-dev-14 && \
    apt-get autoremove -y && \
    apt-get clean
