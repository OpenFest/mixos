# MixOS

This repo contains configuration for a linux distribution optimised
for live audio/video mixing. Very much work in progress.

It is based on NixOS (atomic immutable deploys are quite suited for this usecase).

## Templates and hosts

The configuration is split into templates for different kinds of machines.
Each template is instantiated into one or more hosts.

- `obs-station-qemu`: for running an OBS workstation under qemu for testing
    - `hala`: development host for running locally
- `obs-station-nvidia`: for running an OBS workstation on machines with NVIDIA gpus
    - `zver`: an nvidia-based machine currently located in the protopit office
- `fosdem-box`: for headless mixing on [fosdem boxes](https://github.com/fosdem/video)
    - `fosdem-box-101`: one of the testing boxes
    - `fosdem-box-102`: one of the testing boxes
    - `fosdem-box-103`: one of the testing boxes

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
