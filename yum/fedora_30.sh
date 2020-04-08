#!/bin/bash

yum update
yum install -y rsync ethtool \
        ctags tmux screen ncurses-devel openssl-devel readline-devel snappy-devel \
	wget tcl tcl-devel tk tk-devel git-email bc sysstat libglvnd-glx gcc-c++ bison flex make \
        numactl-devel \	
        libmnl libmnl-devel \
        openvswitch libcap-ng-devel libatomic libtool dh-autoreconf \
        texinfo	\
        python3-devel dh-autoreconf xz-devel zlib-devel lzo-devel \
        libnsl \
        pcre-devel \
	qalculate \
        clang clang-devel llvm llvm-devel llvm-static ncurses-devel \
	rpm-build kexec-tools tcpdump iperf

/mswg/release/mft/mftinstall
