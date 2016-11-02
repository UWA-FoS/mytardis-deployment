#!/usr/bin/env bash

[[ $EUID -eq 0 ]] || { echo "Run as root user."; exit 1; }

yum -y install deltarpm epel-release kernel-devel
yum -y install \
  dkms \
  git \
  puppet \
  tmux

# Ensure Git operations are first so that conflicts in Puppet install
# dependancy resolution are less likely to occur.
# Test for module directory before git clone operation.
#
cd /etc/puppet/modules
#[ -d samba ] || git clone --recursive git://git.science.uwa.edu.au/sciituwa-samba samba

puppet module install puppetlabs-stdlib --version 3.2.1
puppet module install puppetlabs-concat --version 1.1.0
puppet module install puppetlabs-ntp --version 4.2.0

