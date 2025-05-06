{
  description = "Custom nix flake templates";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = inputs: let
    systems = ["x86_64-linux"];
    eachSystem = systems: func: inputs.nixpkgs.lib.genAttrs systems (system: func system);
    eachDefaultSystem = eachSystem systems;
  in {
    formatter = eachDefaultSystem (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);
    devShells = eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
    in {
      default = pkgs.mkShellNoCC {
        name = "templates";
        packages = [
          pkgs.alejandra
        ];
      };
    });

    templates = {
      default = {
        path = ./default;
        description = "Simple flake for arbitrary projects";
      };
      python-shell = {
        path = ./python-shell;
        description = "Python using the modern transparent shell";
      };
      python-env = {
        path = ./python-env;
        description = "Python using a FHS emulated system";
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
  };
}
