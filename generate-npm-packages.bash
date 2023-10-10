#!/usr/bin/env bash

set -eu -o pipefail

# Inspired by https://discourse.nixos.org/t/update-many-shas/5031/5
#
# Use this script to generate an appropriate npm-packages.gen.nix for
# the latest Turborepo version. It prefetches the archives for each of
# the systems and computes each archive's sha256.
#
# Requires: jq
# Run as:
# ./generate-npm-packages.bash > npm-packages.gen.nix
#

declare -A "hashes"
declare -A "urls"
declare -A "versions"

declare -A packages=(
  ["x86_64-linux"]="turbo-linux-64"
  ["x86_64-darwin"]="turbo-darwin-64"
  ["aarch64-linux"]="turbo-linux-arm64"
  ["aarch64-darwin"]="turbo-darwin-arm64"
)

for system in "${!packages[@]}"; do
  versions[$system]=$(curl -s "https://registry.npmjs.org/${packages[$system]}" | jq -r '."dist-tags".latest')
  urls[$system]="https://registry.npmjs.org/${packages[$system]}/-/${packages[$system]}-${versions[$system]}.tgz"
  hashes[$system]=$(nix-prefetch-url "${urls[$system]}" 2> /dev/null)
done

# TODO should we check that all versions are the same?

printf '# DO NOT MODIFY\n'
printf '# This is a generated file. See %s for details\n' "${0}"
printf '{\n'
for system in "${!packages[@]}"; do
  pname="${packages[$system]}"
  version="${versions[$system]}"
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
