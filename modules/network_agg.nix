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
      FallbackDNS=114.114.114.114
      Domains=~.
    '';
  };

  systemd.network = {
    enable = true;

    # 第一张网卡
    networks."10-enp11s0" = {
      matchConfig.Name = "enp11s0";
      networkConfig = {
        DHCP = "yes";
      };
      dhcpConfig = {
        UseDNS = false;   # 不使用DHCP下发的DNS
        UseRoutes = true; # 使用默认路由
      };
      routes = [
        { Gateway = "192.168.5.253"; Metric = 100; }
      ];
    };

    # 第二张网卡（作为备用，可以同样配置）
    networks."10-enp12s0" = {
      matchConfig.Name = "enp12s0";
      networkConfig = {
        DHCP = "yes";
      };
      dhcpConfig = {
        UseDNS = false;
        UseRoutes = true;
      };
      routes = [
        { Gateway = "192.168.5.253"; Metric = 200; } # 高metric表示备份
      ];
    };
  };

  boot.kernelModules = [ "macvlan" ];

  # 保留 macvlan shim 逻辑
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
        ${pkgs.iproute2}/bin/ip link set enp11s0 promisc on
        ${pkgs.iproute2}/bin/ip link add macvlan-shim link enp11s0 type macvlan mode bridge
        ${pkgs.iproute2}/bin/ip addr add 192.168.5.252/32 dev macvlan-shim
        ${pkgs.iproute2}/bin/ip link set macvlan-shim up
        ${pkgs.iproute2}/bin/ip route add 192.168.5.3/32 dev macvlan-shim || true
        ${pkgs.iproute2}/bin/ip route add 192.168.5.4/32 dev macvlan-shim || true
        ${pkgs.iproute2}/bin/ip route add 192.168.5.5/32 dev macvlan-shim || true
        ${pkgs.procps}/bin/sysctl -w net.ipv4.conf.all.proxy_arp=1
        ${pkgs.procps}/bin/sysctl -w net.ipv4.conf.enp11s0.proxy_arp=1
        ${pkgs.procps}/bin/sysctl -w net.ipv4.conf.macvlan-shim.proxy_arp=1
      '';
      ExecStop = pkgs.writeShellScript "macvlan-shim-stop" ''
        ${pkgs.iproute2}/bin/ip link del macvlan-shim || true
      '';
    };
  };

  # DNS 健康检测逻辑保留
  systemd.timers.dns-health-check = {
    description = "Periodic DNS health check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "30s";
      AccuracySec = "5s";
    };
  };

  systemd.services.dns-health-check = {
    description = "Check and restore primary DNS if available";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "dns-health-check" ''
        PRIMARY="192.168.5.3"
        CURRENT=$(${pkgs.systemd}/bin/resolvectl status | grep "Current DNS Server:" | head -1 | awk '{print $4}')
        if [ "$CURRENT" != "$PRIMARY" ]; then
          if ${pkgs.iputils}/bin/ping -c 1 -W 2 $PRIMARY >/dev/null 2>&1; then
            echo "Primary DNS $PRIMARY is back online, resetting resolved..."
            ${pkgs.systemd}/bin/resolvectl flush-caches
            ${pkgs.systemd}/bin/resolvectl reset-server-features
            sleep 1
            ${pkgs.systemd}/bin/systemctl restart systemd-resolved
          fi
        fi
      '';
    };
  };
}
