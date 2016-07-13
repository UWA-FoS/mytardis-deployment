# mytardis-deployment

Getting started

1. git clone https://github.com/UWA-FoS/mytardis-deployment.git --recursive
2. copy mytardis/app/src/tardis/default_settings.py to mytardis/vol/tardis/settings.py
3. ensure that you have installed the Pre-requisits bellow

Project: [MyTardis] (https://github.com/mytardis/mytardis)

```
The University of Western Australia
Faculty of Science
Development and testing environment
```

Pre-requisits:
- [VirtualBox] (https://www.virtualbox.org/)
- [Vagrant] (https://www.vagrantup.com/>)
  - Vagrant plugins:
    - vbguest {run: vagrant plugin install vagrant-vbguest}

Notes:

MyTardis application
- Runs in Docker container
- ubuntu 14.04
- [Gunicorn] (gunicorn.org)
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
- Production environment has been configured with cifs to EMC Isilon (To be documented).

Docker host
- Configured using Puppet, settings in hiera

The build of MyTardis application and MyTardis static Docker containers is in appropriate Dockerfiles
Currently the configuration and deployment of the MyTardis and MyTardis static docker images is done with docker-compose.
