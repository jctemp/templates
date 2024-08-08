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
        default = {
          path = ./default;
          description = "Simple flake for arbitrary projects";
        };
        python = {
          path = ./python;
          description = "Python shell";
        };
        rust = {
          path = ./rust;
          description = "Simple rust project";
        };
        typst = {
          path = ./typst;
          description = "Typst template to write various documents";
        };
        zig = {
          path = ./zig;
          description = "Zig template";
        };
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
