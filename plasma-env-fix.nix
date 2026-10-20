{ ... }:

{
  # Flatten Plasma's dependency data paths instead of inheriting hundreds of
  # XDG_DATA_DIRS entries. This rebuilds plasma-workspace on updates.
  # https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-3741634437
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages // {
        plasma-workspace =
          let
            basePkg = prev.kdePackages.plasma-workspace;
            xdgData = final.stdenv.mkDerivation {
              name = "${basePkg.name}-xdg-data";
              buildInputs = [ basePkg ];
              dontUnpack = true;
              dontFixup = true;
              dontWrapQtApps = true;
              installPhase = ''
                mkdir -p "$out/share"
                IFS=: read -r -a dataDirs <<< "$XDG_DATA_DIRS"
                for dir in "''${dataDirs[@]}"; do
                  if [[ -d "$dir" ]]; then
                    cp -r "$dir/." "$out/share/"
                    chmod -R u+w "$out/share"
                  fi
                done
              '';
            };
          in
          basePkg.overrideAttrs (old: {
            preFixup = (old.preFixup or "") + ''
              filteredQtWrapperArgs=()
              for ((i = 0; i < ''${#qtWrapperArgs[@]}; )); do
                if [[ "''${qtWrapperArgs[i]}" == "--prefix" \
                   && "''${qtWrapperArgs[i+1]}" == "XDG_DATA_DIRS" ]]; then
                  ((i += 4))
                else
                  filteredQtWrapperArgs+=("''${qtWrapperArgs[i]}")
                  ((i += 1))
                fi
              done
              qtWrapperArgs=("''${filteredQtWrapperArgs[@]}")
              qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgData}/share")
              qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
            '';
          });
      };
    })
  ];
}
