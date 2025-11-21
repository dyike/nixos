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
      zstyle ':vcs_info:git:*' formats '%b'
      zstyle ':vcs_info:git:*' actionformats '%b|%a'

      function git_dirty() {
        if git rev-parse --is-inside-work-tree &>/dev/null; then
          if ! git diff --quiet --ignore-submodules HEAD 2>/dev/null; then
            echo " ✗"
          fi
        fi
      }

      # 颜色定义
      GRAY="%F{242}"
      BLUE="%F{33}"
      MAGENTA="%F{201}"
      RED="%F{196}"
      GREEN="%F{46}"
      RESET="%f"
      GIT_ICON=""

      precmd() { vcs_info; }

      setopt PROMPT_SUBST

      # 带时间和箭头的 PS1
      # 格式: 时间 路径 分支名 dirty标记
      #       ❯
      # 例如: 19:50:34 /etc/nixos  master ✗
      #       ❯
      PS1="''${GRAY}%T ''${BLUE}%~''${MAGENTA}''${vcs_info_msg_0_:+ ''${GIT_ICON}$vcs_info_msg_0_}''${RED}''${vcs_info_msg_0_:+$(git_dirty)}''${RESET} ''${GREEN}❯''${RESET} "
      EOF

      source ~/.zsh_nix_prompt
    '';
  };
}
