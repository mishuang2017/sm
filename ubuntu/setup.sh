sudo apt-get -y install openssh-server vim exuberant-ctags cscope tmux ipcalc	\
	git make build-essential flex bison libssl-dev libelf-dev		\
	ethtool tree bc sysstat

# misc, mkfs.vat, brctl
sudo apt-get install dosfstools bridge-utils

# For ovs
sudo apt-get install libcap-ng-dev openvswitch-switch dh-autoreconf

# For bionic bcc
sudo apt-get -y install bpfcc-tools linux-headers-$(uname -r)
sudo apt-get -y install bison build-essential cmake flex git libedit-dev llvm python zlib1g-dev libelf-dev libclang-dev

# For Lua support
sudo apt-get -y install luajit luajit-5.1-dev 

sudo apt-get -y install netperf iperf iperf3

# For systemtap
sudo apt-get -y install libdw-dev

# For binutils-gdb
sudo apt-get -y install texinfo

# For perf
sudo apt-get -y install libunwind-dev libslang2-dev binutils-dev libnuma-dev libbabeltrace-ctf-dev libiberty-dev libperl-dev libreadline-dev 
# sudo apt install openjdk-8-jdk

# apt install linux-crashdump
# dpkg-reconfigure kdump-tools
# /usr/sbin/kdump-config
# /etc/default/grub.d/kdump-tools.cfg
# /etc/default/kdump-tools
# /etc/sysctl.conf
#	vm.min_free_kbytes=65536
# sysctl vm.min_free_kbytes

# For crash, no termcap
sudo apt install -y libncurses5-dev zlib1g-dev

# For drgn
# must install libreadline-dev before install python 3.6
# https://www.python.org/ftp/python/3.6.9/Python-3.6.9.tgz
sudo apt install -y python3-dev liblzma-dev elfutils libbz2-dev python3-pip

# git clone https://github.com/ptesarik/libkdumpfile.git
# error: possibly undefined macro: AC_CHECK_HEADERS #2
sudo apt install -y pkg-config

# install libvirt for debian
sudo apt install -y qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils libguestfs-tools genisoimage virtinst libosinfo-bin
# sudo apt install libvirt-daemon*


# vpn
# libopenconnect5:amd64
# openconnect
# vpnc-scripts
# network-manager-openconnect        /usr/lib/NetworkManager/nm-openconnect-service
# network-manager-openconnect-gnome  /usr/lib/NetworkManager/nm-openconnect-auth-dialog
# reboot

# apt install -y *pinyin*

# No LSB modules are available.
sudo apt-get install -y lsb-core

sudo apt install -y python3-venv

# fix: ImportError: No module named pip
sudo python3 -m ensurepip
