#!/bin/bash
set -e

# Default user & group created in container
USER_NAME="packager"
GROUP_NAME="packager"

if [ "$(stat -c %u ${PKG_HOME})" != "${USER_ID}" ]; then
	echo "Ownership mismatch of your packaging directory. Exiting."
	exit 1
fi

if [ "$(stat -c %g ${PKG_HOME})" != "${GROUP_ID}" ]; then
	echo "Group ownership mismatch of your packaging directory. Exiting."
	exit 2
fi

# Change uid or use other user if necessary
if [ -n "${USER_ID}" ]; then
	if [ ! "$(getent passwd "${USER_ID}")" ]; then
		usermod -u "${USER_ID}" packager
	else
		USER_NAME=$(id -nu "${USER_ID}")
	fi
fi

# Change gid or use other gorup if necessary
if [ -n "${GROUP_ID}" ]; then
	if [ ! "$(getent group "${GROUP_ID}")" ]; then
		groupmod -g "${GROUP_ID}" packager
	else
		GROUP_NAME=$(getent group "${GROUP_ID}"|cut -f1 -d':')
	fi
fi

# Update package db
pacman -Sy --quiet --noconfirm

# Run a command as our packager user
function run_as_packager {
	export HOME="${PKG_HOME}"
	su "${USER_NAME}" -g "${GROUP_NAME}" -m -c "${1}"
}

# Import gpg keys when present
PKG_BUILD="${PKG_HOME}/PKGBUILD"
if [ -e "${PKG_BUILD}" ] && grep -q 'validpgpkeys=' "${PKG_BUILD}"; then
	ORIG_IFS="${IFS}"
	IFS=' ()' read -r -a GPG_KEYS <<< "$(grep 'validpgpkeys=' "${PKG_BUILD}" | awk -F"=" '{print $NF}')"
	IFS="${ORIG_IFS}"
	for key in "${GPG_KEYS[@]}"
	do
		run_as_packager "gpg --recv-keys ${key}"
	done
fi

# Run package build as packager user
run_as_packager "makepkg -s --noconfirm --clean --cleanbuild --force -m"
