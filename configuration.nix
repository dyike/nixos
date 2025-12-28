{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system.nix
    ./modules/network_fixed.nix
    # ./modules/network.nix
    ./modules/users.nix
    ./modules/docker.nix
    ./modules/devtools.nix
    ./configs/git.nix
    ./configs/nvim.nix
    ./configs/zsh.nix
    ./configs/npm.nix
  ];

  users.users.yuanfeng = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  services.xserver = {
    enable = true;

    # 1. 启用 Xfce 桌面环境
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };

    # 2. 使用 LightDM 显示管理器 (比 GDM 更轻量，更适合 Xfce)
    displayManager.lightdm.enable = true;
    
    # 3. 键盘布局 (可选，通常保持默认)
    # layout = "us";
  };

  # 4. 显式禁用 GNOME 和 GDM (防止之前的配置冲突)
  services.xserver.desktopManager.gnome.enable = false;
  services.xserver.displayManager.gdm.enable = false;

  # 5. 配置 XRDP (RDP 服务)
  services.xrdp = {
    enable = true;
    # 核心指令：告诉 RDP 登录后启动 Xfce
    defaultWindowManager = "startxfce4";
  };

  # 6. 安装一些 Xfce 常用工具 (可选，推荐安装以免进来只有个鼠标)
  environment.systemPackages = with pkgs; [
    xfce.xfce4-terminal
    xfce.xfce4-taskmanager
    firefox # 或者是 chromium，方便你在服务器上测试网页
  ];

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
