yum install git -y && git clone https://github.com/onlyJinx/shell_CentOS7.git && chmod +x shell_CentOS7/install.sh && bash shell_CentOS7/install.sh
yum install centos-release-scl-rh
yum install devtoolset-3-gcc devtoolset-3-gcc-c++
source scl_source enable devtoolset-3
