{ pkgs, config, ... }:

{
  imports = [ ./plasma-env-fix.nix ];

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.autoLogin.enable = false;

  environment.systemPackages = [ pkgs.klassy ];

  services.fprintd.enable = true;

  # A terminal cannot offer PAM fingerprint and password authentication in
  # parallel.  Skip the following fprintd rule when the built-in display is
  # closed, allowing sudo to proceed directly to password authentication.
  security.pam.services.sudo.rules.auth.lidOpen = {
    order = config.security.pam.services.sudo.rules.auth.fprintd.order - 10;
    control = "[success=ignore default=1]";
    modulePath = "${pkgs.pam}/lib/security/pam_exec.so";
    args = [
      "quiet"
      "${pkgs.writeShellScript "is-laptop-lid-open" ''
        ${pkgs.gnugrep}/bin/grep -q '^state:.*open' /proc/acpi/button/lid/*/state
      ''}"
    ];
  };
}
