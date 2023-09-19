FROM varnish:7.3-alpine

ENV VARNISH_SIZE=1G

LABEL vendor="HSFDigital" \
      author="digital@henryschein.fr" \
      stage="alpha"

COPY docker-varnish-entrypoint-init-conf.sh /usr/local/bin/docker-varnish-entrypoint
COPY default.vcl /etc/varnish/default.vcl
WORKDIR /etc/varnish/conf.d

