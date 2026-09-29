{
  description = "Håkon's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr = {
      url = "github:herdrdev/herdr-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wsf = {
      url = "github:daniel-g-carrasco/wayland-scroll-factor/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "herdr/flake-utils";
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
      home-manager,
      herdr,
      wsf,
      touchpad-speed-control,
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit herdr wsf touchpad-speed-control; };
        modules = [
          nix-flatpak.nixosModules.nix-flatpak
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./scrollfix.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.users.haaksk = import ./home.nix;
          }
        ];
      };
    };
}
