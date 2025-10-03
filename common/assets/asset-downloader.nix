{ pkgs, config, lib, ... }:
let
  getAsset = { url, name, sha256, convert }:
    pkgs.stdenvNoCC.mkDerivation {
      name = "asset-${name}";
      meta.description = "asset: ${name}";
      src = pkgs.fetchurl { inherit url sha256; };
      buildInputs = [ pkgs.coreutils ];
      phases = [ "unpackPhase" "installPhase" ];

      unpackPhase = "true";

      installPhase = ''
        mkdir -p "$(dirname $out/"${name}")"
        outf="$out/${name}"
        inf="$src"
        ${convert}
      '';
    };

  getAssets = assets:
    pkgs.symlinkJoin {
      name = "assets";
      paths = map getAsset assets;
    };

  assetsPkg = getAssets config.mixos.assets;
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
        convert = lib.mkOption {
          type = lib.types.str;
          default = ''cp -vf "$inf" "$outf"'';
          description = ''
            Command to execute to convert the media. $inf and $outf will contain
            the input and output files. Simply copies by default
          '';
        };
      };
    });
    default = [ ];
    description = ''
      List of assets to download
    '';
  };

  config.home-manager.users.human.home.file.assets.source = assetsPkg;
}
