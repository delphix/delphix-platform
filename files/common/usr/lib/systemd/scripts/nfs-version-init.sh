#!/bin/bash
#
# Copyright 2019 Delphix
#

#
# Work around for kernel failing to parse the 'versions' input string
# "-4.1 -4.2 -2 +3 +4" passed from rpc.nfsd after a reboot
#
# Prime the kernel version after a reboot to include +4 so that the -4.x works
# Called by '/etc/systemd/system/nfs-config.service'
#
# We need this work-around until Ubuntu picks up nfs-utils 2.3.3
#
versions=$(cat /proc/fs/nfsd/versions)
if [[ "$versions" == "-2 -3 -4 -4.0 -4.1 -4.2" ]]; then
	printf "+4\n" >/proc/fs/nfsd/versions
	echo "Initializing the NFS server version"
fi

exit 0
