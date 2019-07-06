yum install -y epel-release
yum install -y golang

yum install -y mercurial git bzr subversion wget

#####手动编译GO环境
##wget https://dl.google.com/go/go1.11.5.linux-amd64.tar.gz
#tar zxvf go*linux-amd64.tar.gz -C /usr/local
#mkdir $HOME/go
#echo 'export GOROOT=/usr/local/go'>> ~/.bashrc
#echo 'export GOPATH=$HOME/go'>> ~/.bashrc
#echo 'export PATH=$PATH:$GOROOT/bin'>> ~/.bashrc
#source $HOME/.bashrc
########END

git clone https://github.com/inconshreveable/ngrok.git
read domain
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
cd /usr/local/go/src/
GOOS=windows GOARCH=amd64 CGO_ENABLED=0 ./make.bash

#编译服务端&客户端
cd ~/ngrok
GOOS=linux GOARCH=amd64 make release-server&&GOOS=windows GOARCH=amd64 make release-client

mkdir /usr/local/bin/ngrok
cp /root/ngrok/bin/ngrokd /usr/local/bin/ngrok/ngrokd

systemctl stop firewalld
###echo "192.168.236.132 ngrok.ruor.club" >>/etc/hosts
###echo "192.168.236.132 remote.ngrok.ruor.club" >>/etc/hosts


###后台脚本

echo  '/usr/local/bin/ngrok/ngrokd -domain="ngrok.ruor.club" -httpAddr=":80"' > /usr/local/bin/ngrok/start.sh

###开机服务
cat >/etc/systemd/system/ngrok.service<< EOF
[Unit]
Description=Ngrok Server
After=network.target
[Service]
ExecStart=/bin/bash /usr/local/bin/ngrok/start.sh
User=root
[Install]
WantedBy=multi-user.target
EOF
systemctl start ngrok
systemctl enable ngrok
systemctl status ngrok



##./ngrokd -domain="ngrok.ruor.club" -httpAddr=":80" -httpsAddr=":890"



