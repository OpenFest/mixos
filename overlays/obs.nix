self: super: {
  obs-studio = super.obs-studio.overrideAttrs (previousAttrs: {
    # pipewire support is buggy on wayland compositors like sway
    # and causes obs to hang for 1min on startup
    pipewireSupport = false;

    cudaSupport = false;

    # enable this only if we start packaging decklink stuff…
    decklinkSupport = false;

    # These overrides mean obs-studio can't be substituted from the binary
    # cache and always builds from source. Its LTO release build is memory-
    # hungry per compile unit, so unbounded parallelism can OOM constrained
    # builders (e.g. Determinate Nix's macOS external-builder VM).
    env = previousAttrs.env // {
      NIX_BUILD_CORES = "4";
    };
  });
}
