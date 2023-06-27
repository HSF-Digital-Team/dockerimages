FROM alpine:latest

RUN apk add --no-cache \
        bash \
        curl \
        wget \
        jq \
        openssl

COPY --from=jwilder/docker-gen:latest  /usr/local/bin/docker-gen /usr/local/bin/docker-gen

WORKDIR /app
ADD . /app

ENV DOCKER_HOST unix:///var/run/docker.sock
ENV NGINX_PROXY_CONTAINER proxy
ENV EXPIRATION 730

ENTRYPOINT [ "/bin/bash", "/app/entrypoint.sh" ]
CMD [ "/bin/bash", "/app/start.sh" ]
