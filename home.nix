{ inputs, config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "carter";
  home.homeDirectory = "/home/carter";

  imports = [ inputs.nixcord.homeModules.nixcord ];

  home.packages = with pkgs; [
    gh
    htop
    sops
    kitty
    devenv
    koreader
    thunderbird
    home-manager
  ];

  programs.nixcord = {
    enable = true;
    discord.vencord.enable = true;
    # Use the release's Vencord package; Nixcord's default requires pnpm_12.
    discord.vencord.package = pkgs.vencord;
    # user = "carterjandrew";
  };

  programs.neovim = {
    enable = true;
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
