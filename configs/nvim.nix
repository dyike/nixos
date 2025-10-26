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
    else
      if [ -d "$USER_HOME/.config/nvim/.git" ]; then
        echo "Updating existing Neovim configuration..."
        (cd $USER_HOME/.config/nvim && git pull) || {
          echo "Warning: Failed to update repository. Continuing with existing configuration."
        }
      else
        echo "Replacing non-git Neovim configuration..."
        rm -rf $USER_HOME/.config/nvim
        git clone https://github.com/dyike/nvimrc.git $USER_HOME/.config/nvim || {
          echo "Error: Failed to clone repository."
          exit 1
        }
      fi
    fi
    echo "Neovim configuration setup complete."
  '';
}
