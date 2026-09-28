{ ... }:

{
  services.syncthing = {
    enable = true;

    user = "haaksk";

    # The default directory where new synced folders will be created
    dataDir = "/home/haaksk";

    # Where Syncthing will store its settings, certificates, and database
    configDir = "/home/haaksk/.config/syncthing";

    # Automatically open ports (22000/TCP, 22000/UDP, 21027/UDP) in the firewall
    openDefaultPorts = true;

    # Declarative enforcement: Force NixOS settings to override GUI manual changes
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      # 1. Register the remote server device
      devices = {
        "services" = {
          id = "M7IMWFU-66PMZO3-WVVK2S7-NJDOZT3-XUIMWGU-3QMAX3B-5PMYWR5-LDA4MQV";
          # Since 10.0.0.44 is a local/Tailscale IP, specifying it directly
          # allows instant connection without relying on global discovery relays.
          addresses = [ "tcp://10.0.0.44:22000" ];
        };
      };

      # 2. Map the shared folder to your local Documents directory
      folders = {
        "Documents" = {
          id = "ulv9z-dbglm"; # Must match the server's folder ID exactly
          label = "Sync"; # Keeps the user-friendly label "Sync" in your GUI
          path = "/home/haaksk/Documents"; # The local target directory on your laptop
          devices = [ "services" ]; # Tell Syncthing to sync this folder with the server
        };
        "2026" = {
          id = "c2xpa-nhtgu"; # Must match the server's folder ID exactly
          label = "2026"; # Keeps the user-friendly label "Sync" in your GUI
          path = "/home/haaksk/Pictures/2026"; # The local target directory on your laptop
          devices = [ "services" ]; # Tell Syncthing to sync this folder with the server
        };
        "Pictures Inbox" = {
          id = "zyxr7-ptepx";
          label = "Pictures Inbox";
          path = "/home/haaksk/Pictures/Inbox";
          devices = [ "services" ];
        };
      };
    };
  };
}
