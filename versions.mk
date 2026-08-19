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
COSIGN_VERSION ?= v3.1.2
COSIGN_CHECKSUM.linux.amd64 := f7622ed3cf22e55e1ae6377c080979ff77a22da9981c11df222a2e444991e7cf
COSIGN_CHECKSUM.linux.arm64 := 90e7ae0b5dfd60f20816b52c012addf7fc055ebcc7bea4ce81c428ca8518c302
COSIGN_CHECKSUM.darwin.arm64 := dec1c3f802320b19c2fbcf2dc7bcfb3f258e1c181a046c23a1a074bdf932f10a

# renovate: datasource=golang-version depName=golang versioning=loose
GO_VERSION ?= 1.26.5
GO_CHECKSUM.linux.amd64 := 5c2c3b16caefa1d968a94c1daca04a7ca301a496d9b086e17ad77bb81393f053
GO_CHECKSUM.linux.arm64 := fe4789e92b1f33358680864bbe8704289e7bb5fc207d80623c308935bd696d49
GO_CHECKSUM.darwin.arm64 := efb87ff28af9a188d0536ef5d42e63dd52ba8263cd7344a993cc48dd11dedb6a

# renovate: datasource=github-releases depName=nodenv/nodenv versioning=loose
NODENV_INSTALL_VERSION ?= v1.6.2
NODENV_INSTALL_SHA ?= dc200d672dda83e6adb9b32b8b4fc752643ab2a4

# renovate: datasource=github-releases depName=nodenv/node-build versioning=loose
NODENV_BUILD_VERSION ?= v5.4.49
NODENV_BUILD_SHA ?= 1330263f5be434685eb14fd2ee563ed1970a8f3a

# renovate: datasource=github-releases depName=pyenv/pyenv versioning=loose
PYENV_INSTALL_VERSION ?= v2.8.4
PYENV_INSTALL_SHA ?= 0f16606e4f906bac76a409bcab40974d579067bf

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
