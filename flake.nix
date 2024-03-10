{
  description = "Basic dependencies";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, }:
    {
      lib.shell = { pkgs, extraDeps ? [ ] }:
        let
          deps = with pkgs; [
            nodejs_latest
            nodePackages_latest.typescript-language-server
            python3
            ripgrep
            bc
            prefetch-npm-deps
            jq
          ] ++ extraDeps;
          env = ''
            export PATH=$PATH:node_modules/.bin
            export NIXPKGS_ALLOW_UNFREE=1
            export XDG_DATA_DIRS=$XDG_DATA_DIRS:/etc/profiles/per-user/$USER/share
            export SHELL=${pkgs.bashInteractive}/bin/bash
          '';
        in
        pkgs.mkShell {
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
      lib.patch-playwright = pkgs: with pkgs; writeShellScriptBin "patch-playwright" ''
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
      lib.playwrightEnv = pkgs: with pkgs; (buildFHSEnv
        {
          name = "playwright-env";
          targetPkgs = pkgs: [
            udev
            alsa-lib
            nodejs_latest
          ] ++ (with xorg;[
            libX11
            libXcursor
            libXrandr
            libXcursor
            libXext
            libXfixes
            libXrender
            libXScrnSaver
            libXcomposite
            libxcb
            libX11
            libXi
            libXdamage
            libXtst
            libXrandr
            libxshmfence
          ]) ++ [
            glib
            fontconfig
            freetype
            pango
            cairo
            atk
            nss
            nspr
            alsa-lib
            expat
            cups
            dbus
            gdk-pixbuf
            gcc-unwrapped.lib
            systemd
            libexif
            pciutils
            liberation_ttf
            curl
            util-linux
            wget
            flac
            harfbuzz
            icu
            libpng
            snappy
            speechd
            bzip2
            libcap
            at-spi2-atk
            at-spi2-core
            libkrb5
            libdrm
            libglvnd
            mesa
            coreutils
            libxkbcommon
            pipewire
            wayland
            gtk3
            gtk4
          ];
          runScript = "bash";
        }).env;
      lib.podmanShell = { pkgs }:
        let
          podmanSetupScript =
            let
              registriesConf = pkgs.writeText "registries.conf" ''
                [registries.search]
                registries = ['docker.io']

                [registries.block]
                registries = []
              '';
            in
            pkgs.writeScript "podman-setup" ''
              #!${pkgs.runtimeShell}
              if ! test -f ~/.config/containers/policy.json; then
                install -Dm555 ${pkgs.skopeo.src}/default-policy.json ~/.config/containers/policy.json
              fi

              if ! test -f ~/.config/containers/registries.conf; then
                install -Dm555 ${registriesConf} ~/.config/containers/registries.conf
              fi
            '';

        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            podman
            runc
            conmon
            skopeo
            slirp4netns
            fuse-overlayfs
          ];
          shellHook = ''
            ${podmanSetupScript}
          '';
        };
    }
    //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      rec {
        devShell = self.lib.shell { inherit pkgs; };
        devShells.podmanShell = self.lib.podmanShell { inherit pkgs; };
        packages = {
          patch-playwright = self.lib.patch-playwright pkgs;
          playwrightEnv = self.lib.playwrightEnv pkgs;
        };
      }
    );
}
