{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "x-homelab";
    useNetworkd = true; # 用 systemd-networkd 管理网络
    firewall.enable = false;
  };

  services.resolved = {
    enable = true;
    extraConfig = ''
      DNS=192.168.5.3 223.5.5.5
      FallbackDNS=114.114.114.114 8.8.8.8 8.8.4.4
      Domains=~.
    '';
  };

  systemd.network = {
    enable = true;

    # 定义聚合接口 bond0
    netdevs."bond0" = {
      netdevConfig = {
        Name = "bond0";
        Kind = "bond";
      };
      bondConfig = {
        Mode = "802.3ad";      # LACP 聚合模式
        MIIMonitorSec = "1s";  # 链路检测间隔
        LACPTransmitRate = "fast";
        # TransmitHashPolicy 字段对 systemd-networkd 支持会因版本不同略有差异，
        # 如果此字段无效，可以在 /etc/modprobe.d/ 或内核参数调整：
        TransmitHashPolicy = "layer3+4";
      };
    };

    # 将物理接口 enp11s0 / enp12s0 加入 bond0
    networks."10-enp11s0" = {
      matchConfig.Name = "enp11s0";
      networkConfig.Bond = "bond0";
    };

    networks."10-enp12s0" = {
      matchConfig.Name = "enp12s0";
      networkConfig.Bond = "bond0";
    };

    # 配置 bond0 的 IP / 路由
    networks."20-bond0" = {
      matchConfig.Name = "bond0";
      networkConfig = {
        DHCP = "yes";   # 或者改成 StaticAddress = [ "192.168.5.xxx/24" ];
      };
      dhcpConfig = {
        UseDNS = false;
        USeRoutes = true;
      };
      routes = [
        { Gateway = "192.168.5.253"; Metric = 100; }
      ];
    };
  };

  boot.kernelModules = [ "bonding" "macvlan" ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.arp_filter" = 1;
    "net.ipv4.conf.all.arp_announce" = 2;
  };

  systemd.services.macvlan-shim = {
    description = "Create macvlan-shim interface for Docker macvlan bridge access";
    after = [ "network-online.target" "systemd-networkd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "macvlan-shim-start" ''
        set -e
        ${pkgs.iproute2}/bin/ip link del macvlan-shim 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip link set bond0 promisc on
        ${pkgs.iproute2}/bin/ip link add macvlan-shim link bond0 type macvlan mode bridge
        ${pkgs.iproute2}/bin/ip addr add 192.168.5.252/32 dev macvlan-shim
        ${pkgs.iproute2}/bin/ip link set macvlan-shim up
        ${pkgs.iproute2}/bin/ip route add 192.168.5.3/32 dev macvlan-shim || true
        ${pkgs.iproute2}/bin/ip route add 192.168.5.4/32 dev macvlan-shim || true
        ${pkgs.iproute2}/bin/ip route add 192.168.5.5/32 dev macvlan-shim || true
        ${pkgs.procps}/bin/sysctl -w net.ipv4.conf.all.proxy_arp=1
        ${pkgs.procps}/bin/sysctl -w net.ipv4.conf.bond0.proxy_arp=1
        ${pkgs.procps}/bin/sysctl -w net.ipv4.conf.macvlan-shim.proxy_arp=1
      '';
      ExecStop = pkgs.writeShellScript "macvlan-shim-stop" ''
        ${pkgs.iproute2}/bin/ip link del macvlan-shim || true
      '';
    };
  };

}

