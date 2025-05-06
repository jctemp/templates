{
  description = "A zig flake";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = inputs: let
    systems = ["x86_64-linux"];
    eachSystem = systems: func: inputs.nixpkgs.lib.genAttrs systems (system: func system);
    eachDefaultSystem = eachSystem systems;
  in {
    formatter = eachDefaultSystem (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);
    devShells = eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
    in {
      default = pkgs.mkShell {
        name = "zig";
        packages = with pkgs; [
          cmake
          ninja
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
  };
}
