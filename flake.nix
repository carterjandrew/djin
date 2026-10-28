{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    sops-nix = {
        url = "github:Mic92/sops-nix";
  	inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    azrah = {
      url = "github:carterjandrew/azrah-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    geometry-change = {
      url = "github:carterjandrew/kwin4_effect_geometry_change";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kitty-themes = {
      url = "github:dexpota/kitty-themes";
      flake = false;
    };
    nixcord.url = "github:4evy/nixcord";
  };

  outputs = inputs@{ nixpkgs, sops-nix, home-manager, azrah, ... }:
    let
      # Each host supplies its own variables and hardware; everything else is shared.
      mkHost = hostDirectory:
        let
          vars = import (hostDirectory + "/vars.nix");
        in {
          name = vars.hostname;
          value = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs vars; };
            modules = [
              ./configuration.nix
              hostDirectory
              sops-nix.nixosModules.sops
              home-manager.nixosModules.home-manager
              azrah.nixosModules.default
              {
                networking.hostName = vars.hostname;
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit inputs vars; };
                home-manager.users.carter = ./home.nix;
                home-manager.backupFileExtension = "backup";
              }
            ];
          };
        };
    in {
      nixosConfigurations = builtins.listToAttrs (map mkHost [
        ./hosts/djin
        ./hosts/nosferatu
      ]);
    };
}
