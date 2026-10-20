{ ... }:

{
  imports = [ ./plasma-env-fix.nix ];

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.autoLogin.enable = false;

  services.fprintd.enable = true;
}
