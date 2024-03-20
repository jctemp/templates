{
  description = "Python ML Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
          overlays = [
            (final: prev: {
              pythonPackagesExtensions = [
                (final: prev: {
                  torch = final.torch-bin;
                  torchvision = final.torchvision-bin;
                })
              ];
            })
          ];
        };
      in {
        formatter = pkgs.alejandra;
        devShell = pkgs.mkShell {
          name = "machine-learning";
          packages =
            (with pkgs; [
              alejandra
              python311
              nodejs
            ])
            ++ (
              if pkgs.config.cudaSupport
              then
                (with pkgs.cudaPackages; [
                  cudatoolkit
                  cudnn
                ])
              else []
            )
            ++ (with pkgs.python311Packages; [
              # Generic
              jupyter
              ipykernel
              black
              pip

              # DataScience
              numpy
              pandas
              polars
              matplotlib
              seaborn
              scikit-learn

              # PyTorch
              torch
              torchvision
              torchinfo
              pytorch-lightning
            ]);
        };
      }
    );
}
