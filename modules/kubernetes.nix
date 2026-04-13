{ config, pkgs, lib, inputs, ... }:

let
  cfg = config.custom;

  krewPlugins = [
    "stern"          # tail logs из нескольких подов
    "neat"           # чистый вывод манифестов (без служебных полей)
    "tree"           # дерево ресурсов
    "access-matrix"  # матрица RBAC-доступов
    "ctx"            # быстрая смена контекста (дублирует kubectx — на выбор)
    "ns"             # быстрая смена namespace
    "images"         # список образов в кластере
  ];
in
lib.mkIf cfg.enableK8s {

  home.packages = with pkgs; [
    kubectl
    kubectx     # содержит и kubectx, и kubens (в nixpkgs они в одном пакете)
    kubecm      # управление несколькими kubeconfig
    argocd
    helm
    kustomize
    krew
  ];

  # ── Автоматическая установка krew-плагинов ────────────────────────────────
  # Запускается после каждого home-manager switch
  # Использует krewfile-flake для декларативного управления плагинами
  home.activation.installKrewPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${config.home.homeDirectory}/.krew/bin:$PATH"
    export HOME="${config.home.homeDirectory}"

    # Инициализируем krew если ещё не установлен
    if ! command -v kubectl-krew &>/dev/null && [ -x "${pkgs.krew}/bin/kubectl-krew" ]; then
      ${pkgs.krew}/bin/kubectl-krew install krew 2>/dev/null || true
    fi

    # Обновляем индекс
    ${pkgs.krew}/bin/kubectl-krew update 2>/dev/null || true

    # Пишем krewfile во временный файл и применяем
    KREWFILE=$(mktemp /tmp/krewfile.XXXXXX)
    printf '%s\n' ${lib.escapeShellArgs krewPlugins} > "$KREWFILE"
    ${inputs.krewfile.packages.${pkgs.system}.default}/bin/krewfile \
      --krewfile "$KREWFILE" 2>/dev/null || true
    rm -f "$KREWFILE"
  '';

  # ── Kubeconfig читается из HOME, не управляется Home Manager ──────────────
  # (уже задано в home.nix через home.file.".kube/config".enable = false)
}
