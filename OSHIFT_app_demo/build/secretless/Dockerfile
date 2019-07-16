FROM cyberark/demo-app:latest

RUN apk update && apk add bash curl vim postgresql-client mysql-client openssh

RUN curl -LO https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 \
  && chmod a+x jq-linux64 \
  && mv jq-linux64 /usr/local/bin/jq

RUN mv /etc/vim/vimrc /etc/vim/vimrc.bak

WORKDIR /

# setup alt SSH known_hosts file cuz OpenShift 
RUN touch /known_hosts \
    && chmod 666 /known_hosts \
    && echo "UserKnownHostsFile /known_hosts" >> /etc/ssh/ssh_config

COPY test_db.sh /
COPY uid_entrypoint.sh /

# setup entrypoint for default user
RUN chmod g=u /etc/passwd /*.sh
ENTRYPOINT [ "/uid_entrypoint.sh" ]
USER 1001
