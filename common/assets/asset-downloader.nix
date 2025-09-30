{ pkgs, config, lib, ... }:
let
  getAsset = { url, name, sha256 }:
    pkgs.stdenvNoCC.mkDerivation {
      name = "asset-${name}";
      meta.description = "asset: ${name}";
      src = pkgs.fetchurl { inherit url sha256; };
      buildInputs = [ pkgs.coreutils ];
      phases = [ "unpackPhase" "installPhase" ];

      unpackPhase = "true";

      installPhase = ''
        mkdir -p "$(dirname $out/"${name}")"
        cp -vf $src $out/"${name}"
      '';
    };

  getAssets = assets:
    pkgs.symlinkJoin {
      name = "assets";
      paths = map getAsset assets;
    };

  assetsPkg = getAssets config.mixos.assets;

  symlink-assets-at-home = pkgs.writeShellApplication {
    name = "symlink-assets-at-home";
    runtimeInputs = [ ];
    text = ''
      set -euo pipefail

      if [[ -e "$HOME/assets" ]]; then
        rm "$HOME/assets"
      fi

      ln -svf "${assetsPkg}" "$HOME/assets"
    '';
  };
in {
  options.mixos.assets = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        url = lib.mkOption {
          type = lib.types.str;
          description = "URL to download the asset from";
        };
        sha256 = lib.mkOption {
          type = lib.types.str;
          description = "Hash of the asset";
        };
        name = lib.mkOption {
          type = lib.types.str;
          description =
            "Filename to save the asset to (might contain slashes for deeper paths)";
        };
      };
    });
    default = [ ];
    description = ''
      List of assets to download
    '';
  };

  config = {
    systemd.services.symlink-assets-at-home = {
      enable = true;
      description = "symlink assets in home dir";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${symlink-assets-at-home}/bin/symlink-assets-at-home";
        User = "human";
        Group = "human";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
