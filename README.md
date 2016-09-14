# mytardis-deployment

Getting started

1. Ensure you have installed:
  1. [VirtualBox](https://www.virtualbox.org/)
    - Ensure that you include the Extension Pack
  2. [Vagrant](https://www.vagrantup.com/)
    - Vagrant plugins:
      - vbguest {run: vagrant plugin install vagrant-vbguest}
2. Use git to clone the development code into your prefered sandbox location
  - git clone --recursive https://github.com/UWA-FoS/mytardis-deployment.git mytardis
  - cd mytardis
3. Build the base Docker server and log in
  - vagrant up
  - vagrant ssh
4. Start a tmux session. [Tmux](https://tmux.github.io/) has been installed to allow multiple terminals
  - tmux
5. Build the mytardis application image
  - cd ~/sync/mytardis
  - docker-compose build
6. Start the MyTardis application
  - docker-compose up
7. Change to another terminal and configure an administrator account
  - Press \<Ctrl\>+B C
  - docker exec -it mytardis_app_1 /bin/bash
  - python mytardis.py createsuperuser
8. From your host machine start a browser and enter the following URI
  - http://localhost:8000

You should now see the MyTardis home page.

NB: this is a full build environment for Docker containers to be deployed on a Docker cluster NOT for production directly.

Enjoy.

NB: You should ensure that you configure the mytardis docker-compose.yml file for your deployment

Project: [MyTardis](https://github.com/mytardis/mytardis)

```
The University of Western Australia
Faculty of Science
Development and testing environment
```

Pre-requisits:
- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)
  - Vagrant plugins:
    - vbguest {run: vagrant plugin install vagrant-vbguest}

Notes:

MyTardis application
- Runs in Docker container
- ubuntu 14.04
- [Gunicorn](http://gunicorn.org)
- exposes port 8000
- This implementation is not to be exposed to the web directly but housed behind a web accelerator

MyTardis static content
- Runs in Docker container
- Nginx web service with direct loading of static content
- common read-only Docker volume with MyTardis application container

Nginx web accelerator
- Hosted in own VM to simulate a corporate HA/load balanced web accelerator configuration
- Could be replaced with Apache, F5's or any other service
- Configured using Puppet, settings in hiera

File server
- Still to be implemented, current config uses local file storage
- Production environment has been configured with cifs to EMC Isilon (To be documented) implemented with docker volume abstraction layer (docker-volume-netshare plugin).

Docker host
- Configured using Puppet, settings in hiera.

The build of MyTardis application and MyTardis static Docker containers is in appropriate Dockerfiles
Currently the configuration and deployment of the MyTardis and MyTardis static docker images is done with docker-compose.
