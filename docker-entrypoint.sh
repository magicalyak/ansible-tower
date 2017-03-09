#!/bin/bash
set -e

trap "kill -15 -1 && echo all proc killed" TERM KILL INT

echo "                      _           _          _     "
echo "    /\/\   __ _  __ _(_) ___ __ _| /\_/\__ _| | __ "
echo "   /    \ / _` |/ _` | |/ __/ _` | \_ _/ _` | |/ / "
echo "  / /\/\ \ (_| | (_| | | (_| (_| | |/ \ (_| |   <  "
echo "  \/    \/\__,_|\__, |_|\___\__,_|_|\_/\__,_|_|\_\ "
echo "                |___/                              "
echo
echo "Starting up Ansible Setup Service..."

rebuild_tower()
{
	echo "Performing rebuild of tower, this could take a while!"
	cd /opt
	wget http://releases.ansible.com/awx/setup/ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz
	tar -xvf ansible-tower-setup-*.tar.gz
	rm -rf /opt/ansible-tower-setup-*.tar.gz
	mv ansible-tower-setup-* /opt/tower-setup
	mv -f /opt/inventory /opt/tower-setup/inventory
	echo "Setting password to $(ADMIN_PASSWORD) in inventory"
	sed -i "s/changeme/${ADMIN_PASSWORD}/g" /opt/tower-setup/inventory
	echo "Patching locale bug in postgresql installation"
	sed -i "s/lc_/#lc_/g" /opt/tower-setup/roles/postgres/templates/postgresql.conf.j2
	echo "Patching IPv6 check for container environment"
	sed -i "s/ansible_all_ipv6_addresses/[]/g" /opt/tower-setup/roles/nginx/templates/nginx.conf
	cp /opt/tower-setup/inventory /opt/inventory
	echo "Installing Tower...this will take a while...maybe 10 minutes...grab a cocktail..."
	cd /opt/tower-setup
	 ./setup.sh
	echo "Cleaning up the place..."
	yum clean all
	cp /opt/tower-setup/inventory ../opt/inventory
	rm -rf \
	       /opt/tower-setup/* \
	       /tmp/* \
	       /var/lib/apt/lists/* \
	       /var/tmp/*

	if [[ -a /certs/.rebuild ]]; then 
		rm -rf /certs/.rebuild
	fi
}

if [[ $SERVER_NAME ]]; then
    echo "Setting hostname to $(SERVER_NAME)"
	if [[ -a /certs/.SERVER_NAME ]]; then
		if [[ $(<.SERVER_NAME) != $SERVER_NAME ]]; then
			echo $SERVER_NAME > /certs/.SERVER_NAME
			touch /certs/.rebuild
			rebuild_tower
		fi
	fi
elif [[ -a /certs/.rebuild ]]; then
	rebuild_tower
fi

if [[ -a /certs/domain.crt && -a /certs/domain.key ]]; then
	echo "Copying new certs..."
	cp -r /certs/domain.crt /etc/tower/tower.cert
	chown awx:awx /etc/tower/tower.cert
	cp -r /certs/domain.key /etc/tower/tower.key
	chown awx:awx /etc/tower/tower.key
fi
if [[ -a /certs/license ]]; then
	echo "Copying new license..."
	cp -r /certs/license /etc/tower/license
	chown awx:awx /etc/tower/license
fi
echo "Starting Ansible Tower Service..."
ansible-tower-service start
sleep inf & wait
