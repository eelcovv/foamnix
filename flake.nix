{
  description = "Nix devshells for multiple OpenFOAM variants";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

  outputs = { self, nixpkgs }:
  let
    systems = [ "x86_64-linux" ];
    forAll = f: builtins.listToAttrs (map (s: { name = s; value = f s; }) systems);
  in {
    devShells = forAll (system:
      let
        pkgs = import nixpkgs { inherit system; };
        baseDeps = with pkgs; [
          gcc cmake gnumake flex bison
          openmpi scotch metis
          cgal gmp mpfr boost zlib
          python3 git gnuplot
        ];
        mkHook = name: cmd: ''
          ulimit -s unlimited || true
          echo "Build ${name}:"
          echo "  ${cmd}"
        '';
      in {
        # OpenFOAM Foundation v13
        openfoam-foundation-13 = pkgs.mkDevShell {
          packages = baseDeps;
          env = { FOAM_USE_MPI = "1"; WM_MPLIB = "OPENMPI"; };
          shellHook = mkHook "OpenFOAM-13" ''
            git clone https://github.com/OpenFOAM/OpenFOAM-13.git
            git clone https://github.com/OpenFOAM/ThirdParty-13.git
            source ./OpenFOAM-13/etc/bashrc
            ./OpenFOAM-13/Allwmake -j$(nproc)
          '';
        };

        # ESI-OpenCFD (voorbeeld: v2406)
        openfoam-esi-2406 = pkgs.mkDevShell {
          packages = baseDeps;
          env = { FOAM_USE_MPI = "1"; WM_MPLIB = "OPENMPI"; };
          shellHook = mkHook "OpenFOAM-ESI v2406" ''
            # clone & build stappen voor ESI-OpenFOAM hier
          '';
        };

        # NavalFOAM (voorbeeld)
        navalfoam-0_9 = pkgs.mkDevShell {
          packages = baseDeps;
          env = { FOAM_USE_MPI = "1"; WM_MPLIB = "OPENMPI"; };
          shellHook = mkHook "NavalFOAM 0.9" ''
            # clone & build stappen voor NavalFOAM hier
          '';
        };

        default = self.devShells.${system}.openfoam-foundation-13;
      });
  };
}

