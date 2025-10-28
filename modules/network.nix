{ config, lib, pkgs, ... }:

{
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
    useNetworkd = true;  # 使用 systemd-networkd 更稳
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
}

