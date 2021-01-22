#!/bin/bash
#
# Copyright (c) 2021 by Delphix. All rights reserved.
#

#
# This script checks if any iSCSI devices are in use by an active zfs pool.

PATH=/sbin:/bin

ZFS_FS_TYPE="zfs_member"

function usage() {
	echo "Usage: $0 [--verbose]" >&2
	exit 2
}

if [[ $# -gt 1 ]]; then
	usage
fi

VERBOSE=0
if [[ $# -eq 1 ]]; then
	if [[ "$1" != "--verbose" ]]; then
		usage
	fi
	VERBOSE=1
fi

shopt -s nullglob

# locate iscsi devices that belong to a zfs pool
while read -r type transport device; do
	# first locate iscsi devices
	[[ "$type" == "disk" && "$transport" == "iscsi" ]] || continue
	[[ $VERBOSE -eq 0 ]] || echo "${device} uses iSCSI"

	# locate any partitions for this device
	for partition in /dev/"${device}"?*; do
		# check if partition type is zfs and grab the pool name
		read -r fstype pool <<<"$(lsblk -n -o FSTYPE,LABEL "${partition}")"
		[[ "$fstype" == "$ZFS_FS_TYPE" && -n "$pool" ]] || continue
		[[ $VERBOSE -eq 0 ]] || echo " ${partition} is a member of pool ${pool}"

		# check if pool is active (imported)
		health=$(zpool list -H -o name,health "${pool}" 2>&1)
		status=$?
		[[ $VERBOSE -eq 0 ]] || echo "  ${health} ($status)"
		if [[ $status -eq 0 ]]; then
			echo "device '${partition}' in use by zfs pool '${pool}'" >&2
			exit 1
		fi
	done
done < <(lsblk --scsi -n -o TYPE,TRAN,NAME)

exit 0
