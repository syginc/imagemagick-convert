#!/bin/bash

set -eo pipefail

MAGICK_VERSION=6.9.10-87
rm -rf build
rm -rf dist

mkdir -p build

pushd build
curl -s -O https://download.imagemagick.org/ImageMagick/download/releases/ImageMagick-$MAGICK_VERSION.tar.xz
tar xf ImageMagick-$MAGICK_VERSION.tar.xz
cd ImageMagick-$MAGICK_VERSION
./configure \
  --enable-shared=no \
  --enable-static=yes \
  --enable-delegate-build \
  --with-quantum-depth=16 \
  --without-magick-plus-plus \
  --without-dps \
  --without-fftw \
  --without-fpx \
  --without-djvu \
  --without-fontconfig \
  --without-freetype \
  --without-raqm \
  --without-heic \
  --without-jbig \
  --without-lcms \
  --without-openjp2 \
  --without-pango \
  --without-raw \
  --without-tiff \
  --without-webp \
  --without-xml \
  --disable-opencl \
  --with-png \
  --with-jpeg
make
popd

mkdir -p dist
cp build/ImageMagick-$MAGICK_VERSION/utilities/convert dist/
