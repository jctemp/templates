{
  description = "A zig flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
    in {
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShell {
        name = "zig shell";
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
        shellHook = ''
          export PATH=$PATH:${pkgs.lldb}/lib:${pkgs.lldb}/bin
        '';
      };
    });
}
