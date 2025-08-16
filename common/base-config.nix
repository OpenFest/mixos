{ flake, lib, ... }:
{ pkgs, config, ... }: rec {
  system.stateVersion = "23.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.require-sigs = false;

  imports = [
    (import ./audio-config.nix)
  ];

  # Let 'nixos-version --json' know about the Git revision
  # of this flake.
  system.configurationRevision = lib.mkIf (flake ? rev) flake.rev;

  boot.kernelModules = [
    "dm-crypt" # to be able to mount encrypted hard drives
  ];

  boot.kernelParams = [
    "mitigations=off"
  ];

  environment.systemPackages = [
    # absolutely essential
    pkgs.rsync
    pkgs.sshfs
    pkgs.git
    pkgs.neovim
    pkgs.coreutils-full
    pkgs.moreutils
    pkgs.sl
    pkgs.tmux

    # video shit
    pkgs.obs-studio
    pkgs.obs-studio-plugins.advanced-scene-switcher
    pkgs.guvcview
    pkgs.v4l-utils

    # gui shit
    pkgs.firefox
    pkgs.tigervnc
    pkgs.alacritty
    pkgs.fuzzel

    # utils
    pkgs.usbutils
    pkgs.lshw
    pkgs.usbtop
    pkgs.pcm

    # sigplan sandbox
    pkgs.cryptsetup   # for integritysetup
  ];

  time.timeZone = "Europe/Sofia";

  services.sshd.enable = true;
  services.openssh.settings.PermitRootLogin = lib.mkDefault "yes";

  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
  };

  services.displayManager = {
    # defaultSession = "fluxbox";
    autoLogin.enable = true;
    autoLogin.user = "human";
    sddm = {
      enable = true;
      wayland = {
        enable = false; # fixme
      };
    };
  };
  programs.niri.enable = true;

  services.xserver = {
    enable = true; # fixme
    windowManager.fluxbox.enable = true;
  };

  users.users.human = {
    home = "/home/human";
    description = "human";
    extraGroups = [ "wheel" "video" "audio" "power" "adm" ];
    isSystemUser = false;
    isNormalUser = true;
    group = "human";
    uid = 1000;
    password = "asdf";
  };
  users.groups.human = {
    gid = 1000;
  };

  # TODO: configuration data (users, networking) should not be in this file/repo
  # maybe see https://nixos.wiki/wiki/Agenix or similar for secret management
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMD5CjmMYpJ5d+EA/uXJZT4Kr67vZhLY+OOuIUPAvCEx human@hoth"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDqFyc4HjRIsx65ANqjq9IwLisVDskGvkN1G93N/iSlx human@arecibo"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJfwOOXhgSNsUykIPjDaWctbDVmaT6IZKeWTSOnX+aHP human@gallifrey"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAcniETp/OAUsrTqPhDcNpw4BURifIE4zuPNZ7V+o3X1 human@kessel"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAiwfMv31QvWl3gouR5852b1yKAXmR1gwEXaUBaBwJow human@shagrat"
  ];

  users.users.human.openssh.authorizedKeys.keys = users.users.root.openssh.authorizedKeys.keys;
}
