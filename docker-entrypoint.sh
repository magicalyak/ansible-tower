#!/bin/bash
set -e

trap "kill -15 -1 && echo all proc killed" TERM KILL INT

rebuild_tower()
{
	echo "Performing rebuild of tower, this could take a while!"
	cd /opt && \
	wget http://releases.ansible.com/awx/setup/ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz && \
	tar -xvf ansible-tower-setup-${ANSIBLE_TOWER_VAR}.tar.gz && \
	mv ansible-tower-setup-* /opt/tower-setup && \
	mv -f /opt/inventory /opt/tower-setup/inventory && \
	cp /opt/tower-setup/inventory /opt/inventory && \
	sed -i "s/changeme/${ADMIN_PASSWORD}/g" /opt/tower-setup/inventory && \
	sed -i "s/lc_/#lc_/g" /opt/tower-setup/roles/postgres/templates/postgresql.conf.j2 && \
	sed -i "s/ansible_all_ipv6_addresses/[]/g" /opt/tower-setup/roles/nginx/templates/nginx.conf && \
	echo "Installing Tower...this will take a while..."
	cd /opt/tower-setup && \
	 ./setup.sh
	echo "Cleaning up the place..."
	apt-get clean && \
	cp /opt/tower-setup/inventory ../opt/inventory && \
	rm -rf \
	       /opt/tower-setup/* \
	       /tmp/* \
	       /var/lib/apt/lists/* \
	       /var/tmp/*

	if [[ -a /certs/.rebuild ]]; then 
		rm -rf /certs/.rebuild
	fi
}

if [ "$1" = 'ansible-tower' ]; then
	if [[ $SERVER_NAME ]]; then
		if [[ -a /certs/.SERVER_NAME ]]; then
			if [[ $(<.SERVER_NAME) != $SERVER_NAME ]]; then
				echo $SERVER_NAME > /certs/.SERVER_NAME
				touch /certs/.rebuild
				rebuild_tower
			fi
		elif [[ $REBUILD = 1 ]]; then
		    touch /certs/.rebuild
		    rebuild_tower
		fi
#		echo "add ServerName to $SERVER_NAME"
#		head -n 1 $APACHE_CONF | grep -q "^ServerName" \
#		&& sed -i -e "s/^ServerName.*/ServerName $SERVER_NAME/" $APACHE_CONF \
#		|| sed -i -e "1s/^/ServerName $SERVER_NAME\n/" $APACHE_CONF
	fi
	if [[ -a /certs/domain.crt && -a /certs/domain.key ]]; then
		echo "copy new certs"
		cp -r /certs/domain.crt /etc/tower/tower.cert
		chown awx:awx /etc/tower/tower.cert
		cp -r /certs/domain.key /etc/tower/tower.key
		chown awx:awx /etc/tower/tower.key
	fi
	if [[ -a /certs/license ]]; then
		echo "copy new license"
		cp -r /certs/license /etc/tower/license
		chown awx:awx /etc/tower/license
	fi
	ansible-tower-service start
	sleep inf & wait
else
	exec "$@"
fi
