mkdir -p /ctf/glibc/$GLIBC_VERSION
curl -LOs http://mirrors.ustc.edu.cn/gnu/libc/glibc-${GLIBC_VERSION}.tar.gz
tar xf glibc-${GLIBC_VERSION}.tar.gz
cd glibc-${GLIBC_VERSION}
mkdir build
cd build
../configure --prefix=/ctf/glibc/${GLIBC_VERSION}/32/ --disable-werror --enable-debug=yes --host=i686-linux-gnu --build=i686-linux-gnu \
     CC="gcc -m32" CXX="g++ -m32" \
     CFLAGS="-O2 -march=i686" \
     CXXFLAGS="-O2 -march=i686"
make -j${THREADS}
make install -j${THREADS}
cd ../../
rm -rf glibc-${GLIBC_VERSION} && rm glibc-${GLIBC_VERSION}.tar.gz
