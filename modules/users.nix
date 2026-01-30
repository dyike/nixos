{ pkgs, ... }:

{
  users.users.yuan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };
  programs.zsh.enable = true;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
}
