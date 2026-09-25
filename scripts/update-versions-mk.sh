#!/usr/bin/env bash
# Copyright 2026 Ian Lewis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# update-versions-mk.sh updates the checksums in versions.mk by fetching
# them from the appropriate upstream sources. This is intended to be run
# as part of `make update-lockfiles`.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSIONS_MK="${SCRIPT_DIR}/../versions.mk"

# update_var updates a single variable in versions.mk.
update_var() {
    local var="$1"
    local value="$2"

    # Handle := assignment (binary checksums)
    if grep -q "^${var} :=" "${VERSIONS_MK}"; then
        sed -i "s|^${var} :=.*|${var} := ${value}|" "${VERSIONS_MK}"
    # Handle ?= assignment
    elif grep -q "^${var} ?=" "${VERSIONS_MK}"; then
        sed -i "s|^${var} ?=.*|${var} ?= ${value}|" "${VERSIONS_MK}"
    else
        echo "WARNING: Variable ${var} not found in ${VERSIONS_MK}" >&2
    fi
}

# Read current versions from versions.mk
COSIGN_VERSION=$(grep '^COSIGN_VERSION' "${VERSIONS_MK}" | sed 's/.*?= //')
GO_VERSION=$(grep '^GO_VERSION' "${VERSIONS_MK}" | sed 's/.*?= //')
SLSA_VERIFIER_VERSION=$(grep '^SLSA_VERIFIER_VERSION' "${VERSIONS_MK}" | sed 's/.*?= //')

echo "Updating checksums in ${VERSIONS_MK}..."

# Update COSIGN checksums.
# cosign releases include a cosign_checksums.txt file.
echo "Updating COSIGN checksums (${COSIGN_VERSION})..."
cosign_checksums_url="https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign_checksums.txt"
cosign_checksums=$(curl -sSfL "${cosign_checksums_url}")
for platform in "linux.amd64" "linux.arm64" "darwin.arm64"; do
    os="${platform%%.*}"
    arch="${platform#*.}"
    checksum=$(echo "${cosign_checksums}" | grep "cosign-${os}-${arch}$" | awk '{print $1}')
    if [ -z "${checksum}" ]; then
        echo "ERROR: Could not find COSIGN checksum for ${os}-${arch}" >&2
        exit 1
    fi
    update_var "COSIGN_CHECKSUM.${platform}" "${checksum}"
done

# Update GO checksums using the Go download API.
echo "Updating GO checksums (${GO_VERSION})..."
go_json=$(curl -sSfL "https://go.dev/dl/?mode=json&include=all")
for platform in "linux.amd64" "linux.arm64" "darwin.arm64"; do
    os="${platform%%.*}"
    arch="${platform#*.}"
    filename="go${GO_VERSION}.${os}-${arch}.tar.gz"
    checksum=$(echo "${go_json}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for release in data:
    if release['version'] == 'go${GO_VERSION}':
        for f in release['files']:
            if f['filename'] == '${filename}':
                print(f['sha256'])
                sys.exit(0)
sys.stderr.write('Could not find Go checksum for ${filename}\n')
sys.exit(1)
")
    update_var "GO_CHECKSUM.${platform}" "${checksum}"
done

# Update SLSA_VERIFIER checksums.
# slsa-verifier releases do not include a checksums file, so download the
# binaries and compute the checksums.
echo "Updating SLSA_VERIFIER checksums (${SLSA_VERIFIER_VERSION})..."
tmpdir=$(mktemp -d)
trap 'rm -rf "${tmpdir}"' EXIT
for platform in "linux.amd64" "linux.arm64" "darwin.arm64"; do
    os="${platform%%.*}"
    arch="${platform#*.}"
    filename="slsa-verifier-${os}-${arch}"
    url="https://github.com/slsa-framework/slsa-verifier/releases/download/${SLSA_VERIFIER_VERSION}/${filename}"
    tmpfile="${tmpdir}/${filename}"
    curl -sSfL -o "${tmpfile}" "${url}"
    checksum=$(sha256sum "${tmpfile}" | awk '{print $1}')
    update_var "SLSA_VERIFIER_CHECKSUM.${platform}" "${checksum}"
done

echo "Done."
