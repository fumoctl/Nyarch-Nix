{
  description = "NyarchLinux Apps (NyarchAssistant and CatgirlDownloader) for Nix and NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      rec {
        packages = {
          default = packages.nyarchassistant;
          nyarchassistant = pkgs.callPackage ./pkgs/nyarchassistant.nix {};
          catgirldownloader = pkgs.callPackage ./pkgs/catgirldownloader.nix {};
        };

        apps = {
          default = apps.nyarchassistant;
          nyarchassistant = {
            type = "app";
            program = "${packages.nyarchassistant}/bin/nyarchassistant";
            meta.description = "Nyarch Assistant - Your ultimate Waifu AI Assistant";
          };
          catgirldownloader = {
            type = "app";
            program = "${packages.catgirldownloader}/bin/catgirldownloader";
            meta.description = "Catgirl Downloader - Download catgirls and waifus from multiple sources";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nix
            git
            curl
            jq
          ];
          shellHook = ''
            echo "NyarchLinux Apps Nix Flake development environment"
            echo "Available commands:"
            echo "  ./scripts/check-version.sh  - Check current vs latest versions"
            echo "  ./scripts/update-version.sh - Update to latest versions"
          '';
        };
      }
    ) // {
      overlays.default = final: prev: {
        nyarchassistant = final.callPackage ./pkgs/nyarchassistant.nix {};
        catgirldownloader = final.callPackage ./pkgs/catgirldownloader.nix {};
      };
    };
}
