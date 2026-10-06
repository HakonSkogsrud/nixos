{ pkgs, lib, ... }:

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

  # Seed a writable upstream config once; Stow can replace it later.
  home.activation.seedNiriConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    niriConfig="$HOME/.config/niri/config.kdl"
    if [ ! -e "$niriConfig" ] && [ ! -L "$niriConfig" ]; then
      run mkdir -p "$HOME/.config/niri"
      run install -m 600 ${pkgs.niri.doc}/share/doc/niri/default-config.kdl "$niriConfig"
      run sed -i \
        's/Run an Application: fuzzel/Open Noctalia Launcher/; s/spawn "fuzzel"/spawn "noctalia" "msg" "panel-toggle" "launcher"/' \
        "$niriConfig"
    fi
  '';
}
