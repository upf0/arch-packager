REG := docker.io
NAME := upf0/arch-packager
DEPS := archlinux/archlinux:base-devel
CONTAINER_RUNTIME := $(shell command -v podman 2> /dev/null || echo docker)

build:
	buildah bud -t upf0/arch-packager .

prune:
	$(CONTAINER_RUNTIME) image prune -f

push:
ifeq ($(CONTAINER_RUNTIME),/usr/bin/podman)
	$(CONTAINER_RUNTIME) tag localhost/$(NAME):latest $(REG)/$(NAME):latest
endif
	$(CONTAINER_RUNTIME) push $(REG)/$(NAME):latest

release: update build push prune

update:
	$(CONTAINER_RUNTIME) pull $(REG)/$(DEPS)
	$(CONTAINER_RUNTIME) pull $(REG)/$(NAME)
