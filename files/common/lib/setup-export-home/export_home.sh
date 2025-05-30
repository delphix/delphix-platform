#!/bin/bash
#
# Copyright (c) 2025 by Delphix. All rights reserved.
#

#
# This script ensures that the /export/home is a symlink
# to /home.
#

if ! mountpoint -q /export/home; then
  if [ ! -L /export/home ]; then
    echo 'Ensuring /export/home is a symlink to /home...'
    if [ -e /export/home ]; then
      echo 'Removing existing /export/home directory...'
      rm -rf /export/home
    fi
    if [ ! -d /export ]; then
      mkdir /export
    fi
    echo 'Creating symlink: /export/home -> /home'
      ln -s /home /export/home
  fi
fi
