{ pkgs, config, ... }:

{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.autoLogin.enable = false;
  services.displayManager.autoLogin.user = "haaksk";
  services.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    (papirus-icon-theme.override { color = "palebrown"; })
    gnome-extension-manager
    gnomeExtensions.bing-wallpaper-changer

    bella
  ];

  # ============================================================================
  # GNOME DESKTOP SETTINGS
  # ============================================================================

  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    # ----------------------------------------------------
    # Database 1: Locked Settings
    # ----------------------------------------------------
    {
      lockAll = true;
      settings = {
        "org/gnome/desktop/interface" = {
          accent-color = "blue";
          show-battery-percentage = true;
          icon-theme = "Papirus";
          font-name = "Inter 11";
          document-font-name = "Inter 11";
          monospace-font-name = "JetBrainsMono Nerd Font 11";
        };
        "org/gnome/desktop/input-sources" = {
          xkb-options = [ "ctrl:nocaps" ];
        };
        "org/gnome/system/locale" = {
          region = "nb_NO.UTF-8";
        };
        "org/gnome/desktop/peripherals/mouse" = {
          speed = -0.2;
        };
        "org/gnome/desktop/peripherals/touchpad" = {
          tap-and-drag = false;
          disable-while-typing = true;
        };
        "org/gnome/settings-daemon/plugins/power" = {
          power-button-action = "nothing";
          sleep-inactive-ac-type = "nothing";
        };
        "org/gnome/desktop/wm/preferences" = {
          button-layout = "appmenu:close";
          titlebar-font = "Inter Bold 11";
        };
      };
    }

    # ----------------------------------------------------
    # Database 2: Unlocked Settings (Allows extension overrides)
    # ----------------------------------------------------
    {
      lockAll = false; # Set to false so background extensions can modify these
      settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = "adw-gtk3";
        };
        "org/gnome/shell" = {
          favorite-apps = [
            "firefox.desktop"
            "org.gnome.Console.desktop"
            "md.obsidian.Obsidian.desktop"
            "brave-cinhimbnkkaeohfgghhklpknlkffjgod-Default.desktop"
            "org.gnome.Nautilus.desktop"
            "org.localsend.localsend_app.desktop"
            "org.signal.Signal.desktop"
            "org.darktable.darktable.desktop"
          ];
        };
      };
    }
  ];

  environment.gnome.excludePackages = with pkgs; [
    showtime
    simple-scan
    snapshot
    yelp
    gnome-tecla
    gnome-music
    gnome-contacts
    decibels
    epiphany
    gnome-tour
    gnome-logs
    pkgs.gnome-connections
    gnome-weather
    gnome-clocks
    gnome-calendar
    gnome-calculator
    pkgs.nixos-render-docs
  ];

  environment.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
  };

  services.xserver.excludePackages = [ pkgs.xterm ];

  services.fprintd.enable = true;

}
