FROM archimg/base-devel

LABEL maintainer="UPF"

ARG MIRROR_URL="https://mirror.nl.leaseweb.net/archlinux/$repo/os/$arch"
ARG REPO_URL="http://upf.space"

ENV PACKAGER="UPF Docker Container <vic@demuzere.be>"

# We'll need access to UPF repository.
RUN pacman-key -r 6690CF94 && \
	pacman-key --lsign 6690CF94 && \
	pacman-key -r 455BE60E && \
	pacman-key --lsign 455BE60E && \
	pacman-key -r CF1F8674 && \
	pacman-key --lsign CF1F8674 && \
	echo -e "\n[upf]\nSigLevel = PackageRequired\nServer = ${REPO_URL}/\$arch\n\n[upf-any]\nSigLevel = PackageRequired\nServer=${REPO_URL}/any" >> /etc/pacman.conf && \
	echo "Server = ${MIRROR_URL}" > /etc/pacman.d/mirrorlist && \
	useradd -Um packager && \
	echo "packager ALL=(ALL) NOPASSWD: /usr/bin/pacman" > /etc/sudoers.d/packager

USER packager:packager
WORKDIR /home/packager

CMD ["/bin/sh", "-c", "sudo pacman -Sy --quiet --noprogressbar --noconfirm && makepkg -s --noconfirm --clean --cleanbuild --noprogressbar --force -m"]
