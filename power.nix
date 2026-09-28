{ pkgs, ... }:

let
  setPowerProfile = pkgs.writeShellScript "set-power-profile" ''
    profile=balanced
    if read -r online < /sys/class/power_supply/ADP0/online && [ "$online" = 1 ]; then
      profile=performance
    fi
    exec ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set "$profile"
  '';
in
{
  services.power-profiles-daemon.enable = true;

  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="ADP0", RUN+="${setPowerProfile}"
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
