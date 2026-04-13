{ config, lib, pkgs, ... }:

let
  preferred = config.custom.preferredShell;
in {
  imports = [
    ./common.nix
    ./zsh.nix
    ./bash.nix
    ./fish.nix
    ./ksh.nix
  ];

  # Starship нужен при любом шелле
  programs.starship = {
    enable = true;
    settings = {
      add_newline         = false;
      line_break.disabled = true;
      format = lib.concatStrings [
        "$username$hostname $directory$git_branch$git_status"
        "$kubernetes"
        " $character"
      ];
      kubernetes = {
        disabled = false;
        format   = "[$symbol$context(/$namespace)]($style) ";
        symbol   = "☸ ";
      };
    };
  };

  # enable-флаги выставляются ТОЛЬКО здесь, не в дочерних модулях
  programs.zsh.enable  = preferred == "zsh";
  programs.fish.enable = preferred == "fish";
  # bash включаем если выбран bash, либо как основу для автозапуска fish/ksh
  programs.bash.enable = preferred == "bash" || preferred == "fish" || preferred == "ksh";
}
