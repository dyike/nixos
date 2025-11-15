{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system.nix
    ./modules/network_fixed.nix
    # ./modules/network.nix
    ./modules/users.nix
    ./modules/docker.nix
    ./modules/devtools.nix
    ./configs/git.nix
    ./configs/nvim.nix
    ./configs/zsh.nix
  ];

  users.users.yuanfeng = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
