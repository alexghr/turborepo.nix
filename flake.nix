{
  description = "Patched turbo binary";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/release-22.11";

  outputs = { self, nixpkgs }:
    let
      binaries = {
        "x86_64-linux" = {
          pname = "turbo-linux-64";
          sha256 = "sha256-Derd/KyLzu8lUaUTLeJp4q2D6fNg6PnaD5r7uzdiHW8=";
        };
        "x86_64-darwin" = {
          pname = "turbo-darwin-64";
          sha256 = "sha256-srHYWvoi23xhLvd3yWj/GX2scQn67bfPmJJxU0FB/KQ=";
        };
        "aarch64-linux" = {
          pname = "turbo-linux-arm64";
          sha256 = "sha256-AfB77AedF3gipXt6Obu5jdgW6ZCOMJ1E3fdochmSUQ8=";
        };
        "aarch64-darwin" = {
          pname = "turbo-darwin-arm64";
          sha256 = "sha256-JrgmRHsFnatrReUTcL+sgMHHGSyfzQZv7D50SwPKamM=";
        };
      };
      version = "1.8.1";
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    rec {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          pname = binaries.${system}.pname;
          sha256 = binaries.${system}.sha256;
          inherit (pkgs.lib) optionals;
        in {
            default = pkgs.stdenv.mkDerivation {
              version = "v${version}";
              inherit pname;
              src = pkgs.fetchurl {
                url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
                inherit sha256;
              };

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
              };
            };
          });
    };
}
