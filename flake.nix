{
  description = "Basic dependencies";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        deps = with pkgs; [
          nodejs_latest
          nodePackages_latest.typescript-language-server
          python3
          ripgrep
          bc
        ];
        env = ''
          export PATH=$PATH:node_modules/.bin
          export NIXPKGS_ALLOW_UNFREE=1
          export XDG_DATA_DIRS=$XDG_DATA_DIRS:/etc/profiles/per-user/$USER/share
          export SHELL=${pkgs.bashInteractive}/bin/bash
        '';
      in
      rec {
        packages = flake-utils.lib.flattenTree
          (with pkgs;  rec {
            devShell = mkShell {
              buildInputs = deps;
              shellHook = ''
                ${env}
                tmux-ui() {
                  PROJECT=$(basename $(pwd))
                  tmux at -t $PROJECT || tmux new -s $PROJECT -n term \; \
                    splitw -v -p 50 \; \
                    neww -n tig \; send "tig" C-m \; \
                    neww -n nvim \; send "nvim" C-m \; \
                    selectw -t 1\; selectp -t 1 \;
                }
              '';
            };
            patch-playwright = writeShellScriptBin "patch-playwright" ''
              path=''${1:-~/.cache/ms-playwright}
              interpr=$(nix eval --raw 'nixpkgs#glibc')/lib64/ld-linux-x86-64.so.2
              rpath=${google-chrome.rpath}:${lib.makeLibraryPath [dbus-glib xorg.libXt]}
              find $path/{chromium,firefox}-*/*/ -executable -type f | while read i; do
                if ! [[ "$i" == *.so ]]; then
                    ${patchelf}/bin/patchelf --set-interpreter "$interpr" "$i" || true
                fi
                ${patchelf}/bin/patchelf --set-rpath "$rpath" "$i" || true
              done
              ${patchelf}/bin/patchelf --set-interpreter "$interpr" $path/ffmpeg-*/ffmpeg-linux
            '';
          });
        defaultPackage = packages.devShell;
      }
    );
}