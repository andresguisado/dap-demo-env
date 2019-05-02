# Ansible Tower Dockerfie
FROM ubuntu:16.04

LABEL maintainer mittell@gmail.com, reuben.stump@gmail.com, ybaltouski@gmail.com 

WORKDIR /opt

ENV ANSIBLE_TOWER_VER 3.3.1-1
ENV PG_DATA /var/lib/postgresql/9.6/main
ENV AWX_PROJECTS /var/lib/awx/projects

RUN apt-get update && apt-get install -y sudo

# Use python >= 2.7.9
RUN apt-get install -y software-properties-common \
	&& add-apt-repository ppa:deadsnakes/ppa \
	&& apt-get update
	
# Install libpython2.7; missing dependency in Tower setup
RUN apt-get install -y libpython2.7

# Install support for https apt sources
RUN apt-get install -y apt-transport-https ca-certificates

# create /var/log/tower
RUN mkdir -p /var/log/tower

# Download & extract Tower tarball
ADD http://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz
RUN tar xvf ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz \
    && rm -f ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz

WORKDIR /opt/ansible-tower-setup-${ANSIBLE_TOWER_VER}
ADD inventory inventory

# Tower setup
RUN ./setup.sh

# Docker entrypoint script
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# volumes and ports
VOLUME ["${PG_DATA}", "${AWX_PROJECTS}", "/certs",]
EXPOSE 443

CMD ["/docker-entrypoint.sh", "ansible-tower"]
