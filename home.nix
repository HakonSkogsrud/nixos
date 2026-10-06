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
  programs.fuzzel = {
    enable = true;
    settings.main.icon-theme = "Papirus";
  };
  dconf.settings."org/gnome/desktop/interface".icon-theme = "Papirus";

  # A reproducible starting session for the fresh Niri installation.
  xdg.configFile."niri/config.kdl".text = ''
    input {
      keyboard {
        xkb {
          layout "no"
          variant "nodeadkeys"
          options "ctrl:nocaps"
        }
      }
      touchpad {
        tap
        dwt
        drag false
      }
    }

    layout {
      gaps 12
      default-column-width { proportion 0.5; }
      focus-ring { width 2; }
    }

    binds {
      Mod+Return { spawn "alacritty"; }
      Mod+D { spawn "fuzzel"; }
      Mod+Shift+Slash { show-hotkey-overlay; }
      Mod+Q { close-window; }
      Mod+Left { focus-column-left; }
      Mod+Right { focus-column-right; }
      Mod+Up { focus-window-up; }
      Mod+Down { focus-window-down; }
      Mod+Shift+Left { move-column-left; }
      Mod+Shift+Right { move-column-right; }
      Mod+Shift+Up { move-window-up; }
      Mod+Shift+Down { move-window-down; }
      Mod+Page_Up { focus-workspace-up; }
      Mod+Page_Down { focus-workspace-down; }
      Mod+Shift+Page_Up { move-column-to-workspace-up; }
      Mod+Shift+Page_Down { move-column-to-workspace-down; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+V { toggle-window-floating; }
      Print { screenshot; }
      Mod+Shift+E { quit; }
    }
  '';
}
