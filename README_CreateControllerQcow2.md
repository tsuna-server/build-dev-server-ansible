# Partiton layout

## stg-controller
```
* Total size of /dev/vda is 32GiB
/dev/vda1 /boot/efi    512MiB
/dev/vda2 /boot        512MiB
/dev/vda3 lvm-01       8GiB
/dev/vda4 lvm-01       8GiB
/dev/vda5 lvm-01       8GiB
/dev/vda6 lvm-01       7GiB
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
lvm-log       (on lvm-01)   4GiB
lvm-swift0001 (on lvm-01)   4GiB
lvm-swift0002 (on lvm-01)   4GiB
lvm-root      (on lvm-01)   43GiB
```

# Creating qcow2 of controller

```
DEBIAN_FRONTEND=noninteractive sudo apt-get -y update
DEBIAN_FRONTEND=noninteractive sudo apt-get -y install \
   debootstrap \
   qemu-utils \
   qemu-system \
   genisoimage
```

