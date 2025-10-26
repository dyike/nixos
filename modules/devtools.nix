{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    openssh
    dig
    neovim
    neofetch
    curl
    wget
    htop
    tmux
    tree
    unzip
    gcc
    gnumake
    go
    nodejs_20
    python3
  ];
}
