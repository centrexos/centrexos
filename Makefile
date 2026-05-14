sync:
	git submodule update --init --recursive

bootstrap:
	./scripts/bootstrap.sh

iso:
	./build/build-iso.sh