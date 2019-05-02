FROM ubuntu:16.04
MAINTAINER CyberArk
LABEL builder="authn-k8s-builder"

#---some useful tools for interactive usage---#
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl

#---install summon and summon-conjur---#
RUN curl -sSL https://raw.githubusercontent.com/cyberark/summon/master/install.sh \
      | env TMPDIR=$(mktemp -d) bash && \
    curl -sSL https://raw.githubusercontent.com/cyberark/summon-conjur/master/install.sh \
      | env TMPDIR=$(mktemp -d) bash
# as per https://github.com/cyberark/summon#linux
# and    https://github.com/cyberark/summon-conjur#install
ENV PATH="/usr/local/lib/summon:${PATH}"

# ============= MAIN CONTAINER ============== #

FROM cyberark/conjur-authn-k8s-client
MAINTAINER CyberArk

#---copy summon into image---#
COPY --from=authn-k8s-builder /usr/local/lib/summon /usr/local/lib/summon
COPY --from=authn-k8s-builder /usr/local/bin/summon /usr/local/bin/summon

#---copy secrets.yml into image---#
COPY secrets.yml /etc/secrets.yml
