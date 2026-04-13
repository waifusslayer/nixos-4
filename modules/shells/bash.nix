{ config, pkgs, lib, ... }:

# Этот модуль активен когда preferred=bash, fish или ksh.
# При fish/ksh bash служит только точкой входа для автозапуска нужного шелла.
lib.mkIf (config.custom.preferredShell == "bash"
       || config.custom.preferredShell == "fish"
       || config.custom.preferredShell == "ksh") {

  programs.bash = {
    shellAliases    = lib.mkIf (config.custom.preferredShell == "bash") config.custom.shellAliases;
    historyFile     = "${config.home.homeDirectory}/.bash_history";
    historyFileSize = 50000;
    historySize     = 50000;
    historyControl  = [ "ignoredups" "erasedups" ];

    initExtra =
      # Если preferred — fish или ksh, просто пробрасываем в нужный шелл
      if config.custom.preferredShell == "fish" then ''
        if [ -z "$_PREFERRED_SHELL_EXEC" ]; then
          export _PREFERRED_SHELL_EXEC=1
          exec ${pkgs.fish}/bin/fish
        fi
      ''
      else if config.custom.preferredShell == "ksh" then ''
        if [ -z "$_PREFERRED_SHELL_EXEC" ]; then
          export _PREFERRED_SHELL_EXEC=1
          exec ${pkgs.ksh}/bin/ksh
        fi
      ''
      # Иначе — полноценная bash-конфигурация
      else ''
        eval "$(starship init bash)"

        if command -v kubectl &>/dev/null; then
          source <(kubectl completion bash 2>/dev/null)
          export PATH="${config.home.homeDirectory}/.krew/bin:$PATH"
        fi
        command -v helm    &>/dev/null && source <(helm    completion bash 2>/dev/null)
        command -v kubectx &>/dev/null && source <(kubectx completion bash 2>/dev/null || true)
        command -v kubens  &>/dev/null && source <(kubens  completion bash 2>/dev/null || true)
        command -v argocd  &>/dev/null && source <(argocd  completion bash 2>/dev/null)

        [ -f "${pkgs.fzf}/share/fzf/completion.bash"   ] && source "${pkgs.fzf}/share/fzf/completion.bash"
        [ -f "${pkgs.fzf}/share/fzf/key-bindings.bash" ] && source "${pkgs.fzf}/share/fzf/key-bindings.bash"

        [ -f "${config.home.homeDirectory}/.config/bash/extra.bash" ] && \
          source "${config.home.homeDirectory}/.config/bash/extra.bash"
      '';
  };
}
