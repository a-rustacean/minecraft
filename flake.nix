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
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      pkgsFor = nixpkgs.legacyPackages;
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system (pkgsFor."${system}"));
    in
    {
      devShells = forAllSystems (
        system: pkgs:
        let
          zig = zig-overlay.packages.${system}.master-2026-02-15;
          zls = zls-overlay.packages.${system}.zls.overrideAttrs (old: {
            nativeBuildInputs = [ zig ];
          });
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.git
              zig
              zls
            ];
          };
        }
      );
    };
}
