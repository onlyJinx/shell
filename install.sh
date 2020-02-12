#!/bin/bash
##ss -lnp|grep :$port|awk -F "pid=" '{print $2}'|sed s/,.*//xargs kill -9
function check(){
	###状态码赋值给s
	#return_code=$?
	###调用函数
	###函数名 参数1 参数2
	if [ "0" != "$?" ]; then
		echo "$1编译失败，请手动检查"
		exit 0
	fi
}

##selinux开放读写
##setsebool -P samba_export_all_ro=1
##setsebool -P samba_export_all_rw=1
##selinux开放端口
##semanage port -a -t smbd_port_t  -p tcp 4555(自定义端口)
##自定义端口：在[global]添加 smb ports = 端口号；

function check_port(){

	while [[ true ]]; do

		read -p "请输入监听端口(默认$1):" port
		port=${port:-$1}
		myport=$(ss -lnp|grep :$port)
		if [ -n "$myport" ];then
			echo "端口$port已被占用,输入 y 关闭占用进程,输入 n 退出程序直接回车更换其他端口"
			read sel
			if [ "$sel" == "y" ] || [ "$sel" == "Y" ]; then
				##关闭进程
				ss -lnp|grep :$port|awk -F "pid=" '{print $2}'|sed 's/,.*//'|xargs kill -9
				if ! [ -n "$(ss -lnp|grep :$port)" ]; then
					echo "已终止占用端口进程"
					break
				else
					echo "进程关闭失败,请手动关闭"
					exit 1
				fi
			elif [ "$sel" == "n" ] || [ "$sel" == "N" ]; then
				echo "已取消操作"
				exit 0
			else
				clear
			fi
		else
			break
		fi
	done

}

function check_version(){
	if [ -x "$(command -v $1)" ]; then
		echo "$2已安装，是否继续覆盖安装？(Y/N)"
		read -t 30 -p "" sel
		if [ "$sel" == "y" ] || [ "$sel" == "Y" ];then
			echo "继续执行安装"
		else
			echo "已取消安装"
			exit 0
		fi
	fi
}

function check_fin(){
	if [ -x "$(command -v $1)" ]; then
		echo "编译安装完成"
	else
		echo "编译失败，请手动检查！！"
		exit 1
	fi
}

function download_dir(){

	#函数 提示语 默认路劲
	read -p "$1" dir
	dir=${dir:-$2}
	 if [ ! -d $dir ]; then
	 	echo "文件夹不存在，已创建文件夹 $dir"
	 	mkdir $dir
	 fi
}

function check_directory_exist(){
	##a_dir=$1
	if [[ -d $1 ]]; then
		echo 文件夹 $1 存在，是否删除\(y/n\)?
		read sel
		if [ "$sel" == "y" ] || [ "$sel" == "Y" ]; then
			rm -fr $1
			if [[ "$?"=="0" ]]; then
				echo 文件夹 $1 已删除
			else
				echo 文件夹 $1 删除失败，请手动删除！
				exit 0
			fi
		else
			mv $1 $1_$(date +%T)
			echo 已将目录 $1 移动至 $1_$(date +%T)
		fi
	fi
}

function shadowsocks-libev(){

	check_directory_exist /root/shadowsocks-libev
	check_version ss-server shadowsocks
	read -t 60 -p "请输入密码，直接回车则设置为默认密码: nPB4bF5K8+apre." passwd
	passwd=${passwd:-nPB4bF5K8+apre.}

	check_port 443

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
	check "shadowsocks依赖MbedTLS"
	cd ~
	sudo ldconfig

	###Installation of Libsodium
	## wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.18.tar.gz
	## wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz
	## tar xvf LATEST.tar.gz
	## cd libsodium-stable
	## ./configure --prefix=/usr && make
	## sudo make install
	## check "shadowsocks依赖Libsodium"
	## sudo ldconfig
	## cd ~

	git clone https://github.com/jedisct1/libsodium.git
	cd libsodium
	./autogen.sh && ./configure --prefix=/usr
	make && make install
	check "shadowsocks依赖Libsodium"
	sudo ldconfig
	cd ~


	###Installation of c-ares
	git clone https://github.com/c-ares/c-ares.git
	cd c-ares
	./buildconf
	autoconf configure.ac
	./configure --prefix=/usr && make
	sudo make install
	check "shadowsocks依赖c-ares"
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

	###报错 undefined reference to `ares_set_servers_ports_csv'，指定libsodium configure路径
	###Installation of shadowsocks-libev
	git clone https://github.com/shadowsocks/shadowsocks-libev.git
	cd shadowsocks-libev
	git submodule update --init --recursive
	./autogen.sh && ./configure --with-sodium-include=/usr/include --with-sodium-lib=/usr/lib
	##检查编译返回的状态码
	check "ShadowSocks-libev"
	make && make install

	###尝试运行程序
	check_fin "ss-server"
	mkdir /etc/shadowsocks-libev
	###cp /root/shadowsocks-libev/debian/config.json /etc/shadowsocks-libev/config.json

	###crate config.json
	###"plugin_opts":"obfs=tls;failover=127.0.0.1:888"
	cat >/etc/shadowsocks-libev/config.json<<-EOF
	{
	    "server":"0.0.0.0",
	    "server_port":$port,
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

	firewall-cmd --zone=public --add-port=$port/tcp --permanent
	firewall-cmd --zone=public --add-port=$port/udp --permanent

	firewall-cmd --reload 


	systemctl start ssl&&systemctl enable ssl
	### remove the file
	cd /root && rm -fr mbedtls* shadowsocks-libev libsodium LATEST.tar.gz c-ares

	clear
	###ss -lnp|grep 443
	echo -e port:"          ""\e[31m\e[1m$port\e[0m"
	echo -e password:"      ""\e[31m\e[1m$passwd\e[0m"
	echo -e method:"        ""\e[31m\e[1mxchacha20-ietf-poly1305\e[0m"
	echo -e plugin:"        ""\e[31m\e[1mv2ray-plugin\e[0m"
	echo -e plugin_opts:"   ""\e[31m\e[1mhttp\e[0m"
	echo -e config.json:"   ""\e[31m\e[1m/etc/shadowsocks-libev/config.json\n\n\e[0m"
	echo -e use \""\e[31m\e[1msystemctl status ssl\e[0m"\" run the shadowsocks-libev in background
	echo -e "\e[31m\e[1mhttps://github.com/shadowsocks\e[0m"
}

function transmission(){

	check_directory_exist transmission-3.00+
	check_version transmission-daemon transmission
	clear
	check_port 9091
	clear
	read -p "请输入用户名，直接回车则设置为默认用户 transmission:  " uname
	uname=${uname:-transmission}
	clear
	read -p "请输入密码，直接回车则设置为默认密码 transmission2020:  " passwd
	passwd=${passwd:-transmission2020}
	clear
	download_dir "输入下载文件保存路径(默认/usr/downloads): " "/usr/downloads"
	check
	config_path="/root/.config/transmission-daemon/settings.json"
	yum -y install gcc gcc-c++ make automake libtool gettext openssl-devel libevent-devel intltool libiconv curl-devel systemd-devel wget

	wget https://build.transmissionbt.com/job/trunk-linux/lastSuccessfulBuild/artifact/transmission-master-r44fc571a67.tar.xz
	tar xf transmission-master-r44fc571a67.tar.xz && cd transmission-3.00+

	./configure && make && make install
	###检查返回状态码
	check transmission
	###尝试运行程序
	check_fin "transmission-daemon"
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

	## change config  sed引用 https://segmentfault.com/a/1190000020613397
	
	sed -i '/rpc-whitelist-enabled/ s/true/false/' $config_path
	sed -i '/rpc-host-whitelist-enabled/ s/true/false/' $config_path
	sed -i '/rpc-authentication-required/ s/false/true/' $config_path
	##取消未完成文件自动添加 .part后缀
	sed -i '/rename-partial-files/ s/true/false/' $config_path
	##单引号里特殊符号都不起作用$ or /\，使用双引号替代单引号
	##sed -i "/rpc-username/ s/\"\"/\"$uname\"/" $config_path
	sed -i "/rpc-username/ s/: \".*/: \"$uname\",/" $config_path
	sed -i "/rpc-port/ s/9091/$port/" $config_path
	##sed分隔符/和路径分隔符混淆，用:代替/
	sed -i ":download-dir: s:\/root\/Downloads:$dir:" $config_path
	sed -i "/rpc-password/ s/\"{.*/\"$passwd\",/" $config_path
	##开启限速
	sed -i "/speed-limit-up-enabled/ s/false/true/" $config_path
	##限速1M/s
	sed -i "/\"speed-limit-up\"/ s/:.*/: 1024,/" $config_path
	##limit rate
	sed -i "/ratio-limit-enabled/ s/false/true/" $config_path
	sed -i "/\"ratio-limit\"/ s/:.*/: 2,/" $config_path

	firewall-cmd --zone=public --add-port=51413/tcp --permanent
	firewall-cmd --zone=public --add-port=51413/udp --permanent
	firewall-cmd --zone=public --add-port=$port/tcp --permanent
	firewall-cmd --zone=public --add-port=$port/udp --permanent
	firewall-cmd --reload

	##替换webUI
	cd ~
	wget https://github.com/ronggang/transmission-web-control/archive/v1.6.0-beta2.tar.gz
	tar zxvf v1.6.0-beta2.tar.gz
	mv /usr/local/share/transmission/web/index.html /usr/local/share/transmission/web/index.original.html
	cp -r /root/transmission-web-control-1.6.0-beta2/src/* /usr/local/share/transmission/web/

	systemctl start transmission-daemon.service
	systemctl enable transmission-daemon.service

	clear

	echo -e port:"          ""\e[31m\e[1m$port\e[0m"
	echo -e password:"      ""\e[31m\e[1m$passwd\e[0m"
	echo -e username:"      ""\e[31m\e[1m$uname\e[0m"
	echo -e download_dir:"      ""\e[31m\e[1m$dir\e[0m"
	echo -e config.json:"   ""\e[31m\e[1m/root/.config/transmission-daemon/settings.json\n\n\e[0m"
}

function samba(){

	yum install samba -y
	cp /etc/samba/smb.conf  /etc/samba/smb.conf_b
	clear
	read -p "输入共享路径(默认/usr/downloads)" upath
	upath=${upath:-/usr/downloads}

	if [ ! -d $upath ]; then
	 	##echo "文件夹不存在，已创建文件夹 $upath"
	 	mkdir $upath
	fi
	clear
	echo "设置smb管理员(root)密码"
	smbpasswd -a root

	##sed -i '/SELINUX/ s/disabled/enforcing/' /etc/selinux/config
	##setroubleshoot
	##sestatus -v 
	##sealert -a /var/log/audit/audit.log > /root/t.txt
	##echo ""> /var/log/audit/audit.log

	firewall-cmd --zone=public --add-service=samba --permanent
	firewall-cmd --reload 

	clear

	echo "loading..."
	setsebool -P samba_load_libgfapi 1
	/sbin/restorecon -R -v /etc/samba/smb.conf
	ausearch -c 'smbd' --raw | audit2allow -M my-smbd
	setsebool -P samba_portmapper 1
	setsebool -P nis_enabled 1
	setsebool -P samba_export_all_rw 1
	setsebool -P samba_export_all_ro 1

	cat >/etc/samba/smb.conf<<-EOF
	[global]
	     	workgroup = SAMBA
	        security = user
	        passdb backend = tdbsam
	        #smb ports = 445
	        printing = cups
	        printcap name = cups
	        load printers = yes
	        cups options = raw
	[share]
	        # 共享文件目录描述
	        comment = Shared Directories
	        # 共享文件目录
	        path = $upath
	        # 是否允许guest访问
	        public = no
	        # 指定管理用户
	        #admin users = admin
	        # 可访问的用户组、用户
	        #valid users = @admin
	        # 是否浏览权限
	        browseable = yes
	        # 是否可写权限
	        writable = yes
	        # 文件权限设置
	        create mask = 0777
	        directory mask = 0777
	        force directory mode = 0777
	        force create mode = 0777
	EOF

	systemctl restart smb nmb
	systemctl enable smb
	clear
	systemctl status smb

}

function aria2(){

	check_directory_exist aria2
	check_version aria2c aria2
	clear
	download_dir "输入下载文件保存路径(默认/usr/downloads): " "/usr/downloads"
	clear
	read -p "输入密码(默认密码crazy_0)： " key
	key=${key:-crazy_0}

	yum install -y gcc-c++ make libtool automake bison autoconf git intltool libssh2-devel expat-devel gmp-devel nettle-devel libssh2-devel zlib-devel c-ares-devel gnutls-devel libgcrypt-devel libxml2-devel sqlite-devel gettext xz-devel gperftools gperftools-devel gperftools-libs trousers-devel

	git clone https://github.com/aria2/aria2.git && cd aria2

	##静态编译
	##autoreconf -i && ./configure ARIA2_STATIC=yes
	
	autoreconf -i && ./configure
	make && make install

	###相关编译报错引用https://weair.xyz/build-aria2/
	check aria2
	###尝试运行程序
	clear
	check_fin "aria2c"
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
	    rpc-secret=$key
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
	    dir=$dir
	    file-allocation=prealloc
	EOF

	##安装nginx
	#SElinux原因不再用nginx，用httpd替代
	#rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
	#yum install nginx -y
	##selinux 设置
	#ausearch -c 'nginx' --raw | audit2allow -M my-nginx
	#semodule -i my-nginx.pp


	systemctl enable aria2
	systemctl start aria2

	firewall-cmd --zone=public --add-port=6800/tcp --permanent
	firewall-cmd --zone=public --add-port=6800/udp --permanent
	firewall-cmd --reload 
	clear

	while [[ true ]]; do
		echo "是否安装webUI (y/n)?"
		read ins
		if [ "$ins" == "y" ] || [ "$ins" == "Y" ];then
			httpd
			clear
			echo -e port:"          ""\e[31m\e[1m$port\e[0m"
			break
		elif [ "$ins" == "n" ] || [ "$ins" == "N" ];then
			clear
			break
		fi
	done

	echo -e token:"      ""\e[31m\e[1m$key\e[0m"
	echo -e download_dir:"      ""\e[31m\e[1m$dir\e[0m"
	echo -e config.json:"   ""\e[31m\e[1m/aria2.conf\n\n\e[0m"

}

function httpd(){

	##if判断参考https://www.cnblogs.com/include/archive/2011/12/09/2307905.html
	count=0
	while(1>0)
	do
	read -p "输入一个大于1024的端口(第$count次)  " port
	let count++
	port=${port:-80}
	if [ "$port" -gt "1024" ];then
		if [ -n "$(ss -lnp|grep :$port)" ];then
			clear
			echo "端口$port已被占用，请输入其他端口"
		else
			break
		fi

	elif [ "$port" -eq "80" ] || [ "$port" -eq "443" ];then
		if [ -n "$(ss -lnp|grep :$port)" ];then
			clear
			echo "端口$port已被占用，请输入其他端口"
		else
			break
		fi
	fi

	if [ $count -gt 10 ]; then
		clear
		echo "滚"
		break
	fi
	done

	yum install httpd -y
	sed -i "/^Listen/ s/[0-9].*/$port/" /etc/httpd/conf/httpd.conf
	firewall-cmd --zone=public --add-port=$port/tcp --permanent
	firewall-cmd --zone=public --add-port=$port/udp --permanent
	firewall-cmd --reload
	clear

	##webui
	cd ~
	git clone https://github.com/ziahamza/webui-aria2.git
	#rm -fr /usr/share/nginx/html/*
	mv /var/www/html /var/www/html_b
	mkdir /var/www/html/
	cp -r /root/webui-aria2/docs/* /var/www/html/
	##config file
	##vi /etc/nginx/conf.d/default.conf
	#sed -i "/listen/ s/80/$port/" /etc/nginx/conf.d/default.conf

	systemctl enable httpd
	systemctl start httpd

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

function ngrok(){
	

	read -p "输入域名:(包含www)  " domain

	clear
	echo "http监听端口"
	check_port 80
	http_port=$port
	echo "http监听端口为 $http_port"

	clear
	echo "https监听端口"
	check_port 443
	https_port=$port
	echo "https监听端口为 $https_port"
		
	check_directory_exist /root/ngrok
	git clone https://github.com/inconshreveable/ngrok.git

	yum install -y epel-release
	yum install -y mercurial git bzr subversion wget golang

	#####手动编译GO环境
	##wget https://dl.google.com/go/go1.11.5.linux-amd64.tar.gz
	#tar zxvf go*linux-amd64.tar.gz -C /usr/local
	#mkdir $HOME/go
	#echo 'export GOROOT=/usr/local/go'>> ~/.bashrc
	#echo 'export GOPATH=$HOME/go'>> ~/.bashrc
	#echo 'export PATH=$PATH:$GOROOT/bin'>> ~/.bashrc
	#source $HOME/.bashrc
	########END

	export NGROK_DOMAIN="$domain"

	openssl genrsa -out rootCA.key 2048
	openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$NGROK_DOMAIN" -days 5000 -out rootCA.pem
	openssl genrsa -out device.key 2048
	openssl req -new -key device.key -subj "/CN=$NGROK_DOMAIN" -out device.csr
	openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 5000

	##激活cp强制覆盖
	echo "unalias cp">>  ~/.bash_profile
	. ~/.bash_profile
	cp -f /root/rootCA.pem /root/ngrok/assets/client/tls/ngrokroot.crt
	cp -f /root/device.crt /root/ngrok/assets/server/tls/snakeoil.crt
	cp -f /root/device.key /root/ngrok/assets/server/tls/snakeoil.key

	##GO环境变量
	cd /usr/lib/golang/src/
	GOOS=windows GOARCH=amd64 CGO_ENABLED=0 ./make.bash

	#编译服务端&客户端
	cd ~/ngrok
	GOOS=linux GOARCH=amd64 make release-server&&GOOS=windows GOARCH=amd64 make release-client

	if ! [ -x "/root/ngrok/bin/ngrokd" ]; then
		echo "编译失败，请手动检查！！！"
		exit 1
	fi

	cp /root/ngrok/bin/ngrokd /usr/local/bin/ngrokd
	cp /root/ngrok/bin/windows_amd64/ngrok.exe /tmp/

	firewall-cmd --zone=public --add-port=$https_port/tcp --permanent
	firewall-cmd --zone=public --add-port=$https_port/udp --permanent
	firewall-cmd --zone=public --add-port=$http_port/tcp --permanent
	firewall-cmd --zone=public --add-port=$http_port/udp --permanent
	firewall-cmd --zone=public --add-port=4443/tcp --permanent
	firewall-cmd --zone=public --add-port=4443/udp --permanent
	firewall-cmd --reload

	###后台脚本

	#echo "/usr/local/bin/ngrokd -domain=\"${NGROK_DOMAIN:4}\" -httpAddr=\":$http_port\"  -httpsAddr=\":$https_port\"" > /usr/local/bin/start.sh
	############################写入service时-domain及-httpAddr里的数值不加引号，直接在command运行才加引号！！！
	###开机服务
	cat >/etc/systemd/system/ngrok.service<<-EOF
	[Unit]
	Description=Ngrok Server
	After=network.target
	[Service]
	ExecStart=/usr/local/bin/ngrokd -domain=${NGROK_DOMAIN:4} -httpAddr=:$http_port  -httpsAddr=:$https_port
	User=root
	[Install]
	WantedBy=multi-user.target
	EOF
	systemctl start ngrok
	systemctl enable ngrok
	systemctl status ngrok

	clear
	echo "按任意键清理残留文件...(ctrl+C取消)"
	read -t 30
	cd ~
	rm -fr device.crt  device.csr  device.key  ngrok  rootCA.key  rootCA.pem  rootCA.srl

	##./ngrokd -domain="ngrok.ruor.club" -httpAddr=":80" -httpsAddr=":890"
	##scp root@www.iruohui.top:/tmp/ngrok.exe c:\temp
}




#
#           File Browser Installer Script
#
#   GitHub: https://github.com/filebrowser/filebrowser
#   Issues: https://github.com/filebrowser/filebrowser/issues
#   Requires: bash, mv, rm, tr, type, grep, sed, curl/wget, tar (or unzip on OSX and Windows)
#
#   This script installs File Browser to your path.
#   Usage:
#
#   	$ curl -fsSL https://filebrowser.xyz/get.sh | bash
#   	  or
#   	$ wget -qO- https://filebrowser.xyz/get.sh | bash
#
#   In automated environments, you may want to run as root.
#   If using curl, we recommend using the -fsSL flags.
#
#   This should work on Mac, Linux, and BSD systems, and
#   hopefully Windows with Cygwin. Please open an issue if
#   you notice any bugs.
#


function filemanager(){

	check_port 8080
	download_dir "输入默认路径，默认/usr/downloads" "/usr/downloads"
	read -p "请输入用户名(默认root)" uname
	uname=${uname:-root}
	read -p "请输入密码(默认daiwei96)" pword
	pword=${pword:-daiwei96}

	yum install -y wget
	wget https://github.com/filebrowser/filebrowser/releases/download/v2.1.0/linux-amd64-filebrowser.tar.gz
	mkdir /etc/filemanager
	tar zxf linux-amd64-filebrowser.tar.gz -C /etc/filemanager
	install_filemanager()
	{
		trap 'echo -e "Aborted, error $? in command: $BASH_COMMAND"; trap ERR; return 1' ERR
		filemanager_os="unsupported"
		filemanager_arch="unknown"
		install_path="/usr/local/bin"

		# Termux on Android has $PREFIX set which already ends with /usr
		if [[ -n "$ANDROID_ROOT" && -n "$PREFIX" ]]; then
			install_path="$PREFIX/bin"
		fi

		# Fall back to /usr/bin if necessary
		if [[ ! -d $install_path ]]; then
			install_path="/usr/bin"
		fi

		# Not every platform has or needs sudo (https://termux.com/linux.html)
		((EUID)) && [[ -z "$ANDROID_ROOT" ]] && sudo_cmd="sudo"

		#########################
		# Which OS and version? #
		#########################

		filemanager_bin="filebrowser"
		filemanager_dl_ext=".tar.gz"

		# NOTE: `uname -m` is more accurate and universal than `arch`
		# See https://en.wikipedia.org/wiki/Uname
		unamem="$(uname -m)"
		case $unamem in
		*aarch64*)
			filemanager_arch="arm64";;
		*64*)
			filemanager_arch="amd64";;
		*86*)
			filemanager_arch="386";;
		*armv5*)
			filemanager_arch="armv5";;
		*armv6*)
			filemanager_arch="armv6";;
		*armv7*)
			filemanager_arch="armv7";;
		*)
			echo "Aborted, unsupported or unknown architecture: $unamem"
			return 2
			;;
		esac

		unameu="$(tr '[:lower:]' '[:upper:]' <<<$(uname))"
		if [[ $unameu == *DARWIN* ]]; then
			filemanager_os="darwin"
		elif [[ $unameu == *LINUX* ]]; then
			filemanager_os="linux"
		elif [[ $unameu == *FREEBSD* ]]; then
			filemanager_os="freebsd"
		elif [[ $unameu == *NETBSD* ]]; then
			filemanager_os="netbsd"
		elif [[ $unameu == *OPENBSD* ]]; then
			filemanager_os="openbsd"
		elif [[ $unameu == *WIN* || $unameu == MSYS* ]]; then
			# Should catch cygwin
			sudo_cmd=""
			filemanager_os="windows"
			filemanager_bin="filebrowser.exe"
			filemanager_dl_ext=".zip"
		else
			echo "Aborted, unsupported or unknown OS: $uname"
			return 6
		fi

		########################
		# Download and extract #
		########################

		echo "Downloading File Browser for $filemanager_os/$filemanager_arch..."
		filemanager_file="${filemanager_os}-$filemanager_arch-filebrowser$filemanager_dl_ext"
		filemanager_tag="$(curl -s https://api.github.com/repos/filebrowser/filebrowser/releases/latest | grep -o '"tag_name": ".*"' | sed 's/"//g' | sed 's/tag_name: //g')"
		filemanager_url="https://github.com/filebrowser/filebrowser/releases/download/$filemanager_tag/$filemanager_file"
		echo "$filemanager_url"

		# Use $PREFIX for compatibility with Termux on Android
		rm -rf "$PREFIX/tmp/$filemanager_file"

		if type -p curl >/dev/null 2>&1; then
			curl -fsSL "$filemanager_url" -o "$PREFIX/tmp/$filemanager_file"
		elif type -p wget >/dev/null 2>&1; then
			wget --quiet "$filemanager_url" -O "$PREFIX/tmp/$filemanager_file"
		else
			echo "Aborted, could not find curl or wget"
			return 7
		fi

		echo "Extracting..."
		case "$filemanager_file" in
			*.zip)    unzip -o "$PREFIX/tmp/$filemanager_file" "$filemanager_bin" -d "$PREFIX/tmp/" ;;
			*.tar.gz) tar -xzf "$PREFIX/tmp/$filemanager_file" -C "$PREFIX/tmp/" "$filemanager_bin" ;;
		esac
		chmod +x "$PREFIX/tmp/$filemanager_bin"

		echo "Putting filemanager in $install_path (may require password)"
		$sudo_cmd mv "$PREFIX/tmp/$filemanager_bin" "$install_path/$filemanager_bin"
		if setcap_cmd=$(PATH+=$PATH:/sbin type -p setcap); then
			$sudo_cmd $setcap_cmd cap_net_bind_service=+ep "$install_path/$filemanager_bin"
		fi
		$sudo_cmd rm -- "$PREFIX/tmp/$filemanager_file"

		if type -p $filemanager_bin >/dev/null 2>&1; then
			echo "Successfully installed"
			trap ERR
			return 0
		else
			echo "Something went wrong, File Browser is not in your path"
			trap ERR
			return 1
		fi
	}

	#不再使用官方脚本，直接在github下载二进制文件
	#install_filemanager

	#创建配置数据库
	/etc/filemanager/filebrowser -d /etc/filemanager/filebrowser.db config init
	#设置监听地址
	/etc/filemanager/filebrowser -d /etc/filemanager/filebrowser.db config set --address 0.0.0.0
	#设置监听端口
	/etc/filemanager/filebrowser -d /etc/filemanager/filebrowser.db config set --port $port
	#设置日志位置
	/etc/filemanager/filebrowser -d /etc/filemanager/filebrowser.db config set --log /var/log/filebrowser.log
	#添加一个用户
	/etc/filemanager/filebrowser -d /etc/filemanager/filebrowser.db users add $uname $pword --perm.admin

	/etc/filemanager/filebrowser -d /etc/filemanager/filebrowser.db config set --root $dir

	firewall-cmd --zone=public --add-port=$port/tcp --permanent
	firewall-cmd --zone=public --add-port=$port/udp --permanent
	firewall-cmd --reload
	#启动命令
	##/etc/filemanager/filebrowser -d /etc/filemanager/filebrowser.db

	cat >/etc/systemd/system/filebrowser.service<<-EOF
	[Unit]
	Description=filebrowser Server
	After=network.target
	[Service]
	ExecStart=/etc/filemanager/filebrowser -d /etc/filemanager/filebrowser.db
	User=root
	[Install]
	WantedBy=multi-user.target
	EOF
	systemctl start filebrowser
	systemctl enable filebrowser
	clear

	echo -e username:"        ""\e[31m\e[1m$uname\e[0m"
	echo -e password:"        ""\e[31m\e[1m$pword\n\n\e[0m"
	echo -e download_dir:"    ""\e[31m\e[1m$dir\e[0m"
	echo -e port:"            ""\e[31m\e[1m$port\n\n\e[0m"

	####################################################################
	#安装方法引用https://www.twblogs.net/a/5c74c5bebd9eee339917ab30/zh-cn
	#install_filemanager函数为官方脚本，网址https://filebrowser.xyz
	####################################################################


}


select option in "shadowsocks-libev" "transmission" "aria2" "Up_kernel" "samba" "ngrok" "filemanager"
do
	case $option in
		"shadowsocks-libev")
			shadowsocks-libev
			break;;
		"transmission")
			transmission
			break;;
		"samba")
			samba
			break;;
		"aria2")
			aria2
			break;;
		"Up_kernel")
			Up_kernel
			break;;
		"ngrok")
			ngrok
			break;;
		"filemanager")
			filemanager
			break;;
		*)
			echo "nothink to do"
			break;;
	esac
done



