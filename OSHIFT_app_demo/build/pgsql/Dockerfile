FROM postgres:9.6

RUN apt-get update && apt-get install -y curl vim

# set docker entrypoint 
RUN mkdir -p /docker-entrypoint-initdb.d

COPY rotate_password /usr/local/bin/
