{
  description = "Typst flake";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = inputs: let
    systems = ["x86_64-linux"];
    eachSystem = systems: func: inputs.nixpkgs.lib.genAttrs systems (system: func system);
    eachDefaultSystem = eachSystem systems;
  in {
    formatter = eachDefaultSystem (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);
    devShells = eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
    in {
      default =
        pkgs.mkShell
        {
          name = "typst";
          packages = with pkgs; [
            firefox
            tinymist
            typst
            typstyle
            bashInteractive
          ];
          shellHook = ''
            echo ""
            tinymist -V
            typst -V
            typstyle -V
            echo ""
          '';
        };
    });
  };
}
