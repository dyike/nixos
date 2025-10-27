{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system.nix
    ./modules/users.nix
    ./modules/docker.nix
    ./modules/devtools.nix
    ./configs/git.nix
    ./configs/nvim.nix
    ./configs/zsh.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.arp_filter" = 1;
    "net.ipv4.conf.enp11s0.arp_filter" = 1;
    "net.ipv4.conf.enp12s0.arp_filter" = 1;
    "net.ipv4.conf.all.arp_announce" = 2;
    "net.ipv4.conf.enp11s0.arp_announce" = 2;
    "net.ipv4.conf.enp12s0.arp_announce" = 2;
  };
  
  networking = {
    hostName = "x-homelab";
    useNetworkd = true;  # 用 systemd-networkd 更稳

    # 默认网关走 enp11s0
    #defaultGateway = {
    #  address = "192.168.5.253";
    #  interface = "enp11s0";
    #};
  };
  
  systemd.network = {
    enable = true;
    networks = {
      "10-enp11s0" = {
        matchConfig.Name = "enp11s0";
        networkConfig.DHCP = "yes";
        routes = [
          { Gateway = "192.168.5.253"; Metric = 100; }
          { Gateway = "192.168.5.253"; Table = 100; Metric = 100; }
        ];
        routingPolicyRules = [
          { Priority = 1000; From = "192.168.5.97/32"; Table = 100; }
        ];
      };
  
      "10-enp12s0" = {
        matchConfig.Name = "enp12s0";
        networkConfig.DHCP = "yes";
        dhcpConfig.UseRoutes = false;
        routes = [
          { Gateway = "192.168.5.253"; Table = 101; Metric = 200; }
        ];
        routingPolicyRules = [
          { Priority = 1100; From = "192.168.5.100/32"; Table = 101; }
        ];
      };
    };
  };
  users.users.yuanfeng = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
