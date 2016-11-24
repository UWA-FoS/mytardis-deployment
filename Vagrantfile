# -*- mode: ruby -*-
# vi: set ft=ruby :

hostname = ENV["HOSTNAME"]
dir_basename = File.basename(File.expand_path(File.dirname(__FILE__)))

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "centos/7"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.synced_folder ".", "/home/vagrant/sync", type: "virtualbox"
  config.vm.synced_folder "./puppet", "/etc/puppet", type: "virtualbox"
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "bootstrap", type: "shell", path: "bootstrap.sh"

  config.vm.provision "puppet", type: "puppet" do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "site.pp"
    puppet.module_path = "puppet/modules"
    puppet.hiera_config_path = "puppet/hiera.yaml"
    puppet.working_directory = "/tmp/vagrant-puppet"
    puppet.options = "--verbose"
  end

  config.vm.define "docker", primary: true do |docker|
    docker.vm.hostname = "docker.#{dir_basename}.#{hostname}"
    # Django standard port
    docker.vm.network "forwarded_port", guest: 8000, host: 8000
    docker.vm.network "private_network", ip: "192.168.33.11", auto_config: false
    docker.vm.provision "network", type: "shell", inline: <<SCRIPT
echo "192.168.33.10 accel" >> /etc/hosts
cat > /etc/sysconfig/network-scripts/ifcfg-eth1 <<EOF
TYPE=Ethernet
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=eth1
ONBOOT=yes
IPADDR=192.168.33.11
PREFIX=24
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
EOF
SCRIPT

    docker.vm.provider "virtualbox" do |vb|
      # Add second HDD for docker local storage (LVM); see bin/docker.sh bootstrap script
      unless File.exist?('./docker.vdi')
        vb.customize ['createhd','--filename','docker.vdi','--size',500*1024]
      end
      vb.customize ['storageattach',:id,'--storagectl','IDE','--port',1,'--device',0,'--type','hdd','--medium','docker.vdi']
      # vb.customize ['storageattach',:id,'--storagectl','IDE Controller','--port',1,'--device',0,'--type','hdd','--medium','docker.vdi']

      vb.memory = "4096"
      vb.cpus = "4"
    end

    # Configure second HDD for docker local storage (LVM); see bin/docker.sh bootstrap script
    docker.vm.provision "docker_parted", type: "shell", path: "bin/docker-parted.sh"
    docker.vm.provision "docker", type: "shell", inline: <<SCRIPT
cd /etc/puppet/modules
puppet module install garethr-docker
SCRIPT
    # TODO: Add this script to Puppet manifest
    docker.vm.provision "docker_volume_netshare", type: "shell", path: "bin/docker-volume-netshare.sh"
    docker.vm.provision "puppet", type: "puppet"
  end

  config.vm.define "storage", autostart: false do |storage|
  end

  config.vm.define "accel", autostart: false do |accel|
    accel.vm.hostname = "accel.#{dir_basename}.#{hostname}"
    accel.vm.network "forwarded_port", guest: 8080, host: 8080
    accel.vm.network "forwarded_port", guest: 8443, host: 8443
    accel.vm.network "private_network", ip: "192.168.33.10"

    accel.vm.provision "network", type: "shell", inline: <<SCRIPT
echo '192.168.33.11 docker' >> /etc/hosts
SCRIPT
    accel.vm.provision "accel", type: "shell", inline: <<SCRIPT
setsebool httpd_can_network_connect 1	# NB: This did not run, need to run manually; FIX REQUIRED
cd /etc/puppet/modules
puppet module install jfryman-nginx
SCRIPT
    accel.vm.provision "puppet", type: "puppet"
  end
end
