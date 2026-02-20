{
  description = "Minecraft Dev Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zls-overlay = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zig-overlay.follows = "zig-overlay";
    };
  };

  outputs =
    {
      nixpkgs,
      zig-overlay,
      zls-overlay,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      devShells = nixpkgs.lib.genAttrs systems (
        system:
        let
          zig = zig-overlay.packages.${system}.master-2026-02-15;
          zls = zls-overlay.packages.${system}.zls.overrideAttrs (old: {
            nativeBuildInputs = [ zig ];
          });
          overlays = [
            (final: prev: {
              inherit zig zls;
            })
          ];
          pkgs = import nixpkgs {
            inherit system;
            inherit overlays;
          };
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.zig
              pkgs.zls
              pkgs.git
            ];
          };
        }
      );
    };
}
