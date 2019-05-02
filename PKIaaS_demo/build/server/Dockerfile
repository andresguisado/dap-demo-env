FROM nginx

RUN    apt-get update -y  \
    && apt-get install -y \
	openssl \
	vim \
	jq \
	curl \
    && mkdir /conjur

ADD tls* /conjur/
RUN chmod 440 /conjur/tls*
ADD nginx.conf /etc/nginx/conf.d/server.conf
ADD index.html /
