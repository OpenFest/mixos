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
      mapValues = f: attrset: builtins.mapAttrs (_: x: f x) attrset;
      mapValuesIf = f: attrset: lib.filterAttrs (_: x: x != null) (mapValues f attrset);
      foreskinHosts = name: let
        hostsFunc = import "${foreskinsDir}/${name}/hosts.nix";
        hostsData = hostsFunc { inherit nixpkgs; };
      in
        map (data: data // { foreskinName = name; }) hostsData;

      lib = nixpkgs.lib;
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ];
      foreskinsDir = ./foreskins;
      foreskinNames = lib.attrNames
        (lib.filterAttrs (_: type: type == "directory")
          (builtins.readDir foreskinsDir));
      hostList = builtins.concatLists (map foreskinHosts foreskinNames);
      hosts = builtins.listToAttrs (map (host: { name = host.hostname; value = host; }) hostList);
      nixosSystemArgs = host: {
        system = host.system;
        specialArgs = { inherit inputs; } // (if host ? moduleArgs then host.moduleArgs else {});
        modules = [ (foreskinsDir + "/${host.foreskinName}") ];
      };

      special = { inherit inputs; };
      mkNixos = host:
        nixpkgs.lib.nixosSystem (nixosSystemArgs host);

      mkImage = host:
        if host ? image then
          nixos-generators.nixosGenerate (host.image // (nixosSystemArgs host))
        else null;

      mkDeployment = host:
        if host ? deploy then
          {
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.${host.system}.activate.nixos
                (mkNixos host);
            };
          } // host.deploy
        else null;
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

      nixosConfigurations = mapValues mkNixos hosts;

      # e.g. self.packages.x86_64-linux.hala, self.packages.x86_64-linux.zver, ...
      packages = forAllSystems (_:  # FIXME: should this be the target system? I think we don't care
        mapValuesIf mkImage hosts
      );

      deploy = {
        magicRollback = true;
        nodes = mapValuesIf mkDeployment hosts;
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
