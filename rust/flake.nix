{
  description = "Rust project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-manifest = {
      url = "https://static.rust-lang.org/dist/channel-rust-1.83.0.toml";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
      rust-toolchain =
        (
          inputs.fenix.packages.${system}.fromManifestFile
          inputs.rust-manifest
        )
        .defaultToolchain;

      # https://crane.dev/
      craneLib = (inputs.crane.mkLib pkgs).overrideToolchain rust-toolchain;
      src = craneLib.cleanCargoSource ./.;

      commonArgs = {
        inherit src;
        strictDeps = true;
        buildInputs =
          [
            # additional inputs
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            # Additional darwin specific inputs can be set here
            pkgs.libiconv
          ];
      };

      cargoArtifacts = craneLib.buildDepsOnly commonArgs;

      crate = craneLib.buildPackage (commonArgs // {
        inherit cargoArtifacts;
      });
    in {
      formatter = pkgs.alejandra;

      checks = {inherit crate;};
      packages.default = crate;

      devShells.default = craneLib.devShell {
        checks = inputs.self.checks.${system};
        packages = [
          (pkgs.writeShellScriptBin "toolchains" ''
            ${pkgs.curl}/bin/curl -sL https://static.rust-lang.org/manifests.txt
          '')
        ];
      };
    });
}
