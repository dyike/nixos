{ pkgs, ... }:

{
  # 开机/重建后自动执行脚本
  system.activationScripts.nvimConfigSetup.text = ''
    USER_HOME="/home/yuanfeng"
    export PATH="${pkgs.openssh}/bin:${pkgs.git}/bin:$PATH"
    echo "Setting up Neovim configuration..."

    if [ ! -d "$USER_HOME/.config/nvim" ]; then
      echo "Cloning Neovim configuration repository..."
      git clone https://github.com/dyike/nvimrc.git $USER_HOME/.config/nvim || {
        echo "Error: Failed to clone repository."
        exit 1
      }
    fi
    echo "Neovim configuration setup complete."
  '';
}
