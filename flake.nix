{
  description = "Patched turbo binary";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/release-22.11";

  outputs = { self, nixpkgs }:
    let
      binaries = {
        "x86_64-linux" = {
          pname = "turbo-linux-64";
          sha256 = "0zi1348rcpmsf3z7w9hwpsfqx5xkyq5mhji9grmms8lqlzn6iyd9";
        };
        "x86_64-darwin" = {
          pname = "turbo-darwin-64";
          sha256 = "1qnqy7j6gg7lxz5wk8lz5px5ffqk1p2bgnf6hszv5npz8ifjvrb8";
        };
        "aarch64-linux" = {
          pname = "turbo-linux-arm64";
          sha256 = "103gbyl3bd47kl5shsax4bj232vbf65a80v80iiiqasvgixc9sgg";
        };
        "aarch64-darwin" = {
          pname = "turbo-darwin-arm64";
          sha256 = "1qsbp8qh5l4x24knbwmr47cssfz584wx2q0vvq6yapzrqcyv5g0a";
        };
      };
      version = "1.8.2";
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
