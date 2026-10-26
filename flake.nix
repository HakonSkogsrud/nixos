{
  description = "Håkon's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=v0.8.0";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-flatpak,
    }:
    let
      system = "x86_64-linux";
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit unstablePkgs; };
        modules = [
          nix-flatpak.nixosModules.nix-flatpak
          ./configuration.nix
        ];
      };
    };
}
