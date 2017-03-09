#                      _           _          _    
#    /\/\   __ _  __ _(_) ___ __ _| /\_/\__ _| | __
#   /    \ / _` |/ _` | |/ __/ _` | \_ _/ _` | |/ /
#  / /\/\ \ (_| | (_| | | (_| (_| | |/ \ (_| |   < 
#  \/    \/\__,_|\__, |_|\___\__,_|_|\_/\__,_|_|\_\
#                |___/                             

FROM ansible/centos7-ansible
MAINTAINER "magicalyak" <tom.gamull@gmail.com>

# global environment settings
ENV ANSIBLE_TOWER_VER=latest \
ADMIN_PASSWORD=changeme \
SERVER_NAME=localhost \
REBUILD=0 \
container=docker 

ADD ./inventory /opt/inventory
ADD ./ansible-setup.service /opt/ansible-setup.service
ADD ./ansible-setup.sh /opt/ansible-setup.sh

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
 cd /opt && \
 wget http://releases.ansible.com/awx/setup/ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz && \
 tar -xvf ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz && \
 rm -rf ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz && \
 mv ansible-tower-setup-* /opt/tower-setup && \
 mv -f /opt/inventory /opt/tower-setup/inventory && \ 
 cp /opt/tower-setup/inventory /opt/inventory && \

# add passwords and fix locale issue
 sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers && \
 sed -i "s/changeme/${ADMIN_PASSWORD}/g" /opt/tower-setup/inventory && \
 echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts && \
 sed -i "s/lc_/#lc_/g" /opt/tower-setup/roles/postgres/templates/postgresql.conf.j2 && \
 sed -i "s/ansible_all_ipv6_addresses/[]/g" /opt/tower-setup/roles/nginx/templates/nginx.conf && \
 mkdir -p /certs/.deleteme && \
 touch /certs/.rebuild && \

# cleanup
 yum clean all && \
 rm -rf \
        /tmp/* \
        /var/tmp/*

# ports and volumes
EXPOSE 443 8080
VOLUME /sys/fs/cgroup /var/lib/postgresql/9.4/main /certs /run /tmp

# set runtime (from ybalt/ansible-tower)
ADD ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && \
    chmod a+x /opt/ansible-setup.sh && \
    chmod a+x /opt/ansible-setup.service && \
    chmod a+x /etc/rc.d/rc.local && \
    echo "/opt/ansible-setup.sh" >> /etc/rc.local && \
    cp /opt/ansible-setup.service /etc/systemd/system/ansible-setup.service && \
    chmod +x /etc/systemd/system/ansible-setup.service
RUN systemctl enable ansible-setup.service
#ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["ansible-tower"]
CMD [ "/usr/sbin/init" ]
