{ pkgs, ... }:

{
  users.users.yuan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAA... your_pubkey"
    # ];
  };
  programs.zsh.enable = true;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
}
