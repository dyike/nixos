{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    zsh
    zsh-completions
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
    ffmpeg-full
    iperf3
    iptables
    iproute2
    procps
    git
    git-credential-manager
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
