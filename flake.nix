{
  description = "Patched turbo binary";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/release-22.11";

  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, utils }:
    let
      npmPackages = import ./npm-packages.gen.nix;
      supportedSystems = builtins.attrNames npmPackages;
    in
      {
        overlays.turborepo = final: prev: {
          turborepo = self.packages.${prev.system}.turborepo;
        };
        overlays.default = self.overlays.turborepo;
      }
      // utils.lib.eachSystem supportedSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (npmPackages.${system}) pname version src;
          inherit (pkgs.lib) optionals;
        in rec {
          packages.turborepo = pkgs.stdenv.mkDerivation {
            inherit pname;
            inherit version;
            src = pkgs.fetchurl src;

            nativeBuildInputs = [] ++ optionals pkgs.stdenv.isLinux [
              pkgs.autoPatchelfHook
            ];

            sourceRoot = ".";

            installPhase = ''
              install -m755 -D ${pname}/bin/turbo $out/bin/turbo
              install -m755 -D ${pname}/bin/go-turbo $out/bin/go-turbo
            '';

            meta = {
              homepage = "https://turbo.build/";
              description = "Binary version of turbo, patched for NixOS";
              mainProgram = "turbo";
            };
          };

          packages.default = packages.turborepo;
        }
      );
}
