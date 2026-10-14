{ inputs, config, pkgs, ... }:

let
  configRoot = "${config.home.homeDirectory}/.config/nixos";
  themeSwitcher = name: colorScheme: themeFile:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [
        pkgs.coreutils
        pkgs.kdePackages.plasma-workspace
        pkgs.procps
      ];
      text = ''
        plasma-apply-colorscheme ${colorScheme} || true
        install -Dm0644 \
          ${inputs.kitty-themes}/themes/${themeFile} \
          "$HOME/.config/kitty/theme.conf"
        pkill -USR1 -u "$UID" kitty 2>/dev/null || true
      '';
    };
in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "carter";
  home.homeDirectory = "/home/carter";

  imports = [
    inputs.nixcord.homeModules.nixcord
    inputs.plasma-manager.homeModules.plasma-manager
    ./modules/plasma-config.nix
  ];

  home.packages = [
    pkgs.gh
    pkgs.htop
    pkgs.tmux
    pkgs.sops
    pkgs.fokus
    pkgs.codex
    pkgs.kitty
    pkgs.neovim
    pkgs.devenv
    pkgs.neovide
    pkgs.koreader
    pkgs.obsidian
    pkgs.thunderbird
    pkgs.jetbrains-mono
    pkgs.kdePackages.krohnkite
    pkgs.plasma-panel-colorizer
    inputs.geometry-change.packages.${pkgs.system}.default
    (themeSwitcher "light" "BreezeLight" "Material.conf")
    (themeSwitcher "dark" "BreezeDark" "Smyck.conf")
  ];

  # These links point at the checkout instead of the Nix store, so edits to
  # application configuration take effect without another rebuild.
  xdg.configFile."kitty/kitty.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${configRoot}/dotfiles/kitty/kitty.conf";
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${configRoot}/dotfiles/nvim";

  programs.nixcord = {
    enable = true;
    discord.vencord.enable = true;
    discord.vencord.package = pkgs.vencord;
  };

  programs.helix = {
    enable = true;
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch";
      secrets = "sudo sops ~/.config/nixos/secrets/secrets.yaml";
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "26.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
