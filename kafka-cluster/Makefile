SHELL   := /usr/bin/env bash
NIXOPS  := $(shell which nixops)
VERSION := nixos-18.09

all: deploy

.created:
	$(NIXOPS) list | grep "kafkazk-cluster" || \
	$(NIXOPS) create deployment.nix vbox.nix -d kafkazk \
		-I nixpkgs=https://github.com/thpham/nixpkgs/archive/$(VERSION).tar.gz
	touch .created

.ec2-created:
	$(NIXOPS) list | grep "kafkazk-cluster" || \
	$(NIXOPS) create deployment.nix ec2.nix -d kafkazk \
		-I nixpkgs=https://github.com/thpham/nixpkgs/archive/$(VERSION).tar.gz
	touch .ec2-created

test: check

check: build

build: .created
	$(NIXOPS) modify deployment.nix vbox.nix -d kafkazk \
	  -I nixpkgs=https://github.com/thpham/nixpkgs/archive/$(VERSION).tar.gz
	$(NIXOPS) deploy -d kafkazk --build-only

deploy: .created
	$(NIXOPS) deploy -d kafkazk --kill-obsolete --allow-reboot

deploy-ec2: .ec2-created
	$(NIXOPS) deploy -d kafkazk --kill-obsolete --allow-reboot
