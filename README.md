# Halide toolkits (Play with Halide)

For more detail about what Halide is, see http://halide-lang.org.

For API documentation see http://halide-lang.org/docs

## Build & Install

To build this project, see the notes below.

Build Status
============

| Linux                        |
|------------------------------|
| [![linux build status][1]][2]|

[1]: https://travis-ci.org/xbwee1024/play-with-halide.svg?branch=master
[2]: https://travis-ci.org/xbwee1024/play-with-halide

### Prerequisites
`Ninja`, `gcc` or `clang` installed

For Android,
`Android NDK` installed. `Android SDK` is not required now (build Android examples is disabled)

### Clone the source code
```bash
git clone https://github.com/xbwee1024/play-with-halide.git
cd play-with-halide
git submodule update --init --recursive
# or clone with --recursive
git clone https://github.com/xbwee1024/play-with-halide.git --recursive
```

### Build Halide

```bash
./script/build-halide.sh
# or add android to cross-compile Android
./script/build-halide.sh android
```
this will build the `Halide` library and install it into `out/halide/distrib/${HOST_NAME}`


### Build Project

```bash
./script/build.sh
# or add android to cross-compile Android
./script/build.sh android
```

When building finished, binaries will be installed at `out/install/${HOST_NAME}/bin`
