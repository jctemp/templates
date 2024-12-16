{
  description = "Simple flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
    in {
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShellNoCC {
        name = "default shell";
        packages = with pkgs; [
          alejandra
        ];
      };
    });
}
