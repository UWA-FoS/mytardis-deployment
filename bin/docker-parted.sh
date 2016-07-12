#!/usr/bin/env bash
# https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/
# https://github.com/docker/docker/issues/16127

dev='/dev/sdb'
vg='docker'

[[ $EUID == 0 ]] || { echo "Run as root..."; exit 1; }

set -e

if ! lvs |awk '{print $2}' |grep -q "${vg}"; then

part_no=0
part_end=0
if ! part=$(parted -s $dev -- print); then
  echo "/dev/sdb mklabel msdos"
  parted --script $dev mklabel msdos
else
  part=$(echo "${part}" |sed -e '/^$/d' -e 's/^\s*//' -e 's/\s\+/ /g' |tail -1)

  if ! echo "${part}" |grep -q 'Number Start End Size Type File system Flags'; then
    part_no=$(echo "${part}" |cut -d' ' -f1)
    part_end=$(echo "${part}" |cut -d' ' -f3)
  fi
fi

dev_part=${dev}$((part_no+1))

parted -s -a optimal $dev -- mkpart primary ext2 $part_end -1
parted $dev -- set $((part_no+1)) lvm on
partprobe $dev

pvcreate $dev_part
vgcreate $vg $dev_part
lvcreate --wipesignature y -n thinpool $vg -l 95%VG
lvcreate --wipesignature y -n thinpoolmeta $vg -l 1%VG
lvconvert -y --zero n -c 512K --thinpool ${vg}/thinpool --poolmetadata ${vg}/thinpoolmeta

fi

if [[ ! -f /etc/lvm/profile/${vg}-thinpool.profile ]]; then
cat >/etc/lvm/profile/${vg}-thinpool.profile <<EOF
activation {
  thin_pool_autoextend_threshold=80
  thin_pool_autoextend_percent=20
}
EOF
lvchange --metadataprofile ${vg}-thinpool ${vg}/thinpool
fi

# Verify the docker lv is monitored
lvs -o+seg_monitor

exit 0
