#!/bin/bash

VER="1.6.0"
DESTDIR=/app/guacamole-client
mkdir -p $DESTDIR/{extensions,lib}

wget https://downloads.apache.org/guacamole/1.6.0/binary/guacamole-1.6.0.war -O $DESTDIR/guacamole-client-${VER}.war
chown -R guacamole:guacamole $DESTDIR


