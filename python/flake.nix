{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.alejandra
          pkgs.uv
          (pkgs.python3.withPackages (pp:
            with pp; [
              pandas
              numpy
              jupyter
              ipykernel
            ]))
        ];
        shellHook = ''
          uv venv
          source .venv/bin/activate
        '';
      };
    });
}
