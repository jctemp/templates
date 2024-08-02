# NixOS and python
#   Nix has actually a good support for python and package creation.
#   However, at the current state of the project it is very difficult
#   to work with python packages that utilises NVIDIA CUDA, e.g.
#   most machine learning and computer vision libraries. It comes
#   with the issues of missing binary builds as NVIDIA is closed
#   source and NixOS is not building packages with non-FOSS liscences.
#   One could use binary caches of thrid party, nonetheless, depending
#   on the version and setup binaries are not available causing a
#   recompiling of these libraries. Hence, INSANE BUILD TIMES.
#   FHS is the best solution at the moment. Note, poetry is no good as
#   it is non-standard python!
{
  description = "Python flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };

        packages = let
          version = "311";
        in [
          pkgs.cachix
          pkgs.alejandra
          pkgs.nodejs

          pkgs."python${version}"
          pkgs."python${version}Packages".pip

          pkgs.cudaPackages.cudatoolkit
          pkgs.cudaPackages.cudnn
        ];
      in {
        formatter = pkgs.alejandra;
        devShell = pkgs.mkShell {
          inherit packages;
          name = "python hierarical environment";
          shellHook = ''
            export PYTHONPATH="''${PYTHONPATH}:${self}"
          '';
        };
      }
    );
}
