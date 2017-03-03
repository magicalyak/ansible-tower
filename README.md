# ansible-tower
Ansible Tower in a Container

##Usage
```
docker run --privileged --name ansible-tower -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 8080:8080 -p 443:443 -d  magicalyak/ansible-tower
```
