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

  outputs =
    { self, nixpkgs, nixos-generators, home-manager, deploy-rs, ... }@inputs:
    let
      lib = nixpkgs.lib;
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ];
      targetSystem = "x86_64-linux";
      machinesDir = ./machines;
      machineNames = lib.attrNames
        (lib.filterAttrs (_: type: type == "directory")
          (builtins.readDir machinesDir));
      special = { inherit inputs; };
      mkNixos = name:
        nixpkgs.lib.nixosSystem {
          system = targetSystem;
          specialArgs = special;
          modules = [ (machinesDir + "/${name}") ];
        };

      mkImage = name:
        nixos-generators.nixosGenerate {
          system = targetSystem;
          format = "raw";
          specialArgs = special;
          modules = [ (machinesDir + "/${name}") ];
        };
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

      nixosConfigurations = builtins.listToAttrs (map (name: {
        inherit name;
        value = mkNixos name;
      }) machineNames);

      # e.g. self.packages.x86_64-linux.hala, self.packages.x86_64-linux.zver, ...
      packages.${targetSystem} = builtins.listToAttrs (map (name: {
        inherit name;
        value = mkImage name;
      }) machineNames);

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
