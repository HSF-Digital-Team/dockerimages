#!/bin/sh

set -e

echo Link /data directory to /var/www/html
  mkdir -p /data && \
  mkdir -p /var/www && \
  ln -sfn /data /var/www/html && \
  chown -h nginx:nginx /var/www/html /data && \
  ls -la /var/www/html

exit 0
