{
  description = "OpenFest/mixos";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    deploy-o-matic.url = "github:dexterlb/deploy-o-matic";
    deploy-o-matic.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, deploy-o-matic, ... }@inputs:
    let
      dom = deploy-o-matic.lib.deployOMatic {
        templatesDir = ./templates;
        overlaysDir = ./overlays;
        moduleArgs = { inherit inputs; };
        nixpkgsConfig = (import ./nixpkgs-global-config.nix);
      };

      lib = nixpkgs.lib;
      forAllSystems = lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ];
    in {
      nixosConfigurations = dom.nixosConfigurations;
      packages = dom.packages;
      deploy = dom.deploy;
      checks = dom.checks;
      apps = dom.apps;

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
    };
}
