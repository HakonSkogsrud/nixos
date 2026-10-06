{ pkgs, ... }:

{
  home.username = "haaksk";
  home.homeDirectory = "/home/haaksk";
  home.stateVersion = "26.05";

  # Install the existing dotfiles during nixos-rebuild.
  home.file.".zshrc".source = ./dotfiles/zshrc;
  home.file.".tmux.conf".source = ./dotfiles/tmux.conf;
  home.file.".config/lazygit/config.yml".source = ./dotfiles/lazygit.yml;
  home.file.".emacs".source = ./dotfiles/emacs.el;
  programs.alacritty = {
    enable = true;
    settings = {
      window.dimensions = {
        columns = 110;
        lines = 30;
      };
      font = {
        normal.family = "BitstromWera Nerd Font";
        size = 12;
      };
      cursor.style = {
        shape = "Block";
        blinking = "On";
      };
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme.override { color = "palebrown"; };
    };
  };
  dconf.settings."org/gnome/desktop/interface".icon-theme = "Papirus";

}
