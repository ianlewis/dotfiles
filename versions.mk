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

# renovate: datasource=github-releases depName=aquaproj/aqua versioning=loose
AQUA_VERSION ?= v2.62.3
# renovate: datasource=github-releases depName=aquaproj/aqua-installer versioning=loose
AQUA_INSTALLER_VERSION ?= v4.0.5

# renovate: datasource=github-releases depName=sigstore/cosign versioning=loose
COSIGN_VERSION ?= v3.1.3
COSIGN_CHECKSUM.linux.amd64 := 4629c757b7618056f8ddd7e2625ae9fdd94c0372a65049520bc7d9df9efc7f71
COSIGN_CHECKSUM.linux.arm64 := c5d324e091826b0d7a78eb16fef316450b4eb9aaec045611c08ba06f5e73220a
COSIGN_CHECKSUM.darwin.arm64 := 5cf948c2f4dfe59687bdd0b8523709067383e03982cc543475c8a7dc70e92a76

# renovate: datasource=golang-version depName=golang versioning=loose
GO_VERSION ?= 1.27.1
GO_CHECKSUM.linux.amd64 := 63d339f0da5ab53635a56f2490a7984dfe12dfcff22ad749f63edaf590168445
GO_CHECKSUM.linux.arm64 := 3450b45a3f9ee8568792736a5c5e70a1f2e9b36c35a8f74958c03e51d7d92bec
GO_CHECKSUM.darwin.arm64 := ee215d57e0ec269c60cc9ceca68e6bda321ba9ee5afe24f4b0988703c2d87d12

# renovate: datasource=github-releases depName=nodenv/nodenv versioning=loose
NODENV_INSTALL_VERSION ?= v1.6.2
NODENV_INSTALL_SHA ?= dc200d672dda83e6adb9b32b8b4fc752643ab2a4

# renovate: datasource=github-releases depName=nodenv/node-build versioning=loose
NODENV_BUILD_VERSION ?= v5.4.56
NODENV_BUILD_SHA ?= 5295c6aacdf388381bfd92da1c162d7e0985f4f5

# renovate: datasource=github-releases depName=pyenv/pyenv versioning=loose
PYENV_INSTALL_VERSION ?= v2.8.6
PYENV_INSTALL_SHA ?= 3787bacc9188d76ba7ca24c23e26afb1a841a543

# renovate: datasource=github-releases depName=pyenv/pyenv-virtualenv versioning=loose
PYENV_VIRTUALENV_VERSION ?= v1.4.0
PYENV_VIRTUALENV_SHA ?= eda64556af9b2992386deeb75dad2130899fc4c9

# renovate: datasource=github-releases depName=rbenv/rbenv versioning=loose
RBENV_INSTALL_VERSION ?= v1.3.2
RBENV_INSTALL_SHA ?= 10e96bfc473c7459a447fbbda12164745a72fd37

# renovate: datasource=github-releases depName=rbenv/ruby-build versioning=loose
RBENV_BUILD_VERSION ?= v20260716
RBENV_BUILD_SHA ?= 013c27d7e557b71b21bfa0f9c7af1081cf5411dc

# renovate: datasource=github-releases depName=slsa-framework/slsa-verifier versioning=loose
SLSA_VERIFIER_VERSION ?= v2.7.1
SLSA_VERIFIER_CHECKSUM.linux.amd64 := 946dbec729094195e88ef78e1734324a27869f03e2c6bd2f61cbc06bd5350339
SLSA_VERIFIER_CHECKSUM.linux.arm64 := 5d3b2349ede7bfec19e7a21569f18b9f7410145ad12e9584b175370669e14061
SLSA_VERIFIER_CHECKSUM.darwin.arm64 := 39abfcf5f1d690c3e889ce3d2d6a8b87711424d83368511868d414e8f8bcb05c
