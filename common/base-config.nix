{ flake, lib, ... }:
{ pkgs, ... }: rec {
  system.stateVersion = "23.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.require-sigs = false;

  # Let 'nixos-version --json' know about the Git revision
  # of this flake.
  system.configurationRevision = lib.mkIf (flake ? rev) flake.rev;

  environment.systemPackages = [
    pkgs.rsync
    pkgs.git
    pkgs.neovim
    pkgs.coreutils-full
    pkgs.moreutils
    pkgs.obs-studio
    pkgs.guvcview
    pkgs.qpwgraph
    pkgs.pavucontrol
    pkgs.firefox
    pkgs.v4l-utils
    pkgs.tigervnc
  ];

  services.sshd.enable = true;
  services.openssh.settings.PermitRootLogin = lib.mkDefault "yes";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  security.sudo = {
    enable = true;

    extraRules = [{
      commands = [
      ];
      groups = [ "wheel" ];
    }];
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
  ];

  users.users.human.openssh.authorizedKeys.keys = users.users.root.openssh.authorizedKeys.keys;
}
