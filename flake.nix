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

  outputs = { self, nixpkgs, nixos-generators, deploy-rs, ... }@inputs:
    let
      templatesDir = ./templates;
      overlaysDir = ./overlays;

      # get all templates, and from there get all hosts (≥1 hosts per template, usually 1)
      templateNames = dirsInDir templatesDir;
      hostList = builtins.concatLists (map templateHosts templateNames);
      hosts = builtins.listToAttrs (map (host: {
        name = host.hostname;
        value = host;
      }) hostList);

      # build a nixos configuration for the given host
      mkNixos = host: lib.nixosSystem (nixosSystemArgs host);

      # build a bootable disk image for the host, if configured
      mkImage = host:
        if host ? image then
          nixos-generators.nixosGenerate (host.image // (nixosSystemArgs host))
        else
          null;

      # build a deploy-rs recipe for the host, if configured
      mkDeployment = host:
        if host ? deploy then
          {
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.${host.system}.activate.nixos (mkNixos host);
            };
          } // host.deploy
        else
          null;

      nixosSystemArgs = host: {
        system = host.system;
        specialArgs = {
          inherit inputs;
        } // (if host ? moduleArgs then host.moduleArgs else { });
        modules = [
          (templatesDir + "/${host.templateName}")
          { nixpkgs.overlays = overlays; }
        ];
      };

      # the usual shit
      lib = nixpkgs.lib;
      forAllSystems = lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ];

      # nixpkgs overlays (used for custom package overrides)
      overlays = map (src: import "${overlaysDir}/${src}") overlaySources;
      overlaySources = lib.attrNames (lib.filterAttrs
        (name: type: type == "directory" || lib.hasSuffix ".nix" name)
        (builtins.readDir overlaysDir));

      # gives a list of hosts from a single template
      templateHosts = name:
        let
          hostsFunc = import "${templatesDir}/${name}/hosts.nix";
          hostsData = hostsFunc {
            inherit nixpkgs;
          }; # maybe pass some other convenient stuff here
        in map (data: data // { templateName = name; }) hostsData;

      # util functions
      mapValues = f: attrset: builtins.mapAttrs (_: x: f x) attrset;
      mapValuesIf = f: attrset:
        lib.filterAttrs (_: x: x != null) (mapValues f attrset);
      dirsInDir = dirname:
        lib.attrNames (lib.filterAttrs (_: type: type == "directory")
          (builtins.readDir dirname));
    in {
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system overlays; };
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
      packages = forAllSystems
        (_: # FIXME: should this be the target system? I think we don't care
          mapValuesIf mkImage hosts);

      # deploy-rs nodes
      deploy = {
        magicRollback = true;
        nodes = mapValuesIf mkDeployment hosts;
      };

      # deploy-rs checks
      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      # tiny helper so you can run `nix run .#deploy -- .#hala`
      apps = forAllSystems (system: {
        deploy = {
          type = "app";
          program = "${deploy-rs.packages.${system}.deploy-rs}/bin/deploy";
        };
      });
    };
}
