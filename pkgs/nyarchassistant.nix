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
  docutils,
  libadwaita,
  gtk4,
  glib,
  glib-networking,
  gsettings-desktop-schemas,
  adwaita-icon-theme,
  gdk-pixbuf,
  librsvg,
  gtksourceview5,
  vte-gtk4,
  webkitgtk_6_0,
  dconf,
  lsb-release,
  git,
  wget,
  gnutar,
  xz,
  xdg-utils,
  ffmpeg,
  portaudio,
  python3,
}:
let
  pname = "nyarchassistant";
  versions = builtins.fromJSON (builtins.readFile ../artifacts/versions.json);
  info = versions."NyarchAssistant" or (throw "No version info for NyarchAssistant");
  version = info.version;

  livepng = python3.pkgs.buildPythonPackage rec {
    pname = "livepng";
    version = "0.1.8";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/0c/48/ed7addd0d500857ab36a74497ee712bd5f2a3915bbe488089c21a4e690a1/livepng-${version}-py3-none-any.whl";
      sha256 = "15ss528xqzbxy2bndr5q7l6q0s7wlyfbnd54i84f5czprq5pkb6h";
    };
    format = "wheel";
    doCheck = false;
    propagatedBuildInputs = with python3.pkgs; [
      pyaudio
      pydub
    ];
  };

  pythonDeps = with python3.pkgs; [
    pygobject3
    libxml2
    requests
    pydub
    gtts
    speechrecognition
    numpy
    matplotlib
    newspaper3k
    lxml
    lxml-html-clean
    pylatexenc
    pyaudio
    tiktoken
    openai
    ollama
    llama-index-core
    llama-index-readers-file
    llama-index-vector-stores-faiss
    cssselect
    markdownify
    edge-tts
    scikit-learn
    mcp
    expandvars
    docx2txt
    feedparser
    tldextract
    webrtcvad
    ddgs
    faiss
    livepng
    pysilero-vad
    elevenlabs
    kokoro
    pycountry
    setuptools
    wheel
    pip
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
    docutils
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
    gtksourceview5
    vte-gtk4
    webkitgtk_6_0
    dconf
    lsb-release
    git
    wget
    gnutar
    xz
    xdg-utils
    ffmpeg
    portaudio
    python3
  ] ++ pythonDeps;

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [ git wget gnutar xz xdg-utils ffmpeg lsb-release python3 ]}"
      --prefix PYTHONPATH : "${python3.pkgs.makePythonPath pythonDeps}"
    )
  '';

  meta = with lib; {
    description = "Nyarch Assistant - Your ultimate Waifu AI Assistant";
    homepage = "https://github.com/NyarchLinux/NyarchAssistant";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    mainProgram = "nyarchassistant";
  };
}
