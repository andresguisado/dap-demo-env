FROM ubuntu:16.04

RUN apt-get update \
    && apt-get install -y \
	bash curl vim \
	python3 ansible \
	postgresql-client \
	mysql-client \
	openssh-client \
	apt-transport-https ca-certificates

RUN curl -LO https://packages.microsoft.com/keys/microsoft.asc \
    && apt-key add microsoft.asc \
    && rm microsoft.asc \
    && curl -LO https://packages.microsoft.com/config/ubuntu/16.04/prod.list \
    && mv prod.list /etc/apt/sources.list.d/msprod.list \
    && apt-get update \
    && env ACCEPT_EULA=Y apt-get install -y mssql-tools 

RUN curl -LO https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 \
  && chmod a+x jq-linux64 \
  && mv jq-linux64 /usr/local/bin/jq

RUN mv /etc/vim/vimrc /etc/vim/vimrc.bak

WORKDIR /

ADD ./pets /pets

COPY ans_run.sh ansible.cfg ansible_hosts uid_entrypoint.sh test_db.sh /

# setup alt SSH known_hosts file cuz OpenShift 
RUN touch /known_hosts /inventory \
    && mkdir -p /.ansible/tmp \
    && chmod -R 777 /known_hosts /inventory /.ansible /ansible_hosts \
    && echo "UserKnownHostsFile /known_hosts" >> /etc/ssh/ssh_config

# add path for sqlcmd
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /.bashrc

# setup entrypoint for default user
RUN chmod g=u /etc/passwd /*.sh
ENTRYPOINT [ "/uid_entrypoint.sh" ]
USER 1001
