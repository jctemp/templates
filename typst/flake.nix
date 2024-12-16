{
  description = "Typst flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
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
