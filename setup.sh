#!/bin/bash
# =============================================================
# LVM-Based Dynamic Storage Allocation System for a Multi-User Server
# Environment: RHEL on Oracle VM VirtualBox
#
# This script documents every command I used to build this project,
# in order. Run as root, and only after adding 3 extra virtual disks
# (5GB each) to the VM in VirtualBox Settings > Storage while it's
# powered off.
#
# NOTE: This is meant to be read and run step-by-step, not blindly
# executed all at once on a system you care about.
# =============================================================

set -e  # stop on first error

echo "== Step 1: Confirm the new disks are visible =="
lsblk

echo "== Step 2: Create Physical Volumes =="
pvcreate /dev/sdb /dev/sdc /dev/sdd
pvdisplay

echo "== Step 3: Create the Volume Group (keeping sdd in reserve) =="
vgcreate vg_storage /dev/sdb /dev/sdc
vgdisplay vg_storage

echo "== Step 4: Create Logical Volumes, one per user =="
lvcreate -L 3G -n lv_user1 vg_storage
lvcreate -L 3G -n lv_user2 vg_storage
lvdisplay

echo "== Step 5: Format both volumes with XFS =="
mkfs.xfs /dev/vg_storage/lv_user1
mkfs.xfs /dev/vg_storage/lv_user2

echo "== Step 6: Create mount points and mount =="
mkdir -p /home/user1_storage /home/user2_storage
mount /dev/vg_storage/lv_user1 /home/user1_storage
mount /dev/vg_storage/lv_user2 /home/user2_storage
df -h

echo "== Step 7: Make the mounts persistent across reboots =="
echo "/dev/vg_storage/lv_user1   /home/user1_storage   xfs   defaults   0 0" >> /etc/fstab
echo "/dev/vg_storage/lv_user2   /home/user2_storage   xfs   defaults   0 0" >> /etc/fstab
systemctl daemon-reload
mount -a

echo "== Step 8: Create the actual Linux users =="
useradd user1
useradd user2
# passwd user1   # run manually - prompts interactively
# passwd user2   # run manually - prompts interactively

echo "== Step 9: Restrict each user's storage to themselves =="
chown user1:user1 /home/user1_storage
chown user2:user2 /home/user2_storage
chmod 700 /home/user1_storage /home/user2_storage
ls -ld /home/user1_storage /home/user2_storage

echo "== Step 10: Demonstrate dynamic resizing (the core of the project) =="
# Grow lv_user1 using free space already in the pool
lvextend -L +2G /dev/vg_storage/lv_user1
xfs_growfs /home/user1_storage

# Grow the pool itself by adding the third disk, then grow lv_user2 into it
vgextend vg_storage /dev/sdd
lvextend -L +3G /dev/vg_storage/lv_user2
xfs_growfs /home/user2_storage

echo "== Step 11: Final verification =="
pvs
vgs
lvs
df -h
cat /etc/fstab

echo "Done. lv_user1 should now be 5G and lv_user2 should now be 6G."
