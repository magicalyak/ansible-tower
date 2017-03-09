#                      _           _          _    
#    /\/\   __ _  __ _(_) ___ __ _| /\_/\__ _| | __
#   /    \ / _` |/ _` | |/ __/ _` | \_ _/ _` | |/ /
#  / /\/\ \ (_| | (_| | | (_| (_| | |/ \ (_| |   < 
#  \/    \/\__,_|\__, |_|\___\__,_|_|\_/\__,_|_|\_\
#                |___/                             

FROM ansible/centos7-ansible
MAINTAINER "magicalyak" <tom.gamull@gmail.com>

# global environment settings
ENV SERVER_NAME=localhost \
    ADMIN_PASSWORD=changeme

ADD ./inventory /opt/inventory
ADD ./ansible-setup.service /opt/ansible-setup.service
ADD ./docker-entrypoint.sh /docker-entrypoint.sh

RUN \
# Set systemd
 yum -y update; yum clean all; \
 (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
 rm -f /lib/systemd/system/multi-user.target.wants/*;\
 rm -f /etc/systemd/system/*.wants/*;\
 rm -f /lib/systemd/system/local-fs.target.wants/*; \
 rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
 rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
 rm -f /lib/systemd/system/basic.target.wants/*; \
 rm -f /lib/systemd/system/anaconda.target.wants/*; \
# install Ansible
 yum makecache fast && \
 yum -y install deltarpm epel-release initscripts && \
 yum -y update && \
 yum -y install ansible sudo which wget && \

# install Ansible Tower
 echo "Downloading the latest version of Ansible Tower" && \
 cd /opt && \
 wget http://releases.ansible.com/awx/setup/ansible-tower-setup-latest.tar.gz && \
 echo "Configuring Ansible Tower for setup at boot" && \
 tar -xvf ansible-tower-setup-latest.tar.gz && \
 rm -rf ansible-tower-setup-latest.tar.gz && \
 mv ansible-tower-setup-* /opt/tower-setup && \
 mv -f /opt/inventory /opt/tower-setup/inventory && \ 
 cp /opt/tower-setup/inventory /opt/inventory && \

# add passwords and fix locale issue
 sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers && \
 echo "Setting password to $(ADMIN_PASSWORD)" && \
 sed -i "s/changeme/${ADMIN_PASSWORD}/g" /opt/tower-setup/inventory && \
 echo "Setting connection to $(SERVER_NAME)" && \
 echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts && \
 echo "Patching locale in postgresql install" && \
 sed -i "s/lc_/#lc_/g" /opt/tower-setup/roles/postgres/templates/postgresql.conf.j2 && \
 echo "Patching IPv6 check in nginx due to docker container" && \
 sed -i "s/ansible_all_ipv6_addresses/[]/g" /opt/tower-setup/roles/nginx/templates/nginx.conf && \
 echo "Setting rebuild flag in /certs in case it isn't mapped" && \
 mkdir -p /certs/.deleteme && \
 touch /certs/.rebuild && \

# cleanup
 echo "Cleaning up...." && \
 yum clean all && \
 rm -rf \
        /tmp/* \
        /var/tmp/*

# ports and volumes
EXPOSE 443 8080
VOLUME /sys/fs/cgroup /var/lib/postgresql/9.4/main /certs

# set runtime options for ansibkle-setup
RUN echo "Setting up ansible-setup service to run at boot" && \
    chmod +x /docker-entrypoint.sh && \
    cp /opt/ansible-setup.service /etc/systemd/system/ansible-setup.service && \
    systemctl enable ansible-setup.service

CMD [ "/usr/sbin/init" ]
