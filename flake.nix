{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    sops-nix = {
        url = "github:Mic92/sops-nix";
  	inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    azrah = {
      url = "github:carterjandrew/azrah-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    geometry-change = {
      url = "github:carterjandrew/kwin4_effect_geometry_change";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord.url = "github:4evy/nixcord";
  };

  outputs = inputs@{
    nixpkgs,
    home-manager,
    sops-nix,
    geometry-change,
    azrah,
    ...
  }: {
    nixosConfigurations.djin = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix 
	sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
	azrah.nixosModules.default
	# geometry-change.default
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.carter = ./home.nix;
	  home-manager.backupFileExtension = "backup";
        }
      ];
    };    
  };
}
