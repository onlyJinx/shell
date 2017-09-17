###搬瓦工默认禁用epel
yum remove epel-release -y
yum install epel-release -y

###yum install gcc gettext autoconf libtool automake make pcre-devel asciidoc xmlto c-ares-devel libev-devel libsodium-devel mbedtls-devel -y
yum install gcc gettext autoconf libtool automake make pcre-devel wget git vim asciidoc xmlto c-ares-devel libev-devel -y
###手动编译libsodium-devel mbedtls-devel


###Installation of MbedTLS
wget https://tls.mbed.org/download/mbedtls-2.6.0-gpl.tgz
tar xvf mbedtls-2.6.0-gpl.tgz
cd mbedtls-2.6.0
make SHARED=1 CFLAGS=-fPIC
sudo make DESTDIR=/usr install
cd ~
sudo ldconfig

###Installation of Libsodium
wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.13.tar.gz
tar xvf libsodium-1.0.13.tar.gz
cd libsodium-1.0.13
./configure --prefix=/usr && make
sudo make install
sudo ldconfig
cd ~


###Installation of shadowsocks-libev
git clone https://github.com/shadowsocks/shadowsocks-libev.git
cd shadowsocks-libev
git submodule update --init --recursive
./autogen.sh && ./configure && make
sudo make install
mkdir /etc/shadowsocks-libev
###cp /root/shadowsocks-libev/debian/config.json /etc/shadowsocks-libev/config.json

###crate config.json
###"plugin_opts":"obfs=tls;failover=127.0.0.1:888"
cat >/etc/shadowsocks-libev/config.json<< EOF
{
    "server":"0.0.0.0",
    "server_port":443,
    "local_port":1080,
    "password":"12345m",
    "timeout":60,
    "method":"xchacha20-ietf-poly1305"
    "nameserver": "8.8.8.8",
    "mode": "tcp_and_udp",
    "plugin":"obfs-server",
    "plugin_opts":"obfs=tls"

}
EOF

###crate service
cat >/etc/systemd/system/ssl.service<< EOF
[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
ExecStart=/usr/local/bin/ss-server -c /etc/shadowsocks-libev/config.json
User=root

[Install]
WantedBy=multi-user.target
EOF

###Installation of simple-obfs

git clone https://github.com/shadowsocks/simple-obfs.git
cd simple-obfs
git submodule update --init --recursive
./autogen.sh
./configure && make
sudo make install


### remove the file
rm -fr mbedtls-2.6.0 shadowsocks-libev libsodium-1.0.13 simple-obfs test.sh


echo install successflu
echo port:443
echo password:12345m
echo method:xchacha20-ietf-poly1305
choo plugin:obfs-server
echo plugin_opts:obfs=tls
echo config.json:/etc/shadowsocks-libev/config.json
echo use "systemctl start ssl" run the shadowsocks-libev in background

echo https://github.com/shadowsocks




