{
  description = "Basic dependencies";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, }:
    {
      lib.shell = { pkgs, extraDeps ? [ ] }: pkgs.callPackage ./env.nix { inherit extraDeps; };
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
      lib.playwrightEnv = pkgs: pkgs.callPackage ./env.nix { };
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
