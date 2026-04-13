{ config, pkgs, lib, ... }:

# enable выставляется в default.nix — здесь только конфигурация
lib.mkIf (config.custom.preferredShell == "fish") {

  programs.fish = {
    shellAliases = config.custom.shellAliases;

    interactiveShellInit = ''
      starship init fish | source

      if command -q kubectl
        set -gx PATH "${config.home.homeDirectory}/.krew/bin" $PATH
        kubectl completion fish 2>/dev/null | source
      end
      command -q helm   && helm   completion fish 2>/dev/null | source
      command -q argocd && argocd completion fish 2>/dev/null | source

      ${pkgs.fzf}/bin/fzf --fish | source

      set -gx fish_history "${config.home.homeDirectory}/.local/share/fish/fish_history"

      test -f "${config.home.homeDirectory}/.config/fish/extra.fish" && \
        source "${config.home.homeDirectory}/.config/fish/extra.fish"
    '';

    functions = {
      kctx = ''
        kubectx (kubectx | fzf --prompt="context> ")
      '';
      kns-pick = ''
        kubens (kubens | fzf --prompt="namespace> ")
      '';
    };
  };
}
