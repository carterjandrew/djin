<img width="1920" height="1080" alt="Screenshot_20261015_181350" src="https://github.com/user-attachments/assets/013cfdfa-415a-43aa-9edc-deab6f53a8d0" />

```
________       __.__        
\______ \     |__|__| ____  
 |    |  \    |  |  |/    \ 
 |    `   \   |  |  |   |  \
/_______  /\__|  |__|___|  /
        \/\______|       \/
    Lightning in a bottle
```

Djin is my configuration for a userland computer I do developement on. It's intended to be a _almost_ monorepo. This is done using NixOS, and including symlinks to dotfiles I don't want to be Nix based (think NeoVim or Kitty)

It's pretty simple. At the end of the day it boils down to a few key important decisions:

1. NixOS
2. KDE Plasma
3. Krohnkite
4. [Geometry Change Animations for Windows](https://github.com/peterfajdiga/kwin4_effect_geometry_change)
5. Sops and LUKS
6. Other things you would expect


## Multiple machines

One `flake.nix` and `flake.lock` provide two independent NixOS outputs:
`nixosConfigurations.djin` and `nixosConfigurations.nosferatu`. They share
`configuration.nix`, `home.nix`, and the modules under `modules/`.

Each directory under `hosts/` contains:

- `vars.nix`: the hostname, used for the flake output name, system hostname,
  and Home Manager's Bash `rebuild` alias.
- `default.nix`: machine-specific settings and an import of that machine's
  hardware configuration.
- `hardware-configuration.nix`: tracked disks, mounts, and hardware modules.
  Keep each machine's generated file here rather than overwriting a shared file.

The flake's `mkHost` helper combines these pieces. It passes `inputs` and `vars`
to NixOS through `specialArgs`, and to Home Manager through `extraSpecialArgs`.
There is no global variable to change when moving between machines.

### Building and switching

For the first rebuild, explicitly select the machine you are running:

```bash
sudo nixos-rebuild switch --flake /home/carter/.config/nixos#djin
# On nosferatu instead:
sudo nixos-rebuild switch --flake /home/carter/.config/nixos#nosferatu
```

After opening a new Bash session, `rebuild` selects that installed machine's
output automatically. To build either configuration without activating it:

```bash
nix build .#nixosConfigurations.djin.config.system.build.toplevel --no-link
nix build .#nixosConfigurations.nosferatu.config.system.build.toplevel --no-link
```

Nosferatu's hardware file was restored from commit `8a4c0cc`. Before its first
switch, verify its boot filesystem UUID (`0F51-FD18`), root and swap logical
volumes, and LUKS UUID against the actual machine, using `lsblk -f` and its
current hardware configuration. Build success alone cannot verify disk identities.

### Changing or adding machines

Put changes intended for both machines in the shared files. Put host-specific
services and overrides in that host's `default.nix`; keep hardware detection
results in its hardware file. Preserve the installed system's `system.stateVersion`
and `home.stateVersion`; do not bump them as part of adding a host.

To add a machine, create its directory under `hosts/` with these three files,
set a unique hostname in `vars.nix`, and add its directory to the `map mkHost`
list in `flake.nix`. Generate hardware information on the new machine, not on
another host. If its state versions differ from the shared values, move those
settings into the host modules (and a host-specific Home Manager override).
Add new files to Git before building: Git-backed flakes only include files
known to Git.
