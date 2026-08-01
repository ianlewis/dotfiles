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
AQUA_VERSION ?= v2.60.1
# renovate: datasource=github-releases depName=aquaproj/aqua-installer versioning=loose
AQUA_INSTALLER_VERSION ?= v4.0.5

# renovate: datasource=github-releases depName=sigstore/cosign versioning=loose
COSIGN_VERSION ?= v3.1.1
COSIGN_CHECKSUM.linux.amd64 := ae1ecd212663f3693ad9edf8b1a183900c9a52d3155ba6e354237f9a0f6463fc
COSIGN_CHECKSUM.linux.arm64 := 2ec865872e331c32fd12b08dae15332d3f92c0aa029219589684a4903ca85d11
COSIGN_CHECKSUM.darwin.arm64 := 94b42a9e697be95675f6160ab031a9a5f1ec1e646d6f648d7b2f5cd59ececbc5

# renovate: datasource=golang-version depName=golang versioning=loose
GO_VERSION ?= 1.26.4
GO_CHECKSUM.linux.amd64 := 1153d3d50e0ac764b447adfe05c2bcf08e889d42a02e0fe0259bd47f6733ad7f
GO_CHECKSUM.linux.arm64 := ef758ae7c6cf9267c9c0ef080b8965f453d89ab2d25d9eb22de4405925238768
GO_CHECKSUM.darwin.arm64 := b62ad2b6d7d2464f12a5bcad7ff47f19d08325773b5efd21610e445a05a9bf53

# renovate: datasource=github-releases depName=nodenv/nodenv versioning=loose
NODENV_INSTALL_VERSION ?= v1.6.2
NODENV_INSTALL_SHA ?= dc200d672dda83e6adb9b32b8b4fc752643ab2a4

# renovate: datasource=github-releases depName=nodenv/node-build versioning=loose
NODENV_BUILD_VERSION ?= v5.4.44
NODENV_BUILD_SHA ?= 12ac21c200aa4af5a49302ae66b1a3dbd129bb1a

# renovate: datasource=github-releases depName=pyenv/pyenv versioning=loose
PYENV_INSTALL_VERSION ?= v2.7.3
PYENV_INSTALL_SHA ?= 933d0aaf1d1190a641c3ddce484e72b1a993473d

# renovate: datasource=github-releases depName=pyenv/pyenv-virtualenv versioning=loose
PYENV_VIRTUALENV_VERSION ?= v1.4.0
PYENV_VIRTUALENV_SHA ?= eda64556af9b2992386deeb75dad2130899fc4c9

# renovate: datasource=github-releases depName=rbenv/rbenv versioning=loose
RBENV_INSTALL_VERSION ?= v1.3.2
RBENV_INSTALL_SHA ?= 10e96bfc473c7459a447fbbda12164745a72fd37

# renovate: datasource=github-releases depName=rbenv/ruby-build versioning=loose
RBENV_BUILD_VERSION ?= v20260716
RBENV_BUILD_SHA ?= 3671c9ef15d58759311faba68c947d90b2d5980e

# renovate: datasource=github-releases depName=slsa-framework/slsa-verifier versioning=loose
SLSA_VERIFIER_VERSION ?= v2.7.1
SLSA_VERIFIER_CHECKSUM.linux.amd64 := 946DBEC729094195E88EF78E1734324A27869F03E2C6BD2F61CBC06BD5350339
SLSA_VERIFIER_CHECKSUM.linux.arm64 := 5D3B2349EDE7BFEC19E7A21569F18B9F7410145AD12E9584B175370669E14061
SLSA_VERIFIER_CHECKSUM.darwin.arm64 := 39ABFCF5F1D690C3E889CE3D2D6A8B87711424D83368511868D414E8F8BCB05C
