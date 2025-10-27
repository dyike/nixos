{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;

    daemon.settings = {
      # 镜像源
      registry-mirrors = [
        "https://hub-mirror.c.163.com"
        "https://mirror.gcr.io"
      ];
    };
  };
}
