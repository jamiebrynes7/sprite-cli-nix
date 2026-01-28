# Sprite CLI Nix Flake

A Nix flake that packages the [Sprite CLI](https://sprites.dev/) using official binaries.

## Features

- Official binary distribution from Sprite
- Nix overlay support for NixOS/Home Manager integration
- Automated update script for version bumping

## Usage

### Quick Run

```bash
nix run github:jamiebrynes7/sprites-cli-nix
```

### NixOS / Home Manager

Add the overlay to your configuration:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sprite-cli.url = "github:jamiebrynes7/sprites-cli-nix";
  };

  outputs = { nixpkgs, sprite-cli, ... }: {
    # NixOS configuration
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs.overlays = [ sprite-cli.overlays.default ];
          environment.systemPackages = [ pkgs.sprite ];
        }
      ];
    };

    # Or Home Manager
    homeConfigurations.myuser = home-manager.lib.homeManagerConfiguration {
      modules = [
        {
          nixpkgs.overlays = [ sprite-cli.overlays.default ];
          home.packages = [ pkgs.sprite ];
        }
      ];
    };
  };
}
```

## Supported Platforms

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin`
- `aarch64-darwin`

## Updating

Run the update script to fetch the latest version:

```bash
./scripts/update-version.sh
```

This will:
1. Fetch the latest version from the release channel (falling back to rc)
2. Download and compute SRI hashes for all platforms
3. Update `version.json`

## License

Sprite CLI is proprietary software. This flake simply packages the official binaries for Nix.
