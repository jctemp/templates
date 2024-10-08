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
    flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      formatter = pkgs.alejandra;
      devShells.default =
        pkgs.mkShell
        {
          packages = with pkgs; [
            firefox
            tinymist
            typst
            typstyle
            bashInteractive
          ];
          shellHook = let
            languages = {
              language-server.tinymist = {
                command = "${pkgs.tinymist}/bin/tinymist";
                config.typstExtraArgs = ["main.typ"];
              };
              language = [
                {
                  name = "typst";
                  formatter = {
                    command = "${pkgs.typstyle}/bin/typstyle";
                    # args = [ "--inplace" ];
                  };
                }
              ];
            };
            file = pkgs.writers.writeTOML "languages.toml" languages;
          in ''
            mkdir .helix
            ln -sf ${file} .helix/languages.toml
          '';
        };
    });
}
