{
  description = "Custom nix flake templates";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    {
      templates = {
        default = {
          path = ./default;
          description = "Simple flake for arbitrary projects";
        };
        python = {
          path = ./python;
          description = "Python";
        };
        rust = {
          path = ./rust;
          description = "Rust";
        };
        typst = {
          path = ./typst;
          description = "Typst";
        };
        zig = {
          path = ./zig;
          description = "Zig";
        };
      };
    }
    // (
      inputs.flake-utils.lib.eachDefaultSystem (system: let
        pkgs = import inputs.nixpkgs {inherit system;};
      in {
        formatter = pkgs.alejandra;
        devShells.default = pkgs.mkShellNoCC {
          name = "templates shell";
          packages = [
            pkgs.alejandra
          ];
        };
      })
    );
}
