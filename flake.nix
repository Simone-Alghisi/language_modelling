{
  inputs = {
    mach-nix = {
      url = "mach-nix/3.4.0";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {self, nixpkgs, flake-utils, mach-nix }@inp:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      torch-nlp = mach-nix.lib."${system}".buildPythonPackage {
        pname = "torchnlp";
        version = "0.5.0";
        src = pkgs.fetchFromGitHub {
          owner = "PetrochukM";
          repo = "PyTorch-NLP";
          rev = "d7814a297811c9b0dfb285fe0475098b86f3d348";
          hash = "sha256-ZE49XJTg1yaqlFpZSgpnoAWMyP+cdpGxu/s/pvQIO+0=";
        };
      };
      python-build = mach-nix.lib."${system}".mkPython {
        python = "python39";
        requirements = builtins.readFile ./requirements.txt;
      };
    in
    {
      # enter this python environment by executing `nix shell .`
      devShell = pkgs.mkShell {
        buildInputs = [
          python-build
          pkgs.python39Packages.pytorch-bin
          pkgs.python39Packages.matplotlib
          pkgs.python39Packages.jupyterlab
          pkgs.glibc
          torch-nlp
        ];
      };
    });
}
