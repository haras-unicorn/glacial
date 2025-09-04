{
  self,
  pyproject-nix,
  root,
  pyproject-build-systems,
  uv2nix,
  lib,
  ...
}:

let
  mkUvLib = pkgs: rec {
    python = pkgs.python311;
    uv = pkgs.uv;

    cudaPackages = pkgs.cudaPackages;

    cudaDeps = with cudaPackages; [
      cudnn_8_9
      cuda_nvrtc
      nccl
      cuda_cudart
      cudatoolkit
    ];

    cudaEnvWrapProgramArgs = ''
      --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath cudaDeps}"
    '';

    cudaEnvShellHook = ''
      LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath cudaDeps}"
      export LD_LIBRARY_PATH
    '';

    playwrightDeps = builtins.attrValues (self.lib.playwright.packages pkgs.system);

    playwrightEnvWrapProgramArgs = builtins.concatStringsSep " " (
      builtins.map ({ name, value }: "--set ${name} ${value}") (
        lib.attrsToList (self.lib.playwright.env pkgs.system)
      )
    );

    playwrightEnvShellHook = builtins.concatStringsSep "\n\n" (
      builtins.map ({ name, value }: "${name}=${value}\nexport ${name}") (
        lib.attrsToList (self.lib.playwright.env pkgs.system)
      )
    );

    packages = [
      "glacial-synthesis"
      "glacial-orchestration"
    ];

    workspace = uv2nix.lib.workspace.loadWorkspace {
      workspaceRoot = root;
    };

    pyprojectOverlay = workspace.mkPyprojectOverlay {
      sourcePreference = "wheel";
    };

    pyprojectOverrides = final: prev: {
      antlr4-python3-runtime = prev.antlr4-python3-runtime.overrideAttrs (old: {
        buildInputs =
          (old.buildInputs or [ ])
          ++ (with prev; [
            setuptools
          ]);
      });

      audiocraft = prev.audiocraft.overrideAttrs (old: {
        buildInputs =
          (old.buildInputs or [ ])
          ++ (with prev; [
            setuptools
          ]);
      });

      demucs = prev.demucs.overrideAttrs (old: {
        buildInputs =
          (old.buildInputs or [ ])
          ++ (with prev; [
            setuptools
          ]);
      });

      docopt = prev.docopt.overrideAttrs (old: {
        buildInputs =
          (old.buildInputs or [ ])
          ++ (with prev; [
            setuptools
          ]);
      });

      dora-search = prev.dora-search.overrideAttrs (old: {
        buildInputs =
          (old.buildInputs or [ ])
          ++ (with prev; [
            setuptools
          ]);
      });

      encodec = prev.encodec.overrideAttrs (old: {
        buildInputs =
          (old.buildInputs or [ ])
          ++ (with prev; [
            setuptools
          ]);
      });

      flashy = prev.flashy.overrideAttrs (old: {
        buildInputs =
          (old.buildInputs or [ ])
          ++ (with prev; [
            setuptools
          ]);
      });

      julius = prev.julius.overrideAttrs (old: {
        buildInputs =
          (old.buildInputs or [ ])
          ++ (with prev; [
            setuptools
          ]);
      });

      numba = prev.numba.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [
          pkgs.tbb_2022_0
        ];
      });

      soundfile = prev.soundfile.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          substituteInPlace "$out/${final.python.sitePackages}/soundfile.py" \
            --replace "_find_library('sndfile')" "'${pkgs.libsndfile.out}/lib/libsndfile.so'"
        '';
      });

      # TODO: fix this up so wrapping with env is not needed
      torch = prev.torch.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ cudaDeps;
        postFixup = (old.postFixup or "") + ''
          mkdir -p $out/lib
          for f in "$out/lib/python3.11/site-packages/torch/lib"/*.so; do
            ln -sf "$f" $out/lib/$(basename "$f")
          done
        '';
      });

      torchaudio = prev.torchaudio.overrideAttrs (old: {
        autoPatchelfIgnoreMissingDeps = [
          "libavutil.so.56"
          "libavcodec.so.58"
          "libavformat.so.58"
          "libavdevice.so.58"
          "libavfilter.so.7"
          "libavutil.so.57"
          "libavcodec.so.59"
          "libavformat.so.59"
          "libavdevice.so.59"
          "libavfilter.so.8"
        ];
        buildInputs =
          (old.buildInputs or [ ])
          ++ [
            pkgs.ffmpeg_6
            pkgs.sox
            final.torch
          ]
          ++ cudaDeps;
      });

      torchtext = prev.torchtext.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [
          final.torch
        ];
      });

      torchvision = prev.torchvision.overrideAttrs (old: {
        buildInputs =
          (old.buildInputs or [ ])
          ++ [
            final.torch
          ]
          ++ cudaDeps;
      });

      xformers = prev.xformers.overrideAttrs (old: {
        buildInputs =
          (old.buildInputs or [ ])
          ++ [
            final.torch
          ]
          ++ cudaDeps;
      });

      # TODO: fix this up so wrapping with env is not needed
      playwright = prev.playwright.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ playwrightDeps;
      });
    };

    packageOverrides = final: prev: {
      glacial-synthesis = prev.glacial-synthesis.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
        postInstall = (old.postInstall or "") + ''
          wrapProgram $out/bin/glacial-synthesis \
            ${cudaEnvWrapProgramArgs}
        '';
      });
      glacial-orchestration = prev.glacial-orchestration.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
        postInstall = (old.postInstall or "") + ''
          wrapProgram $out/bin/glacial-orchestration \
            ${playwrightEnvWrapProgramArgs} \
            ${cudaEnvWrapProgramArgs}
        '';
      });
    };

    editableOverrides =
      final: prev:
      builtins.listToAttrs (
        builtins.map (package: {
          name = package;
          value = prev.${package}.overrideAttrs (old: {
            src = lib.cleanSource old.src;

            # NOTE: hatchling requirement
            nativeBuildInputs =
              old.nativeBuildInputs
              ++ final.resolveBuildSystem {
                editables = [ ];
              };
          });
        }) packages
      );

    editableEnvShellHook = ''
      REPO_ROOT=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
      export REPO_ROOT
    '';

    editableOverlay = workspace.mkEditablePyprojectOverlay {
      root = "$REPO_ROOT";
      members = packages;
    };

    basePythonSet =
      (pkgs.callPackage pyproject-nix.build.packages {
        inherit python;
      }).overrideScope
        (
          lib.composeManyExtensions [
            pyproject-build-systems.overlays.default
            pyprojectOverlay
            pyprojectOverrides
          ]
        );

    pythonSet = basePythonSet.overrideScope (
      lib.composeManyExtensions [
        packageOverrides
      ]
    );

    editablePythonSet = basePythonSet.overrideScope (
      lib.composeManyExtensions [
        editableOverlay
        editableOverrides
      ]
    );

    buildUtil = pkgs.callPackages pyproject-nix.build.util { };

    buildInputs = builtins.attrValues (self.lib.playwright.packages pkgs.system);

    mkShellHook = venv: ''
      export UV_NO_SYNC="1"
      export UV_PYTHON="${venv}/bin/python"
      export UV_PYTHON_DOWNLOADS="never"

      unset PYTHONPATH

      ${editableEnvShellHook}
      ${cudaEnvShellHook}
      ${playwrightEnvShellHook}
    '';

    uvDirenv = pkgs.writeShellApplication {
      name = "uv-direnv";
      runtimeInputs = [
        pkgs.uv
        pkgs.direnv
      ];
      text = ''
        uv "$@"
        direnv reload .
      '';
    };
  };
in
{
  flake.lib.python.mkPackage =
    pkgs: package:
    let
      uv = mkUvLib pkgs;
      venv = uv.pythonSet.mkVirtualEnv "glacial-env" uv.workspace.deps.default;
    in
    uv.buildUtil.mkApplication {
      venv = venv;
      package = uv.pythonSet.${package};
    };

  flake.lib.python.mkDevShell =
    pkgs:
    let
      uvLib = mkUvLib pkgs;
      venv = uvLib.editablePythonSet.mkVirtualEnv "glacial-dev-env" uvLib.workspace.deps.all;
      shellHook = uvLib.mkShellHook venv;
      buildInputs = uvLib.buildInputs;
    in
    pkgs.mkShell {
      inherit shellHook buildInputs;

      packages = [
        venv
        uvLib.uvDirenv
        uvLib.uv
      ];
    };
}
