#!/bin/bash

VER="1.6.0"
DLURL="https://downloads.apache.org/guacamole/${VER}/source/guacamole-server-${VER}.tar.gz"
DLDIR=/opt/src_downloads

mkdir -p $DLDIR 2>/dev/null ; cd $DLDIR && wget $DLURL
#mkdir -p $DLDIR 2>/dev/null ; cd $DLDIR
tar -C /opt/src -zxf guacamole-server-${VER}.tar.gz
# Remove FreeRDP3 libs on Ubuntu 24.04. Note: You cant use ubuntu26.04 image because the freerdp2-dev package is now freerdp3-dev for which Guacamole 1.6.0 does not support (beta)
apt remove -y libfreerdp-client3-3 libfreerdp-server3-3 libfreerdp-shadow3-3 libfreerdp3-3
apt install -y freerdp2-dev
cd /opt/src/guacamole-server-${VER}
./configure --prefix=/app/guacamole --sysconfdir=/app/guacamole/conf > /opt/config.log && make >> /opt/make.log && make install 2>&1 |tee /opt/guacamole-compile.log

