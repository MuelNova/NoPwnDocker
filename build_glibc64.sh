mkdir -p /ctf/glibc/$GLIBC_VERSION
curl -LOs http://mirrors.ustc.edu.cn/gnu/libc/glibc-${GLIBC_VERSION}.tar.gz
tar xf glibc-${GLIBC_VERSION}.tar.gz
cd glibc-${GLIBC_VERSION}
mkdir build
cd build
../configure --prefix=/ctf/glibc/${GLIBC_VERSION}/64/ --disable-werror --enable-debug=yes
make -j${THREADS}
make install -j${THREADS}
cd ../../
rm -rf glibc-${GLIBC_VERSION} && rm glibc-${GLIBC_VERSION}.tar.gz
