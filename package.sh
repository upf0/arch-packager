#!/bin/sh
set -e

# Default user & group created in container
USER_NAME="packager"
GROUP_NAME="packager"

# Change user id if necessary
if [ "$(stat -c %u /home/packager)" != "${USER_ID}" ]; then
	# Only change uid if it's not assigned yet, otherwise lookup user by id
	if [ ! "$(getent passwd "${USER_ID}")" ]; then
		usermod -u "${USER_ID}" packager
	else
		USER_NAME=$(id -nu "${USER_ID}")
	fi
	chown "${USER_NAME}" /home/packager
else
	USER_NAME=$(id -nu "${USER_ID}")
fi

# Change group id if necessary
if [ "$(stat -c %g /home/packager)" != "${GROUP_ID}" ]; then
	# Only change gid if it's not assigned yet, otherwise lookup group by id
	if [ ! "$(getent group "${GROUP_ID}")" ]; then
		groupmod -g "${GROUP_ID}" packager
	else
		GROUP_NAME=$(getent group "${GROUP_ID}"|cut -f1 -d':')
	fi
	chgrp "${GROUP_NAME}" /home/packager
else
	GROUP_NAME=$(getent group "${GROUP_ID}"|cut -f1 -d':')
fi

# Update package db
pacman -Sy --quiet --noconfirm

# Run package build as packager user
su "${USER_NAME}" -g "${GROUP_NAME}" -m -c "makepkg -s --noconfirm --clean --cleanbuild --force -m"
