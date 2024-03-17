{ buildFHSEnv
, nodejs_20
, nodePackages
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
}: (buildFHSEnv
  {
    name = "playwright-env";
    targetPkgs = pkgs: [
      udev
      alsa-lib
      nodejs_20
      nodePackages.typescript-language-server
    ] ++ [
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
  }).env
