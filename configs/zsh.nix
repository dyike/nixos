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
      autoload -Uz compinit
      compinit
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
            echo "%F{red}✗%f"
          fi
        fi
      }
      
      function git_prompt_status() {
        local symbols=""
        
        if ! git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
          return
        fi
        
        local git_status=$(git status --porcelain 2>/dev/null)
        
        # Untracked files
        if echo "$git_status" | grep -q '^?? '; then
          symbols+="%F{red}?%f"
        fi
        
        # Stashed changes
        if git rev-parse --verify refs/stash &>/dev/null 2>&1; then
          symbols+="%F{yellow}\$%f"
        fi
        
        # Ahead/behind remote
        local ahead_behind=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)
        if [[ -n "$ahead_behind" ]]; then
          local behind=$(echo "$ahead_behind" | awk '{print $1}')
          local ahead=$(echo "$ahead_behind" | awk '{print $2}')
          if [[ $ahead -gt 0 && $behind -gt 0 ]]; then
            symbols+="%F{magenta}⇕%f"
          elif [[ $ahead -gt 0 ]]; then
            symbols+="%F{green}↑%f"
          elif [[ $behind -gt 0 ]]; then
            symbols+="%F{red}↓%f"
          fi
        fi
        
        echo "$symbols"
      }
      
      GRAY="%F{245}"
      BLUE="%F{33}"
      MAGENTA="%F{201}"
      GREEN="%F{46}"
      RESET="%f"
      GIT_ICON=""
      
      precmd() { 
        vcs_info
      }
      
      PS1="''${GRAY}%T ''${BLUE}%~''${MAGENTA}''${GIT_ICON}\$vcs_info_msg_0_\$(git_dirty)\$(git_prompt_status)''${RESET} ''${GREEN}❯''${RESET} "
      EOF
      
      source ~/.zsh_nix_prompt
    '';
  };
}
