# Multi-host NixOS configuration

This flake manages the `cloudbox` host and the primary user's Home Manager
configuration. The host name and Linux user name are separate settings.

## Layout

- `hosts/default.nix`: host inventory.
- `hosts/<name>/`: host settings and generated hardware configuration.
- `modules/nixos/`: reusable NixOS modules and the `my.*` interface.
- `home/`: Home Manager packages and application configuration.
- `config/`: live, ordinary application configuration files.
- `lib/mk-host.nix`: shared host constructor.
- `justfile`: global NixOS maintenance recipes.

## First deployment

### Automated installation from GitHub

Run the installer as the normal user who will own the configuration:

```bash
curl -fsSL https://raw.githubusercontent.com/USER/REPO/main/install.sh |
  bash -s -- \
    --repo https://github.com/USER/REPO.git \
    --host cloudbox \
    --yes
```

Replace `USER/REPO` with the actual GitHub repository. The installer:

- clones the repository to `$HOME/.nixos`;
- updates the selected host's primary user to the current user;
- evaluates the flake through a temporary `nix shell nixpkgs#just`;
- moves an existing `/etc/nixos` to a timestamped backup;
- creates `/etc/nixos -> $HOME/.nixos`;
- runs the global `switch` recipe.

For an interactive confirmation, omit `--yes`. To clone and evaluate without
changing `/etc/nixos` or the running system, add `--check-only`.

After the first switch, start a new login shell or run:

```bash
exec zsh -l
j switch
```

`j` already means `just --global-justfile`, so use `j switch`, not
`j -g switch`. Without the alias, use `just -g switch`.

### Manual installation

Copy this directory to `$HOME/.nixos`, then make sure it is owned by the
current user.
If the directory is a Git repository, add new files before evaluating the
flake:

```bash
git -C "$HOME/.nixos" add --all
```

Build without changing the running system:

```bash
sudo nixos-rebuild build \
  --option experimental-features 'nix-command flakes' \
  --flake "$HOME/.nixos#cloudbox"
```

After the build succeeds:

```bash
sudo nixos-rebuild switch \
  --option experimental-features 'nix-command flakes' \
  --flake "$HOME/.nixos#cloudbox"
```

To make `/etc/nixos` point to the user-owned configuration, choose an unused
backup path and run:

```bash
sudo mv /etc/nixos /etc/nixos.before-flake
sudo ln -s "$HOME/.nixos" /etc/nixos
readlink -f /etc/nixos
```

Future rebuilds can then use:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#cloudbox
```

## Common changes

Edit `hosts/cloudbox/default.nix` to:

- set the real Git email;
- select `desktop = "niri"` or `"sway"`;
- enable or disable services and user programs;
- add host-specific system or Home Manager packages.

`modules/nixos/options.nix` declares and validates the reusable `my.*`
interface. It does not install programs by itself. `home/default.nix` is the
Home Manager entry point that imports the user-level implementations. The
Linux login name is set once as `my.user.name` in the host module and is passed
to Home Manager automatically. Git author name and email are independent and
remain unset until explicitly configured.

The default `pkgs` package set tracks `nixos-unstable`. A stable 26.05 package
set is available as `stablePkgs`, for example:

```nix
{ stablePkgs, ... }:

{
  my.programs.firefox.package = stablePkgs.firefox;
}
```

## Live application configuration

Home Manager creates out-of-store links from `~/.config` to the corresponding
directories below `~/.nixos/config`. These files remain ordinary writable
files rather than immutable Nix store files:

- `config/sway/config`
- `config/niri/config.kdl`
- `config/foot/foot.ini`
- `config/nvim/`
- `config/gtk-3.0/` and `config/gtk-4.0/`
- `config/qt5ct/` and `config/qt6ct/`

After the first `switch`, editing one of these files takes effect without
another rebuild. Reload Sway with `Mod+Shift+c`; Niri and Foot may need their
application or session restarted. Foot runs as a user-level server, and both
desktop configurations launch terminals with `footclient`.

The login shell is Zsh. It includes Oh My Zsh's Git aliases, autosuggestions,
syntax highlighting, shared history, substring history search, FZF integration
and Zoxide. Use `z <part-of-directory-name>` to jump between directories.

## Global Just recipes

The repository `justfile` is linked to `~/.config/just/justfile`. From the
flake directory use `just <recipe>`. From any directory use `just -g <recipe>`
or the Zsh alias `j <recipe>`.

```bash
just -g check
just -g build
just -g switch
just -g generations
just -g clean-shell
just -g gc 30d
just -g clean-results .
```

An exited `nix-shell -p ...` does not normally leave project files. Its
unreferenced store paths are removed by `clean-shell` or `gc`.

## Installing software

Choose where a package belongs before adding it:

### Temporary commands

Use `nix shell` when a command is only needed for the current shell:

```bash
nix shell nixpkgs#jq nixpkgs#lazygit
```

Run a single application without entering a shell:

```bash
nix run nixpkgs#cowsay
```

These commands do not modify the NixOS configuration.

### Packages for the cloudbox user

Add user applications to `my.packages.home` in
`hosts/cloudbox/default.nix`:

```nix
packages = {
  system = [ ];
  home = with pkgs; [
    jq
    lazygit
    tree
  ];
};
```

### System-wide packages

Commands needed by root, system services, or every user belong in
`my.packages.system`:

```nix
packages = {
  system = with pkgs; [
    ethtool
    smartmontools
  ];
  home = [ ];
};
```

Packages shared by every host at the user level can instead be added to the
common list in `home/packages.nix`.

### Packages from stable nixpkgs

Add `stablePkgs` to the host module arguments and select packages explicitly:

```nix
{ pkgs, stablePkgs, ... }:

{
  my.packages.home =
    (with pkgs; [
      jq
    ])
    ++ [
      stablePkgs.lazygit
    ];
}
```

After changing a Nix file, evaluate it first and then switch:

```bash
just -g check
just -g switch
```

## Headless Sway and WayVNC

`cloudbox` starts a headless Sway session through greetd. Home Manager starts
WayVNC when `sway-session.target` becomes active and restarts it after a
failure. The current test configuration listens on every address and opens TCP
port 5900:

```nix
my.remoteDesktop.wayvnc = {
  enable = true;
  address = "0.0.0.0";
  port = 5900;
  openFirewall = true;
  insecureTestMode = true;
};
```

This test mode has no VNC authentication or transport encryption. Do not leave
port 5900 exposed to the public Internet. For an SSH-only test, bind WayVNC to
`127.0.0.1`, keep `openFirewall = false`, and forward the port:

```bash
ssh -L 5900:127.0.0.1:5900 "$USER"@cloudbox
```

After WireGuard is configured, bind WayVNC to the cloudbox WireGuard address
and restrict the firewall rule to its interface:

```nix
my.remoteDesktop.wayvnc = {
  enable = true;
  address = "10.10.0.2";
  port = 5900;
  openFirewall = true;
  firewallInterface = "wg0";
  insecureTestMode = false;
};
```

Do not put passwords, private keys, cookies, or tokens in this flake. Flake
sources and generated configuration can be copied to the world-readable Nix
store.
