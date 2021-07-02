FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
USER root:root

RUN apt update && apt install -y wget gnupg
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://ppa.launchpad.net/timescale/timescaledb-ppa/ubuntu focal main" > /etc/apt/sources.list.d/timescale.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 55EE6BF7698E3D58D72C0DD9ECB3980CC59E610B
RUN apt-get update && apt install -y timescaledb-2-postgresql-13
#RUN su -c "/usr/lib/postgresql/13/bin/pg_ctl initdb" postgres
RUN rm -rf /var/lib/postgresql/13/main/*; su -c "/usr/lib/postgresql/13/bin/pg_ctl initdb -D /var/lib/postgresql/13/main" postgres

# Allow remote connection to postgres
RUN echo "host all all 0.0.0.0/0 md5" >> /var/lib/postgresql/13/main/pg_hba.conf

# timescaledb-tune
RUN timescaledb-tune --quiet --yes -conf-path /var/lib/postgresql/13/main/postgresql.conf

# Set postgres to listen to all ip
RUN echo "listen_addresses='*'" >> /var/lib/postgresql/13/main/postgresql.conf

ENV POSTGRES_PASSWORD=1

EXPOSE 5432

#RUN su -c "/usr/lib/postgresql/13/bin/pg_ctl init -D /var/lib/postgresql/13/main" postgres
#CMD su -c "/usr/lib/postgresql/13/bin/pg_ctl start -D /var/lib/postgresql/13/main -l /var/lib/postgresql/13/main/pg_log" postgres
CMD su -c "/usr/lib/postgresql/13/bin/postgres -D /var/lib/postgresql/13/main" postgres
