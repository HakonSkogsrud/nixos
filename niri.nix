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

  # Keep terminal access and application icons without the GNOME desktop.
  environment.systemPackages = with pkgs; [
    hicolor-icon-theme
    adwaita-icon-theme
  ];
  programs.dconf.enable = true;
  environment.sessionVariables.XCURSOR_THEME = "Adwaita";
}
