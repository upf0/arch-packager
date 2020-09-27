NAME := upf0/arch-packager
CONTAINER_RUNTIME := $(shell command -v podman 2> /dev/null || echo docker)

build:
	$(CONTAINER_RUNTIME) build -t $(NAME):latest --rm .

release: build
	$(CONTAINER_RUNTIME) push $(NAME):latest
