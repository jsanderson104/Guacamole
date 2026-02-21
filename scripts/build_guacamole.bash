#!/bin/bash

VER="1.6.0"
DLURL="https://downloads.apache.org/guacamole/${VER}/source/guacamole-server-${VER}.tar.gz"
DLDIR=/opt/src_downloads

mkdir -p $DLDIR 2>/dev/null ; cd $DLDIR && wget $DLURL
tar -C /opt/src -zxf guacamole-server-${VER}.tar.gz

cd /opt/src/guacamole-server-${VER}
./configure --prefix=/app/guacamole --sysconfdir=/app/guacamole/conf && make && make install 2>&1 |tee /opt/guacamole-compile.log

