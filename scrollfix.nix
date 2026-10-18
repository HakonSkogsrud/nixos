{
  pkgs,
  lib,
  wsf,
  touchpad-speed-control,
  ...
}:

let
  scrollFactors = lib.gvariant.mkArray [
    (lib.gvariant.mkDictionaryEntry "brave" 0.20)
    (lib.gvariant.mkDictionaryEntry "md.obsidian.Obsidian" 0.30)
  ];

  touchpadSpeedControl =
    pkgs.runCommand "touchpad-speed-control" { nativeBuildInputs = [ pkgs.glib ]; }
      ''
        extensionDir=$out/share/gnome-shell/extensions/touchpad-speed-control@ritesh
        mkdir -p "$extensionDir"
        cp -r ${touchpad-speed-control}/. "$extensionDir/"
        chmod -R u+w "$extensionDir"
        glib-compile-schemas --strict "$extensionDir/schemas"
      '';
in

{
  imports = [ wsf.nixosModules.default ];

  options.local.gnome.extraExtensions = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Additional GNOME Shell extensions to enable.";
  };

  config = {
    programs.wsf.enable = true;

    environment.systemPackages = [ touchpadSpeedControl ];

    local.gnome.extraExtensions = [ "touchpad-speed-control@ritesh" ];

    programs.dconf.profiles.user.databases = lib.mkAfter [
      {
        lockAll = false;
        settings."org/gnome/shell/extensions/touchpad-speed-control" = {
          global-factor = 1.0;
          h-global-factor = 1.0;
          app-factors = scrollFactors;
          h-app-factors = scrollFactors;
        };
      }
    ];
  };
}
