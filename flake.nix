{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
  let
    lib = nixpkgs.lib;

    hosts = {
      zver = (import ./configurations/zver);
    };

    pkg_overrides = { system } : (import ./common/pkg-overrides.nix) {
      inherit nixpkgs lib system;
    };

    getPkgs = system: let
        orig_pkgs = import nixpkgs ({
          inherit system;
        });

        pkgs = orig_pkgs.extend (pkg_overrides { inherit system; });
      in pkgs;

    buildHost = hostFunc: let
      hostInfo = hostFunc {
        inherit lib nixpkgs getPkgs;
        flake = self;
      };

      system = hostInfo.system;

      config = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = hostInfo.modules ++
          ([
            {
              nixpkgs.overlays = [ (pkg_overrides { inherit system; }) ];
              nixpkgs.config = (import ./common/nixpkgs-global-config.nix);
            }
          ]) ++
          (if hostInfo ? imports
          then [
              {
                imports = hostInfo.imports;
              }
            ]
          else []);
      };
    in {
      inherit config system;
      image =
        if hostInfo ? image
        then hostInfo.image
        else config.config.system.build.${hostInfo.imageBuilder};
      devTools = args: (
        if hostInfo ? devTools
        then hostInfo.devTools args
        else {}
      );
      devPkgs = args: (
        if hostInfo ? devPkgs
        then hostInfo.devPkgs args
        else {}
      );
    };

    hostsData = builtins.mapAttrs (
      name: hostFunc: (buildHost hostFunc)
    ) hosts;
  in {
    nixosConfigurations = builtins.mapAttrs (
      name: data: data.config
    ) hostsData;

    images = builtins.mapAttrs (
      name: data: data.image
    ) hostsData;
  } // (flake-utils.lib.eachDefaultSystem (hostSystem:
    let
      hostPkgs = nixpkgs.legacyPackages.${hostSystem};
    in {
      packages = (builtins.mapAttrs (
        host-name: data: (data.devPkgs { pkgs = (getPkgs hostSystem); })
      ) hostsData);

      apps = (builtins.mapAttrs (
        host-name: data: (builtins.mapAttrs (
          tool-name: tool-pkg: (flake-utils.lib.mkApp {
              drv = tool-pkg;
            })
          ) (data.devTools { pkgs = (getPkgs hostSystem); })
        )
      ) hostsData) // {
        deploy = {
          # here we need to do some magic that runs nix-copy-closure to the
          # target machines
          # and then nix-env -p <profile> --set <closure> on the target machine
          # maybe replicate deploy-rs's magic rollback,
          # or somehow use or patch deploy-rs itself
          # deploy-rs has a handy activate.rs binary that does the activation
          type = "app";
          program = let
            deployScript = hostPkgs.writeShellScript "deploy" ''
              ${hostPkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ".#$1" --target-host "$2"
            '';
          in
            "${deployScript}";
        };
        deploy-local = {
          type = "app";
          program = let
            deployScript = hostPkgs.writeShellScript "deploy-local" ''
              ${hostPkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ".#$1"
            '';
          in
            "${deployScript}";
        };
      };
    }
  ));
}

