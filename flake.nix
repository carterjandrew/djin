{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.djin = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };    
  };
}
