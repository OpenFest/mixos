self: super: {
  obs-studio = super.obs-studio.overrideAttrs {
    # pipewire support is buggy on wayland compositors like sway
    # and causes obs to hang for 1min on startup
    pipewireSupport = false;

    # enable this only if we start packaging decklink stuff…
    decklinkSupport = false;
  };
}
