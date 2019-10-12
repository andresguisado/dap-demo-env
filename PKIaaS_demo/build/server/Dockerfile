FROM nginx

RUN    apt-get update -y  \
    && apt-get install -y \
	openssl \
	vim \
	jq \
	curl \
    && mkdir /conjur

ENV TZ=America/Chicago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD tls* /conjur/
RUN chmod 440 /conjur/tls*
ADD nginx.conf /etc/nginx/conf.d/server.conf
ADD index.html /
