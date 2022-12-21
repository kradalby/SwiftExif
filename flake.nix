{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    version =
      if (self ? shortRev)
      then self.shortRev
      else "dev";
  in
    {
      overlay = final: prev: let
        pkgs = nixpkgs.legacyPackages.${prev.system};
      in rec {
      };
    }
    // flake-utils.lib.eachDefaultSystem
    (system: let
      pkgs = import nixpkgs {
        overlays = [self.overlay];
        inherit system;
      };
    in rec {
      # `nix develop`
      devShell = pkgs.mkShell {
        nativeBuildInputs = [pkgs.pkg-config];
        buildInputs = with pkgs;
          [
            clang
            coreutils
            libexif
            libiptcdata
          ]
          ++ lib.optionals pkgs.stdenv.isLinux [
            swift
            swift-corelibs-libdispatch
          ];
      };
    });
}
