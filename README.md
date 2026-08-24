# Multi-host NixOS configuration

This flake manages the `cloudbox` host and the primary user's Home Manager
configuration. The host name and Linux user name are separate settings.

## Layout

- `hosts/default.nix`: host inventory.
- `hosts/<name>/`: host settings and generated hardware configuration.
- `modules/nixos/`: reusable NixOS modules and the `my.*` interface.
- `home/desktops/`: compositor adapters and generated native configuration.
- `home/components/`: selectable desktop-shell implementations.
- `home/programs/` and `home/services/`: Home Manager configuration.
- `lib/mk-host.nix`: shared host constructor.
- `justfile`: global NixOS maintenance recipes.

## First deployment

### Automated installation from GitHub

Run the installer as the normal user who will own the configuration:

```bash
curl -fsSL https://raw.githubusercontent.com/Kycer/MyNixos/main/install.sh |
  bash -s -- \
    --repo https://github.com/Kycer/MyNixos.git \
    --host cloudbox \
    --yes
```

This direct download method requires the GitHub repository to be public. The installer:

- clones the repository to `$HOME/.nixos`;
- temporarily provides Git through `nix shell nixpkgs#git` when Git is not installed;
- writes the selected host's primary user to ignored `hosts/<host>/installer.nix`;
- evaluates the flake through a temporary `nix shell nixpkgs#just`;
- moves an existing `/etc/nixos` to a timestamped backup;
- creates `/etc/nixos -> $HOME/.nixos`;
- runs the global `switch` recipe.

If the repository is private, or you prefer the configured SSH remote, clone
it first and then run the local installer:

```bash
nix --extra-experimental-features 'nix-command flakes' \
  shell nixpkgs#git --command \
  git clone git@github.com:Kycer/MyNixos.git "$HOME/.nixos"
"$HOME/.nixos/install.sh" --host cloudbox --yes
```

For an interactive confirmation, omit `--yes`. To clone and evaluate without
changing `/etc/nixos` or the running system, add `--check-only`.

After the first switch, start a new login shell or run:

```bash
exec "$SHELL" -l
j switch
```

`j` already means `just --global-justfile`, so use `j switch`, not
`j -g switch`. Without the alias, use `just -g switch`.

### Manual installation

Copy this directory to `$HOME/.nixos`, then make sure it is owned by the
current user.
Create `hosts/cloudbox/installer.nix` with the local login name; the file is
ignored by Git but included by the explicit `path:` flake reference:

```nix
{ my.user.name = "your-user"; }
```

Build without changing the running system:

```bash
sudo nixos-rebuild build \
  --option experimental-features 'nix-command flakes' \
  --flake "path:$HOME/.nixos#cloudbox"
```

After the build succeeds, make `/etc/nixos` point to the user-owned
configuration before the first Home Manager activation. Choose an unused
backup path and run:

```bash
sudo mv /etc/nixos /etc/nixos.before-flake
sudo ln -s "$HOME/.nixos" /etc/nixos
readlink -f /etc/nixos
```

Activate the configuration; future rebuilds use the same command:

```bash
sudo nixos-rebuild switch \
  --option experimental-features 'nix-command flakes' \
  --flake path:/etc/nixos#cloudbox
```

## Common changes

Edit `hosts/cloudbox/default.nix` to:

- set the real Git email;
- choose the login shell with `my.user.shell = "zsh"` or `my.user.shell = "fish"`;
- select `my.desktop.wm = "niri"` or `"sway"`;
- enable or disable services and user programs;
- add host-specific system or Home Manager packages.

`modules/nixos/options.nix` declares and validates the reusable `my.*`
interface. It does not install programs by itself. `home/default.nix` is the
Home Manager entry point that imports the user-level implementations. The
Linux login name is set once as `my.user.name` and is passed to Home Manager
automatically. Automated deployments override the placeholder through the
ignored `hosts/<host>/installer.nix`, so installing a machine no longer
modifies tracked host configuration. Git author name and email are independent
and remain unset until explicitly configured.

The default `pkgs` package set tracks `nixos-unstable`. A stable 26.05 package
set is available as `stablePkgs`, for example:

```nix
{ stablePkgs, ... }:

{
  my.programs.firefox.package = stablePkgs.firefox;
}
```

## Desktop adapter boundary

Desktop names and imports are discovered automatically. Adding a compositor
does not require editing the option enum, the desktop import lists, shell
components, or user services. Add only the matching adapters:

- `modules/nixos/desktops/<name>.nix` enables the system compositor and
  publishes its session target and capabilities;
- `home/desktops/<name>/default.nix` enables the Home Manager integration and
  renders shared startup commands and key bindings into native syntax.

Components such as Noctalia and Rofi publish desktop-neutral commands through
`my.desktop.session`. Foot, Polkit, Waybar, and WayVNC consume the published
session interface rather than comparing `my.desktop.wm` themselves. The
matching adapter filenames are the only places that introduce a new desktop
name.

## Application configuration

Niri, Sway, Foot, and Noctalia are managed as Nix data:

- `home/desktops/niri/*.nix` contributes ordered KDL fragments;
- `home/desktops/sway/default.nix` uses Home Manager's Sway options;
- `home/programs/foot/default.nix` uses `programs.foot.settings`;
- `home/components/noctalia/config.toml` provides the Noctalia v5 defaults;
  Home Manager renders and validates them as
  `~/.config/noctalia/config.toml`. Noctalia itself comes directly from the
  default `nixpkgs-unstable` package set, without a separate flake input.

These files require `just switch` after editing. Foot runs as a user systemd
service, and both compositors launch terminals with `footclient`. Neovim is
kept as an out-of-store link through `/etc/nixos`, so its Lua configuration can
still be edited without rebuilding.

To select the modular Niri configuration with Noctalia on a local graphical
machine, use:

```nix
my.desktop = {
  wm = "niri";
  shellStyle = "noctalia";
};
my.remoteDesktop.wayvnc.enable = false;
```

The current WayVNC implementation is Sway-specific, so it must be disabled
before selecting Niri.

The default login shell is Zsh, and the host can select Fish instead. Both
shells share the basic aliases, FZF integration and Zoxide. Zsh additionally
includes Oh My Zsh, autosuggestions, syntax highlighting, shared history and
substring history search. Use `z <part-of-directory-name>` to jump between
directories.

## Global Just recipes

The repository `justfile` is linked to `~/.config/just/justfile`. From the
flake directory use `just <recipe>`. From any directory use `just -g <recipe>`
or the Zsh alias `j <recipe>`.

Build and validation recipes never change the checkout or require a network
pull. Run `just -g pull` explicitly when the repository should be synchronized.

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

`cloudbox` starts a headless Sway session through greetd. The configured
`my.remoteDesktop.wayvnc.resolution` generates the `HEADLESS-1` output. Home
Manager starts WayVNC on the session target published by the active desktop
adapter and restarts it after a failure. Currently only the Sway adapter
publishes the WayVNC capability.

Unauthenticated WayVNC may only open a firewall port on loopback or on an
explicit trusted interface. A deliberately unsafe temporary test must opt in:

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
