{
  description = "Simple flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
      pkgs = import nixpkgs {inherit system;};
      rust-toolchain = pkgs.symlinkJoin {
        name = "rust-toolchain";
        paths = with pkgs; [
          cargo
          cargo-watch
          clippy
          rust-analyzer
          rustc
          rustfmt
          rustPlatform.rustcSrc
        ];
      };
    in {
      packages.default = pkgs.rustPlatform.buildRustPackage {
        inherit (cargoToml.package) version;
        pname = cargoToml.package.name;
        src = ./.;
        cargoLock.lockFile = ./Cargo.lock;
      };
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShell {
        shellHook = ''
          export RUST_SRC_PATH=${pkgs.rustPlatform.rustLibSrc}
          export RUST_BACKTRACE=1;
        '';
        packages = with pkgs; [
          alejandra
          rust-toolchain
        ];
      };
    });
}
