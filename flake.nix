{
  description = "Patched turbo binary";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.11";

  outputs = { self, nixpkgs }:
    let
      pname = "turbo-linux-64";
      version = "1.6.3";
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system} = {
        ${pname} = pkgs.stdenv.mkDerivation {
          inherit pname;
          version = "v${version}";
          src = pkgs.fetchurl {
            url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
            sha256 = "sha256-WNJz52h8hu+q+p8QxxVaym/YnUG9NtAFD7lyXdEc2WM=";
          };

          nativeBuildInputs = [
            pkgs.autoPatchelfHook
          ];

          sourceRoot = ".";

          installPhase = ''
            install -m755 -D ${pname}/bin/turbo $out/bin/turbo
          '';

          meta = {
            homepage = "https://turbo.build/";
            description = "Binary version of turbo, patched for NixOS";
          };
        };

        default = self.packages.${system}.${pname};
      };
    };
}
