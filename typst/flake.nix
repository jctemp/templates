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
            alejandra
            firefox
            tinymist
            typst
            typst-live
            typstyle
            (vscode-with-extensions.override {
              vscode = vscodium;
              vscodeExtensions = with vscode-extensions; [
                myriad-dreamin.tinymist
                christian-kohler.path-intellisense
                pkief.material-icon-theme
              ];
            })
            bashInteractive
          ];
          shellHook = let
            settings = {
              "editor.rulers" = [80 120];
              "workbench.colorCustomizations" = {
                "editorRuler.foreground" = "#ff4081";
              };
              "editor.formatOnSave" = true;
              "tinymist.formatterMode" = "typstyle";
              "workbench.iconTheme" = "material-icon-theme";
              "terminal.integrated.defaultProfile.linux" = "bash";
              "terminal.integrated.profiles.linux" = {
                "bash" = {
                  "path" = "${pkgs.bashInteractive}/bin/bash";
                  "icon" = "terminal-bash";
                };
              };
            };
            settingsJson = builtins.toJSON settings;
          in ''
            mkdir -p .vscode
            echo '${settingsJson}'
            echo '${settingsJson}' > .vscode/settings.json
          '';
        };
    });
}
