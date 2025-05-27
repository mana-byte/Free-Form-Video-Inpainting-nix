{
  description = "Nix flake for free_form_video_inpainting env";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Optional: poetry2nix if you want tighter pip integration
    # poetry2nix.url = "github:nix-community/poetry2nix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.cudaSupport = true;
        };

        pythonEnv = pkgs.python312.withPackages (ps:
          with ps; [
            pip
            setuptools
            wheel
            numpy
            scipy
            pillow
            imageio
            matplotlib
            scikit-image
            dask
            networkx
            pyqt5
            cffi
            six
            certifi
            cloudpickle
            coloredlogs
            humanfriendly
            decorator
            python-dateutil
            pytz
            pywavelets
            kiwisolver
            pyparsing
            flake8
            mccabe
            pycodestyle
            pyflakes
            protobuf
            torch
            torchvision
            tensorboardx
            opencv4
          ]);
      in {
        devShell = pkgs.mkShell {
          name = "free_form_video_inpainting";

          buildInputs = with pkgs; [
            python312Packages.python-lsp-server
            black

            pythonEnv
            dlib
            libGL
            libGLU
            libpng
            ffmpeg
            qt5.qtbase
            xorg.libX11
            xorg.libXrender
            xorg.libSM
            xorg.libICE
            xorg.libxcb
            gettext
            cairo
            freetype
            dbus
            gst_all_1.gst-plugins-base
            gst_all_1.gstreamer

            # cuda dependencies
            cudaPackages.cudatoolkit
            cudaPackages.cudnn
          ];

          shellHook = ''
            export CUDA_PATH=${pkgs.cudatoolkit}
            export LD_LIBRARY_PATH=${pkgs.cudatoolkit}/lib:$LD_LIBRARY_PATH
            export EXTRA_CCFLAGS="-I/usr/include"
              echo "🔧 Activating free_form_video_inpainting environment..."
          '';
        };
      }
    );
}
