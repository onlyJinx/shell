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

#yum update -y

ping 127.0.0.1 -c 5 >>null
reboot

###引用：http://www.jianshu.com/p/726bd9f37220
###引用：https://legolasng.github.io/2017/05/08/upgrade-centos-kernel/#3安装新版本内核
