#!/usr/bin/env python3
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

"""Update sha256 checksums in versions.mk.

Reads the current versions from versions.mk and fetches updated sha256
checksums from the upstream release checksum files, then updates versions.mk
in place.

Usage:
    python3 scripts/update-checksums.py [versions.mk path]
"""

import hashlib
import json
import os
import re
import sys
import urllib.request


def get_version(content: str, var_name: str) -> str | None:
    """Extract version value from versions.mk content."""
    match = re.search(rf"^{var_name}\s*\?=\s*(\S+)", content, re.MULTILINE)
    if match:
        return match.group(1)
    return None


def update_checksum(content: str, var_name: str, value: str) -> str:
    """Update a checksum value in versions.mk content."""
    return re.sub(
        rf"^({re.escape(var_name)}\s*:=\s*).*$",
        rf"\g<1>{value}",
        content,
        flags=re.MULTILINE,
    )


def fetch_text(url: str) -> str:
    """Fetch text content from URL."""
    req = urllib.request.Request(url, headers={"User-Agent": "update-checksums.py"})
    with urllib.request.urlopen(req) as response:
        return response.read().decode("utf-8")


def parse_checksums_txt(content: str, filename: str) -> str | None:
    """Parse a checksums.txt file and return the sha256 for the given filename."""
    for line in content.splitlines():
        parts = line.split()
        if len(parts) == 2 and parts[1] == filename:
            return parts[0]
    return None


def compute_sha256_from_url(url: str) -> str:
    """Download content from URL and compute sha256."""
    sha256 = hashlib.sha256()
    req = urllib.request.Request(url, headers={"User-Agent": "update-checksums.py"})
    with urllib.request.urlopen(req) as response:
        while chunk := response.read(65536):
            sha256.update(chunk)
    return sha256.hexdigest()


def update_aqua_checksums(content: str) -> str:
    """Update AQUA checksums from GitHub release checksums file."""
    version = get_version(content, "AQUA_VERSION")
    if not version:
        return content

    version_no_v = version.lstrip("v")
    url = f"https://github.com/aquaproj/aqua/releases/download/{version}/aqua_{version_no_v}_checksums.txt"
    print(f"Fetching aqua checksums for {version}...")
    checksums_txt = fetch_text(url)

    platforms = [
        ("linux.amd64", "aqua_linux_amd64.tar.gz"),
        ("linux.arm64", "aqua_linux_arm64.tar.gz"),
        ("darwin.arm64", "aqua_darwin_arm64.tar.gz"),
    ]
    for platform, filename in platforms:
        sha256 = parse_checksums_txt(checksums_txt, filename)
        if sha256:
            content = update_checksum(content, f"AQUA_CHECKSUM.{platform}", sha256)
        else:
            print(f"WARNING: checksum not found for {filename}", file=sys.stderr)

    return content


def update_cosign_checksums(content: str) -> str:
    """Update COSIGN checksums from GitHub release checksums file."""
    version = get_version(content, "COSIGN_VERSION")
    if not version:
        return content

    url = f"https://github.com/sigstore/cosign/releases/download/{version}/cosign_checksums.txt"
    print(f"Fetching cosign checksums for {version}...")
    checksums_txt = fetch_text(url)

    platforms = [
        ("linux.amd64", "cosign-linux-amd64"),
        ("linux.arm64", "cosign-linux-arm64"),
        ("darwin.arm64", "cosign-darwin-arm64"),
    ]
    for platform, filename in platforms:
        sha256 = parse_checksums_txt(checksums_txt, filename)
        if sha256:
            content = update_checksum(content, f"COSIGN_CHECKSUM.{platform}", sha256)
        else:
            print(f"WARNING: checksum not found for {filename}", file=sys.stderr)

    return content


def update_slsa_verifier_checksums(content: str) -> str:
    """Update SLSA_VERIFIER checksums by downloading each binary and computing sha256."""
    version = get_version(content, "SLSA_VERIFIER_VERSION")
    if not version:
        return content

    platforms = [
        ("linux.amd64", "slsa-verifier-linux-amd64"),
        ("linux.arm64", "slsa-verifier-linux-arm64"),
        ("darwin.arm64", "slsa-verifier-darwin-arm64"),
    ]
    for platform, filename in platforms:
        url = f"https://github.com/slsa-framework/slsa-verifier/releases/download/{version}/{filename}"
        print(f"Downloading {filename} to compute sha256...")
        sha256 = compute_sha256_from_url(url).upper()
        content = update_checksum(
            content, f"SLSA_VERIFIER_CHECKSUM.{platform}", sha256
        )

    return content


def update_go_checksums(content: str) -> str:
    """Update GO checksums from the Go download JSON API."""
    version = get_version(content, "GO_VERSION")
    if not version:
        return content

    go_version_full = f"go{version}"
    print(f"Fetching Go checksums for {go_version_full}...")
    go_json_url = "https://go.dev/dl/?mode=json&include=all"
    go_data = json.loads(fetch_text(go_json_url))

    version_data = next(
        (r for r in go_data if r["version"] == go_version_full), None
    )
    if not version_data:
        print(
            f"WARNING: Go version {go_version_full} not found in download API",
            file=sys.stderr,
        )
        return content

    platforms = [
        ("linux.amd64", f"{go_version_full}.linux-amd64.tar.gz"),
        ("linux.arm64", f"{go_version_full}.linux-arm64.tar.gz"),
        ("darwin.arm64", f"{go_version_full}.darwin-arm64.tar.gz"),
    ]
    for platform, filename in platforms:
        file_data = next(
            (f for f in version_data["files"] if f["filename"] == filename), None
        )
        if file_data and file_data.get("sha256"):
            content = update_checksum(
                content, f"GO_CHECKSUM.{platform}", file_data["sha256"]
            )
        else:
            print(f"WARNING: checksum not found for {filename}", file=sys.stderr)

    return content


def main() -> int:
    """Main entry point."""
    if len(sys.argv) > 1:
        versions_mk_path = sys.argv[1]
    else:
        # Default to versions.mk relative to the script's parent directory
        versions_mk_path = os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
            "versions.mk",
        )

    if not os.path.exists(versions_mk_path):
        print(f"ERROR: {versions_mk_path} not found", file=sys.stderr)
        return 1

    with open(versions_mk_path) as f:
        content = f.read()

    content = update_aqua_checksums(content)
    content = update_cosign_checksums(content)
    content = update_slsa_verifier_checksums(content)
    content = update_go_checksums(content)

    with open(versions_mk_path, "w") as f:
        f.write(content)

    print(f"Updated checksums in {versions_mk_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
