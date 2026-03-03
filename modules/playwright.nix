{ pkgs, lib, ... }:

let
  playwright-runtime-deps = with pkgs; [
    at-spi2-atk
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libdrm
    libnotify
    libuuid
    libxkbcommon
    mesa
    nspr
    nss
    pango
    pipewire
    systemd
    wayland
    icu
    libopus
    stdenv.cc.cc.lib
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
    alsa-lib
    libgbm
  ];
in
{
  environment.systemPackages = with pkgs; [
    playwright-driver.browsers
    playwright-driver
    noto-fonts-cjk-sans
  ];

  # nix-ld libraries: allow downloaded Playwright browsers (non-nix binaries) to find .so files
  programs.nix-ld.libraries = playwright-runtime-deps;

  environment.variables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";

    # 使用 mkForce 强制覆盖，并将之前的系统路径合并进来
    LD_LIBRARY_PATH = lib.mkForce "${pkgs.lib.makeLibraryPath playwright-runtime-deps}:/run/current-system/sw/lib";
  };

  fonts.fontconfig.enable = true;
}
