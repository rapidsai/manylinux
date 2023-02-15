#!/bin/bash

# Stop at any error, show all commands
set -Eexuo pipefail

if which yum; then
  yum update ; yum install -y \
      curl \
      wget \
      numactl \
      numactl-devel \
      openssh-clients \
      libcudnn8-devel \
      zip \
      blas-devel \
      lapack-devel \
      protobuf-compiler
else
  apt update ; apt install -y --no-install-recommends \
      curl \
      wget \
      numactl \
      libnuma-dev \
      openssh-client \
      libcudnn8-dev \
      zip \
      libblas-dev \
      liblapack-dev \
      protobuf-compiler
fi

# backported gcc-9 in 18.04
if [ "${AUDITWHEEL_POLICY}" == "manylinux_2_27" ] ; then
    apt-get install -y software-properties-common &&\
        add-apt-repository ppa:jonathonf/gcc &&\
        apt-get update && apt-get install -y gcc-9 g++-9 &&\
        update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 900 --slave /usr/bin/g++ g++ /usr/bin/g++-9
fi

export SCCACHE_VERSION=0.3.3
curl -o /tmp/sccache.tar.gz \
        -L "https://github.com/ajschmidt8/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-${AUDITWHEEL_ARCH}-unknown-linux-musl.tar.gz" ;\
        tar -C /tmp -xvf /tmp/sccache.tar.gz ;\
        mv "/tmp/sccache-v${SCCACHE_VERSION}-${AUDITWHEEL_ARCH}-unknown-linux-musl/sccache" /usr/bin/sccache ;\
        chmod +x /usr/bin/sccache

export UCX_VERSION=1.13.0
mkdir -p /ucx-src /usr ; cd /ucx-src \
 ; git clone https://github.com/openucx/ucx -b v${UCX_VERSION} ucx-git-repo ; cd ucx-git-repo \
 ; ./autogen.sh \
 ; ./contrib/configure-release \
    --prefix=/usr               \
    --enable-mt                 \
    --enable-cma                \
    --enable-numa               \
    --with-gnu-ld               \
    --with-sysroot              \
    --without-verbs             \
    --without-rdmacm            \
    --with-cuda=/usr/local/cuda \
    CPPFLAGS=-I/usr/local/cuda/include \
 ; make -j \
 ; make install \
 ; cd /usr \
 ; rm -rf /ucx-src/

# Install latest gha-tools
wget https://github.com/rapidsai/gha-tools/releases/latest/download/tools.tar.gz -O - | tar -xz -C /usr/local/bin

# Remove libnccl-cuda12.0 which UNAVOIDABLY gets installed
if which yum; then
  case "${CUDA_VERSION}" in
    11.5.1)
      yum remove -y libnccl libnccl-devel
      yum install -y libnccl-2.11.4-1+cuda11.5 libnccl-devel-2.11.4-1+cuda11.5
      ;;
    11.8.0)
      yum remove -y libnccl libnccl-devel
      yum install -y libnccl-2.16.2-1+cuda11.8 libnccl-devel-2.16.2-1+cuda11.8
      ;;
    12.0.0)
      true
      ;;
  esac
fi
