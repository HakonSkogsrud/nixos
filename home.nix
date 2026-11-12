{ pkgs, ... }:

{
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    ghostty
  ];

  programs.bash = {
    enable = true;
    initExtra = builtins.readFile ./bashrc;
  };

  home.file.".emacs".source = ./init.el;
  xdg.configFile."ghostty/config".source = ./ghostty.conf;
}
