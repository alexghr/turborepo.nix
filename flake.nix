{
  description = "Patched turbo binary";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/release-22.11";

  outputs = { self, nixpkgs }:
    let
      binaries = {
        "x86_64-linux" = {
          pname = "turbo-linux-64";
          sha256 = "0bqhg6ffr51hh2wlknc3q4h4zfs2hng6l5aziji0cf9ccy6992cd";
        };
        "x86_64-darwin" = {
          pname = "turbo-darwin-64";
          sha256 = "0pmb3yj3041z3x5fzfay9sqw1qxkvpks1zn2y4nmbvn790dvbfsd";
        };
        "aarch64-linux" = {
          pname = "turbo-linux-arm64";
          sha256 = "1am12px882d9bkfd54wrdvzrhr23zvszcha64np8cs9aq32gfa1k";
        };
        "aarch64-darwin" = {
          pname = "turbo-darwin-arm64";
          sha256 = "1szv48jvvnjfld22m6sfspz56rmiclln4vpm9cp5gkd39cqyhrfn";
        };
      };
      version = "1.7.2";
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
