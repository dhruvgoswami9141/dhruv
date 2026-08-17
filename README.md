# LVM-Based Dynamic Storage Allocation System

This is my micro project where I set up dynamic, resizable storage for a
multi-user server using LVM on RHEL, running inside Oracle VM VirtualBox.

## Why I built this
Normal disk partitions are fixed — once you run out of space, you're stuck
resizing manually or migrating data. I wanted to actually build and test a
setup where storage can grow live, without touching the disk layout or taking
anything offline.

## What I used
- RHEL (free developer subscription), running in Oracle VM VirtualBox
- XFS as the filesystem
- 3 extra virtual disks added specifically for this (5GB each)

## How it's structured
I followed the standard LVM layering:

`Physical disks -> Volume Group (shared pool) -> Logical Volumes (per user)`

- Physical Volumes: /dev/sdb, /dev/sdc, /dev/sdd
- Volume Group: vg_storage
- Logical Volumes: lv_user1, lv_user2 (one per user)

## What I actually got working
- Grew lv_user1 from 3GB to 5GB live, while it was mounted
- Added a third disk to the pool and grew lv_user2 from 3GB to 6GB
- Set up /etc/fstab so mounts survive a reboot (broke it once, fixed it — details in the report)
- Locked down each user's folder so they can only access their own storage

## A few things that went wrong along the way
I ran into a handful of real errors while building this — a bad lvcreate
syntax, a broken fstab from editing in vi, trying to shrink an XFS volume
with the wrong tool, and forgetting to actually create the Linux users before
chown-ing their folders. All of that is written up in the report since I think
it's more honest (and more useful) than pretending everything worked first try.

## Files here
- `report/` — the full write-up
- `presentation/` — slides I used to present this
- `screenshots/` — terminal output from each stage

## Full VM
The VM itself (RHEL + everything already set up) is too big for GitHub, so
it's here instead: [Download OVA](PASTE_YOUR_LINK_HERE)

## Author
YOUR NAME HERE
