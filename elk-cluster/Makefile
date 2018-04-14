SHELL   := /usr/bin/env bash
NIXOPS  := $(shell which nixops)
VERSION := 709b6f664e472ae2075bbee83bfb1dd1ba95e0e7

all: deploy

.created:
	$(NIXOPS) list | grep "ELK Cluster" || \
	$(NIXOPS) create deployment.nix -d elk \
		-I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/$(VERSION).tar.gz
	touch .created

test: check

check: build

build: .created
	$(NIXOPS) modify deployment.nix -d elk \
	  -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/$(VERSION).tar.gz
	$(NIXOPS) deploy -d elk --build-only

deploy: .created
	$(NIXOPS) deploy -d elk --kill-obsolete --allow-reboot

