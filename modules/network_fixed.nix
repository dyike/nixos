{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };
  
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
  # 使用 lib.mkForce 强制覆盖 resolv.conf
  # environment.etc."resolv.conf".text = lib.mkForce ''
  #   nameserver 127.0.0.1
  #   nameserver 223.5.5.5
  #   nameserver 114.114.114.114
  # '';

  # 使用 iptables 将 53 端口重定向到 5300
  # networking.firewall.extraCommands = ''
  #   iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-port 5300
  #   iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-port 5300
  #   iptables -t nat -A OUTPUT -p udp -d 127.0.0.1 --dport 53 -j REDIRECT --to-port 5300
  #   iptables -t nat -A OUTPUT -p tcp -d 127.0.0.1 --dport 53 -j REDIRECT --to-port 5300
  # '';

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
