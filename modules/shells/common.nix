{ lib, ... }:

# Общие алиасы и функции для всех шеллов.
# Объявляем через options чтобы модули шеллов могли ссылаться
# на config.custom.shellAliases — это валидный способ шарить данные.
{
  options.custom.shellAliases = lib.mkOption {
    type    = lib.types.attrsOf lib.types.str;
    default = {};
    description = "Общие алиасы для всех шеллов";
  };

  config.custom.shellAliases = {
    # ── Kubernetes ──────────────────────────────────────────────────────────
    k    = "kubectl";
    kg   = "kubectl get";
    kd   = "kubectl describe";
    kl   = "kubectl logs";
    ke   = "kubectl exec -it";
    kns  = "kubens";
    ktx  = "kubectx";
    kcm  = "kubecm";

    # ── Git ─────────────────────────────────────────────────────────────────
    gs   = "git status";
    gp   = "git pull";
    gP   = "git push";
    gl   = "git log --oneline --graph";

    # ── Файловая система ────────────────────────────────────────────────────
    ll   = "eza -la --icons";
    la   = "eza -a --icons";
    lt   = "eza --tree --icons";

    # ── Nix ─────────────────────────────────────────────────────────────────
    # Запускать из директории с flake.nix
    hms    = "home-manager switch --flake .#default";
    hmsb   = "home-manager switch --flake .#default --show-trace";
    gc     = "nix-collect-garbage -d";
  };
}
