#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

ROOT_PATH=/media/sdb1
MOCK_PATH="${ROOT_PATH}/mock"
PKGS_PATH="${ROOT_PATH}/pkgs"
REPOS_PATH="${ROOT_PATH}/repos"
CLEAR_VERSION=$(cat /usr/share/clear/version)

if [ ! -w "${ROOT_PATH}" ]; then
	echo "ROOT_PATH: ${ROOT_PATH} not writtable"
	exit 1
fi

sudo swupd bundle-add mixer

if [ ! -e /etc/mock/clear.conf ]; then
	sudo mkdir -p /etc/mock
	sudo tee /etc/mock/clear.cfg >/dev/null <<-EOF 
		config_opts['root'] = 'clear'
		config_opts['target_arch'] = 'x86_64'
		config_opts['legal_host_arches'] = ('x86_64',)
		config_opts['releasever'] = '${CLEAR_VERSION}'
		config_opts['chroot_setup_cmd'] = 'install @srpm-build'

		config_opts['basedir'] = '${MOCK_PATH}/lib'
		config_opts['cache_topdir'] = '${MOCK_PATH}/cache'

		config_opts['yum.conf'] = """

		[main]
		keepcache=1
		debuglevel=2
		reposdir=/dev/null
		logfile=/var/log/yum.log
		retries=20
		obsoletes=1
		gpgcheck=0
		assumeyes=1
		syslog_ident=mock
		syslog_device=
		mdpolicy=group:primary

		# Repos
		[clear]
		name=Clear
		failovermethod=priority
		baseurl=https://download.clearlinux.org/releases/\$releasever/clear/x86_64/os/
		enabled=1
		gpgcheck=0

		[local-x86_64]
		name=Local x86_64
		failovermethod=priority
		baseurl=file://${REPOS_PATH}/x86_64/os
		enabled=1
		gpgcheck=0
		"""
	EOF
fi

mkdir -p "${PKGS_PATH}/common"

# Generate licenses file
TMPDIR=$(mktemp -d)
curl -L https://api.github.com/repos/spdx/license-list/tarball | tar -xz -C "${TMPDIR}" --strip 1
rm -f "${TMPDIR}/Updating the SPDX Licenses.txt" "${TMPDIR}/README.txt"

( cd "${TMPDIR}" && for lic in *.txt; do sha1sum "${lic}"; done | sed -e 's/  / | /' | sed 's/.txt//' ) > "${PKGS_PATH}/common/licenses"

rm -rf "${TMPDIR}"

# Setup repo directories
mkdir -p "${REPOS_PATH}/source" "${REPOS_PATH}/x86_64/os" "${REPOS_PATH}/x86_64/debug"

createrepo_c "${REPOS_PATH}/source"
createrepo_c "${REPOS_PATH}/x86_64/os"
createrepo_c "${REPOS_PATH}/x86_64/debug"
