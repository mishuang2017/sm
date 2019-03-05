sudo apt-get install openssh-server vim exuberant-ctags cscope tmux ipcalc	\
	git make build-essential flex bison libssl-dev libelf-dev		\
	ethtool tree

# For bionic bcc
sudo apt-get -y install bison build-essential cmake flex git libedit-dev	\
	libllvm3.7 llvm-3.7-dev libclang-3.7-dev python zlib1g-dev libelf-dev

# For Lua support
sudo apt-get -y install luajit luajit-5.1-dev 

sudo apt-get -y netperf iperf iperf3
