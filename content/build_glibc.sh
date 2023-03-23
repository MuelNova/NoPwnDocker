#!/bin/bash
# This script is used to build glibc for the target platform.

usage() {
  printf "%s\n" \
    "bash $0 [options] GLIBC_VERSION" \
    "" \
    "Download and auto compile glibc with debugging sourcecode." 

  printf "\n%s\n" "Options"
  printf "\t%s\n\t\t%s\n\n" \
    "-b, --bin-dir" "Override the bin installation directory [default: ${BIN_DIR}]" \
    "-a, --arch" "Override the architecture identified by the installer [default: ${ARCH}]" \
    "-B, --base-url" "Override the base URL used for downloading releases [default: ${BASE_URL}]" \
    "-t, --threads" "Override the number of threads used for compilation [default: ${THREADS}]" \
    "-y, --yes" "Continue to build without confirming" \
    "-s, --silent" "Build in silent" \
    "-h, --help" "Display this help message"
}

get_arch() {
  case $(uname -m) in
    x86_64)
      echo "x86_64"
      ;;
    i?86)
      echo "i686"
      ;;
    *)
      echo "Unknown architecture"
      exit 1
      ;;
  esac
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -b|--bin-dir)
        BIN_DIR="$(readlink -f "$2")"
        shift 2
        ;;
      -a|--arch)
        ARCH="$2"
        shift 2
        ;;
      -B|--base-url)
        BASE_URL="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      -t|--threads)
        THREADS="$2"
        shift 2
        ;;
      -y|--yes)
        YES=1
        shift 1
        ;;
      -s|--silient)
        SILENT=1
        shift 1
        ;;
      -*)
        echo "Unknown option: $1"
        exit 1
        ;;
      *)
        GLIBC_VERSION="$1"
        shift 1
        ;;
    esac
  done
  if [ -z "$GLIBC_VERSION" ]; then
    printf "%s:\t%s\n" "ERROR" "Missing GLIBC_VERSION"
    usage
    exit 1
  fi
}

get_threads() {
  if [[ -f /proc/cpuinfo ]]; then
    echo $(grep -c ^processor /proc/cpuinfo)
  else
    echo 1
  fi
}

run() {
  if [ $SILENT -eq 1 ]; then
    compilearg='-s'
  fi
  curl -LO "${BASE_URL}/glibc-${GLIBC_VERSION}.tar.gz" $compilearg
  tar xf glibc-${GLIBC_VERSION}.tar.gz
  cd glibc-${GLIBC_VERSION}
  mkdir build
  cd build
  if [ '$arch'='i686' ]; then
    ../configure --prefix=${BIN_DIR}/${GLIBC_VERSION}/32/ --disable-werror --enable-debug=yes --host=i686-linux-gnu --build=i686-linux-gnu \
      CC="gcc -m32" CXX="g++ -m32" \
      CFLAGS="-O2 -march=i686" \
      CXXFLAGS="-O2 -march=i686" \
  else
    ../configure --prefix=${BIN_DIR}/${GLIBC_VERSION}/64/ --disable-werror --enable-debug=yes
  fi
  make -j${THREADS} $compilearg
  make install -j${THREADS} $compilearg
  cd ../../
  rm -rf glibc-${GLIBC_VERSION} && rm glibc-${GLIBC_VERSION}.tar.gz
}

YES=0
SILENT=0
BIN_DIR=/ctf/glibc
ARCH=$(get_arch)
BASE_URL=http://mirrors.ustc.edu.cn/gnu/libc
THREADS=$(get_threads)

parse_args "$@"

printf "%s\n" "Configuration:"
printf "\t%s\t%s\n" "GLIBC_VERSION:" "${GLIBC_VERSION}"
printf "\t%s\t%s\n" "BIN_DIR:" "${BIN_DIR}"
printf "\t%s\t%s\n" "ARCH:" "${ARCH}"
printf "\t%s\t%s\n" "BASE_URL:" "${BASE_URL}"
printf "%s\t%s\n" "Tarball:" "${BASE_URL}/glibc-${GLIBC_VERSION}.tar.gz"

if [ $YES -eq 0 ]; then
  printf "%s" "Confirm your installtaion? [y|N] "
  read -r input
  case $input in
    [yY][eE][sS]|[yY])
      ;;
    [nN][oO]|[nN])
      exit 0
      ;;
    *)
      exit 0
      ;;
  esac
fi

run