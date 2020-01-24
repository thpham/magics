SHELL   := /usr/bin/env bash
NIXOPS  := $(shell which nixops)
VERSION := nixos-19.09
NIXPKGS := https://github.com/NixOS/nixpkgs-channels/archive/$(VERSION).tar.gz

# -I nixpkgs=$(NIXPKGS)

all: deploy

.created:
	$(NIXOPS) list | grep "thanos server" || \
	$(NIXOPS) create deployment.nix vbox.nix -d thanos
	touch .created

.ec2-created:
	$(NIXOPS) list | grep "thanos server" || \
	$(NIXOPS) create deployment.nix ec2.nix -d thanos
	touch .ec2-created

test: check

check: build

build: .created
	$(NIXOPS) modify deployment.nix vbox.nix -d thanos
	$(NIXOPS) deploy -d thanos --build-only

deploy: .created
	$(NIXOPS) deploy -d thanos --kill-obsolete --allow-reboot

deploy-ec2: .ec2-created
	$(NIXOPS) deploy -d thanos --kill-obsolete --allow-reboot
