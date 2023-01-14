{
  description = "Patched turbo binary";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/release-22.11";

  outputs = { self, nixpkgs }:
    let
      binaries = {
        "x86_64-linux" = {
          pname = "turbo-linux-64";
          sha256 = "1926a91gba32msnsb6plz7rpg28wfwin1b6p6x624c16hcman6qb";
        };
        "x86_64-darwin" = {
          pname = "turbo-darwin-64";
          sha256 = "08y3lg439yxaljwkqyjqk3wxlv0ab3v7jyq26sdqn0ahciqqf3d5";
        };
        "aarch64-linux" = {
          pname = "turbo-linux-arm64";
          sha256 = "1lw2s7jb72pvr7vqjm8g75hq6m97slrrzwdw5lln5k67ms6nj3b6";
        };
        "aarch64-darwin" = {
          pname = "turbo-darwin-arm64";
          sha256 = "018gh9ps2x1fkck9n78l3d8ax1j5glayddl5cs56r94nj6zj1dff";
        };
      };
      version = "1.7.0";
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
