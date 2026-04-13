{ config, pkgs, lib, ... }:

# ksh (KornShell) — Home Manager не имеет встроенного модуля programs.ksh,
# поэтому настраиваем вручную через home.packages + home.file.
lib.mkIf (config.custom.preferredShell == "ksh") {

  home.packages = [ pkgs.ksh ];

  # .kshrc — аналог .bashrc для ksh
  # Пишем в HOME (не в nix-store) через home.file
  home.file.".kshrc".text = ''
    # ── Starship prompt ────────────────────────────────────────────────────
    eval "$(starship init ksh)"

    # ── История в HOME (требование задачи) ────────────────────────────────
    export HISTFILE="${config.home.homeDirectory}/.ksh_history"
    export HISTSIZE=50000

    # ── Алиасы ────────────────────────────────────────────────────────────
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (k: v: "alias ${k}='${v}'") config.custom.shellAliases
    )}

    # ── PATH ──────────────────────────────────────────────────────────────
    export PATH="${config.home.homeDirectory}/.krew/bin:${config.home.homeDirectory}/.nix-profile/bin:$PATH"

    # ── Kubernetes completions ─────────────────────────────────────────────
    # ksh поддерживает bash-style completion через ENV sourcing
    command -v kubectl &>/dev/null && . <(kubectl completion bash 2>/dev/null)
    command -v helm    &>/dev/null && . <(helm    completion bash 2>/dev/null)
    command -v argocd  &>/dev/null && . <(argocd  completion bash 2>/dev/null)

    # ── fzf ───────────────────────────────────────────────────────────────
    [ -f "${pkgs.fzf}/share/fzf/key-bindings.bash" ] && \
      . "${pkgs.fzf}/share/fzf/key-bindings.bash"

    # ── Пользовательские оверрайды из HOME ────────────────────────────────
    [ -f "${config.home.homeDirectory}/.config/ksh/extra.kshrc" ] && \
      . "${config.home.homeDirectory}/.config/ksh/extra.kshrc"
  '';

  # ENV указывает ksh где искать rc-файл
  home.sessionVariables.ENV = "${config.home.homeDirectory}/.kshrc";
}
