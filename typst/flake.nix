{
  description = "Typst flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          (pkgs.writeShellScriptBin "microsoft-edge-w" "${pkgs.microsoft-edge}/bin/microsoft-edge --ozone-platform-hint=auto")
          microsoft-edge
          alejandra
          typst
          typst-live
          typst-lsp
        ];
      };
    });
}
