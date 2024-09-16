{
  description = "Nix Flake for SPRING R package";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    SpiecEasi.url = "github:artur-sannikov/SpiecEasi/nix-flakes";
    mixedCCA.url = "github:artur-sannikov/mixedCCA/nix-flakes";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      SpiecEasi,
      mixedCCA,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        SpiecEasiPkg = SpiecEasi.packages.${system}.default;
        mixedCCAPkg = mixedCCA.packages.${system}.default;
        SPRING = pkgs.rPackages.buildRPackage {
          name = "SPRING";
          src = self;
          propagatedBuildInputs =
            builtins.attrValues {
              inherit (pkgs.rPackages)
                mixedCCA
                huge
                pulsar
                rootSolve
                mvtnorm
                VGAM
                glmnet
                ;
            }
            ++ [
              SpiecEasiPkg
              mixedCCAPkg
            ];
        };
      in
      {
        packages.default = SPRING;
        devShells.default = pkgs.mkShell {
          buildInputs = [ SPRING ];
          inputsFrom = pkgs.lib.singleton SPRING;
        };
      }
    );
}
