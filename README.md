# MixOS

This repo contains configuration for a linux distribution optimised
for live audio/video mixing. Very much work in progress.

It is based on NixOS (atomic immutable deploys are quite suited for this usecase).

## Configurations

Every configuration has a corresponding directory in `configurations/`.

- `zver`: base configuration targeting x86_64 machines with NVidia GPUs

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

```sh
nix build nixpkgs#OVMF.fd
./run-qemu.sh
```

## Deploy on remote machine over SSH

@todo - WIP
