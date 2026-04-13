# username и homeDir приходят из extraSpecialArgs во flake.nix
# где builtins.getEnv ещё работает (до sandbox-изоляции сборки)
{ config, pkgs, lib, inputs, username, homeDir, ... }:

{
  home.username      = username;
  home.homeDirectory = homeDir;
  home.stateVersion  = "25.05";

  programs.home-manager.enable = true;

  imports = [
    ./modules/options.nix
    ./modules/core-utils.nix
    ./modules/shells/default.nix
    ./modules/kubernetes.nix
    ./modules/editors.nix
    ./modules/cloud.nix
  ];

  # ── Пользовательские флаги ────────────────────────────────────────────────
  custom = {
    preferredShell = "zsh";   # zsh | fish | bash | ksh
    enableK8s      = true;
    enableAws      = true;
    enableHelix    = false;
  };

  # ── Atuin — история шеллов в HOME ─────────────────────────────────────────
  programs.atuin = {
    enable                = true;
    enableZshIntegration  = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    settings = {
      sync_address = "";
      auto_sync    = false;
    };
  };

  # ── Глобальные переменные окружения ───────────────────────────────────────
  home.sessionVariables = {
    EDITOR     = "nvim";
    VISUAL     = "nvim";
    KUBECONFIG = "${homeDir}/.kube/config";
    PATH = lib.concatStringsSep ":" [
      "${homeDir}/.krew/bin"
      "${homeDir}/.nix-profile/bin"
      "$PATH"
    ];
  };

  # ── Пользовательские конфиги не трогаем ───────────────────────────────────
  home.file.".kube/config".enable = false;
  home.file.".ssh/config".enable  = false;
}
