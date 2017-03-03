FROM centos:centos7
MAINTAINER "magicalyak" <tom.gamull@gmail.com>

ENV ANSIBLE_TOWER_VER latest
ENV ADMIN_PASSWORD changeme

RUN yum -y update; yum clean all
RUN yum -y install sudo epel-release; yum clean all
RUN yum -y install ansible wget; yum clean all

#Sudo requires a tty. fix that.
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers

ADD http://releases.ansible.com/awx/setup/ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz /ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz
RUN tar -xvf ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz 
RUN rm -rf ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz
RUN mv ansible-tower-setup-* ansible-tower-setup

ADD ./inventory /ansible-tower-setup/inventory
RUN sed -i "s/changeme/${ADMIN_PASSWORD}/g" /ansible-tower-setup/inventory

RUN cd ansible-tower-setup \
  && chmod +x ./setup.sh
  && sudo ./setup.sh

EXPOSE 443 8080
