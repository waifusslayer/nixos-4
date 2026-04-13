{ config, pkgs, lib, ... }:

let cfg = config.custom; in
{
  # ── Neovim ────────────────────────────────────────────────────────────────
  programs.neovim = {
    enable        = true;
    viAlias       = true;
    vimAlias      = true;
    defaultEditor = true;
  };

  # ── vim ───────────────────────────────────────────────────────────────────
  programs.vim = {
    enable = true;
  };

  # ── nano — нет HM-модуля, ставим пакетом + конфиг через home.file ────────
  home.packages = [ pkgs.nano ]
    ++ lib.optional cfg.enableHelix pkgs.helix;

  home.file.".nanorc".text = ''
    set linenumbers
    set mouse
    set autoindent
    set tabsize 2
    set softwrap
  '';

  # ── Helix — опционально (custom.enableHelix = true) ───────────────────────
  # Конфиг читается из ~/.config/helix/ — HOME, не nix-store
}
