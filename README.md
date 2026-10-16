# Multi-host NixOS configuration

This flake manages the `cloudbox` host and the primary user's Home Manager
configuration. The host name and Linux user name are separate settings.

## Layout

- `hosts/default.nix`: host inventory.
- `hosts/<name>/`: host settings and an ignored machine-local hardware configuration.
- `nixos/`: reusable NixOS modules and the `my.*` interface.
- `home/desktops/`: compositor adapters and generated native configuration.
- `home/components/`: selectable desktop-shell implementations.
- `home/programs/` and `home/services/`: Home Manager configuration.
- `lib/mk-host.nix`: shared host constructor.
- `justfile`: global NixOS maintenance recipes.

## First deployment

### Machine-local hardware configuration

Run `install.sh` on an already installed NixOS system. Before evaluating the
flake or replacing `/etc/nixos`, the installer copies the machine's existing
`/etc/nixos/hardware-configuration.nix` to
`hosts/<host>/hardware-configuration.nix`. If the original file is unavailable,
it uses `sudo nixos-generate-config --show-hardware-config` to generate one
from the currently running system. This includes the machine's filesystem
identifiers, mount layout, and initrd drivers.

The copied file is ignored by Git and included by the explicit `path:` flake
reference. It is required for evaluating the host; a fresh checkout needs the
installer or a manual copy before `nix flake check` can succeed.
Subsequent installer runs preserve the host's existing hardware file.
The updated `j pull` recipe and `install.sh --update` also back up the hardware
file before pulling and restore it if Git deletes it during the transition
from tracked configuration to an ignored local file.

For the first update using an older installer/justfile, or when running
`git pull` directly during that transition, make a backup outside the checkout
first. In Bash:

```bash
hardware_backup="$(mktemp)"
cp "$HOME/.nixos/hosts/cloudbox/hardware-configuration.nix" "$hardware_backup"
git -C "$HOME/.nixos" pull --ff-only
cp "$hardware_backup" "$HOME/.nixos/hosts/cloudbox/hardware-configuration.nix"
```

If Git reports local modifications or a merge conflict, keep the backup and
resolve the conflict before continuing. After the file is no longer tracked,
normal Git pulls leave it in place.

To replace it explicitly, use a verified hardware configuration from this
machine, for example a backup made before switching to the flake:

```bash
bash "$HOME/.nixos/install.sh" --host cloudbox \
  --hardware-config /path/to/hardware-configuration.nix --yes
```

The installer does not partition or format disks. For a reinstall, use the
hardware configuration generated for the new installation rather than copying
the previous machine's hardware file. Fixed disk labels are no longer required.

### Recovery from the installation ISO

For recovery from the NixOS installation ISO, mount the installed root and
its `/home`, `/nix`, and EFI filesystems under `/mnt`, then enter as root:

```bash
sudo nixos-enter --root /mnt
id -u  # Must print 0.
```

In the target root shell, edit the hardware configuration in the installed
checkout and run `nixos-rebuild boot --flake path:/etc/nixos#cloudbox`.
Use `boot` to rebuild the next boot configuration from the rescue environment.
Run it directly as root: `j boot` and `j switch` invoke `sudo`, whose runtime
setuid wrapper may be unavailable inside the rescue chroot. Do not change the
permissions of binaries in the Nix store to repair this.

### Automated installation from GitHub

Run the installer as the normal user who will own the configuration:

```bash
curl -fsSL https://raw.githubusercontent.com/Kycer/MyNixos/main/install.sh |
  bash -s -- \
    --repo https://github.com/Kycer/MyNixos.git \
    --host cloudbox \
    --git-name "Your Name" \
    --git-email "you@example.com" \
    --yes
```

This direct download method requires the GitHub repository to be public. The installer:

- clones the repository to `$HOME/.nixos`;
- temporarily provides Git through `nix shell nixpkgs#git` when Git is not installed;
- copies or generates the selected host's ignored machine-local hardware configuration;
- writes the selected host's primary user and Git identity to ignored
  `hosts/<host>/installer.nix`;
- evaluates the flake through a temporary `nix shell nixpkgs#just`;
- moves an existing `/etc/nixos` to a timestamped backup;
- creates `/etc/nixos -> $HOME/.nixos`;
- runs the global `switch` recipe.

If the repository is private, or you prefer the configured SSH remote, clone
it first and then run the local installer:

```bash
nix --extra-experimental-features 'nix-command flakes' \
  shell nixpkgs#git --command \
  git clone --recurse-submodules git@github.com:Kycer/MyNixos.git "$HOME/.nixos"
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
current user. Copy the installed machine's original hardware configuration
before replacing `/etc/nixos`:

```bash
cp /etc/nixos/hardware-configuration.nix \
  "$HOME/.nixos/hosts/cloudbox/hardware-configuration.nix"
```

If the original file is unavailable, generate it from the running NixOS system:

```bash
sudo nixos-generate-config --show-hardware-config \
  > "$HOME/.nixos/hosts/cloudbox/hardware-configuration.nix"
```

Create `hosts/cloudbox/installer.nix` with the local login name and Git
identity; the file is ignored by Git but included by the explicit `path:`
flake reference:

```nix
{
  my.user = {
    name = "your-user";
    git = {
      name = "Your Name";
      email = "you@example.com";
    };
  };
}
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

Host-specific settings are grouped by responsibility under `hosts/cloudbox`:

- use `user.nix` for the Git identity, login shell, groups, and SSH keys;
- use `desktop.nix` to select the desktop and enable desktop programs;
- use `flatpak.nix` for host-specific Flatpak remotes and applications;
- use `networking.nix` for WireGuard and remote desktop settings;
- use `packages.nix` for host-specific system and Home Manager packages;
- keep boot settings and `system.stateVersion` in `default.nix`.

`nixos/options.nix` declares and validates the reusable `my.*`
interface. It does not install programs by itself. `home/default.nix` is the
Home Manager entry point that imports the user-level implementations. The
Linux login name is set once as `my.user.name` and is passed to Home Manager
automatically. Automated deployments override the placeholder through the
ignored `hosts/<host>/installer.nix`, so installing a machine no longer
modifies tracked host configuration. Git author name and email are independent;
the installer accepts `--git-name` and `--git-email`, falling back to the
existing global Git configuration when those options are omitted.

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

- `nixos/desktops/<name>.nix` enables the system compositor and
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
service, and both compositors launch terminals with `footclient`.

Neovim configuration is the `Kycer/nvim` Git submodule at
`home/programs/nvim/config`. Home Manager links that complete worktree to
`~/.config/nvim` through `/etc/nixos`, so Lua changes take effect immediately
without rebuilding. Pull upstream changes and record the new pinned commit in
this repository with:

```bash
j nvim-pull
git -C "$HOME/.nixos" add home/programs/nvim/config
git -C "$HOME/.nixos" commit -m 'chore(nvim): update config'
```

Files edited through `~/.config/nvim` belong to the standalone nvim repository.
Run `j nvim-pull` once after a fresh clone so the submodule is on `main` rather
than a detached HEAD. Commit and push changes there first, then commit its new
pointer in MyNixos:

```bash
git -C "$HOME/.nixos/home/programs/nvim/config" add .
git -C "$HOME/.nixos/home/programs/nvim/config" commit -m 'describe the nvim change'
git -C "$HOME/.nixos/home/programs/nvim/config" push

git -C "$HOME/.nixos" add home/programs/nvim/config
git -C "$HOME/.nixos" commit -m 'chore(nvim): update config'
```

After an older clone, initialize missing submodules once with
`git submodule update --init --recursive`. The installer and `j pull` do this
automatically.

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

Flatpak itself is managed by `nixos/flatpak.nix`, while each host owns
its remote and application lists through `my.flatpak`. Applications are
installed system-wide only on hosts that enable this option; manually installed
Flatpak applications are left untouched.

The default login shell is Zsh, and the host can select Fish instead. Both
shells share the basic aliases, FZF integration and Zoxide. Zsh additionally
includes Oh My Zsh, autosuggestions, syntax highlighting, shared history and
substring history search. Use `z <part-of-directory-name>` to jump between
directories.

## Project development environments

Language toolchains are provided by project-local Flakes instead of the host
configuration. From a new or existing project directory that does not already
contain a Flake, pass one or more languages to the shared generator:

```bash
j dev-init rust
j dev-init rust node
j dev-init python node
```

The command creates `flake.nix`, `flake.lock`, and `.envrc` in the current
directory. Language package groups and shell attributes are maintained in
`lib/dev-language-tools.nix`; the generator merges the selected entries into a
single development shell. Commit all three generated files with the project,
then approve the directory once:

```bash
git add flake.nix flake.lock .envrc
direnv allow
```

Home Manager enables Direnv with the nix-direnv integration, so the pinned
environment is loaded and unloaded automatically as the shell enters and leaves
the project directory. `nix develop` remains available when explicit entry is
useful.

The nix-direnv cache directory `.direnv/` is ignored globally by the managed
Git configuration.

The generated Flake supports `x86_64-linux` and `aarch64-linux`. Available
language names are `rust`, `go`, `node`, and `python`. Add project-specific
native libraries and tools to the generated `packages` list rather than to the
host configuration.

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
just -g nvim-pull
just -g nvim-status
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
`hosts/cloudbox/packages.nix`:

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

The `wg0` configuration generates `/etc/wireguard/private.key` automatically
before starting the tunnel when the file is missing. Existing keys are preserved.
To retain the same WireGuard identity after reinstalling, restore the original
private key to that path with root ownership and mode `0600` before the first
switch. Otherwise, a new key is generated and the peers must be updated with
the new public key. Show the public key with:

```bash
sudo sh -c 'wg pubkey < /etc/wireguard/private.key'
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
