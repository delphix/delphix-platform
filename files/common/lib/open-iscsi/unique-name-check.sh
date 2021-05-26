#!/bin/bash
#
# Copyright (c) 2021 by Delphix. All rights reserved.
#

#
# This script generates a unique initiator name based on the system-uuid
#

PATH=/bin:/usr/bin/

NAME_FILE="/etc/iscsi/initiatorname.iscsi"
AUTHORITY="2008-07.com.delphix"

if [[ -f $NAME_FILE ]]; then
	system_uuid=$(get-system-uuid)

	if [[ ${#system_uuid} -ne 36 ]]; then
		echo "Error: unexpected UUID -- $system_uuid" >&2
		exit 1
	fi

	name_entry="InitiatorName=iqn.$AUTHORITY:$system_uuid"

	#
	# Generate IQN for this Delphix Engine (if not already present)
	#
	if ! grep -Gq "^$name_entry" $NAME_FILE; then
		{
			echo "## DO NOT EDIT OR REMOVE THIS FILE!"
			echo "## If you remove this file, the iSCSI daemon will not start."
			echo "## If you change the InitiatorName, existing access control lists"
			echo "## may reject this initiator.  The InitiatorName must be unique"
			echo "## for each iSCSI initiator.  Do NOT duplicate iSCSI InitiatorNames."
			printf '%s\n' "$name_entry"
		} >$NAME_FILE
		chmod 640 $NAME_FILE
		echo "Generating unique iSCSI name using UUID $system_uuid"
	fi
fi

exit 0
