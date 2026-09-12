#!/usr/bin/env bash
set -euo pipefail

if command -v sudo >/dev/null 2>&1; then
  SUDO=sudo
else
  SUDO=
fi

if ! command -v aarch64-linux-gnu-g++ >/dev/null 2>&1; then
  $SUDO dpkg --add-architecture arm64

  if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
    $SUDO perl -0pi -e 's/^Types: deb$/Types: deb\nArchitectures: amd64/mg' \
      /etc/apt/sources.list.d/ubuntu.sources
  fi

  cat <<'EOF' | $SUDO tee /etc/apt/sources.list.d/arm64-ports.list >/dev/null
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports noble main universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports noble-updates main universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports noble-security main universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports noble-backports main universe multiverse
  EOF

  $SUDO apt-get update
  $SUDO apt-get install -y --no-install-recommends \
    build-essential \
    make \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    libc6-dev-arm64-cross \
    libstdc++-12-dev-arm64-cross \
    libgl1-mesa-dev libgl1-mesa-dev:arm64 \
    libgles2-mesa-dev libgles2-mesa-dev:arm64 \
    libegl1-mesa-dev libegl1-mesa-dev:arm64 \
    libglvnd-dev libglvnd-dev:arm64 \
    libx11-dev libx11-dev:arm64
fi

export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++
export AR=aarch64-linux-gnu-ar
export STRINGS=aarch64-linux-gnu-strings
export ARCH=aarch64
export platform=linux-aarch64
export HAVE_PARALLEL_RDP=1
export HAVE_PARALLEL_RSP=1
export HAVE_THR_AL=1
export LLE=1

make clean
make platform=linux-aarch64 ARCH=aarch64 -j"$(nproc)"
