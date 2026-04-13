{ config, pkgs, lib, inputs, ... }:

{
  home.username      = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion  = "25.05";

  programs.home-manager.enable = true;

  imports = [
    ./modules/options.nix        # ← ИСПРАВЛЕНО: был не импортирован
    ./modules/core-utils.nix
    ./modules/shells/default.nix
    ./modules/kubernetes.nix
    ./modules/editors.nix
    ./modules/cloud.nix
  ];

  # ── Пользовательские флаги ─────────────────────────────────────────────────
  # Меняй здесь — остальное подхватится автоматически
  custom = {
    preferredShell = "zsh";   # zsh | fish | bash | ksh
    enableK8s      = true;
    enableAws      = true;
    enableHelix    = false;
  };

  # ── Atuin — единый хранитель истории всех шеллов ──────────────────────────
  # История хранится в ~/.local/share/atuin/ (в HOME, не в nix-store)
  programs.atuin = {
    enable                = true;
    enableZshIntegration  = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    settings = {
      # Писать историю локально, без синхронизации с сервером
      sync_address = "";
      auto_sync    = false;
    };
  };

  # ── Глобальные переменные окружения ───────────────────────────────────────
  # sessionVariables задаются ТОЛЬКО здесь — не дублируются в модулях
  home.sessionVariables = {
    EDITOR     = "nvim";
    VISUAL     = "nvim";
    KUBECONFIG = "${config.home.homeDirectory}/.kube/config";
    # krew и nix-profile всегда в PATH
    PATH = lib.concatStringsSep ":" [
      "${config.home.homeDirectory}/.krew/bin"
      "${config.home.homeDirectory}/.nix-profile/bin"
      "$PATH"
    ];
  };

  # ── Защита пользовательских конфигов ──────────────────────────────────────
  # Home Manager НЕ трогает эти файлы — они управляются пользователем вручную
  home.file.".kube/config".enable = false;
  home.file.".ssh/config".enable  = false;
}
