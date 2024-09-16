{
  description = "Nix Flake for SPRING R package";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    SpiecEasi.url = "github:artur-sannikov/SpiecEasi/nix-flakes";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      SpiecEasi,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        SpiecEasiPkg = SpiecEasi.packages.${system}.default;
        SPRING = pkgs.rPackages.buildRPackage {
          name = "SPRING";
          src = self;
          propagatedBuildInputs =
            builtins.attrValues {
              inherit (pkgs.rPackages)
                glmnet
                huge
                mixedCCA
                mvtnorm
                pulsar
                rootSolve
                VGAM
                ;
            }
            ++ [
              SpiecEasiPkg
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
