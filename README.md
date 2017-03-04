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

## Usage
```
docker create \
--name=ansible-tower \
-p 8080:8080 \
-p 443:443 \
-e ANSIBLE_TOWER_VER=latest \
-e ADMIN_PASSWORD=changme \
-v </path/to/library>:/etc \
-v </path/to/database>:/var/lib/postgresql/9.4/main \
magicalyak/ansible-tower
```
## Parameters

`The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
http://192.168.x.x:8080 would show you what's running INSIDE the container on port 80.`

* `-p 8080:8080` - Uses port 8080 for the Tower API, **required**.
* `-p 443:443` - Uses port 443 for the Tower UI, **required**.
* `-v /etc` - All the configuration files for Tower's etc directory
* `-v /var/lib/postgresql/9.4/main` - Database Folder to preseve data across container upgrades
* `-e ANSIBLE_TOWER_VER=latest` - Set to specific version of tower or put at latest.
* `-e ADMIN_PASSWORD=changeme` - Administrator passwords (don't use special symbols). 

It is based on ubuntu xenial with s6 overlay, for shell access whilst the container is running do `docker exec -it ansible-tower /bin/bash`.

## Setting up the application
Webui can be found at `https://<your-ip>:443`

Valid settings for ANSIBLE_TOWER_VER are:-
+ **`latest`**: will update ansible tower to the latest version available.
+ **`<specific-version>`**: will select a specific version (eg 3.1.0) of tower to install.

## Info

* Shell access whilst the container is running: `docker exec -it ansible-tower /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f ansible-tower`
* Upgrade to the latest version (see setting up application section) : `docker restart ansible-tower

## Versions
+ **05.03.17:** Initial publish`
