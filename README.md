# Nyarch-Nix

Nix flake packaging for [Nyarch Linux](https://nyarchlinux.moe) applications:
- **[NyarchAssistant](https://github.com/NyarchLinux/NyarchAssistant)**: Waifu AI Assistant for Linux desktop
- **[CatgirlDownloader](https://github.com/NyarchLinux/CatgirlDownloader)**: GTK4 application to download images of catgirls and waifus

## Usage

### Run directly with Flakes

```bash
# Run NyarchAssistant (default app)
nix run github:fumoctl/Nyarch-Nix

# Or explicitly:
nix run github:fumoctl/Nyarch-Nix#nyarchassistant

# Run CatgirlDownloader
nix run github:fumoctl/Nyarch-Nix#catgirldownloader
```

### Install with Nix Profile

```bash
# Install NyarchAssistant
nix profile install github:fumoctl/Nyarch-Nix#nyarchassistant

# Install CatgirlDownloader
nix profile install github:fumoctl/Nyarch-Nix#catgirldownloader
```

### NixOS Configuration

Add the flake to your `flake.nix` inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nyarch-nix = {
      url = "github:fumoctl/Nyarch-Nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nyarch-nix, ... }: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            nyarch-nix.packages.${pkgs.system}.nyarchassistant
            nyarch-nix.packages.${pkgs.system}.catgirldownloader
          ];
        })
      ];
    };
  };
}
```

### Home Manager Configuration

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nyarch-nix = {
      url = "github:fumoctl/Nyarch-Nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nyarch-nix, ... }: {
    homeConfigurations."username" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        ({ pkgs, ... }: {
          home.packages = [
            nyarch-nix.packages.${pkgs.system}.nyarchassistant
            nyarch-nix.packages.${pkgs.system}.catgirldownloader
          ];
        })
      ];
    };
  };
}
```

### Using Overlays

```nix
{
  nixpkgs.overlays = [
    inputs.nyarch-nix.overlays.default
  ];

  environment.systemPackages = with pkgs; [
    nyarchassistant
    catgirldownloader
  ];
}
```

## Development & Maintenance

Enter the development shell:

```bash
nix develop
```

Available maintenance scripts:

- `./scripts/check-version.sh`: Checks currently pinned versions against the latest GitHub releases.
- `./scripts/update-version.sh`: Fetches the latest stable releases, prefetches hashes, updates `artifacts/versions.json`, and verifies the flake.
