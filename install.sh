#!/bin/bash


###状态码赋值给s
return_code=$?
function check(){
        ###调用函数
        ###函数名 参数1 参数2
        echo $1
        if [ "0" != "$return_code" ]; then
                echo "$1编译失败，请手动检查"
        fi
}
###check aria2

function shadowsocks-libev(){

	read -t 6 -p "请输入密码，直接回车则设置为默认密码: " passwd
	passwd=${passwd:-nPB4bF5K8+apre.}
	###echo "passwd=$passwd"
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
	cat >/etc/shadowsocks-libev/config.json<<-EOF
	{
	    "server":"0.0.0.0",
	    "server_port":443,
	    "local_port":1080,
	    "password":"$passwd",
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
	cat >/etc/systemd/system/ssl.service<<-EOF
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

	firewall-cmd --zone=public --add-port=443/udp --permanent
	firewall-cmd --zone=public --add-port=443/udp --permanent

	firewall-cmd --reload 


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
}

function transmission(){

	yum -y install gcc gcc-c++ make automake libtool gettext openssl-devel libevent-devel intltool libiconv curl-devel systemd-devel wget

	wget https://build.transmissionbt.com/job/trunk-linux/lastSuccessfulBuild/artifact/transmission-master-r44fc571a67.tar.xz
	tar xf transmission-master-r44fc571a67.tar.xz && cd transmission-3.00+

	./configure && make && make install

	##默认配置文件
	##vi /root/.config/transmission-daemon/settings.json

	##crate service
	cat >/etc/systemd/system/transmission-daemon.service<<-EOF
	[Unit]
	Description=Transmission BitTorrent Daemon
	After=network.target

	[Service]
	User=root
	Type=notify
	ExecStart=/usr/local/bin/transmission-daemon -f --log-error
	ExecReload=/bin/kill -s HUP \$MAINPID
	NoNewPrivileges=true

	[Install]
	WantedBy=multi-user.target
	EOF

	##首次启动，生成配置文件
	systemctl start transmission-daemon.service
	systemctl stop transmission-daemon.service

	##systemctl status transmission-daemon.service

	## change config
	sed -i '/rpc-whitelist-enabled/ s/true/false/' /root/.config/transmission-daemon/settings.json

	firewall-cmd --zone=public --add-port=51413/tcp --permanent
	firewall-cmd --zone=public --add-port=51413/udp --permanent
	firewall-cmd --zone=public --add-port=9091/tcp --permanent
	firewall-cmd --zone=public --add-port=9091/udp --permanent
	firewall-cmd --reload

	##替换webUI
	cd ~
	wget https://github.com/ronggang/transmission-web-control/archive/v1.6.0-beta2.tar.gz
	tar zxvf v1.6.0-beta2.tar.gz
	mv /usr/local/share/transmission/web /usr/local/share/transmission/web_backup
	mkdir /usr/local/share/transmission/web/
	cp -r /root/transmission-web-control-1.6.0-beta2/src/* /usr/local/share/transmission/web/

	systemctl start transmission-daemon.service
	systemctl enable transmission-daemon.service
}

function aria2(){

	yum install -y gcc-c++ bison libssh2-devel expat-devel gmp-devel nettle-devel libssh2-devel zlib-devel c-ares-devel gnutls-devel libgcrypt-devel libxml2-devel sqlite-devel gettext lzma-devel xz-devel gperftools gperftools-devel gperftools-libs jemalloc-devel trousers-devel

	git clone https://github.com/aria2/aria2.git && cd aria2

	##静态编译
	autoreconf -i && ./configure ARIA2_STATIC=yes
	make && make install

	cat >/etc/systemd/system/aria2.service<<-EOF
	[Unit]
	Description=aria2c
	After=network.target
	[Service]
	ExecStart=/usr/local/bin/aria2c --conf-path=/aria2.conf
	User=root
	[Install]
	WantedBy=multi-user.target
	EOF


	##aria2 config file

	cat >/aria2.conf<<-EOF
	    rpc-secret=crazy_0
	    enable-rpc=true
	    rpc-allow-origin-all=true
	    rpc-listen-all=true
	    max-concurrent-downloads=5
	    continue=true
	    max-connection-per-server=5
	    min-split-size=10M
	    split=16
	    max-overall-download-limit=0
	    max-download-limit=0
	    max-overall-upload-limit=0
	    max-upload-limit=0
	    dir=/web_home/downloads
	    file-allocation=prealloc
	EOF

	##安装nginx

	rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
	yum install nginx -y
	firewall-cmd --zone=public --add-port=80/tcp --permanent
	firewall-cmd --zone=public --add-port=80/udp --permanent
	firewall-cmd --zone=public --add-port=6800/tcp --permanent
	firewall-cmd --zone=public --add-port=6800/udp --permanent

	##webui
	cd ~
	git clone https://github.com/ziahamza/webui-aria2.git
	rm -fr /usr/share/nginx/html/*
	cp /root/webui-aria2/docs/* /usr/share/nginx/html/

	systemctl enable nginx
	systemctl start nginx
	systemctl enable aria2
	systemctl start aria2
}

function Up_kernel(){

	###导入elrepo密钥
	rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

	###安装elrepo仓库
	rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm

	###查询可用版本
	###yum --disablerepo="*" --enablerepo="elrepo-kernel" list available

	###安装内核
	yum --enablerepo=elrepo-kernel install kernel-ml -y

	###修改默认内核
	sed -i 's/saved/0/g' /etc/default/grub

	###重新创建内核配置
	grub2-mkconfig -o /boot/grub2/grub.cfg

	# TCP-BBR
	#net.core.default_qdisc=fq
	#net.ipv4.tcp_congestion_control=bbr

	cp /etc/sysctl.conf /etc/sysctl.conf.bak
	sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
	echo net.core.default_qdisc=fq >> /etc/sysctl.conf
	echo net.ipv4.tcp_congestion_control=bbr >> /etc/sysctl.conf

	###使修改的内核配置生效
	sysctl -p

	###查看tcp_bbr内核模块是否启动
	lsmod | grep bbr

	#Please reboot your VPS after run command "yum update -y"

	#ping 127.0.0.1 -c 5 >>null
	#reboot

	###引用：http://www.jianshu.com/p/726bd9f37220
	###引用：https://legolasng.github.io/2017/05/08/upgrade-centos-kernel/#3安装新版本内核
}

select option in "shadowsocks-libev" "transmission" "aria2" "Up_kernel"
do
	case $option in
		"shadowsocks-libev")
			shadowsocks-libev
			break;;
		"transmission")
			transmission
			break;;
		"aria2")
			aria2
			break;;
		"Up_kernel")
			Up_kernel
			break;;
		*)
			echo "nothink to do"
			break;;
	esac
done
