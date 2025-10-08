self: super: {
  ffmpeg = let
    ffmpegPkg = super.callPackage
      "${super.path}/pkgs/development/libraries/ffmpeg/generic.nix" {
        version = "7.0.3";
        hash = "sha256-J6WLj4l7KuqMnEDOgpmSynYIYF2NeOvDEAwdQyMkVcw=";

        withCuda = false;
        withCudaLLVM = false;
        withCudaNVCC = false;

        inherit (super.darwin) xcode;
        inherit (super.cudaPackages) cuda_cudart cuda_nvcc libnpp;
      };
    ffmpegPkgNew = ffmpegPkg.overrideAttrs (old: {
      patches = super.lib.filter
        (p: isNull (super.lib.match ".*-texinfo-7.1.patch$" (toString p)))
        old.patches;
    });
  in ffmpegPkgNew;
}
