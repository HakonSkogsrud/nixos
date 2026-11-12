{ ... }:

{
  home.stateVersion = "25.11";

  programs.bash = {
    enable = true;
    initExtra = builtins.readFile ./bashrc;
  };

  home.file.".emacs".source = ./init.el;
}
