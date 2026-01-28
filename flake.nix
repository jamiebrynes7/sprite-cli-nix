{
  description = "Sprite CLI - Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        sprite = pkgs.callPackage ./package.nix { };
      in
      {
        packages = {
          default = sprite;
          sprite = sprite;
        };

        apps.default = {
          type = "app";
          program = "${sprite}/bin/sprite";
          meta = {
            description = "Spite CLI";
            homepage = "https://sprites.dev/";
            license = "unfree";
            platforms = [
              "x86_64-linux"
              "aarch64-linux"
              "x86_64-darwin"
              "aarch64-darwin"
            ];
          };
        };
      }
    ) // {
      overlays.default = final: prev: {
        sprite = final.callPackage ./package.nix { };
      };
    };
}
