{
  description = "Nix Flake for SPRING R package";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
        rvenv = pkgs.rWrapper.override {
          packages = with pkgs.rPackages; [
            devtools
            languageserver
          ];
        };
      in
      {
        packages.default = SPRING;
        devShells.default = pkgs.mkShell {
          buildInputs = [ SPRING ];
          inputsFrom = pkgs.lib.singleton SPRING;
          packages = pkgs.lib.singleton rvenv;
        };
      }
    );
}
