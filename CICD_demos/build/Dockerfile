FROM ubuntu:16.04

# install utilities & ansible
RUN apt-get update -y \
    && apt-get install -y \
    vim \
    ssh \
    curl \
    wget \
    unzip \
    ansible \
    python-pip

# install Ansible lookup plugin from local tarfile
COPY ansible-conjur-lookup-plugin.tar.gz /tmp
RUN  mkdir -p /etc/ansible/roles \
     && cd /etc/ansible/roles \
     && tar xvf /tmp/ansible-conjur-lookup-plugin.tar.gz -C . \
     && mv ansible-conjur-lookup-plugin-master cyberark.conjur-lookup-plugin

# install chef 
RUN cd /tmp \
    && curl -L https://www.opscode.com/chef/install.sh | bash \
    && mkdir /var/chef 

# install Summon and the Summon-conjur provider
RUN cd /tmp \
    && curl -LO https://github.com/cyberark/summon/releases/download/v0.6.7/summon-linux-amd64.tar.gz \
    && tar xzf summon-linux-amd64.tar.gz && mv summon /usr/local/bin/ \
    && rm summon-linux-amd64.tar.gz \
    && mkdir -p /usr/local/lib/summon \
    && curl -LO https://github.com/cyberark/summon-conjur/releases/download/v0.5.2/summon-conjur-linux-amd64.tar.gz \
    && tar xzf summon-conjur-linux-amd64.tar.gz && mv summon-conjur /usr/local/lib/summon/ \
    && rm summon-conjur-linux-amd64.tar.gz

# install terraform & terraform provider
RUN cd /tmp \
    && curl -O https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip \
    && unzip terraform_0.11.7_linux_amd64.zip \
    && mv terraform /usr/local/bin \
    && rm terraform*.zip \
    && wget https://github.com/cyberark/terraform-provider-conjur/releases/download/v0.2.0/terraform-provider-conjur-linux-amd64.tar.gz \
    && tar xvzf terraform-provider-conjur-linux-amd64.tar.gz \
    && rm terraform-provider-conjur-linux-amd64.tar.gz \
    && mkdir -p ~/.terraform.d/plugins \
    && mv terraform-provider-conjur ~/.terraform.d/plugins

# install concourse fly cli
RUN cd /tmp \
    && curl -LO https://github.com/concourse/fly/releases/download/v4.0.0-rc.93/fly_linux_amd64 \
    && mv /tmp/fly_linux_amd64 /usr/local/bin/fly \
    && chmod +x /usr/local/bin/fly

RUN echo "root:demo" | chpasswd		# set demo as root password

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /demo
