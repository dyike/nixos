{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "x-homelab";
    useNetworkd = true; # 用 systemd-networkd 管理网络
    firewall.enable = false;
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
      routes = [
        { Gateway = "192.168.5.253"; Metric = 100; }
      ];
    };
  };

  boot.kernelModules = [ "bonding" ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.arp_filter" = 1;
    "net.ipv4.conf.all.arp_announce" = 2;
  };
}

