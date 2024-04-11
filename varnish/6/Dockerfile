FROM varnish:6.6

LABEL vendor="Artifakt" \
      author="djalal@artifakt.io" \
      stage="alpha"

COPY docker-varnish-entrypoint-init-conf.sh /usr/local/bin/docker-varnish-entrypoint
COPY default.vcl /etc/varnish/default.vcl
WORKDIR /etc/varnish/conf.d

