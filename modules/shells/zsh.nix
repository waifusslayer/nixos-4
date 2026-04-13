{ config, pkgs, lib, ... }:

# enable выставляется в default.nix — здесь только конфигурация
lib.mkIf (config.custom.preferredShell == "zsh") {

  programs.zsh = {
    enableCompletion          = true;
    autosuggestion.enable     = true;
    syntaxHighlighting.enable = true;

    shellAliases = config.custom.shellAliases;

    history = {
      path       = "${config.home.homeDirectory}/.zsh_history";
      size       = 50000;
      save       = 50000;
      share      = true;
      ignoreDups = true;
      extended   = true;
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        eval "$(starship init zsh)"
      '')

      (lib.mkOrder 550 ''
        if command -v kubectl &>/dev/null; then
          source <(kubectl completion zsh 2>/dev/null)
          export PATH="${config.home.homeDirectory}/.krew/bin:$PATH"
        fi
        command -v helm    &>/dev/null && source <(helm    completion zsh 2>/dev/null)
        command -v kubectx &>/dev/null && source <(kubectx completion zsh 2>/dev/null || true)
        command -v kubens  &>/dev/null && source <(kubens  completion zsh 2>/dev/null || true)
        command -v argocd  &>/dev/null && source <(argocd  completion zsh 2>/dev/null)
      '')

      (lib.mkOrder 600 ''
        [ -f "${pkgs.fzf}/share/fzf/completion.zsh"   ] && source "${pkgs.fzf}/share/fzf/completion.zsh"
        [ -f "${pkgs.fzf}/share/fzf/key-bindings.zsh" ] && source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
      '')

      (lib.mkOrder 900 ''
        [ -f "${config.home.homeDirectory}/.config/zsh/extra.zsh" ] && \
          source "${config.home.homeDirectory}/.config/zsh/extra.zsh"
      '')
    ];
  };
}
