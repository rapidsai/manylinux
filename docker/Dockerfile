# default to latest supported policy, x86_64
ARG BASEIMAGE=amd64/almalinux:8
ARG POLICY=manylinux_2_28
ARG PLATFORM=x86_64
ARG DEVTOOLSET_ROOTPATH=/opt/rh/gcc-toolset-12/root
ARG LD_LIBRARY_PATH_ARG=${DEVTOOLSET_ROOTPATH}/usr/lib64:${DEVTOOLSET_ROOTPATH}/usr/lib:${DEVTOOLSET_ROOTPATH}/usr/lib64/dyninst:${DEVTOOLSET_ROOTPATH}/usr/lib/dyninst
ARG PREPEND_PATH=${DEVTOOLSET_ROOTPATH}/usr/bin:

FROM $BASEIMAGE AS runtime_base
ARG POLICY
ARG PLATFORM
ARG DEVTOOLSET_ROOTPATH
ARG LD_LIBRARY_PATH_ARG
ARG PREPEND_PATH
LABEL maintainer="The ManyLinux project"

ENV AUDITWHEEL_POLICY=${POLICY} AUDITWHEEL_ARCH=${PLATFORM} AUDITWHEEL_PLAT=${POLICY}_${PLATFORM}
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8
ENV DEVTOOLSET_ROOTPATH=${DEVTOOLSET_ROOTPATH}

# first save the old LD_LIBRARY_PATH, whose original value may be important e.g. in a cuda container
ENV LD_LIBRARY_PATH_OLD=${LD_LIBRARY_PATH}

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH_ARG}
ENV PATH=${PREPEND_PATH}${PATH}
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

# first copy the fixup mirrors script, keep the script around
COPY build_scripts/fixup-mirrors.sh /usr/local/sbin/fixup-mirrors

# setup entrypoint, this will wrap commands with `linux32` with i686 images
COPY build_scripts/install-entrypoint.sh \
     build_scripts/update-system-packages.sh \
     build_scripts/build_utils.sh \
     /build_scripts/

RUN /build_scripts/install-entrypoint.sh && rm -rf /build_scripts
COPY manylinux-entrypoint /usr/local/bin/manylinux-entrypoint
ENTRYPOINT ["manylinux-entrypoint"]

COPY build_scripts/install-runtime-packages.sh \
     build_scripts/update-system-packages.sh \
     build_scripts/build_utils.sh \
     /build_scripts/
RUN manylinux-entrypoint /build_scripts/install-runtime-packages.sh && rm -rf /build_scripts/

COPY build_scripts/build_utils.sh /build_scripts/

COPY build_scripts/install-autoconf.sh /build_scripts/
RUN export AUTOCONF_ROOT=autoconf-2.71 && \
    export AUTOCONF_HASH=431075ad0bf529ef13cb41e9042c542381103e80015686222b8a9d4abef42a1c && \
    export AUTOCONF_DOWNLOAD_URL=http://ftp.gnu.org/gnu/autoconf && \
    manylinux-entrypoint /build_scripts/install-autoconf.sh

COPY build_scripts/install-automake.sh /build_scripts/
RUN export AUTOMAKE_ROOT=automake-1.16.5 && \
    export AUTOMAKE_HASH=07bd24ad08a64bc17250ce09ec56e921d6343903943e99ccf63bbf0705e34605 && \
    export AUTOMAKE_DOWNLOAD_URL=http://ftp.gnu.org/gnu/automake && \
    manylinux-entrypoint /build_scripts/install-automake.sh

COPY build_scripts/install-libtool.sh /build_scripts/
RUN export LIBTOOL_ROOT=libtool-2.4.7 && \
    export LIBTOOL_HASH=04e96c2404ea70c590c546eba4202a4e12722c640016c12b9b2f1ce3d481e9a8 && \
    export LIBTOOL_DOWNLOAD_URL=http://ftp.gnu.org/gnu/libtool && \
    manylinux-entrypoint /build_scripts/install-libtool.sh

COPY build_scripts/install-libxcrypt.sh /build_scripts/
RUN export LIBXCRYPT_VERSION=4.4.33 && \
    export LIBXCRYPT_HASH=0a0c06bcd028fd0f0467f89f6a451112e8ec97c36e0f58e7464449a4c04607ed && \
    export LIBXCRYPT_DOWNLOAD_URL=https://github.com/besser82/libxcrypt/archive && \
    export PERL_ROOT=perl-5.34.0 && \
    export PERL_HASH=551efc818b968b05216024fb0b727ef2ad4c100f8cb6b43fab615fa78ae5be9a && \
    export PERL_DOWNLOAD_URL=https://www.cpan.org/src/5.0 && \
    manylinux-entrypoint /build_scripts/install-libxcrypt.sh

FROM runtime_base AS build_base
COPY build_scripts/install-build-packages.sh /build_scripts/
RUN manylinux-entrypoint /build_scripts/install-build-packages.sh


FROM build_base AS build_git
COPY build_scripts/build-git.sh /build_scripts/
RUN export GIT_ROOT=git-2.40.0 && \
    export GIT_HASH=ab37c343c0ad097282fd311ab9ca521ab3da836e5c4ed2093994f1b7f8575b09 && \
    export GIT_DOWNLOAD_URL=https://www.kernel.org/pub/software/scm/git && \
    manylinux-entrypoint /build_scripts/build-git.sh


FROM build_base AS build_cpython
COPY build_scripts/build-sqlite3.sh /build_scripts/
RUN export SQLITE_AUTOCONF_ROOT=sqlite-autoconf-3410200 && \
    export SQLITE_AUTOCONF_HASH=e98c100dd1da4e30fa460761dab7c0b91a50b785e167f8c57acc46514fae9499 && \
    export SQLITE_AUTOCONF_DOWNLOAD_URL=https://www.sqlite.org/2023 && \
    manylinux-entrypoint /build_scripts/build-sqlite3.sh

COPY build_scripts/build-openssl.sh /build_scripts/
RUN export OPENSSL_ROOT=openssl-1.1.1t && \
    export OPENSSL_HASH=8dee9b24bdb1dcbf0c3d1e9b02fb8f6bf22165e807f45adeb7c9677536859d3b && \
    export OPENSSL_DOWNLOAD_URL=https://www.openssl.org/source && \
    manylinux-entrypoint /build_scripts/build-openssl.sh

COPY build_scripts/build-tcltk.sh /build_scripts/
RUN export TCL_ROOT=tcl8.6.13 && \
    export TCL_HASH=43a1fae7412f61ff11de2cfd05d28cfc3a73762f354a417c62370a54e2caf066 && \
    export TCL_DOWNLOAD_URL=https://prdownloads.sourceforge.net/tcl && \
    export TK_ROOT=tk8.6.13 && \
    export TK_HASH=2e65fa069a23365440a3c56c556b8673b5e32a283800d8d9b257e3f584ce0675 && \
    manylinux-entrypoint /build_scripts/build-tcltk.sh

COPY build_scripts/build-cpython.sh /build_scripts/


FROM build_cpython AS build_cpython36
COPY build_scripts/cpython-pubkeys.txt /build_scripts/cpython-pubkeys.txt
RUN manylinux-entrypoint /build_scripts/build-cpython.sh 3.6.15


FROM build_cpython AS build_cpython37
COPY build_scripts/cpython-pubkeys.txt /build_scripts/cpython-pubkeys.txt
RUN manylinux-entrypoint /build_scripts/build-cpython.sh 3.7.16


FROM build_cpython AS build_cpython38
COPY build_scripts/ambv-pubkey.txt /build_scripts/cpython-pubkeys.txt
RUN manylinux-entrypoint /build_scripts/build-cpython.sh 3.8.16


FROM build_cpython AS build_cpython39
COPY build_scripts/ambv-pubkey.txt /build_scripts/cpython-pubkeys.txt
RUN manylinux-entrypoint /build_scripts/build-cpython.sh 3.9.16


FROM build_cpython AS build_cpython310
COPY build_scripts/cpython-pubkey-310-311.txt /build_scripts/cpython-pubkeys.txt
RUN manylinux-entrypoint /build_scripts/build-cpython.sh 3.10.11

FROM build_cpython AS build_cpython311
COPY build_scripts/cpython-pubkey-310-311.txt /build_scripts/cpython-pubkeys.txt
RUN manylinux-entrypoint /build_scripts/build-cpython.sh 3.11.3

FROM build_cpython AS all_python
COPY build_scripts/install-pypy.sh \
     build_scripts/pypy.sha256 \
     build_scripts/finalize-python.sh \
     /build_scripts/
RUN manylinux-entrypoint /build_scripts/install-pypy.sh 3.7 7.3.9
RUN manylinux-entrypoint /build_scripts/install-pypy.sh 3.8 7.3.11
RUN manylinux-entrypoint /build_scripts/install-pypy.sh 3.9 7.3.11
COPY --from=build_cpython36 /opt/_internal /opt/_internal/
COPY --from=build_cpython37 /opt/_internal /opt/_internal/
COPY --from=build_cpython38 /opt/_internal /opt/_internal/
COPY --from=build_cpython39 /opt/_internal /opt/_internal/
COPY --from=build_cpython310 /opt/_internal /opt/_internal/
COPY --from=build_cpython311 /opt/_internal /opt/_internal/
RUN manylinux-entrypoint /build_scripts/finalize-python.sh


FROM runtime_base
COPY --from=build_git /manylinux-rootfs /
COPY --from=build_cpython /manylinux-rootfs /
COPY --from=all_python /opt/_internal /opt/_internal/
COPY build_scripts/finalize.sh \
     build_scripts/update-system-packages.sh \
     build_scripts/python-tag-abi-tag.py \
     build_scripts/requirements3.6.txt \
     build_scripts/requirements3.7.txt \
     build_scripts/requirements3.8.txt \
     build_scripts/requirements3.9.txt \
     build_scripts/requirements3.10.txt \
     build_scripts/requirements3.11.txt \
     build_scripts/requirements-base-tools.txt \
     /build_scripts/
COPY build_scripts/requirements-tools/* /build_scripts/requirements-tools/
RUN manylinux-entrypoint /build_scripts/finalize.sh && rm -rf /build_scripts

COPY 1337-manylinux.conf /etc/ld.so.conf.d/
COPY build_scripts/install-rapids-tools.sh /build_scripts/
RUN manylinux-entrypoint /build_scripts/install-rapids-tools.sh

ENV SSL_CERT_FILE=/opt/_internal/certs.pem

# restore LD_LIBRARY_PATH back to the cuda one
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH_OLD}

CMD ["/bin/bash"]
