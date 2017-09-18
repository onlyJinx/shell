###导入elrepo密钥
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

###安装elrepo仓库
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm

###查询可用版本
###yum --disablerepo="*" --enablerepo="elrepo-kernel" list available

###安装内核
yum --enablerepo=elrepo-kernel install kernel-ml

###修改默认内核
sed -i '/s/saved/0/g' /etc/default/grub

###重新创建内核配置
grub2-mkconfig -o /boot/grub2/grub.cfg

yum update
###原文：http://www.jianshu.com/p/726bd9f37220
