{
  description = "Nix flake templates";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    {
      templates = {
      };
    }
    // (
      flake-utils.lib.eachDefaultSystem (system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        formatter = pkgs.alejandra;
        devShells.default = pkgs.mkShellNoCC {
          packages = [
            pkgs.alejandra
          ];
        };
      })
    );
}
