{ inputs, config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "carter";
  home.homeDirectory = "/home/carter";

  imports = [ inputs.nixcord.homeModules.nixcord ];

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
  ];

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
      light = "~/.config/nixos/bash_scripts/light";
      dark = "~/.config/nixos/bash_scripts/dark";
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
