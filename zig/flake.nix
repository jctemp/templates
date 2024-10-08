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
          bashInteractive
        ];
        shellHook = let
          languages.language-server.zls.command = "${pkgs.zls}/bin/zls";
          file = pkgs.writers.writeTOML "languages.toml" languages;
        in ''
          mkdir .helix
          export PATH=$PATH:${pkgs.lldb}/lib:${pkgs.lldb}/bin
          ln -sf ${file} .helix/languages.toml
        '';
      };
    });
}
