{ pkgs, unstablePkgs, ... }:

{
  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    ./hardware-configuration.nix
    ./gnome.nix
    ./networking.nix
    ./syncthing.nix
  ];

  # ============================================================================
  # BOOT & SYSTEM CORE
  # ============================================================================

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Linux 7.3 triggered an intel_ipu6_isys runtime-suspend kernel oops on this XPS 9440.
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  hardware.enableRedistributableFirmware = true;


  # ============================================================================
  # LOCALE & TIMEZONE
  # ============================================================================

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

  # ============================================================================
  # DISPLAY & DESKTOP ENVIRONMENT (X11 + GNOME)
  # ============================================================================

  # Keyboard configuration
  services.xserver.xkb = {
    layout = "no";
    variant = "nodeadkeys";
  };
  console.keyMap = "no";

  # ============================================================================
  # AUDIO & SOUND (PipeWire)
  # ============================================================================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ============================================================================
  # ENVIRONMENT & SESSION VARIABLES
  # ============================================================================

  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "iHD";
  };

  # ============================================================================
  # USERS
  # ============================================================================

  users.users.haaksk = {
    isNormalUser = true;
    description = "Håkon Skogsrud";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  # ============================================================================
  # FONTS
  # ============================================================================

  fonts.packages = with pkgs; [
    inter
    nerd-fonts.jetbrains-mono
    nerd-fonts.bitstream-vera-sans-mono
  ];

  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Inter" ];
    monospace = [ "JetBrainsMono Nerd Font" ];
  };

  # ============================================================================
  # PROGRAMS & APPLICATIONS
  # ============================================================================

  # Firefox with declarative enterprise policies
  programs.firefox = {
    enable = true;

    policies = {
      Preferences = {
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

      # Automatically install extensions
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "jid1-MnnxcxisBPnSXQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
          installation_mode = "force_installed";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
      };

    };
  };

  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Git configuration
  programs.git = {
    enable = true;
    config = {
      user.name = "Håkon Skogsrud";
      user.email = "haakon.skogsrud@pm.me";
    };
  };

  # ============================================================================
  # PACKAGE MANAGEMENT
  # ============================================================================

  nixpkgs.config.allowUnfree = true;

  programs.nh = {
    enable = true;
    flake = "git+file:///home/haaksk/Workspace/nixos";
  };

  services.flatpak = {
    enable = true;
    packages = [
      # Keep both variants available so GTK3 Flatpaks follow GNOME's
      # light/dark appearance setting.
      "org.gtk.Gtk3theme.adw-gtk3"
      "org.gtk.Gtk3theme.adw-gtk3-dark"
      "org.libreoffice.LibreOffice"
      "md.obsidian.Obsidian"
      "org.localsend.localsend_app"
      "org.signal.Signal"
    ];


    # Both applications currently render a light client-side titlebar on
    # native Wayland.  Use Mutter's X11 decorations until that is fixed
    # upstream; the GTK theme itself still follows GNOME's color scheme.
    overrides."org.localsend.localsend_app".Context.sockets = [
      "x11"
      "!wayland"
      "!fallback-x11"
    ];
  };

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================

  environment.systemPackages = with pkgs; [
    # Development Tools and Editors
    lazygit
    delta
    neovim
    gh
    stow
    gcc
    python3
    lua-language-server
    nixd
    nixfmt
    nix-direnv
    unstablePkgs.codex

    # Terminal and Shell Utilities
    wget
    fzf
    fd
    bat
    ripgrep
    zoxide
    eza
    zsh-autosuggestions
    uv

    # Applications and Utilities
    loupe
    darktable
    syncthing
    brave
    tailscale

    # Other Tools
    nodejs
  ];

  # ============================================================================
  # INPUT DEVICES
  # ============================================================================

  # Mouse motion normalization before GNOME settings.
  # Libinput scales motion down for DPI values above 1000.
  services.udev.extraHwdb = ''
    mouse:bluetooth:v1915p0040:name:*:
     MOUSE_DPI=1200@1000

    mouse:bluetooth:v046Dp0B020:name:*:
     MOUSE_DPI=1800@1000
  '';

  # ============================================================================
  # HARDWARE
  # ============================================================================

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  services.printing.enable = true;

  # ============================================================================
  # SERVICES
  # ============================================================================

  services.fwupd.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # ============================================================================
  # NIX PACKAGE MANAGER
  # ============================================================================

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  nix.settings.auto-optimise-store = true;

  # ============================================================================
  # SYSTEM UPDATES & STATE
  # ============================================================================

  # Disabled auto-upgrade to avoid frequent kernel recompilations
  # Run 'sudo nixos-rebuild switch' manually when you want to apply updates
  system.autoUpgrade = {
    enable = false;
    dates = "04:00";
    channel = "https://channels.nixos.org/nixos-26.05";
    allowReboot = false;
    persistent = true;
    randomizedDelaySec = "30min";
  };

  # DO NOT change this value. It does NOT track your current NixOS version.
  # It records which version you originally installed on (for backwards compatibility).
  system.stateVersion = "25.11";
}
