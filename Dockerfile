#                      _           _          _    
#    /\/\   __ _  __ _(_) ___ __ _| /\_/\__ _| | __
#   /    \ / _` |/ _` | |/ __/ _` | \_ _/ _` | |/ /
#  / /\/\ \ (_| | (_| | | (_| (_| | |/ \ (_| |   < 
#  \/    \/\__,_|\__, |_|\___\__,_|_|\_/\__,_|_|\_\
#                |___/                             

FROM lsiobase/xenial
MAINTAINER "magicalyak" <tom.gamull@gmail.com>

# global environment settings
ENV ANSIBLE_TOWER_VER=latest \
ADMIN_PASSWORD=changme \
SERVER_NAME=localhost

ADD ./inventory /opt/inventory
ADD ./tower_setup_conf.yml /opt/inventory/tower_setup_conf.yml

RUN \
 apt-get -y update && \
 apt-get install -y software-properties-common && \
 apt-add-repository -y ppa:ansible/ansible && \
 apt-get -y update && \
 apt-get install -y sudo wget ansible && \

# install Ansible Tower
 cd /opt && \
 wget http://releases.ansible.com/awx/setup/ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz && \
 tar -xvf ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz && \
 rm -rf ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz && \
 mv ansible-tower-setup-* /opt/tower-setup && \
 mv /opt/inventory /opt/tower-setup/inventory && \ 
 mv /opt/tower_setup_conf.yml /opt/tower-setup/tower_setup_conf.yml && \

# add passwords and fix locale issue
 sed -i "s/changeme/${ADMIN_PASSWORD}/g" /opt/tower-setup/inventory && \
 sed -i "s/lc_/#lc_/g" /opt/tower-setup/roles/postgres/templates/postgresql.conf.j2 && \
 cd /opt/tower-setup && \
 ./setup.sh && \

# cleanup
 apt-get clean && \
 rm -rf \
        /opt/tower-setup/* \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

# ports and volumes
EXPOSE 443 8080
VOLUME /var/lib/postgresql/9.4/main /etc
