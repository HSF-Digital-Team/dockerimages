#!/bin/sh

set -e

DIR="/etc/varnish/conf.d"

# init
# look for empty dir
if [ "$(ls -A $DIR)" ]; then
  echo "NOTICE: Configuration folder is not Empty:"
else
  echo "$DIR is Empty, will init"
  OLDPWD=$PWD
  cd $DIR
  touch custom_backends.vcl &&\
    touch custom_start_rules.vcl &&\
    touch custom_vcl_recv.vcl &&\
    touch custom_vcl_hash.vcl &&\
    touch custom_process_graphql_headers.vcl &&\
    touch custom_vcl_backend_response.vcl &&\
    touch custom_vcl_deliver.vcl &&\
    touch custom_vcl_hit.vcl &&\
    touch custom_end_rules.vcl &&\
    touch acl_purge.vcl &&\
    touch vcl_init.vcl &&\
    touch acl_purge.vcl &&\
    touch backends.vcl
  cd $OLDPWD
fi

echo "NOTICE: configuration folder is now:"
ls -la $DIR

# this will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    set -- varnishd \
	    -F \
	    -f /etc/varnish/default.vcl \
	    -a http=:80,HTTP \
	    -a proxy=:8443,PROXY \
	    -p feature=+http2 \
            -p http_max_hdr=512 \
	    -p http_req_hdr_len=16384 \
     	    -p http_resp_hdr_len=16384 \
	    -p workspace_backend=2M \
 	    -p workspace_client=2M \
	    -s malloc,$VARNISH_SIZE \
	    "$@"
fi

exec "$@"
