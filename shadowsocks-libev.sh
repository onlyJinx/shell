###搬瓦工默认禁用epel
#yum remove epel-release -y
#yum install epel-release -y

###yum install gcc gettext autoconf libtool automake make pcre-devel asciidoc xmlto c-ares-devel libev-devel libsodium-devel mbedtls-devel -y
yum install gcc gettext autoconf libtool automake make pcre-devel wget git vim asciidoc xmlto libev-devel -y
###手动编译libsodium-devel mbedtls-devel c-ares


###Installation of MbedTLS
wget https://tls.mbed.org/download/mbedtls-2.16.3-gpl.tgz
###wget https://tls.mbed.org/download/mbedtls-2.16.2-apache.tgz
tar xvf mbedtls*gpl.tgz
cd mbedtls*
make SHARED=1 CFLAGS=-fPIC
sudo make DESTDIR=/usr install
cd ~
sudo ldconfig

###Installation of Libsodium
#wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.13.tar.gz
#wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.17.tar.gz
wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.18.tar.gz
tar xvf libsodium-*.tar.gz
cd libsodium-*
./configure --prefix=/usr && make
sudo make install
sudo ldconfig
cd ~


###Installation of c-ares
git clone https://github.com/c-ares/c-ares.git
cd c-ares
./buildconf
autoconf configure.ac
./configure --prefix=/usr && make
sudo make install
sudo ldconfig
cd ~
###安装方法引用http://blog.sina.com.cn/s/blog_6c4a60110101342m.html

###Installation of simple-obfs

###obfs已弃用###
#git clone https://github.com/shadowsocks/simple-obfs.git
#cd simple-obfs
#git submodule update --init --recursive
#./autogen.sh
#./configure && make
#sudo make install


#wget https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.1.0/v2ray-plugin-linux-amd64-v1.1.0.tar.gz
#tar zxvf v2ray-plugin* && mv v2ray-plugin-linux-amd64 /etc/shadowsocks-libev/v2ray-plugin &&rm -f v2ray-plugin*


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
    "password":"nPB4bF5K8+apre.",
    "timeout":60,
    "method":"xchacha20-ietf-poly1305",
    "fast_open": true,
    "nameserver": "8.8.8.8",
    "plugin":"/etc/shadowsocks-libev/v2ray-plugin",
    "plugin_opts":"server",
    "mode": "tcp_and_udp"

}
EOF


###下载V2ray插件
wget https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.1.0/v2ray-plugin-linux-amd64-v1.1.0.tar.gz
tar zxvf v2ray-plugin* && mv v2ray-plugin_linux_amd64 /etc/shadowsocks-libev/v2ray-plugin &&rm -f v2ray-plugin*


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

###禁用ping###
###echo net.ipv4.icmp_echo_ignore_all=1>>/etc/sysctl.conf
###sysctl -p


###firewall oprt
sed -i '$d' /etc/firewalld/zones/public.xml
echo "  <port protocol=\"udp\" port=\"443\"/>" >> /etc/firewalld/zones/public.xml
echo "  <port protocol=\"tcp\" port=\"443\"/>" >> /etc/firewalld/zones/public.xml
echo "  <port protocol=\"udp\" port=\"28532\"/>" >> /etc/firewalld/zones/public.xml
echo "  <port protocol=\"tcp\" port=\"28532\"/>" >> /etc/firewalld/zones/public.xml
echo "</zone>" >> /etc/firewalld/zones/public.xml
firewall-cmd --reload > null

systemctl start ssl&&systemctl enable ssl
### remove the file
cd /root && rm -fr mbedtls* shadowsocks-libev libsodium* test.sh c-ares auto

clear
ss -lnp|grep 443
echo -e port:"          ""\e[31m\e[1m443\e[0m"
echo -e password:"      ""\e[31m\e[1mnPB4bF5K8+apre.\e[0m"
echo -e method:"        ""\e[31m\e[1mxchacha20-ietf-poly1305\e[0m"
echo -e plugin:"        ""\e[31m\e[1mv2ray-plugin\e[0m"
echo -e plugin_opts:"   ""\e[31m\e[1mhttp\e[0m"
echo -e config.json:"   ""\e[31m\e[1m/etc/shadowsocks-libev/config.json\n\n\e[0m"
echo -e use \""\e[31m\e[1msystemctl start ssl\e[0m"\" run the shadowsocks-libev in background
echo -e "\e[31m\e[1mhttps://github.com/shadowsocks\e[0m"




