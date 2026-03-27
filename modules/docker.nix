{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;

    daemon.settings = {
      # 镜像源
      registry-mirrors = [
        "https://docker.xuanyuan.me"
        "https://docker.rainbond.cc"
        "https://hub.rat.dev"
        "https://dockerpull.org"
        "https://docker.1panel.live"
      ];
    };
  };
}
