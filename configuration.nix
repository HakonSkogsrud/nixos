{
  config,
  pkgs,
  unstablePkgs,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  # --- Boot ------------------------------------------------------------------

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --- Nix -------------------------------------------------------------------

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  programs.nh = {
    enable = true;
    flake = "git+file:///home/haaksk/nixos";
  };

  # --- Locale, time, keyboard ------------------------------------------------

  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nb_NO.UTF-8";
    LC_IDENTIFICATION = "nb_NO.UTF-8";
    LC_MEASUREMENT = "nb_NO.UTF-8";
    LC_MONETARY = "nb_NO.UTF-8";
    LC_NAME = "nb_NO.UTF-8";
    LC_NUMERIC = "nb_NO.UTF-8";
    LC_PAPER = "nb_NO.UTF-8";
    LC_TELEPHONE = "nb_NO.UTF-8";
    LC_TIME = "nb_NO.UTF-8";
  };

  services.xserver.xkb = {
    layout = "no";
    variant = "nodeadkeys";
  };
  console.keyMap = "no";

  # --- User ------------------------------------------------------------------

  users.users.haaksk = {
    isNormalUser = true;
    description = "Håkon Skogsrud";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.bashInteractive;
  };

  environment.sessionVariables = {
    EDITOR = "nvim";
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "iHD";
  };

  # --- Hardware --------------------------------------------------------------

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver ];
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.printing.enable = true;
  services.fwupd.enable = true;
  services.fprintd.enable = true;

  # Libinput scales motion down for DPI values above 1000.
  services.udev.extraHwdb = ''
    mouse:bluetooth:v1915p0040:name:*:
     MOUSE_DPI=1200@1000

    mouse:bluetooth:v046Dp0B020:name:*:
     MOUSE_DPI=1800@1000
  '';

  # --- Networking ------------------------------------------------------------

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  services.tailscale.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    checkReversePath = "loose";
  };

  # Prefer the normal LAN route over policy-routing tables (for example,
  # tables installed by VPN software) when reaching the local subnet.
  systemd.services.local-network-policy-rule = {
    description = "Route the local subnet through the main routing table";
    wantedBy = [ "network.target" ];
    after = [ "NetworkManager.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.iproute2}/bin/ip rule delete to 10.0.0.0/24 priority 5000 table main 2>/dev/null || true
      # Ignore the main table's default route: use main only when the home LAN
      # has a more-specific route, otherwise fall through to Tailscale's table.
      ${pkgs.iproute2}/bin/ip rule add to 10.0.0.0/24 priority 5000 table main suppress_prefixlength 0
    '';
    preStop = ''
      ${pkgs.iproute2}/bin/ip rule delete to 10.0.0.0/24 priority 5000 table main 2>/dev/null || true
    '';
  };

  services.syncthing = {
    enable = true;
    user = "haaksk";
    dataDir = "/home/haaksk";
    configDir = "/home/haaksk/.config/syncthing";
    openDefaultPorts = true;

    # Nix settings override anything changed in the GUI.
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices.services = {
        id = "M7IMWFU-66PMZO3-WVVK2S7-NJDOZT3-XUIMWGU-3QMAX3B-5PMYWR5-LDA4MQV";
        # Direct address avoids relying on global discovery relays.
        addresses = [ "tcp://10.0.0.44:22000" ];
      };

      folders.Documents = {
        id = "ulv9z-dbglm"; # Must match the server's folder ID
        label = "Sync";
        path = "/home/haaksk/Documents";
        devices = [ "services" ];
      };
    };
  };

  # --- Desktop (GNOME) -------------------------------------------------------

  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Drop all default GNOME apps, then add back only the ones wanted.
  services.gnome.core-apps.enable = false;

  fonts.packages = with pkgs; [
    inter
    nerd-fonts.comic-shanns-mono
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.bitstream-vera-sans-mono
  ];

  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Inter" ];
    monospace = [ "JetBrainsMono Nerd Font" ];
  };

  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          accent-color = "blue";
          show-battery-percentage = true;
          icon-theme = "Papirus";
          font-name = "Inter 11";
          document-font-name = "Inter 11";
          monospace-font-name = "JetBrainsMono Nerd Font 11";
        };
        "org/gnome/desktop/input-sources".xkb-options = [ "ctrl:nocaps" ];
        "org/gnome/system/locale".region = "nb_NO.UTF-8";
        "org/gnome/desktop/peripherals/mouse".speed = -0.2;
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
        "org/gnome/shell".favorite-apps = [
          "firefox.desktop"
          "com.mitchellh.ghostty.desktop"
          "brave-cinhimbnkkaeohfgghhklpknlkffjgod-Default.desktop"
          "org.gnome.Nautilus.desktop"
          "md.obsidian.Obsidian.desktop"
          "org.localsend.localsend_app.desktop"
        ];
      };
    }
  ];

  # --- Applications ----------------------------------------------------------

  programs.firefox = {
    enable = true;
    policies.Preferences = {
      "media.ffmpeg.vaapi.enabled" = {
        Value = true;
        Status = "user";
      };
      "widget.wayland-dmabuf-vaapi.enabled" = {
        Value = true;
        Status = "user";
      };
      "toolkit.legacyUserProfileCustomizations.stylesheets" = {
        Value = true;
        Status = "user";
      };
    };
  };

  programs.git = {
    enable = true;
    config = {
      user.name = "Håkon Skogsrud";
      user.email = "haakon.skogsrud@pm.me";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  services.flatpak = {
    enable = true;
    packages = [
      "org.libreoffice.LibreOffice"
      "md.obsidian.Obsidian"
      "org.localsend.localsend_app"
      "org.signal.Signal"
    ];
  };

  environment.systemPackages = with pkgs; [
    # Desktop
    ghostty
    brave
    loupe
    nautilus
    gnome-text-editor
    gnome-calendar
    gnome-calculator
    papers
    gnome-system-monitor
    hicolor-icon-theme
    adwaita-icon-theme
    (papirus-icon-theme.override { color = "palebrown"; })

    # Development
    neovim
    lazygit
    delta
    gh
    stow
    nixd
    nixfmt
    unstablePkgs.codex
    unstablePkgs.vscode
  ];

  # Records the release originally installed; do NOT change.
  system.stateVersion = "25.11";
}
