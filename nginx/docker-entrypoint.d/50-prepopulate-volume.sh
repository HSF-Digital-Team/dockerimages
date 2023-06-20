#!/bin/sh
SRC="/.artifakt"
DIR="/etc/nginx/conf.d"

# init
# look for empty dir
if [ -d "$DIR" ]
then
  if [ "$(ls -A $DIR)" ]; then
    echo "NOTICE: Configuration folder is not Empty:"
    ls -la $DIR
  else
    echo "$DIR is Empty, will init config"
    cp -rp $SRC/* $DIR
  fi
else
  echo "Configuration folder $DIR not found, will create and init config"
   mkdir -p $DIR
   cp -rp $SRC/* $DIR
fi

exit 0
