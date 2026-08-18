{
  lib,
  stdenv,
  fetchurl,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
  desktop-file-utils,
  gobject-introspection,
  libadwaita,
  gtk4,
  glib,
  glib-networking,
  gsettings-desktop-schemas,
  adwaita-icon-theme,
  gdk-pixbuf,
  librsvg,
  python3,
}:
let
  pname = "catgirldownloader";
  versions = builtins.fromJSON (builtins.readFile ../artifacts/versions.json);
  info = versions."CatgirlDownloader" or (throw "No version info for CatgirlDownloader");
  version = info.version;

  pythonDeps = with python3.pkgs; [
    pygobject3
    requests
  ];
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    inherit (info) url;
    sha256 = info.hash;
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    libadwaita
    gtk4
    glib
    glib-networking
    gsettings-desktop-schemas
    adwaita-icon-theme
    gdk-pixbuf
    librsvg
    python3
  ] ++ pythonDeps;

  preFixup = ''
    gappsWrapperArgs+=(--prefix PYTHONPATH : "${python3.pkgs.makePythonPath pythonDeps}")
  '';

  meta = with lib; {
    description = "GTK4 application that downloads images of catgirls and waifus from multiple sources";
    homepage = "https://github.com/NyarchLinux/CatgirlDownloader";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    mainProgram = "catgirldownloader";
  };
}
