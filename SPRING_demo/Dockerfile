FROM ubuntu

# Install Java.
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  apt-get update && \
  apt-get install -y software-properties-common && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get install -y oracle-java8-installer curl && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

RUN \
  mkdir -p /usr/local/lib/summon \
  && cd /usr/local/bin \
  && curl -sSL https://github.com/cyberark/summon/releases/download/v0.6.6/summon-linux-amd64.tar.gz \
      | tar xz \
  && cd /usr/local/lib/summon \
  && curl -sSL https://github.com/cyberark/summon-conjur/releases/download/v0.5.2/summon-conjur-linux-amd64.tar.gz \
      | tar xz

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#ENTRYPOINT [ "summon", "-f", "/etc/secrets.yml" ]
