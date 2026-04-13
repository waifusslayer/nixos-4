{ lib, ... }:

# Все кастомные опции конфигурации объявляются здесь.
# Добавляй новые флаги сюда — они автоматически становятся доступны
# во всех модулях через config.custom.*
{
  options.custom = {

    preferredShell = lib.mkOption {
      type        = lib.types.enum [ "zsh" "fish" "bash" "ksh" ];
      default     = "zsh";
      description = ''
        Предпочитаемый интерактивный шелл.
        Выбор применяется один раз при установке.
        Допустимые значения: zsh (default) | fish | bash | ksh
      '';
    };

    enableK8s = lib.mkOption {
      type        = lib.types.bool;
      default     = true;
      description = "Включить Kubernetes-инструменты (kubectl, krew, helm и т.д.)";
    };

    enableAws = lib.mkOption {
      type        = lib.types.bool;
      default     = true;
      description = "Включить AWS CLI и rclone";
    };

    enableHelix = lib.mkOption {
      type        = lib.types.bool;
      default     = false;
      description = "Включить редактор Helix (опциональный)";
    };

  };
}
