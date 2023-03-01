#!/usr/bin/env bash

set -eu -o pipefail

# Inspired by https://discourse.nixos.org/t/update-many-shas/5031/5
#
# Use this script to generate an appropriate npm-packages.gen.nix for a
# specific Turborepo version. It prefetches the archives for each of
# the systems and computes its sha256.
#
# Update the version variable below and run
# ./generate-npm-packages.bash > npm-packages.gen.nix
#

declare version="1.8.3"
declare -A "hashes"
declare -A "urls"
declare -A packages=(
  ["x86_64-linux"]="turbo-linux-64"
  ["x86_64-darwin"]="turbo-darwin-64"
  ["aarch64-linux"]="turbo-linux-arm64"
  ["aarch64-darwin"]="turbo-darwin-arm64"
)

for system in "${!packages[@]}"; do
  urls[$system]="https://registry.npmjs.org/${packages[$system]}/-/${packages[$system]}-${version}.tgz"
  hashes[$system]=$(nix-prefetch-url "${urls[$system]}" 2> /dev/null)
done

printf '# DO NOT MODIFY\n'
printf '# This is a generated file. See %s for details\n' "${0}"
printf '{\n'
for system in "${!packages[@]}"; do
  pname="${packages[$system]}"
  hash="${hashes[$system]}"
  url="${urls[$system]}"

  cat <<-EOF
  "$system" = {
    pname = "${pname}";
    version = "v${version}";
    src = {
      sha256 = "${hash}";
      url = "${url}";
    };
  };
EOF
done

printf '}'
