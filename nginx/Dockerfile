FROM nginx:1.26-alpine

LABEL vendor="Artifakt" \
      author="djalal@artifakt.io" \
      stage="alpha" \
      stack="v5"

# Customization of the nginx user and group ids in the image. It's 101:101 in
# the base image. Here we use 33 which is the user id and group id for www-data
# on Ubuntu, Debian, etc.
ARG nginx_uid=33
ARG nginx_gid=33

# The worker processes in the nginx image run as the user nginx with group
# nginx. This is where we override their respective uid and guid to something
# else that lines up better with file permissions.
# The -o switch allows reusing an existing user id
RUN apk add shadow && usermod -u $nginx_uid -o nginx && groupmod -g $nginx_gid -o nginx

# flush conf folder
RUN rm -rf /etc/nginx/conf.d/*

COPY /docker-entrypoint.d/*.sh /docker-entrypoint.d/

COPY /conf.d/*.conf /.artifakt/
