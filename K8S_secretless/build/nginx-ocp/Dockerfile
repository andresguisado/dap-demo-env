FROM nginx

RUN    apt-get update -y  \
    && apt-get install -y \
	openssl \
	vim \
	jq \
	curl \
    && mkdir /conjur

###################
# From: https://torstenwalter.de/openshift/nginx/2017/08/04/nginx-on-openshift.html
# Fix file ownership, port and user directive for OCP
RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx
# users are not allowed to listen on priviliged ports
RUN sed -i.bak 's/listen\(.*\)80;/listen 8081;/' /etc/nginx/conf.d/default.conf
EXPOSE 8081
# comment user directive as master process is run as user in OpenShift anyhow
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
###################

ADD conjur.pem /conjur/conjur.pem
RUN chmod 440 /conjur/conjur.pem
ADD nginx.conf /etc/nginx/conf.d/default.conf
ADD .htpasswd /.htpasswd
ADD index.html /
