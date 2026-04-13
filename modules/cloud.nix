{ config, pkgs, lib, ... }:

lib.mkIf config.custom.enableAws {
  home.packages = with pkgs; [
    awscli2
    rclone
  ];

  # AWS конфиг читается из ~/.aws/ — HOME, не nix-store
  # Не объявляем home.file.".aws/..." чтобы не затирать пользовательские профили
}
