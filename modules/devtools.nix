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
    libxkbcommon
    xorg.libxcb
    xorg.libX11
    vulkan-loader
    curl
    wget
    htop
    tmux
    tree
    tcpdump
    gcc
    gnumake
    nodejs_22
    yarn
    pnpm
    python3
    rustup
    go
    gopls
    delve
    golangci-lint
  ];

  environment.variables = {
    LIBRARY_PATH = "/run/current-system/sw/lib";
    LD_LIBRARY_PATH = "/run/current-system/sw/lib";
    PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig:/run/current-system/sw/share/pkgconfig";
  };

}
