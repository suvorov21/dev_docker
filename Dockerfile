FROM centos as dev_base
RUN yum -y install centos-release-scl-rh
RUN yum -y install devtoolset-8
RUN yum -y install rh-python36-python-devel
ENV COMMON_INSTALL_PREFIX=/usr/local/
ENV COMMON_BUILD_PREFIX=/usr/local/build/
RUN mkdir -p $COMMON_BUILD_PREFIX && \
    mkdir -p $COMMON_INSTALL_PREFIX && \
    mkdir -p $COMMON_INSTALL_PREFIX/usr/ && \
    echo "#!bin/sh" > $COMMON_INSTALL_PREFIX/usr/setup.sh && \
    echo ". scl_source enable devtoolset-8" >> $COMMON_INSTALL_PREFIX/usr/setup.sh && \
    echo ". scl_source enable rh-python36" >> $COMMON_INSTALL_PREFIX/usr/setup.sh && \
    /bin/true
FROM dev_base as dev_ext
COPY --from=dev_base $COMMON_BUILD_PREFIX $COMMON_BUILD_PREFIX
COPY --from=dev_base $COMMON_INSTALL_PREFIX $COMMON_INSTALL_PREFIX
RUN yum -y install  openssl-devel libcurl-devel \
                    expat-devel xerces-c-devel \
                    qt-devel libxmu-devel \
                    libX11-devel libXaw-devel \
                    mysql-devel \
                    wget which autoconf
# git 2.*
ENV GIT_VER=2.21.0
RUN . $COMMON_INSTALL_PREFIX/usr/setup.sh && \
    cd $COMMON_BUILD_PREFIX && \
    wget https://github.com/git/git/archive/v${GIT_VER}.tar.gz && \
    tar -xf v2.*.tar.gz && \
    rm -f v2.*.tar.gz && \
    cd git-* && \
    make configure && \
    ./configure --prefix=$COMMON_INSTALL_PREFIX && \
    make install  && \
    rm -rf $COMMON_BUILD_PREFIX/*
# cmake 3.*
ENV CMAKE_VER=3.14.4
RUN . $COMMON_INSTALL_PREFIX/usr/setup.sh && \
    cd $COMMON_BUILD_PREFIX && \
    wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VER}/cmake-${CMAKE_VER}.tar.gz && \
    tar -xf cmake-3.* && \
    rm -f cmake-3*tar.gz && \
    cd cmake-3.* && \
    ./bootstrap --prefix=$COMMON_INSTALL_PREFIX && \
    make -j3 && \
    make install && \
    cd $COMMON_BUILD_PREFIX && \
    rm -rf $COMMON_BUILD_PREFIX/*
## GSL 2.*
ENV GSL_VER=2.5
RUN source $COMMON_INSTALL_PREFIX/usr/setup.sh && \
    cd $COMMON_BUILD_PREFIX && \
    wget ftp://ftp.gnu.org/gnu/gsl/gsl-${GSL_VER}.tar.gz && \
    tar -xzf gsl-2.*.tar.gz && \
    cd gsl-2* && \
    ./configure --prefix=$COMMON_INSTALL_PREFIX && \
    make -j3 all && \
    make install && \
    cd $COMMON_BUILD_PREFIX && \
    rm -rf $COMMON_BUILD_PREFIX/*

## CPPCHECK
ENV CPPCHECK_VER=1.88
RUN source $COMMON_INSTALL_PREFIX/usr/setup.sh && \
    cd $COMMON_BUILD_PREFIX && \
    wget https://github.com/danmar/cppcheck/archive/${CPPCHECK_VER}.tar.gz && \
    tar -xf ${CPPCHECK_VER}.tar.gz && \
    cd cppcheck-${CPPCHECK_VER}/ && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=$COMMON_INSTALL_PREFIX ../ && \
    make -j3 && \
    make install

## DOXYGEN
ENV DOXYGEN_VER=1.8.16
RUN source $COMMON_INSTALL_PREFIX/usr/setup.sh && \
    yum install flex && \
    yum install bison && \
    pip3 install graphviz && \
    cd $COMMON_BUILD_PREFIX && \
    wget http://doxygen.nl/files/doxygen-${DOXYGEN_VER}.src.tar.gz && \
    tar -xf doxygen-*.tar.gz && \
    cd doxygen-* && \
    mkdir build; cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=$COMMON_INSTALL_PREFIX ../ && \
    make -j3 && \
    make install
