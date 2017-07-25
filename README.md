[![](https://images.microbadger.com/badges/image/magicalyak/ansible-tower.svg)](https://microbadger.com/images/magicalyak/ansible-tower "Get your own image badge on microbadger.com")
```
                    _           _          _    
  /\/\   __ _  __ _(_) ___ __ _| /\_/\__ _| | __
 /    \ / _` |/ _` | |/ __/ _` | \_ _/ _` | |/ /
/ /\/\ \ (_| | (_| | | (_| (_| | |/ \ (_| |   < 
\/    \/\__,_|\__, |_|\___\__,_|_|\_/\__,_|_|\_\
              |___/                             
```

# ansible-tower
Ansible Tower in a Container. Run Ansible by Red Hat's Tower through a container and let your worries be a thing of yesterday!

**IMPORTANT: This is completely unsupported and you are on your own, if this blows up your home lab or makes SkyNet self-aware, you have no one to blame but yourself!**

Note: This is a personal project, it is not endorsed or sanctioned by Red Hat or Ansible.

## Usage
```
docker run -d -t \
--name=ansible-tower \
--cap-add=SYS_ADMIN \
-p 8080:8080 \
-p 443:443 \
-v </path/to/library>:/certs \
-v </path/to/data>:/var/lib/pgsql/9.4/data \
magicalyak/ansible-tower
```
## Parameters

`The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
http://192.168.x.x:8080 would show you what's running INSIDE the container on port 80.`

* `--cap-add=SYS_ADMIN` - This is needed for systemd to work usually.
* `-p 8080:8080` - Uses port 8080 for the Tower API, **required**.
* `-p 443:443` - Uses port 443 for the Tower UI, **required**.
* `-v /certs` - Certificate and license file location, **requires files from Setup below**.
* `-v /var/lib/pgsql/9.4/main` - Database Folder to preseve data across container upgrades, optional.

It is based on centos7, for shell access whilst the container is running do `docker exec -it ansible-tower /bin/bash`.

## Setting up the application
Webui can be found at `https://<your-ip>:443`

Valid settings for ANSIBLE_TOWER_VER are:-
+ **`latest`**: will update ansible tower to the latest version available.
+ **`<specific-version>`**: will select a specific version (eg 3.1.1) of tower to install.

Create a file called ansible-setup.env in the /certs directory (you can copy the /opt/ansible-setup.env)
* `ANSIBLE_TOWER_VER=latest` - Set to specific version of tower or put at latest.
* `ADMIN_PASSWORD=changeme` - Administrator passwords (don't use special symbols).
* `SERVER_NAME=localhost` - hostname for tower to use (for cert generation) (this is not working). 

For certs direction, add your license and certificates as follows:-
+ **`/certs/domain.crt`** - copied to /etc/tower/tower.cert
+ **`/certs/domain.kry`** - copied to /etc/tower/tower.key
+ **`/certs/license`** - copied to /etc/tower/license
+ **`/certs/.rebuild`** - touch this file to ensure it rebuilds, **required for first boot**.

## Info

* Shell access whilst the container is running: `docker exec -it ansible-tower /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f ansible-tower`
* Upgrade to the latest version (see setting up application section) : `touch /certs/.rebuild && docker restart ansible-tower`

## Credits
* ybalt/ansible-tower is the original basis for this Dockerfile

## Versions
+ **05.09.17:** Enabled setup to run as a service and removed anything redistributable from tower in build
+ **05.07.17:** Replaced Ubuntu with Centos7 and made tower install on first run
+ **05.04.17:** Added docker-entrypoint.sh from ybalt/ansible-tower github
+ **05.03.17:** Initial publish
