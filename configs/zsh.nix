{ config, pkgs, ... }:
{
  environment.extraInit = ''
    export PATH="$HOME/.yarn/bin:$PATH"
  '';
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    enableGlobalCompInit = false;
    interactiveShellInit = ''
      # 防止 zsh-newuser-install
      touch ~/.zshrc
    '';
    promptInit = ''
      cat <<'EOF' > ~/.zsh_nix_prompt
      autoload -Uz vcs_info
      setopt prompt_subst
      
      zstyle ':vcs_info:*' enable git
      zstyle ':vcs_info:git:*' formats ' %b'
      zstyle ':vcs_info:git:*' actionformats ' %b|%a'
      
      function git_dirty() {
        if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
          if ! git diff --quiet --ignore-submodules HEAD 2>/dev/null; then
            echo " ✗"
          fi
        fi
      }
      
      GRAY="%F{245}"
      BLUE="%F{33}"
      MAGENTA="%F{201}"
      RED="%F{196}"
      GREEN="%F{46}"
      RESET="%f"
      GIT_ICON=""
      
      precmd() { 
        vcs_info
      }
      
      PS1="''${GRAY}%T ''${BLUE}%~''${MAGENTA}''${GIT_ICON}\$vcs_info_msg_0_''${RED}\$(git_dirty)''${RESET} ''${GREEN}❯''${RESET} "
      EOF
      
      source ~/.zsh_nix_prompt
    '';
  };
}
