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
          DHCP = "ipv4";
          # 告诉系统，即使 DHCP 给了 IP，也要优先用我上面写的静态 Address
          IPv4LLRoute = false;
        };
        # 确保 DHCP 获取到的 DNS 能够被注册到全局
        dhcpV4Config = {
          UseDNS = true;
          UseRoutes = false; # 只想要它的 DNS，不想要它乱改我的默认网关
        };
      };

      "10-enp12s0" = {
        matchConfig.Name = "enp12s0";
        networkConfig = {
          Address = "192.168.5.4/24";
        };
      };
    };
  };
}
