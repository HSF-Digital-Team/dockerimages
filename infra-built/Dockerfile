FROM nginx:alpine
RUN apk add --no-cache libcurl=7.79.1-r0 curl=7.79.1-r0
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY . /usr/share/nginx/html
