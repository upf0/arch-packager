#!/bin/sh
set -e

# Default user & group created in container
USER_NAME="packager"
GROUP_NAME="packager"

if [ "$(stat -c %u /home/packager)" != "${USER_ID}" ]; then
	echo "Ownership mismatch of your packaging directory. Exiting."
	exit 1
fi

if [ "$(stat -c %g /home/packager)" != "${GROUP_ID}" ]; then
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

# Run package build as packager user
su "${USER_NAME}" -g "${GROUP_NAME}" -m -c "makepkg -s --noconfirm --clean --cleanbuild --force -m"
