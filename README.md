# manylinux

RAPIDS manylinux CUDA images for cibuildwheel in GitHub Actions.

| Image | CUDA base | OS | GCC | GLIBC |
|-------|---------|---|-|-|
| [rapidsai/manylinux_2_31_x86_64](https://hub.docker.com/r/rapidsai/manylinux_2_31_x86_64)<br>[rapidsai/manylinux_2_31_aarch64](https://hub.docker.com/r/rapidsai/manylinux_2_31_aarch64) | nvidia/cuda:11.5.1-devel-ubuntu20.04 | Ubuntu 20.04 | 9.4.0 | 2.31 |
| [rapidsai/manylinux2014_x86_64](https://hub.docker.com/r/rapidsai/manylinux2014_x86_64) | nvidia/cuda:11.5.1-devel-centos7 | CentOS 7 | 10.2.1 | 2.17 |
| [rapidsai/manylinux_2_27_x86_64](https://hub.docker.com/r/rapidsai/manylinux_2_27_x86_64)<br>[rapidsai/manylinux_2_27_aarch64](https://hub.docker.com/r/rapidsai/manylinux_2_27_aarch64) | nvidia/cuda:11.5.1-devel-ubuntu18.04 | Ubuntu 18.04 | 8.4.0 | 2.27 |

The containers are built and published with the following [GitHub Action workflow](.github/workflows/build-and-publish.yml). They can also be built locally, using similar parameters from the workflow file:

Example for manylinux_2_27_x86_64:
```
LOCAL_BUILD=true \
    COMMIT_SHA="latest" \
    PLATFORM="x86_64" \
    POLICY="manylinux_2_27" \
    BASEIMAGE_OVERRIDE="nvidia/cuda:11.5.1-devel-ubuntu18.04" \
    ./build.sh
```

Example for manylinux_2_31_aarch64:
```
LOCAL_BUILD=true \
    COMMIT_SHA="latest" \
    PLATFORM="aarch64" \
    POLICY="manylinux_2_31" \
    BASEIMAGE_OVERRIDE="nvidia/cuda:11.5.1-devel-ubuntu20.04" \
    ./build.sh
```
