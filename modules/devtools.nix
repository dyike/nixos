{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    zip
    xz
    p7zip
    unzip
    ripgrep
    fzf # A command-line fuzzy finder 
    nload
    chafa
    iperf3
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
    tcpdump
    gcc
    gnumake
    nodejs_20
    yarn
    pnpm
    python3
    rustup
    go
    gopls
    delve
    golangci-lint
  ];
}
