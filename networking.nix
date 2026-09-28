{ config, pkgs, ... }:

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Prefer the normal LAN route over policy-routing tables (for example,
  # tables installed by VPN software) when reaching the local subnet.
  systemd.services.local-network-policy-rule = {
    description = "Route the local subnet through the main routing table";
    wantedBy = [ "network.target" ];
    after = [ "NetworkManager.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.iproute2}/bin/ip rule delete to 10.0.0.0/24 priority 5000 table main 2>/dev/null || true
      # Ignore the main table's default route: use main only when the home LAN
      # has a more-specific route, otherwise fall through to Tailscale's table.
      ${pkgs.iproute2}/bin/ip rule add to 10.0.0.0/24 priority 5000 table main suppress_prefixlength 0
    '';
    preStop = ''
      ${pkgs.iproute2}/bin/ip rule delete to 10.0.0.0/24 priority 5000 table main 2>/dev/null || true
    '';
  };

  services.tailscale.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [
      config.services.tailscale.port
      53317
    ];
    checkReversePath = "loose";
  };

  # Enable systemd-resolved to fix Tailscale suspend/reboot DNS hangs
  services.resolved = {
    enable = true;
    # Ensures a global fallback is used if Tailscale's DNS drops
    settings.Resolve.Domains = [ "~." ];
  };
}
