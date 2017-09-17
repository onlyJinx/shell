###搬瓦工默认禁用epel
yum remove epel-release -y
yum install epel-release -y

###yum install gcc gettext autoconf libtool automake make pcre-devel asciidoc xmlto c-ares-devel libev-devel libsodium-devel mbedtls-devel -y
yum install gcc gettext autoconf libtool automake make pcre-devel wget git vim asciidoc xmlto c-ares-devel libev-devel -y
###手动编译libsodium-devel mbedtls-devel

wget https://tls.mbed.org/download/mbedtls-2.6.0-gpl.tgz
tar xvf mbedtls-2.6.0-gpl.tgz
cd mbedtls-2.6.0
make SHARED=1 CFLAGS=-fPIC
sudo make DESTDIR=/usr install
popd
sudo ldconfig
