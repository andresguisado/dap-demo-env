FROM ubuntu

# Install Java.
RUN \
  apt update -y && \
  apt upgrade -y && \
  apt install -y software-properties-common curl && \
  apt install -y openjdk-11-jdk && \
  apt update -y

RUN \
  mkdir -p /usr/local/lib/summon \
  && cd /usr/local/bin \
  && curl -sSL https://github.com/cyberark/summon/releases/download/v0.6.6/summon-linux-amd64.tar.gz \
      | tar xz \
  && cd /usr/local/lib/summon \
  && curl -sSL https://github.com/cyberark/summon-conjur/releases/download/v0.5.2/summon-conjur-linux-amd64.tar.gz \
      | tar xz

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-11-oracle

RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#ENTRYPOINT [ "summon", "-f", "/etc/secrets.yml" ]
