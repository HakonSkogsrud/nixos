{ pkgs, ... }:

{
  programs.niri.enable = true;

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
    systemd = {
      enable = true;
      target = "niri.service";
    };
  };

  # Start the systemd session so Noctalia and desktop portals follow Niri.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${pkgs.niri}/bin/niri-session";
      user = "greeter";
    };
  };
  security.pam.services.greetd.enableGnomeKeyring = true;

  # Support X11 applications and provide fallback application icons.
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    hicolor-icon-theme
    adwaita-icon-theme
  ];
  programs.dconf.enable = true;
  # Enable network shares and virtual filesystems in Nautilus.
  services.gvfs.enable = true;
  environment.sessionVariables.XCURSOR_THEME = "Adwaita";
}
