# NixOS configuration

## Initial setup


```bash
nix-shell -p git

git clone https://github.com/HakonSkogsrud/nixos.git ~/nixos

cp /etc/nixos/hardware-configuration.nix ~/nixos/hardware-configuration.nix

cd ~/nixos
git add -A

sudo nixos-rebuild switch --flake .#nixos --option experimental-features "nix-command flakes"
```

## Updates


```bash
nix flake update
sudo nixos-rebuild switch --flake .#nixos
```

