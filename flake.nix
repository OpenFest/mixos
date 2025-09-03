{
  description = "OpenFest/mixos";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-generators, home-manager, deploy-rs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ];
    in {

      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              OVMF.fd
              findutils
              gnumake
              nixfmt-classic
              rsync
            ];
          };
        });

      nixosConfigurations.zver = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./common/raw-efi.nix
          ./common/base-config.nix
          ./common/audio-config.nix
          #./common/nvidia.nix
          ./common/grow-root.nix
        ];
      };

      nixosConfigurations.hala = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./common/raw-efi.nix
          ./common/base-config.nix
          ./common/audio-config.nix
          ./common/virtio-initrd.nix
          home-manager.nixosModules.home-manager
          ({ config, pkgs, ... }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.human = {
              imports = [ ./common/home-manager.nix ];
              home.stateVersion = "25.05";
            };
          })
        ];
      };

      packages.x86_64-linux.hala = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "raw";
        modules = [
          ./common/raw-efi.nix
          ./common/base-config.nix
          ./common/audio-config.nix
          ./common/virtio-initrd.nix
          home-manager.nixosModules.home-manager
          ({ config, pkgs, ... }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.human = {
              imports = [ ./common/home-manager.nix ];
              home.stateVersion = "25.05";
            };
          })
        ];
      };

      deploy = {
        magicRollback = true; # optional but nice to have
        nodes = {
          hala = {
            hostname = "localhost";
            sshUser = "human";

            remoteBuild = false; # build on the target instead of locally
            fastConnection = true; # skip store verification for faster deploys
            sshOpts = [ "-p" "2222" ];

            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos
                self.nixosConfigurations.hala;
            };
          };
        };
      };

      # tiny helper so you can run `nix run .#deploy -- .#hala`
      apps = forAllSystems (system: {
        deploy = {
          type = "app";
          program = "${deploy-rs.packages.${system}.deploy-rs}/bin/deploy";
        };
      });

    };
}
