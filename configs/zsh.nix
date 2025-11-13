{ config, pkgs, ... }:

{
  environment.extraInit = ''
    export PATH="$HOME/.yarn/bin:$PATH"
  '';
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    promptInit = ''
      autoload -Uz promptinit && promptinit
      prompt agnoster
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    '';
  };
}
