{
  description = "Håkon's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    };
    wsf = {
      url = "github:daniel-g-carrasco/wayland-scroll-factor/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    touchpad-speed-control = {
      url = "github:ritesh-777/touchpad-speed-control/1e612ec4093b42127a454723cfe5cdf1a4f45c1d";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-flatpak,
      wsf,
      touchpad-speed-control,
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit wsf touchpad-speed-control; };
        modules = [
          nix-flatpak.nixosModules.nix-flatpak
          ./configuration.nix
          ./scrollfix.nix
        ];
      };
    };
}
