FROM varnish:7.4

LABEL vendor="HSFDigital" \
      author="digital@henryschein.fr" \
      stage="alpha"

COPY docker-varnish-entrypoint-init-conf.sh /usr/local/bin/docker-varnish-entrypoint
COPY default.vcl /etc/varnish/default.vcl
WORKDIR /etc/varnish/conf.d

