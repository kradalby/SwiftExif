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
  }:
  # Not eachDefaultSystem: nixpkgs 26.11 dropped x86_64-darwin and throws on eval.
    flake-utils.lib.eachSystem ["x86_64-linux" "aarch64-linux" "aarch64-darwin"]
    (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      # `nix develop`
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [pkgs.pkg-config];
        buildInputs = with pkgs;
          [
            clang
            coreutils
            libexif
            libiptcdata
            swift-format
            sourcekit-lsp
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            swift
            swift-corelibs-libdispatch
          ];
      };
    });
}
