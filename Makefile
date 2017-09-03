NAME := upf0/arch-packager

build:
	docker build -t $(NAME):latest --rm .

release: build
	docker push $(NAME):latest
