FROM cyberark/dap-seedfetcher:latest

ENV CONJUR_VERSION=5 \
    CONTAINER_MODE=init

COPY start-follower.sh /usr/bin/

RUN chmod +x /usr/bin/start-follower.sh

CMD ["get-seedfile.sh"]
