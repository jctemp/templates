{
  description = "Minimal Python environment with CUDA in FHS";

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
        cu-version = "12_4";

        python = pkgs."python${py-version}";
        cuda = pkgs."cudaPackages_${cu-version}".cudatoolkit;
        cudnn = pkgs."cudaPackages_${cu-version}".cudnn;
      in
        (pkgs.buildFHSEnv {
          name = "python${py-version}-cuda${cu-version}";
          targetPkgs = pkgs: (with pkgs; [
            # Basic tools
            bashInteractive

            # Build tools
            gcc
            binutils
            gnumake
            cmake
            ninja

            # Core libraries
            glib
            libGL
            stdenv.cc.cc.lib

            # Python and basic packages
            python
            python.pkgs.uv
            python.pkgs.pip

            # CUDA packages
            cuda
            cudnn
          ]);

          profile = ''
            # Set up compiler environment variables
            export CC=${pkgs.gcc}/bin/gcc
            export CXX=${pkgs.gcc}/bin/g++
            export CUDA_HOME=${cuda}
            export CUDNN_HOME=${cudnn}
            export CUDACXX=${cuda.cc}/bin/nvcc

            export LD_LIBRARY_PATH=/lib:/lib64:/usr/lib:/usr/lib64
            export LD_LIBRARY_PATH=${cuda}/lib:${cudnn}/lib:$LD_LIBRARY_PATH

            export PATH=$PATH:${cuda}/bin
            export PYTHONPATH=$PYTHONPATH:$PWD

            # Display environment info
            echo "FHS Environment"
            echo "  Python: $(python --version)"
            echo "  GCC: $(gcc --version | head -n 1)"
            echo "  NVCC: $(nvcc --version | head -n 1)"
            echo "  UV: $(uv --version)"
            echo "  CUDA toolkit: $CUDA_HOME"
          '';

          runScript = "bash";
        })
        .env;
    });
  };
}
