{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    zsh
    zip
    xz
    p7zip
    unzip
    ripgrep
    fzf # A command-line fuzzy finder 
    nload
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
    gcc
    gnumake
    go
    nodejs_20
    python3
  ];
}
