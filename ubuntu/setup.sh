sudo apt-get -y install openssh-server vim exuberant-ctags cscope tmux ipcalc	\
	git make build-essential flex bison libssl-dev libelf-dev		\
	ethtool tree linux-tools-generic sysstat

# For bionic bcc
sudo apt-get -y install bison build-essential cmake flex git libedit-dev	\
	llvm python zlib1g-dev libelf-dev
sudo apt-get -y install libclang-6.0-dev

# For Lua support
sudo apt-get -y install luajit luajit-5.1-dev 

sudo apt-get -y install netperf iperf iperf3

# For systemtap
sudo apt-get -y install libdw-dev

# For binutils-gdb
sudo apt-get -y install texinfo

# For perf
sudo apt-get -y install libunwind-dev libslang2-dev binutils-dev libnuma-dev libbabeltrace-ctf-dev libiberty-dev libperl-dev
# sudo apt install openjdk-8-jdk

apt install linux-crashdump
# dpkg-reconfigure kdump-tools
# /usr/sbin/kdump-config
# /etc/default/grub.d/kdump-tools.cfg
# /etc/default/kdump-tools
# /etc/sysctl.conf
#	vm.min_free_kbytes=65536
# sysctl vm.min_free_kbytes

# For drgn
apt install -y python3-setuptools
