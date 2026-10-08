{ pkgs, ... }:

{
  home.username = "haaksk";
  home.homeDirectory = "/home/haaksk";
  home.stateVersion = "26.05";

  # Install the existing dotfiles during nixos-rebuild.
  home.file.".zshrc".source = ./dotfiles/zshrc;
  home.file.".tmux.conf".source = ./dotfiles/tmux.conf;
  home.file.".config/lazygit/config.yml".source = ./dotfiles/lazygit.yml;
  # Emacs configuration is managed by .dotfiles/emacs-home.
  # Alacritty configuration is managed by .dotfiles/niri-noctalia.
  home.packages = [
    pkgs.alacritty
    pkgs.glib
    pkgs.zip
  ];

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };
    gtk3.extraConfig.gtk-decoration-layout = ":";
    gtk4.extraConfig.gtk-decoration-layout = ":";
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme.override { color = "palebrown"; };
    };
  };
  dconf.settings."org/gnome/desktop/interface".icon-theme = "Papirus";
  dconf.settings."org/gnome/desktop/wm/preferences".button-layout = ":";

}
