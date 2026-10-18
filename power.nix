{ pkgs, ... }:

let
  setPowerProfile = pkgs.writeShellScript "set-power-profile" ''
    profile=balanced
    for supply in /sys/class/power_supply/*; do
      if [ -r "$supply/online" ] \
        && read -r online < "$supply/online" \
        && [ "$online" = 1 ]; then
        profile=performance
        break
      fi
    done
    exec ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set "$profile"
  '';
in
{
  services.power-profiles-daemon.enable = true;

  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="power_supply", TEST=="online", RUN+="${setPowerProfile}"
  '';

  systemd.services.power-profile-on-boot = {
    description = "Set power profile for current charger state";
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profiles-daemon.service" ];
    requires = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = setPowerProfile;
    };
  };
}
