{
  description = "Minimal Python environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = inputs: let
    systems = ["x86_64-linux"];
    eachSystem = systems: func: inputs.nixpkgs.lib.genAttrs systems (system: func system);
    eachDefaultSystem = eachSystem systems;
  in {
    formatter = eachDefaultSystem (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);
    devShells = eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      default = let
        py-version = "312";
        python = pkgs."python${py-version}";
      in (pkgs.mkShell {
        name = "python${py-version}";
        packages = [
          python
          python.pkgs.pip
          python.pkgs.bokeh
          python.pkgs.ipykernel
          python.pkgs.matplotlib
          python.pkgs.notebook
          python.pkgs.numpy
          python.pkgs.polars
          python.pkgs.pyarrow
          python.pkgs.scipy
          python.pkgs.seaborn
          python.pkgs.uv
        ];
        shellHook = ''
          export PYTHONPATH=$PYTHONPATH:$PWD

          # Display environment info
          echo "Environment"
          echo "  Python: $(python --version)"
          echo "  UV: $(uv --version)"
        '';
      });
    });
  };
}
