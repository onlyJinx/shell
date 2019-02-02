cd ~
yum install -y gcc-c++ bison libssh2-devel expat-devel gmp-devel nettle-devel libssh2-devel zlib-devel c-ares-devel gnutls-devel libgcrypt-devel libxml2-devel sqlite-devel gettext lzma-devel xz-devel gperftools gperftools-devel gperftools-libs jemalloc-devel
wget https://github.com/aria2/aria2/releases/download/release-1.34.0/aria2-1.34.0.tar.gz
tar zxvf aria2*
cd aria2*
./configure
make&make install

mkdir /web_home
mkdir /web_home/downloads
mv aria2.conf /

cat >/etc/systemd/system/aria2.service<< EOF
[Unit]
Description=aria2c
After=network.target
[Service]
ExecStart=/usr/local/bin/aria2c --conf-path=/aria2.conf
User=root
[Install]
WantedBy=multi-user.target
EOF

systemctl start aria2
systemctl enable aria2
systemctl status aria2
##aria2c --conf-path=/aria2.conf


##  WEB UI
cd ~
git clone https://github.com/onlyJinx/auto.git
git clone https://github.com/ziahamza/webui-aria2.git
mv auto/this.jsp ~/webui-aria2/
mv auto/Unity.js ~/webui-aria2/
mv auto/pisi.css ~/webui-aria2/css/
cd webui-aria2
sed '15 i  <script src="Unity.js"></script>' -i index.html
cd css
mv style.css style.cs
cat style.cs pisi.css > style.css
rm -f style.cs
rm -f pisi.css
mv ~/webui-aria2/* /usr/local/tomcat/webapps/ROOT/







