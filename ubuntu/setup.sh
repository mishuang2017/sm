sudo apt-get -y install openssh-server vim exuberant-ctags cscope tmux ipcalc	\
	git make build-essential flex bison libssl-dev libelf-dev		\
	ethtool tree linux-tools-generic sysstat

# For bionic bcc
sudo apt-get -y install bison build-essential cmake flex git libedit-dev	\
	llvm libclang python zlib1g-dev libelf-dev

# For Lua support
sudo apt-get -y install luajit luajit-5.1-dev 

sudo apt-get -y install netperf iperf iperf3

# For systemtap
sudo apt-get -y install libdw-dev
