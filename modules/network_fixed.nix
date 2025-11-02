{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.route_localnet" = 1;
    "net.ipv4.conf.default.route_localnet" = 1;
  };
  boot.kernelModules = [ "wireguard" "iptable_nat" "ip6table_nat" ];
  
  networking = {
    hostName = "x-homelab";
    useNetworkd = true;
    firewall.enable = false;
  };

  services.resolved = {
    enable = true;
    extraConfig = ''
      DNSStubListener=no
      DNS=127.0.0.1
      FallbackDNS=223.5.5.5 114.114.114.114
      Domains=~.
    '';
  };

  systemd.services.wg-wan2-route = {
    description = "WireGuard WAN2 policy routing setup";
    after = [ "network-online.target" "docker.service" ];
    wants = [ "network-online.target" "docker.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/data/app/moni/wireguard/ct-wan/wg-wan2-ct-route.sh";
      Environment = "PATH=/run/current-system/sw/bin:/run/wrappers/bin";
    };
    wantedBy = [ "multi-user.target" ];
  };


  systemd.network = {
    enable = true;
    networks = {
      "10-enp11s0" = {
        matchConfig.Name = "enp11s0";
        networkConfig = {
          Address = "192.168.5.1/24";
          Gateway = "192.168.5.253";  # 添加到主路由表
        };
        routes = [
          { Gateway = "192.168.5.253"; Table = 100; Metric = 100; }
        ];
        routingPolicyRules = [
          { Priority = 100; From = "192.168.5.1/32"; Table = 100; }
        ];
      };

      "10-enp12s0" = {
        matchConfig.Name = "enp12s0";
        networkConfig = {
          Address = "192.168.5.2/24";
        };
        routes = [
          { Gateway = "192.168.5.253"; Table = 101; Metric = 100; }
        ];
        routingPolicyRules = [
          { Priority = 100; From = "192.168.5.2/32"; Table = 101; }
        ];
      };
    };
  };
}
