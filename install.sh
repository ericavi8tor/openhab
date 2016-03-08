#!/bin/bash
# base configuration nicked from github.com/limetech/dockerapp-plex
# Configure user nobody to match unRAID's settings
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home

# chfn workaround - Known issue within Dockers
ln -s -f /bin/true /usr/bin/chfn

# Update Apt-Get
apt-get -q update

# Set Timezone
apt-get install -y ntp
echo 'server 0.uk.pool.ntp.org' > /etc/ntp.conf
echo 'Europe/London' > /etc/timezone

# Install Java 7
apt-get purge -qy openjdk*
add-apt-repository ppa:webupd8team/java
apt-get update
apt-get install oracle-java7-installer
#apt-get install -y openjdk-7-jdk
#apt-get install -y oracle-java7-jdk

# Downloads Openhab and extras
apt-get install -qy wget unzip
mkdir /downloads
cd /downloads
wget -nv https://bintray.com/artifact/download/openhab/bin/distribution-1.8.1-runtime.zip
wget -nv https://bintray.com/artifact/download/openhab/bin/distribution-1.8.1-addons.zip
wget -nv wget -nv https://github.com/cdjackson/HABmin/blob/master/addons/org.openhab.io.habmin-1.7.0-SNAPSHOT.jar?raw=true
wget -nv https://github.com/cdjackson/HABmin/archive/master.zip
wget -nv https://github.com/cdjackson/HABmin2/releases/download/0.0.15/HABmin2-0.0.15-release.zip

# Main runtime
unzip -q distribution-1.8.1-runtime.zip -d /opt/openhab

# Addons
unzip -q distribution-1.8.1-addons.zip -d /downloads/addons/
cp -rp addons/org.openhab.binding.zwave-1.8.1.jar /opt/openhab/addons/
cp -rp addons/org.openhab.action.astro-1.8.1.jar /opt/openhab/addons/
cp -rp addons/org.openhab.binding.astro-1.8.1.jar /opt/openhab/addons/
cp -rp addons/org.openhab.binding.exec-1.8.1.jar /opt/openhab/addons/
cp -rp addons/org.openhab.binding.http-1.8.1.jar /opt/openhab/addons/
cp -rp addons/org.openhab.binding.hue-1.8.1.jar /opt/openhab/addons/
cp -rp addons/org.openhab.binding.ntp-1.8.1.jar /opt/openhab/addons/
cp -rp addons/org.openhab.binding.systeminfo-1.8.1.jar /opt/openhab/addons/
cp -rp addons/org.openhab.binding.tcp-1.8.1.jar /opt/openhab/addons/
cp -rp addons/org.openhab.binding.weather-1.8.1.jar /opt/openhab/addons/
cp -rp addons/org.openhab.io.myopenhab-1.8.1.jar /opt/openhab/addons/
cp -rp addons/org.openhab.persistence.exec-1.8.1.jar /opt/openhab/addons/
cp -rp addons/org.openhab.persistence.rrd4j-1.8.1.jar /opt/openhab/addons/

# HabMin1.7 jar
cp -rp org.openhab.io.habmin-1.7.0-SNAPSHOT.jar?raw=true /opt/openhab/addons/org.openhab.io.habmin-1.7.0-SNAPSHOT.jar

# HabMin1.7 webapp
unzip -q master.zip
cp -rp HABmin-master /opt/openhab/webapps/habmin

# HabMin2 webapp
unzip -q HABmin2-0.0.15-release.zip -d /opt/openhab/webapps/habmin2

# Add user:group and chown
adduser --system --no-create-home --group openhab
usermod openhab -a -G dialout
chown -R openhab:openhab /opt/openhab
chmod +x /opt/openhab/addons/*.jar

# This is now handled by a custom config
#cp -rp /opt/openhab/configurations/openhab_default.cfg /opt/openhab/configurations/openhab.cfg

# Move startup as were using a custom one
# mv /opt/openhab/start.sh /opt/openhab/start.sh.original

# Add startup
mkdir -p /etc/service/openhab
cat <<'EOT' > /etc/service/openhab/run
#!/bin/bash
umask 000
exec /opt/openhab/start.sh
EOT
chmod +x /etc/service/openhab/run

# Quick Cleanup
rm /opt/openhab/*.bat 
rm -r /downloads
rm /install.sh
