{ flake, lib, ... }:
{ pkgs, config, ... }: rec {
  system.stateVersion = "23.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.require-sigs = false;

  imports = [ (import ./audio-config.nix) ];

  # Let 'nixos-version --json' know about the Git revision
  # of this flake.
  system.configurationRevision = lib.mkIf (flake ? rev) flake.rev;

  boot.kernelModules = [
    "dm-crypt" # to be able to mount encrypted hard drives
  ];

  boot.kernelParams = [ "mitigations=off" ];

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
    pkgs.v4l-utils

    # utils
    pkgs.usbutils
    pkgs.lshw
    pkgs.usbtop
    pkgs.pcm
  ];

  time.timeZone = "Europe/Sofia";

  services.sshd.enable = true;
  services.openssh.settings.PermitRootLogin = lib.mkDefault "yes";

  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [{
        command = "ALL";
        options = [ "NOPASSWD" ];
      }];
      groups = [ "wheel" ];
    }];
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
  users.groups.human = { gid = 1000; };

  # TODO: configuration data (users, networking) should not be in this file/repo
  # maybe see https://nixos.wiki/wiki/Agenix or similar for secret management
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMD5CjmMYpJ5d+EA/uXJZT4Kr67vZhLY+OOuIUPAvCEx human@hoth"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDqFyc4HjRIsx65ANqjq9IwLisVDskGvkN1G93N/iSlx human@arecibo"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJfwOOXhgSNsUykIPjDaWctbDVmaT6IZKeWTSOnX+aHP human@gallifrey"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAcniETp/OAUsrTqPhDcNpw4BURifIE4zuPNZ7V+o3X1 human@kessel"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAiwfMv31QvWl3gouR5852b1yKAXmR1gwEXaUBaBwJow human@shagrat"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyE0L8ivXyEMysyBiEUvc5xTmDyC4OpaljKvwPKsiZ16PvxM61IHumssaPUGaWYBxpkdQwVqeQigtI3yTz6xHV+Y05Po7ptqBs6LuXFWJ8dExTASq48deYh48M/hoELy6f9Ascs2/WZ39TK4X/Ok3/YH47K1A/o+qu3lfGswAJ393xQ4HioTMETPFag0NigwRPwSaBTJZHkKoMdsOWYPBUwE5l0wjoLLqkWTs0fD/78cxk5ctMaKWiqTq/iEt0Enw7L001rlN2ew24fnKOpkFEC7Wa3MYc3EXH1O0iVQSGC+rFF3hM+D7/m2NIGAvhnWmoBiCOZCUJl9RWehe8LQ1H gotha"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC//hCcxBoM3l06lagxvdJ/3bnckP2xtX93B5Pv1D2BGcGvjOgtiqJMY8HfrlbHj2KuG2SiMR6HBbm/utZF4mMBnvGscNjr8lb8tfdbj6ZRroig1ngTdRyZxXVoE0UXH/1Xz15ezuf+mTSaUV/GXPte1a2Xo1izp0bbdg6WYImD3aGf+XawZaS09Vsh4xqoXRd4cPXMiCFOz8iwq3L0ycep6MasNAYT6BOZ1qWECUn0IgrNJtM9Iaxk0nEarHAi3qEi/XTBIOtejLmz3vk1C5dPXHZk/C2qDMNawPoVQAJ9MhjH+HWSx9L/MMzjpknApovMiJ5pppGp80e5L5oHJjwqla+dunedO9GSkg2fW2Vlabk1DMRmUGEyYhLCTD4vop9xxLLq4e3jazgRI/l26yhxYJhrrQVCNJcCMitSoPeJJGhFUjNKgftGWyTHk2ICMlcpwtMoolecChstiHXnZsrrs1pREzt6dWZeOILHVUQ64eBbPhUrNjtuZCTkB/FPHaJVNJP/uiqC9NTpk3zVxycK7cqYeNsWAXlXcLjFAwXj2VOdOQz8XrW6zpeDPak/+v4I5q1dIh/1VeN7ESO/6h7wEzkNJd5YhZrVThjgxIbGy+OZfi2IslQX7GAf9rBbA/5jK0WCaJYvIt+zRXPxMfeAJcMn3sWYo7/jR1viB7YApQ== vasil@nymphadora"
  ];

  users.users.human.openssh.authorizedKeys.keys =
    users.users.root.openssh.authorizedKeys.keys;
}
