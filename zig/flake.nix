{
  description = "A zig flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
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
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          # c/c++ in
          libclang
          clang_multi
          clang-tools
          clang-manpages
          clang-analyzer

          zig
          zls
          zig-shell-completions
          (vscode-with-extensions.override {
            vscode = vscodium;
            vscodeExtensions = with vscode-extensions;
              [
                ziglang.vscode-zig
                christian-kohler.path-intellisense
                pkief.material-icon-theme
              ]
              ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
                {
                  name = "zig-tools";
                  publisher = "bwork";
                  version = "0.0.4";
                  sha256 = "sha256-N4JYcdb/l2WAJpwsuVj+BZvOIhEUUbDl0SKNZ+PbqKI=";
                }
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
