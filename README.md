# DevOps Environment — Nix Home Manager

Декларативное пользовательское окружение для DevOps-инженера.
Работает **полностью в userspace** — root не нужен, систему не трогает.

---

## Что входит

| Категория | Инструменты |
|---|---|
| **Kubernetes** | kubectl, kubectx, kubens, kubecm, argocd, helm, kustomize, krew + плагины (stern, neat, tree, access-matrix, images) |
| **Cloud** | aws-cli v2, rclone |
| **Утилиты** | git, fzf, ripgrep, bat, eza, jq, yq, curl, rsync и др. |
| **Шеллы** | zsh (default), fish, bash, ksh — с completions и алиасами |
| **Редакторы** | neovim (default), vim, nano, helix (опционально) |
| **Промпт** | Starship — однострочный, с kubernetes-контекстом |
| **История** | Atuin — единое хранилище истории всех шеллов |

---

## Быстрый старт

### 1. Установи Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
  sh -s -- install
```

> Используется **Determinate Nix Installer** — он надёжнее официального,
> корректно настраивает flakes и не требует ручной правки конфигов.

После установки **перезапусти терминал** (или выполни `exec $SHELL`), затем проверь:

```bash
nix --version
# nix (Nix) 2.x.x
```

---

### 2. Скопируй конфигурацию

```bash
git clone <url-репозитория> ~/dotfiles
cd ~/dotfiles
```

Или просто распакуй архив:

```bash
unzip nix1-fixed.zip -d ~/dotfiles
cd ~/dotfiles/nix1-fixed
```

---

### 3. Выбери свой шелл и настройки

Открой `home.nix` и отредактируй блок `custom`:

```nix
custom = {
  preferredShell = "zsh";   # zsh | fish | bash | ksh
  enableK8s      = true;    # kubectl, helm, krew и т.д.
  enableAws      = true;    # aws-cli, rclone
  enableHelix    = false;   # редактор helix (опционально)
};
```

> **По умолчанию** стоит `zsh`. Если не уверен — оставь как есть.

---

### 4. Применить конфигурацию

```bash
nix run home-manager/master -- switch --flake .#default
```

> При первом запуске это займёт несколько минут — Nix скачивает все пакеты.
> Последующие `switch` работают быстрее благодаря кешу.

После завершения **перезапусти терминал**.

---

### 5. Проверь что всё работает

```bash
# Шелл и промпт
echo $SHELL
# Инструменты
kubectl version --client
helm version
krew version
# Алиасы
k get nodes   # = kubectl get nodes
ll            # = eza -la --icons
```

---

## Обновление окружения

```bash
cd ~/dotfiles/nix1-fixed

# Применить изменения из home.nix / модулей
home-manager switch --flake .#default

# Полное обновление пакетов до последних версий
nix flake update && home-manager switch --flake .#default
```

---

## Структура проекта

```
.
├── flake.nix                  # точка входа, inputs (nixpkgs, home-manager, krewfile)
├── home.nix                   # главный файл — редактируй флаги здесь
└── modules/
    ├── options.nix            # объявление всех custom.* флагов
    ├── core-utils.nix         # базовые утилиты (git, fzf, curl, …)
    ├── kubernetes.nix         # k8s-инструменты + krew-плагины
    ├── editors.nix            # neovim, vim, nano, helix
    ├── cloud.nix              # aws-cli, rclone
    └── shells/
        ├── default.nix        # логика выбора шелла
        ├── common.nix         # общие алиасы для всех шеллов
        ├── zsh.nix
        ├── bash.nix
        ├── fish.nix
        └── ksh.nix
```

---

## Пользовательские оверрайды

Хочешь добавить своё — **не трогай nix-файлы**, создай оверрайд в HOME:

| Шелл | Файл для оверрайда |
|---|---|
| zsh | `~/.config/zsh/extra.zsh` |
| bash | `~/.config/bash/extra.bash` |
| fish | `~/.config/fish/extra.fish` |
| ksh | `~/.config/ksh/extra.kshrc` |
| neovim | `~/.config/nvim/init.lua` |
| helix | `~/.config/helix/config.toml` |

Эти файлы автоматически подхватываются при старте шелла и никогда не перезаписываются Home Manager.

---

## Kubeconfig и SSH

`~/.kube/config` и `~/.ssh/` **не трогаются** Home Manager.
Кладёшь свои конфиги туда как обычно — они читаются напрямую из HOME.

Для нескольких kubeconfig-ов удобно использовать `kubecm`:

```bash
kubecm add -f ~/my-cluster.yaml   # добавить контекст
kubecm ls                          # список контекстов
ktx                                # переключить контекст
kns                                # переключить namespace
```

---

## Полезные алиасы

| Алиас | Команда |
|---|---|
| `k` | kubectl |
| `kg` | kubectl get |
| `kd` | kubectl describe |
| `kl` | kubectl logs |
| `ke` | kubectl exec -it |
| `kns` | kubens |
| `ktx` | kubectx |
| `ll` | eza -la --icons |
| `hms` | home-manager switch --flake .#default |
| `gc` | nix-collect-garbage -d |

---

## Возможные проблемы

**`error: experimental Nix feature 'flakes' is not enabled`**

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

---

**`krew: command not found` после первого switch**

Krew устанавливается в `~/.krew/bin` — убедись что PATH обновился:

```bash
exec $SHELL
krew version
```

---

**На macOS: `aarch64-darwin` или `x86_64-darwin`?**

```bash
uname -m
# arm64  → aarch64-darwin
# x86_64 → x86_64-darwin
```

Flake определяет систему автоматически — ничего менять не нужно.

---

## Добавить новый инструмент

1. Найди пакет: `nix search nixpkgs <название>`
2. Добавь в нужный модуль (например `core-utils.nix`):
   ```nix
   home.packages = with pkgs; [
     ...
     <новый-пакет>
   ];
   ```
3. Примени: `hms`
