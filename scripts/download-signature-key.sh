#!/bin/bash
#
# Copyright 2019 Delphix
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

TOP=$(git rev-parse --show-toplevel 2>/dev/null)

if [[ -z "$TOP" ]]; then
	echo "Must be run inside the git repsitory."
	exit 1
fi

#
# As a precaution, we don't use "xtrace" since that would expose the
# DELPHIX_SIGNATURE_TOKEN environment variable contents to stdout, which
# we want to avoid.
#
set -o errexit
set -o pipefail

if [[ -z "$1" ]] || [[ -z "$2" ]]; then
	echo "Must specify key 'type' and 'version'."
	exit 1
fi

TYPE="$1"
VERSION="$2"

#
# To better enable this package to be built manually, we don't throw an
# error when these required environment variables are not set. This way,
# the package can be built successfully without the user knowing how to
# properly set these variables, but the public key contained by the
# package will not be correct. When this package is built by our build
# system and automation, these variables should be available.
#
if [[ -n "${DELPHIX_SIGNATURE_TOKEN:-}" ]] && [[ -n "${DELPHIX_SIGNATURE_URL:-}" ]]; then
	curl -s -S -u "$DELPHIX_SIGNATURE_TOKEN" \
		"$DELPHIX_SIGNATURE_URL/$TYPE/keyVersion/$VERSION" |
		jq -Mr .publicKey
fi
