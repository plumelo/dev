{ buildFHSEnv
, nodejs_22
, nodePackages
, python3
, ripgrep
, bc
, prefetch-npm-deps
, jq
, git
, git-lfs
, openssh
, glib
, fontconfig
, freetype
, pango
, cairo
, atk
, nss
, nspr
, alsa-lib
, expat
, cups
, dbus
, dbus-glib
, gdk-pixbuf
, gcc-unwrapped
, systemd
, libexif
, pciutils
, liberation_ttf
, curl
, util-linux
, wget
, flac
, harfbuzz
, icu
, libpng
, snappy
, speechd
, bzip2
, libcap
, at-spi2-atk
, at-spi2-core
, libkrb5
, libdrm
, libglvnd
, mesa
, coreutils
, libxkbcommon
, pipewire
, wayland
, gtk3
, gtk4
, udev
, libX11
, libXcursor
, libXrandr
, libXext
, libXfixes
, libXrender
, libXScrnSaver
, libXcomposite
, libxcb
, libXi
, libXdamage
, libXtst
, libxshmfence
, lz4
, libz
, extraDeps ? [ ]
}: (buildFHSEnv
  {
    name = "env";
    profile = ''
      export PATH=$PATH:node_modules/.bin
      export NIXPKGS_ALLOW_UNFREE=1
    '';
    targetPkgs = pkgs: [
      udev
      alsa-lib
      nodejs_22
      nodePackages.typescript-language-server
      python3
      ripgrep
      bc
      prefetch-npm-deps
      jq
      git
      git-lfs
      openssh
    ] ++ [
      (pkgs.writeShellScriptBin
        "tmux-ui"
        ''
          PROJECT=$(basename $(pwd))
          tmux at -t $PROJECT || tmux new -s $PROJECT -n term \; \
            splitw -v -p 50 \; \
            neww -n tig \; send "tig" C-m \; \
            neww -n nvim \; send "nvim" C-m \; \
            selectw -t 1\; selectp -t 1 \;
        '')
    ] ++ extraDeps ++ [
      libX11
      libXcursor
      libXext
      libXfixes
      libXrender
      libXScrnSaver
      libXcomposite
      libxcb
      libXi
      libXdamage
      libXtst
      libXrandr
      libxshmfence
    ] ++ [
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
      dbus-glib
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
      lz4
      libz
    ];
  }).env
