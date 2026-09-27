{
  description = "OpenFest/mixos";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    deploy-o-matic.url = "github:dexterlb/deploy-o-matic";
    deploy-o-matic.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      deploy-o-matic,
      ...
    }@inputs:
    let
      dom = deploy-o-matic.lib.deployOMatic {
        templatesDir = ./templates;
        overlaysDir = ./overlays;
        moduleArgs = {
          inherit inputs;
          nixosConfigurations = dom.nixosConfigurations;
        };
        nixpkgsConfig = (import ./nixpkgs-global-config.nix);
      };

      lib = nixpkgs.lib;
      forAllSystems = lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];
    in
    {
      nixosConfigurations = dom.nixosConfigurations;
      packages = dom.packages;
      deploy = dom.deploy;

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              OVMF.fd
              findutils
              gnumake
              rsync
            ];
          };
        }
      );

      apps =
        dom.apps
        // forAllSystems (
          system:
          let
            pkgs = (import nixpkgs { inherit system; });
            installer-img = dom.packages.x86_64-linux.mixos-installer-image;
            install = pkgs.writeShellApplication {
              name = "flash-mixos";
              runtimeInputs = [ pkgs.caligula ];
              text = ''
                find ${installer-img}/
                exec caligula burn --hash skip --compression none --root always \
                  ${installer-img}/nixos.img
              '';
            };
          in
          {
            default.type = "app";
            default.program = "${install}";
          }
        );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
