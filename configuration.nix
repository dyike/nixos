{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system.nix
    ./modules/users.nix
    ./modules/docker.nix
    ./modules/devtools.nix
    ./configs/git.nix
  ];

  networking = {
    hostName = "x-homelab";
    useDHCP = true;
    defaultGateway = "192.168.5.253";   # 由 DHCP 自动下发
  };

  users.users.yuanfeng = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
