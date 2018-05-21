
# NixOS / NixOps magics

This repository includes various personal experiments.

## Requirements

Even if those experiments have been build and tested on [NixOS](https://nixos.org), they should be usable on other platform which support the [Nix](https://nixos.org/nix) package manager.

All the required tools are provided by the `dev-env.nix`. Some new package features are not yet released in the various Nix channels. That's why I had to include `nixops` as a git submodule.

You can start a sandboxed dev environment with the `./shell` script.

Then have a look on the `readme` file of each particular sub-folders for more details.
