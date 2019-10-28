FROM cyberark/demo-app:latest

RUN apk add --no-cache \
	bash curl vim \
	postgresql-client mysql-client \
	openssh python3 ansible

RUN curl -LO https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 \
  && chmod a+x jq-linux64 \
  && mv jq-linux64 /usr/local/bin/jq

RUN mv /etc/vim/vimrc /etc/vim/vimrc.bak

WORKDIR /

COPY ans_run.sh ansible.cfg ansible_hosts uid_entrypoint.sh test_db.sh /

# setup alt SSH known_hosts file cuz OpenShift 
RUN touch /known_hosts /inventory \
    && mkdir -p /.ansible/tmp \
    && chmod -R 777 /known_hosts /inventory /.ansible /ansible_hosts \
    && echo "UserKnownHostsFile /known_hosts" >> /etc/ssh/ssh_config

# setup entrypoint for default user
RUN chmod g=u /etc/passwd /*.sh
ENTRYPOINT [ "/uid_entrypoint.sh" ]
USER 1001
