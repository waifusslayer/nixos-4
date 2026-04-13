{ pkgs, lib, ... }:

# Базовые GNU/BSD утилиты — эквивалент busybox, но отдельными пакетами.
# Работают в userspace без root.
{
  home.packages = with pkgs; [
    # ── GNU coreutils (ls, cp, mv, cat, …) ──────────────────────────────────
    coreutils      # base utils
    findutils      # find, xargs, locate
    diffutils      # diff, cmp, patch
    gnugrep        # grep, egrep
    gnused         # sed
    gawk           # awk
    gnutar         # tar
    gzip           # gzip, gunzip, zcat
    bzip2          # bzip2, bunzip2
    xz             # xz, unxz
    which          # which
    procps         # ps, top, kill, …

    # ── Сеть ────────────────────────────────────────────────────────────────
    curl
    wget
    rsync

    # ── Современные замены классических утилит ───────────────────────────────
    fzf            # fuzzy finder
    ripgrep        # rg — замена grep
    fd             # замена find
    bat            # замена cat с подсветкой
    eza            # замена ls с иконками
    jq             # JSON-процессор
    yq-go          # YAML-процессор (совместим с jq-синтаксисом)

    # ── Git ──────────────────────────────────────────────────────────────────
    git
    git-lfs

    # ── Прочее ───────────────────────────────────────────────────────────────
    less
    tree
    unzip
    zip
  ];
}
