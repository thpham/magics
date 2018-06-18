SHELL   := /usr/bin/env bash
NIXOPS  := $(shell which nixops)
VERSION := nixpkgs-unstable

all: deploy

.created:
	$(NIXOPS) list | grep "k8s-cluster" || \
	$(NIXOPS) create deployment.nix vbox.nix -d k8s \
		-I nixpkgs=https://github.com/thpham/nixpkgs/archive/$(VERSION).tar.gz
	touch .created

.ec2-created:
	$(NIXOPS) list | grep "k8s-cluster" || \
	$(NIXOPS) create deployment.nix ec2.nix -d k8s \
		-I nixpkgs=https://github.com/thpham/nixpkgs/archive/$(VERSION).tar.gz
	touch .ec2-created

test: check

check: build

build: .created
	$(NIXOPS) modify deployment.nix vbox.nix -d k8s \
	  -I nixpkgs=https://github.com/thpham/nixpkgs/archive/$(VERSION).tar.gz
	$(NIXOPS) deploy -d k8s --build-only

deploy: .created
	$(NIXOPS) deploy -d k8s --kill-obsolete --allow-reboot

deploy-ec2: .ec2-created
	$(NIXOPS) deploy -d k8s --kill-obsolete --allow-reboot
