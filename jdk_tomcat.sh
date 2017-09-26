wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.tar.gz
tar xvf jdk*tar.gz
cd jdk1.8.0*
mkdir /usr/local/java
mv * /usr/local/java/
http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.tar.gz
echo "export JAVA_HOME=/usr/local/java" >> /etc/profile 
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile 
echo "export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> /etc/profile 
source /etc/profile
###tomcat###
wget http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.0.M26/bin/apache-tomcat-9.0.0.M26.tar.gz
tar xvf apache-tomcat*tar.gz
cd apache-tomcat*
mkdir /usr/local/tomcat
mv * /usr/local/tomcat/
cat >/etc/profile.d/java.sh<< EOF
export JAVA_HOME=/usr/local/java
export PATH=\$PATH:\$JAVA_HOME/bin
EOF

cat >/etc/systemd/system/tomcat.service<< EOF

# Systemd unit file for tomcat
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/local/java/jre
Environment=CATALINA_PID=/usr/local/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINA_BASE=/usr/local/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/usr/local/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

User=root
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start tomcat && systemctl enable tomcat