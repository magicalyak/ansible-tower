FROM ansible:centos7-ansible
MAINTAINER "magicalyak" <tom.gamull@gmail.com>

ENV ANSIBLE_TOWER_VER latest
ENV ADMIN_PASSWORD changeme

RUN yum -y update; yum clean all

#Sudo requires a tty. fix that.
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers

ADD http://releases.ansible.com/awx/setup/ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz /opt/ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz
RUN cd /opt; tar -xvf ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz 
RUN rm -rf /opt/ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz
RUN mv /opt/ansible-tower-setup-* /opt/ansible-tower-setup

ADD ./inventory /opt/ansible-tower-setup/inventory
RUN sed -i "s/changeme/${ADMIN_PASSWORD}/g" /opt/ansible-tower-setup/inventory

RUN cd /opt/ansible-tower-setup; ./setup.sh

EXPOSE 443 8080
CMD ["/bin/bash"]
