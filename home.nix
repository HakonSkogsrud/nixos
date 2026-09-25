{ ... }:

{
  home.username = "haaksk";
  home.homeDirectory = "/home/haaksk";
  home.stateVersion = "26.05";

  # Install the existing dotfiles during nixos-rebuild.
  home.file.".zshrc".source = ./dotfiles/zshrc;
  home.file.".tmux.conf".source = ./dotfiles/tmux.conf;
  home.file.".config/ghostty/config".source = ./dotfiles/ghostty.conf;
  home.file.".config/lazygit/config.yml".source = ./dotfiles/lazygit.yml;
  home.file.".emacs".source = ./dotfiles/emacs.el;
  home.file.".codex/config.toml".source = ./dotfiles/codex-config.toml;
}
