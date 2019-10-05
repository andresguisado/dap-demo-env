FROM ubuntu:16.04

ENV JRE_VERSION 9.0.4

RUN apt-get update && \
    apt-get -y install curl vim wget

WORKDIR /

# Install Java runtime env
COPY jre-${JRE_VERSION}_linux-x64_bin.tar.gz / 
RUN  cd / && \
     tar xvf jre-${JRE_VERSION}_linux-x64_bin.tar.gz && \
     rm jre-${JRE_VERSION}_linux-x64_bin.tar.gz && \
     ln -s /jre-${JRE_VERSION}/bin/keytool /usr/local/bin/keytool && \
     ln -s /jre-${JRE_VERSION}/bin/java /usr/local/bin/java

# Install jq cuz json
RUN curl -LO https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 \
  && chmod a+x jq-linux64 \
  && mv jq-linux64 /usr/local/bin/jq

RUN mv /etc/vim/vimrc /etc/vim/vimrc.bak

# install Summon and the Summon-conjur provider
RUN curl -sSL https://raw.githubusercontent.com/cyberark/summon/master/install.sh \
      | env TMPDIR=$(mktemp -d) bash && \
    curl -sSL https://raw.githubusercontent.com/cyberark/summon-conjur/master/install.sh \
      | env TMPDIR=$(mktemp -d) bash

COPY conjur-dev.pem JavaDemo.jar 1_runJava.sh javademo.config /
