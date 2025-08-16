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

## Quick start

To build the distribution and burn a bootable drive (make sure to use a fast drive), do:

```bash
$ ./deploy.sh image-on <configuration> /dev/sdX
```

To deploy changes to an already-running machine, do:

```bash
$ ./deploy.sh sync <configuration> <hostname or IP address>
```

If you want to build everything locally instead of on the target machine,
use `remote` instead of `sync`.
