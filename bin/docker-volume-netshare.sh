#!/usr/bin/env bash
# https://github.com/ContainX/docker-volume-netshare
# https://github.com/ContainX/docker-volume-netshare/releases

name='docker-volume-netshare'
ver='0.18'
machine='linux_amd64'
url="https://github.com/ContainX/docker-volume-netshare/releases/download/v${ver}/docker-volume-netshare_${ver}_${machine}.tar.gz"

wd="/opt/${name}"
systemd="/etc/systemd/system/${name}.service"

[[ $EUID -eq 0 ]] || { echo "Run as root user..."; exit 1; }

set -e

[[ -d "${wd}" ]] || mkdir -p "${wd}"

cd "${wd}"
[[ -f docker-volume-netshare_${ver}_${machine}.tar.gz ]] || curl -L -O $url

tar xzf docker-volume-netshare_${ver}_${machine}.tar.gz

cd /usr/local/sbin
ln -sf "${wd}/docker-volume-netshare_${ver}_${machine}/${name}"

yum -y install \
  cifs-utils \
  nfs-utils

if [[ ! -f "${systemd}" ]]; then
  cat > "${systemd}" <<EOF
[Unit]
Description=Docker Volume NetShare
After=network.target

[Service]
ExecStart=/opt/docker-volume-netshare/docker-volume-netshare_0.18_linux_amd64/docker-volume-netshare cifs
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
fi

# .netrc file is placed in the root folder as $HOME is not set during systemd process
# the link /root/.netrc is created for testing of the docker-volume-netshare when run as the root user
echo "Ensure that you review the auth file /.netrc"
if [[ ! -f /.netrc ]]; then
  cat > /.netrc <<EOF
machine <machine_name> username <service_account> password <password> domain <domain>
EOF
fi
chmod 0600 /.netrc
cd /root; ln -sf /.netrc

cat <<EOF
Reviewed this installation
Run the following commands to ensure service is started automatically

# systemctl enable docker-volume-netshare.service
# systemctl start docker-volume-netshare.service
EOF

exit 0
