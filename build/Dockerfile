FROM alpine:3.9

ENV DOCKERVERSION=18.03.1-ce
ENV MINISHIFT_VERSION=1.21.0
ENV OS_PLATFORM=linux

RUN apk add --no-cache bash \
                       jq \
                       wget \
			curl

COPY /usr/local/bin/vboxmanage /usr/local/bin

RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz \
  && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 \
                 -C /usr/local/bin docker/docker \
  && rm docker-${DOCKERVERSION}.tgz

RUN curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-$OS_PLATFORM-amd64 \
  && chmod +x minikube \
  && mv minikube /usr/local/bin \
  && curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.13.2/bin/linux/amd64/kubectl \
  && chmod +x kubectl \
  && mv kubectl /usr/local/bin/

RUN wget https://github.com/minishift/minishift/releases/download/v$MINISHIFT_VERSION/minishift-$MINISHIFT_VERSION-$OS_PLATFORM-amd64.tgz \
  && tar xvzf minishift-$MINISHIFT_VERSION-$OS_PLATFORM-amd64.tgz \
  && cd minishift-$MINISHIFT_VERSION-$OS_PLATFORM-amd64 \
    && chmod +x minishift \
    && mv minishift /usr/local/bin \
  && cd .. \
  && rm -rf minishift-$MINISHIFT_VERSION-$OS_PLATFORM-amd64*

WORKDIR /demo
