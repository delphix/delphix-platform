#
# Copyright 2018 Delphix
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

#
# The version field defaults to a timestamp. Note that it can be
# overridden by running: make package VERSION="<custom version>"
#
VERSION := $(shell date '+%Y.%m.%d.%H')

.PHONY: \
	check \
	package \
	shellcheck \
	shfmtcheck

check: shellcheck shfmtcheck

package:
	@rm -f debian/changelog
	dch --create --package delphix-platform -v $(VERSION) \
			"Automatically generated changelog entry."
	dpkg-buildpackage -us
	@for ext in dsc tar.xz; do \
		mv -v ../delphix-platform_*.$$ext artifacts; \
	done

	@for ext in buildinfo changes deb; do \
		mv -v ../delphix-platform_*_amd64.$$ext artifacts; \
	done

shellcheck:
	shellcheck \
		etc/delphix-platform/ansible/apply \
		etc/delphix-platform/upgrade/download-latest-image \
		etc/delphix-platform/upgrade/unpack-image

shfmtcheck:
	! shfmt -d \
		etc/delphix-platform/ansible/apply \
		etc/delphix-platform/upgrade/download-latest-image \
		etc/delphix-platform/upgrade/unpack-image | grep .
