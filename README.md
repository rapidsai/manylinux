# manylinux

RAPIDS manylinux CUDA images for cibuildwheel in GitHub Actions.

## manylinux_2_31 based on ubuntu 20.04

The upstream [pypa/manylinux](https://github.com/pypa/manylinux) project hosts their containers on their [quay.io organization page](https://quay.io/organization/pypa). The latest official pypa/manylinux container is manylinux_2_28, based on AlmaLinux 8.

For RAPIDS projects, the AlmaLinux development environment proved challenging, lacking many development libraries compared to Ubuntu 20.04.

As a result, we added a new manylinux_2_31 platform based on Ubuntu 20.04:
* Ubuntu 20.04 is already proven capable of building RAPIDS projects in other CI environments
* Ubuntu 20.04 is an acceptable distro for a future official manylinux_2_31 image, as hinted at in the [pep600_compliance](https://github.com/mayeut/pep600_compliance) repo

The RAPIDS manylinux_2_31 container uses the nvidia/cuda-devel-ubuntu20.04 container as a base and adds some common dependencies such as the CUDA Toolkit, NCCL, and UCX.

## manylinux_2_27 based on ubuntu 18.04

Broader compatiblity

## manylinux2014 based on Centos 7

x86-only
