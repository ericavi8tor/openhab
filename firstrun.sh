#!/bin/bash
if [ ! -d /config/addons ]; then
	echo '******MOVING**********'
	mv /opt/openhab/addons /config/
	mv /opt/openhab/webapps /config/
	mv /opt/openhab/configurations /config/

	echo '******LINKING**********'
	ln -s /config/addons /opt/openhab/addons
	ln -s /config/webapps /opt/openhab/webapps
	ln -s /config/configurations /opt/openhab/configurations

	chown -R openhab:openhab /config
	chmod -R 777 /config
fi

# Remove any lock files
rm -f /var/lock/LCK.*
