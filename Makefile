NAME := upf0/arch-packager
DEPS := archlinux/base
CONTAINER_RUNTIME := $(shell command -v podman 2> /dev/null || echo docker)

build:
	$(CONTAINER_RUNTIME) build -t $(NAME):latest --rm .

prune:
	$(CONTAINER_RUNTIME) image prune

push:
	$(CONTAINER_RUNTIME) push $(NAME):latest

release: update build push prune

update:
	$(CONTAINER_RUNTIME) pull $(DEPS)
	$(CONTAINER_RUNTIME) pull $(NAME)
