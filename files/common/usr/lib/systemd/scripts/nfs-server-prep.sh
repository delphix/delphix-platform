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
	printf "+4\\n" >/proc/fs/nfsd/versions
	echo "Initializing the NFS server version"
fi

#
# DLPX-65853
# Due to a permissions error, where '/var/lib/nfs' is owned by statd, the
# database used by nfsdcltrack(8) is never initialized.  This database is
# necessary for the NFSv4 server to track clients and notify them when the
# server is restarted.
#
# The work around is to create the directory that holds the client tracking
# database upfront.
#
NFSD_CL_TRACK_DIR="/var/lib/nfs/nfsdcltrack"

if [[ ! -d "$NFSD_CL_TRACK_DIR" ]]; then
	mkdir "$NFSD_CL_TRACK_DIR" && echo Creating dir for fsdcltrack database
fi

exit 0
