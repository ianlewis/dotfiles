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

# renovate: datasource=github-releases depName=sigstore/cosign versioning=loose
COSIGN_VERSION ?= v3.1.3
COSIGN_CHECKSUM.linux.amd64 := 4629c757b7618056f8ddd7e2625ae9fdd94c0372a65049520bc7d9df9efc7f71
COSIGN_CHECKSUM.linux.arm64 := c5d324e091826b0d7a78eb16fef316450b4eb9aaec045611c08ba06f5e73220a
COSIGN_CHECKSUM.darwin.arm64 := 5cf948c2f4dfe59687bdd0b8523709067383e03982cc543475c8a7dc70e92a76

# renovate: datasource=golang-version depName=golang versioning=loose
GO_VERSION ?= 1.27.3
GO_CHECKSUM.linux.amd64 := 65efbc80fdc1fa2cd2631cad5b481777a68e8725f34e89f50fc6ac714e379b40
GO_CHECKSUM.linux.arm64 := a06e99309dbcbdca1a8ccd2282c3ee146e55930886e26b4f1193269587165f49
GO_CHECKSUM.darwin.arm64 := dd3908cf20959d798c1e06ebe5b72213f0505ce01373b40ce3110975a6cd99c2

# renovate: depName=nodenv/nodenv
NODENV_INSTALL_VERSION ?= v1.6.2
NODENV_INSTALL_SHA ?= dc200d672dda83e6adb9b32b8b4fc752643ab2a4

# renovate: depName=nodenv/node-build
NODENV_BUILD_VERSION ?= v5.4.62
NODENV_BUILD_SHA ?= 77cfc3cac8797a85380a5a7b733eccb86178cbb2

# renovate: depName=pyenv/pyenv
PYENV_INSTALL_VERSION ?= v2.8.14
PYENV_INSTALL_SHA ?= 3fb25668b463ad38ac2db6092dbf476ef744c0ca

# renovate: depName=pyenv/pyenv-virtualenv
PYENV_VIRTUALENV_VERSION ?= v1.4.1
PYENV_VIRTUALENV_SHA ?= 7d821a62d6eeae21a451141c41898be1ed4ed147

# renovate: depName=jawshooah/pyenv-default-packages
PYENV_DEFAULT_PACKAGES_VERSION ?= 0.3.1
PYENV_DEFAULT_PACKAGES_SHA ?= b78465fc2b5436b0ecdbc8982377adffa8b8520b

# renovate: depName=rbenv/rbenv
RBENV_INSTALL_VERSION ?= v1.3.2
RBENV_INSTALL_SHA ?= 10e96bfc473c7459a447fbbda12164745a72fd37

# renovate: depName=rbenv/ruby-build
RBENV_BUILD_VERSION ?= v20261013
RBENV_BUILD_SHA ?= 7eacc0aaf063436f12eea006beaef5c629aa918e

# renovate: datasource=github-releases depName=slsa-framework/slsa-verifier versioning=loose
SLSA_VERIFIER_VERSION ?= v2.7.1
SLSA_VERIFIER_CHECKSUM.linux.amd64 := 946dbec729094195e88ef78e1734324a27869f03e2c6bd2f61cbc06bd5350339
SLSA_VERIFIER_CHECKSUM.linux.arm64 := 5d3b2349ede7bfec19e7a21569f18b9f7410145ad12e9584b175370669e14061
SLSA_VERIFIER_CHECKSUM.darwin.arm64 := 39abfcf5f1d690c3e889ce3d2d6a8b87711424d83368511868d414e8f8bcb05c
