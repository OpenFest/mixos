# MixOS

This repo contains configuration for a linux distribution optimised
for live audio/video mixing. Very much work in progress.

It is based on NixOS (atomic immutable deploys are quite suited for this usecase).

## Configurations

- `zver`: base configuration targeting x86_64 machines with NVidia GPUs
- `hala`: dev config meant to be run in QEMU

## Requirements

run `nix develop`
or if you use [direnv](https://direnv.net/) `direnv allow .`

install git hook/s to check nix linting rules:

```sh
make git-hooks
```

fix linting errors in nix:

```sh
make nixfmt
```

## Build

```sh
nix build .#packages.x86_64-linux.hala
```

## Run in QEMU

this will run the latest image found in `./result` inside QEMU VM

```sh
nix build nixpkgs#OVMF.fd
./run-qemu.sh
```

## Deploy on remote machine over SSH

Make sure the `deploy.nodes.hala.hostname` in `flake.nix` is correct and run:

```sh
nix run .#deploy -- .#hala
```
