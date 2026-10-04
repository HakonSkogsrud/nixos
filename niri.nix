{ ... }:

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

  # Select Niri from GDM's session menu when trying it out.
  services.displayManager.defaultSession = "gnome";
}
