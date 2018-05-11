SHELL   := /usr/bin/env bash
NIXOPS  := $(shell which nixops)
VERSION := 9c8fa9729cf8d4b3791a1f7339393fcbff26be52

all: deploy

.created:
	$(NIXOPS) list | grep "elk-cluster" || \
	$(NIXOPS) create deployment.nix vbox.nix -d elk \
		-I nixpkgs=https://github.com/NixOS/nixpkgs/archive/$(VERSION).tar.gz
	touch .created

.ec2-created:
	$(NIXOPS) list | grep "elk-cluster" || \
	$(NIXOPS) create deployment.nix ec2.nix -d elk \
		-I nixpkgs=https://github.com/NixOS/nixpkgs/archive/$(VERSION).tar.gz
	touch .created

test: check

check: build

build: .created
	$(NIXOPS) modify deployment.nix vbox.nix -d elk \
	  -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/$(VERSION).tar.gz
	$(NIXOPS) deploy -d elk --build-only

deploy: .created
	$(NIXOPS) deploy -d elk --kill-obsolete --allow-reboot

deploy-ec2: .ec2-created
	$(NIXOPS) deploy -d kafka --kill-obsolete --allow-reboot
