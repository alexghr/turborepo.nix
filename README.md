# turborepo.nix

[Turborepo](https://turbo.build/) is a build system for Node.js monorepos similar to Lerna and Yarn workspaces. It's written in Go and since v1.5.6 it [no longer runs out of the box on NixOS systems](https://github.com/vercel/turbo/issues/2556).

This repo provides a flake of a patched version of the `turbo` variant. The binary is the same one that `npm install` gets just with `autoPatchelfHook` applied to it. For other targets (MacOS, non-NixOS-linux) the binary remains untouched so you can use it in your project even if you swap between different systems for development.

## Example

I use this in dev shells for my project like this:

```
# flake.nix
{
  description = "Example";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
  
  inputs.turbo.url = "github:alexghr/turborepo.nix/v1.8.3";
  inputs.turbo.inputs.nixpkgs.follows = "nixpkgs";
  
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, turbo, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.bashInteractive ];
          buildInputs = [
            turbo.packages.${system}.default
          ];
          shellHook = with pkgs; ''
            export TURBO_BINARY_PATH="${turbo.packages.${system}.default}/bin/turbo"
          '';
        };
      }
    );
}
```

## Update turbo version

This repo aims to track the turbo releases closely. To update the turbo version used run:

```
$ bash ./generate-npm-packages.bash > npm-packages.gen.nix 
```

This script will download the binary for each supported system and compute the sha256 hashes necessary and output an appropriate nix file for the flake.
