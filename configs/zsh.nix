{ config, pkgs, lib, ... }:

let
  homeDir = config.home.homeDirectory;
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      path = "${homeDir}/.zsh_history";
      ignoreDups = true;
      share = true;
      expireDuplicatesFirst = true;
    };

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" "sudo" "z" "history" "extract" ];
    };

    initExtra = ''
      # Custom prompt with enhanced Git status
      autoload -Uz vcs_info
      zstyle ':vcs_info:*' enable git
      zstyle ':vcs_info:*' check-for-changes true
      zstyle ':vcs_info:*' unstagedstr '!'
      zstyle ':vcs_info:*' stagedstr '+'
      zstyle ':vcs_info:git:*' formats ' %F{cyan}(%F{green}%b%f%F{yellow}%u%c%f%F{cyan})%f'
      zstyle ':vcs_info:git:*' actionformats ' %F{cyan}(%F{green}%b%f|%F{red}%a%f%F{yellow}%u%c%f%F{cyan})%f'

      function git_prompt_status() {
        local symbols=""
        local git_status=$(git status --porcelain 2>/dev/null)
        if echo "$git_status" | grep -q '?? '; then
          symbols+="%F{red}?%f"
        fi
        if git rev-parse --verify refs/stash &>/dev/null; then
          symbols+="%F{yellow}$%f"
        fi
        local ahead_behind=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)
        if [[ -n "$ahead_behind" ]]; then
          local ahead=$(echo "$ahead_behind" | awk '{print $2}')
          local behind=$(echo "$ahead_behind" | awk '{print $1}')
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

      precmd() {
        vcs_info
      }

      setopt PROMPT_SUBST
      PROMPT='%F{blue}%n%f@%F{green}%m%f:%F{yellow}%~%f$vcs_info_msg_0_$(git_prompt_status)'$'\n'
      PROMPT+='%F{magenta}➜%f '
      RPROMPT='%F{white}%*%f'

      bindkey -s '^R' 'clear\n'

      alias ll="ls -l"
      alias la="ls -A"
      alias l="ls -CF"
      alias go="goenv"
    '';

    envExtra = ''
      export PATH="${homeDir}/.local/bin:${homeDir}/.npm-global/bin:$PATH"
      export NPM_CONFIG_PREFIX="${homeDir}/.npm-global"
      export SHELL="${config.home.profileDirectory}/bin/zsh"
      export LANG=en_US.UTF-8
      export LC_ALL=en_US.UTF-8
      export PATH="${config.home.profileDirectory}/bin:${homeDir}/.local/bin:${homeDir}/.npm-global/bin:${pkgs.coreutils}/bin:${pkgs.git}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
    '';
  };
}
