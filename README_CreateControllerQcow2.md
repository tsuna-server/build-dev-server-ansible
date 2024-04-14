# Partiton layout

## stg-controller
```
* Total size of /dev/vda is 32GiB
/dev/vda1 /boot/efi    512MiB
/dev/vda2 /boot        512MiB
# /dev/vda3 lvm-01       8GiB
# /dev/vda4 lvm-01       8GiB
# /dev/vda5 lvm-01       8GiB
# /dev/vda6 lvm-01       7GiB
/dev/vda3 lvm-01       31GiB
* LVM
lvm-log  (on lvm-01)   4GiB
lvm-root (on lvm-01)   27GiB
```

## stg-comstorage

```
* Total size of /dev/vda is 64GiB
/dev/vda1  /boot/efi    512MiB
/dev/vda2  /boot        512MiB
/dev/vda3  (ceph)       8GiB
/dev/vda4  lvm-01       8GiB
/dev/vda5  lvm-01       8GiB
/dev/vda6  lvm-01       8GiB
/dev/vda7  lvm-01       8GiB
/dev/vda8  lvm-01       8GiB
/dev/vda9  lvm-01       8GiB
/dev/vda10 lvm-01       7GiB
* LVM
lvm-log     (on lvm-01)   4GiB
lvm-swift01 (on lvm-01)   4GiB
lvm-swift02 (on lvm-01)   4GiB
lvm-root    (on lvm-01)   43GiB
```

# Creating qcow2 of controller

```
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y install apt-cacher-ng
cache_ng_ip="x.x.x.x"
cat << EOF > /etc/apt/apt.conf.d/01proxy
Acquire::HTTP::Proxy "http://${cache_ng_ip}:3142";
Acquire::HTTPS::Proxy "false";
EOF

apt-get update
```

```
INSTANCE_TYPE="controller"    # If you want to create a qcow2 image for controllers
INSTANCE_TYPE="comstorage"    # If you want to create a qcow2 image for comstorages
```

```
DEBIAN_FRONTEND=noninteractive sudo apt-get -y update
DEBIAN_FRONTEND=noninteractive sudo apt-get -y install \
   debootstrap \
   qemu-utils \
   qemu-system \
   genisoimage
```

```
rm -rf $HOME/cloud-image-ubuntu-from-scratch
mkdir $HOME/cloud-image-ubuntu-from-scratch
cd $HOME/cloud-image-ubuntu-from-scratch
if [ "${INSTANCE_TYPE}" = "comstorage" ]; then
    size_of_disk="64424509440"
else
    size_of_disk="34359738368"
fi
dd if=/dev/zero of=cloud-ubuntu-image.raw bs=1 count=0 seek=${size_of_disk} status=progress
```

```
if [ "${INSTANCE_TYPE}" = "comstorage" ]; then
    sgdisk -z cloud-ubuntu-image.raw
    sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI System" cloud-ubuntu-image.raw
    sgdisk -n 2:0:+512M -t 2:8300 -c 2:"Linux filesystem" cloud-ubuntu-image.raw
    sgdisk -n 3:0:+8G -t 3:8300 -c 3:"Ceph filesystem" cloud-ubuntu-image.raw
    sgdisk -n 4:0:    -t 4:8e00 -c 4:"Linux LVM" cloud-ubuntu-image.raw
else
    sgdisk -z cloud-ubuntu-image.raw
    sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI System" cloud-ubuntu-image.raw
    sgdisk -n 2:0:+512M -t 2:8300 -c 2:"Linux filesystem" cloud-ubuntu-image.raw
    sgdisk -n 3:0: -t 3:8e00 -c 3:"Linux LVM" cloud-ubuntu-image.raw
fi
```

```
sudo losetup -fP cloud-ubuntu-image.raw
sudo losetup -a | grep cloud-ubuntu-image.raw
> /dev/loop3: [64769]:201335002 (/root/cloud-image-ubuntu-from-scratch/cloud-ubuntu-image.raw)

# Declare L_DEV to recognize which loop device will be used
L_DEV=/dev/loop3
```

```
sudo gdisk -l ${L_DEV}
ls -l ${L_DEV}*
```


```
mkfs.vfat -F32 ${L_DEV}p1
mkfs.ext4 ${L_DEV}p2
if [ "${INSTANCE_TYPE}" = "comstorage" ]; then
    pvcreate ${L_DEV}p4
    vgcreate lvm-vg01 ${L_DEV}p4
    lvcreate -L 4G -n lvm-vg01-log lvm-vg01
    lvcreate -L 4G -n lvm-vg01-swift01 lvm-vg01
    lvcreate -L 4G -n lvm-vg01-swift02 lvm-vg01
    lvcreate -l 100%FREE -n lvm-vg01-root lvm-vg01
    mkfs.xfs /dev/lvm-vg01/lvm-vg01-log
    mkfs.xfs /dev/lvm-vg01/lvm-vg01-root
else
    pvcreate ${L_DEV}p3
    vgcreate lvm-vg01 ${L_DEV}p3
    lvcreate -L 4G -n lvm-vg01-log lvm-vg01
    lvcreate -l 100%FREE -n lvm-vg01-root lvm-vg01
    mkfs.xfs /dev/lvm-vg01/lvm-vg01-log
    mkfs.xfs /dev/lvm-vg01/lvm-vg01-root
fi
```

```
cd $HOME/cloud-image-ubuntu-from-scratch
mkdir chroot
sudo mount /dev/lvm-vg01/lvm-vg01-root chroot/
sudo mkdir -p chroot/var/log
sudo mount /dev/lvm-vg01/lvm-vg01-log chroot/var/log
sudo mkdir -p chroot/boot
sudo mount ${L_DEV}p2 chroot/boot
sudo mkdir -p chroot/boot/efi
sudo mount ${L_DEV}p1 chroot/boot/efi
```

```
sudo debootstrap \
   --arch=amd64 \
   --variant=minbase \
   --components "main,universe" \
   --include "ca-certificates,cron,iptables,isc-dhcp-client,libnss-myhostname,ntp,ntpdate,rsyslog,ssh,sudo,dialog,whiptail,man-db,curl,dosfstools,e2fsck-static" \
   jammy \
   $HOME/cloud-image-ubuntu-from-scratch/chroot \
   http://jp.archive.ubuntu.com/ubuntu/
```

