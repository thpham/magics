SHELL   := /usr/bin/env bash
NIXOPS  := $(shell which nixops)
VERSION := nixos-18.09

all: deploy

.created:
	$(NIXOPS) list | grep "monitoring server" || \
	$(NIXOPS) create deployment.nix vbox.nix -d monitor \
		-I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/$(VERSION).tar.gz
	touch .created

.ec2-created:
	$(NIXOPS) list | grep "monitor server" || \
	$(NIXOPS) create deployment.nix ec2.nix -d monitor \
		-I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/$(VERSION).tar.gz
	touch .ec2-created

test: check

check: build

build: .created
	$(NIXOPS) modify deployment.nix vbox.nix -d monitor \
	  -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/$(VERSION).tar.gz
	$(NIXOPS) deploy -d monitor --build-only

deploy: .created
	$(NIXOPS) deploy -d monitor --kill-obsolete --allow-reboot

deploy-ec2: .ec2-created
	$(NIXOPS) deploy -d monitor --kill-obsolete --allow-reboot
