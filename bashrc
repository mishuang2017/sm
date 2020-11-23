# Source global definitions"
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

debian=0
cloud=0
test -f /usr/bin/lsb_release && debian=1

ofed_mlx5=0
/sbin/modinfo mlx5_core -n > /dev/null 2>&1 && /sbin/modinfo mlx5_core -n | egrep "extra|updates" > /dev/null 2>&1 && ofed_mlx5=1

numvfs=17
numvfs=1
numvfs=3

# alias virc='vi /images/chrism/sm/bashrc'
# alias rc='. /images/chrism/sm/bashrc'
alias virc='vi ~/.bashrc'
alias rc='. ~/.bashrc'

[[ "$(hostname -s)" == "dev-r630-03" ]] && host_num=13
[[ "$(hostname -s)" == "dev-r630-04" ]] && host_num=14
[[ "$(hostname -s)" == "dev-chrism-vm1" ]] && host_num=15
[[ "$(hostname -s)" == "dev-chrism-vm2" ]] && host_num=16
[[ "$(hostname -s)" == "dev-chrism-vm3" ]] && host_num=17
[[ "$(hostname -s)" == "dev-chrism-vm4" ]] && host_num=18

[[ "$(hostname -s)" == "c-236-148-180-183" ]] && host_num=83
[[ "$(hostname -s)" == "c-236-148-180-184" ]] && host_num=84

function get_vf
{
	local h=$1
	local p=$2
	local n=$3

	h=$(printf "%02d" $h)
	p=$(printf "%02d" $p)
	n=$(printf "%02x" $n)

	[[ $# != 3 ]] && return

	local l=$link
	local dir1=/sys/class/net/$l
	[[ ! -d $dir1 ]] && return

	local dir2=$(readlink $dir1)
	# dir1=/sys/class/net/enp4s0f0
	# dir2=../../devices/pci0000:00/0000:00:02.0/0000:04:00.0/net/enp4s0f0
	cd $dir1

	cd ../$dir2

	cd ../../../
	# /sys/devices/pci0000:00/0000:00:02.0
	for a in $(find . -name address); do
		local mac=$(cat $a)
		if [[ "$mac" == "02:25:d0:$h:$p:$n" ]]; then
			dirname $a | xargs basename
		fi
	done
}

if (( host_num == 13 )); then
	export DISPLAY=MTBC-CHRISM:0.0
	export DISPLAY=localhost:10.0	# via vpn

	link_name=2
	link_pre=enp4s0f0n
	link=${link_pre}p0

	link2_pre=enp4s0f1n
	link2=${link2_pre}p1

# 	link=enp4s0f0

	rhost_num=14
	link_remote_ip=192.168.1.$rhost_num
	link_remote_ip2=192.168.2.$rhost_num
	link_remote_ipv6=1::$rhost_num

	link_mac=b8:59:9f:bb:31:66
	remote_mac=b8:59:9f:bb:31:82
	machine_num=1

	if (( link_name == 2 )); then
		for (( i = 0; i < numvfs; i++)); do
			eval vf$((i+1))=${link}v$i
			eval rep$((i+1))=${link_pre}pf0vf$i
		done

		for (( i = 0; i < numvfs; i++)); do
			eval vf$((i+1))_2=${link2}v$i
			eval rep$((i+1))_2=${link2_pre}pf1vf$i
		done
	fi

	if (( link_name == 1 )); then
		for (( i = 0; i < numvfs; i++)); do
			eval vf$((i+1))=${link}v$i
			eval rep$((i+1))=${link}_$i
		done
	fi

	if [[ "$USER" == "root" ]]; then
		echo 1 > /proc/sys/net/netfilter/nf_conntrack_tcp_be_liberal;
		echo 2000000 > /proc/sys/net/netfilter/nf_conntrack_max
	fi

# 	modprobe aer-inject

elif (( host_num == 14 )); then
# 	export DISPLAY=MTBC-CHRISM:0.0
	export DISPLAY=localhost:10.0

	link=enp4s0f0np0
	link2=enp4s0f1np1

	link_name=2
	link_pre=enp4s0f0n
	link=${link_pre}p0

	link2_pre=enp4s0f1n
	link2=${link2_pre}p1

# 	link=enp4s0f0
# 	link2=enp4s0f1

	rhost_num=13
	link_remote_ip=192.168.1.$rhost_num
	link_remote_ip2=192.168.2.$rhost_num
	link_remote_ipv6=1::$rhost_num

	link_mac=b8:59:9f:bb:31:82
	remote_mac=b8:59:9f:bb:31:66
	machine_num=2

	vf1=enp4s0f2
	vf2=enp4s0f3
	vf3=enp4s0f4

	for (( i = 0; i < numvfs; i++)); do
		eval vf$((i+1))=${link}v$i
# 		eval rep$((i+1))=${link}_$i
		eval rep$((i+1))=${link_pre}pf0vf$i
	done

	for (( i = 0; i < numvfs; i++)); do
		eval vf$((i+1))_2=${link2}v$i
# 		eval rep$((i+1))_2=${link2}_$i
		eval rep$((i+1))_2=${link2_pre}pf1vf$i
	done

	if [[ "$link" == "enp4s0f0" ]]; then
		for (( i = 0; i < numvfs; i++)); do
			eval vf$((i+1))=${link}v$i
			eval rep$((i+1))=${link}_$i
		done
	fi

# 	modprobe aer-inject

	if [[ "$USER" == "root" ]]; then
		echo 1 > /proc/sys/net/netfilter/nf_conntrack_tcp_be_liberal;
		echo 2000000 > /proc/sys/net/netfilter/nf_conntrack_max
	fi
elif (( host_num == 15 )); then
	link=ens9
elif (( host_num == 16 )); then
	link=ens9
elif (( host_num == 17 )); then
	link=ens9
elif (( host_num == 18 )); then
	link=ens9
elif (( host_num == 83 )); then
	link_name=1
	link=enp8s0f0
	link2=enp8s0f1
	machine_num=1

	for (( i = 0; i < numvfs; i++)); do
		eval vf$((i+1))=$(get_vf $host_num 1 $((i+1)))
		eval rep$((i+1))=${link}_$i
	done
	for (( i = 0; i < numvfs; i++)); do
		eval vf$((i+1))_2=$(get_vf $host_num 2 $((i+1)))
		eval rep$((i+1))_2=${link2}_$i
	done
	rhost_num=84
	link_remote_ip=192.168.1.$rhost_num
	cloud=1
elif (( host_num == 84 )); then
	link_name=1
	link=enp8s0f0
	link2=enp8s0f1
	machine_num=2

	for (( i = 0; i < numvfs; i++)); do
		eval vf$((i+1))=$(get_vf $host_num 1 $((i+1)))
		eval rep$((i+1))=${link}_$i
	done
	for (( i = 0; i < numvfs; i++)); do
		eval vf$((i+1))_2=$(get_vf $host_num 2 $((i+1)))
		eval rep$((i+1))_2=${link2}_$i
	done
	rhost_num=83
	link_remote_ip=192.168.1.$rhost_num
	cloud=1
fi

vni=200
vni=100
vid=5
svid=1000
vid2=6
vxlan_port=4000
vxlan_port=4789
vxlan_mac=24:25:d0:e2:00:00
ecmp=0
ports=2
ports=1

base_baud=115200
base_baud=9600

cpu_num=$(nproc)
if (( cloud == 0 )); then
	cpu_num2=$((cpu_num*2))
else
	cpu_num2=$((cpu_num-2))
fi

nfs_dir='/auto/mtbcswgwork/chrism'
if which kdump-config > /dev/null 2>&1; then
	crash_dir=$(kdump-config show | grep KDUMP_COREDIR | awk '{print $2}')
else
	crash_dir=/var/crash
fi
linux_dir=$(readlink /lib/modules/$(uname -r)/build)
images=images

# Append to history
shopt -s histappend
[[ $(hostname -s) != vnc14 ]] && shopt -s autocd
ofed=0
uname -r | grep 3.10 > /dev/null 2>&1 && ofed=1

centos=0
centos72=0
if uname -r | grep 3.10.0-327 > /dev/null 2>&1; then
	unum=327
	centos=1
	centos72=1
fi

kernel49=0
uname -r | grep 4.9 > /dev/null 2>&1 && kernel49=1

centos74=0
if uname -r | grep 3.10.0-693 > /dev/null 2>&1; then
	unum=693
	centos=1
	centos74=1
fi

jd_kernel=0
if uname -r | grep 3.10.0-693.21.3 > /dev/null 2>&1; then
	unum=693
	centos=1
	jd_kernel=1
fi

centos75=0
if uname -r | grep 3.10.0-862 > /dev/null 2>&1; then
	unum=862
	centos=1
	centos75=1
fi

centos76=0
if uname -r | grep 3.10.0-957 > /dev/null 2>&1; then
	unum=957
	centos=1
	centos76=1
fi

# if [[ "$UID" == "0" ]]; then
# 	dmidecode | grep "Red Hat" > /dev/null 2>&1
# 	rh=$?
# fi

export LC_ALL=en_US.UTF-8
# export DISPLAY=:0.0

#	 --add-kernel-support		    --upstream-libs --dpdk
# export DPDK_DIR=/images/chrism/dpdk-stable-17.11.2
export DPDK_DIR=/root/dpdk-stable-17.11.4
# export RTE_SDK=$DPDK_DIR
# export MLX5_GLUE_PATH=/lib
# export DPDK_TARGET=x86_64-native-linuxapp-gcc
# export DPDK_BUILD=$DPDK_DIR/$DPDK_TARGET
# make install T=$DPDK_TARGET DESTDIR=install
# export LD_LIBRARY_PATH=$DPDK_DIR/x86_64-native-linuxapp-gcc/lib

export CONFIG=config_chrism_cx5.sh
# export INSTALL_MOD_STRIP=1
unset CONFIG_LOCALVERSION_AUTO

link_ip=192.168.1.$host_num
link2_ip=192.168.2.$host_num
link_ipv6=1::$host_num
link2_ipv6=2::$host_num

br=br
br2=br2
vx=vxlan0
vx2=vxlan1
bond=bond0

# if [[ "$USER" == "root" ]]; then
#	if [[ "$(virt-what)" == "" && $centos72 != 1 ]]; then
#		echo 1 > /proc/sys/net/netfilter/nf_conntrack_tcp_be_liberal
#		echo 2000000 > /proc/sys/net/netfilter/nf_conntrack_max
#	fi
# fi

link_ip_vlan=1.1.1.100
link_ip_vxlan=1.1.1.200
link_ipv6_vxlan=1::200

brd_mac=ff:ff:ff:ff:ff:ff

if (( centos72 == 1 )); then
	vx_rep=dummy_4789
else
	vx_rep=vxlan_sys_$vxlan_port
fi

alias scp='scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
alias ssh='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
alias noga='/.autodirect/sw_tools/Internal/Noga/RELEASE/latest/cli/noga_manage.py'

cx5=0
function get_pci
{
# 	if [[ -e /sys/class/net/$link/device && -f /usr/sbin/lspci ]]; then
	if [[ -e /sys/class/net/$link/device ]]; then
		pci=$(basename $(readlink /sys/class/net/$link/device))
		pci_id=$(echo $pci | cut -b 6-)
		lspci -d 15b3: -nn | grep $pci_id | grep 1019 > /dev/null && cx5=1
		lspci -d 15b3: -nn | grep $pci_id | grep 1017 > /dev/null && cx5=1
		pci2=$(basename $(readlink /sys/class/net/$link2/device) 2> /dev/null)
	fi
}
get_pci

alias dpdk-test="sudo build/app/testpmd -c7 -n3 --log-level 8 --vdev=net_pcap0,iface=$link --vdev=net_pcap1,iface=$link2 -- -i --nb-cores=2 --nb-ports=2 --total-num-mbufs=2048"

# testpmd> set fwd flowgen
# testpmd> start
# testpmd> show port stats 0
alias testpmd-ovs='testpmd -l 0-8 -n 4 --socket-mem=1024,1024 -w 04:00.0 -w 04:00.1 -- -i'
alias testpmd-ovs1='testpmd -l 0-8 -n 4 --socket-mem=1024,1024 -w 04:00.3 -- -i'

alias mac1="ip l show $link | grep ether; ip link set dev $link address $link_mac;  ip l show $link | grep ether"
alias mac2="ip l show $link | grep ether; ip link set dev $link address $link_mac2; ip l show $link | grep ether"

alias vxlan6="ovs-vsctl add-port $br $vx -- set interface $vx type=vxlan options:remote_ip=$link_remote_ipv6  options:key=$vni options:dst_port=$vxlan_port"
alias vxlan1="ovs-vsctl add-port $br $vx -- set interface $vx type=vxlan options:remote_ip=$link_remote_ip  options:key=$vni options:dst_port=$vxlan_port"
alias vxlan4000="ovs-vsctl add-port $br $vx -- set interface $vx type=vxlan options:remote_ip=$link_remote_ip  options:key=$vni options:dst_port=4000"
alias vxlan4789="ovs-vsctl add-port $br $vx -- set interface $vx type=vxlan options:remote_ip=$link_remote_ip  options:key=$vni options:dst_port=4789"
alias vxlan1-2="ovs-vsctl add-port $br2 $vx2 -- set interface $vx2 type=vxlan options:remote_ip=$link_remote_ip2  options:key=$vni options:dst_port=$vxlan_port"
alias vxlan2="ovs-vsctl del-port $br $vx"
alias vx='vxlan2; vxlan1'

alias ipmirror="ifconfig $link 0; ip addr add dev $link $link_ip_vlan/16; ip link set $link up"

alias vsconfig="sudo ovs-vsctl get Open_vSwitch . other_config"
function vsconfig3
{
set -x
	ovs-vsctl get Open_vSwitch . other_config
	ovs-vsctl get Port $rep2 other_config
set +x
}
alias vsconfig-idle='ovs-vsctl set Open_vSwitch . other_config:max-idle=30000'
alias vsconfig-hw='ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"'
alias vsconfig-sw='ovs-vsctl set Open_vSwitch . other_config:hw-offload="false"'
alias vsconfig-skip_sw='ovs-vsctl set Open_vSwitch . other_config:tc-policy=skip_sw'
alias vsconfig-skip_hw='ovs-vsctl set Open_vSwitch . other_config:tc-policy=skip_hw'
alias ovs-log='sudo tail -f  /var/log/openvswitch/ovs-vswitchd.log'
alias ovs2-log=' tail -f /var/log/openvswitch/ovsdb-server.log'

alias p23="ping 1.1.1.23"
alias p6="ping6 2017::14"

alias 3.10='cd /usr/src/debug/kernel-3.10.0-327.el7/linux-3.10.0-327.el7.x86_64'
alias restart-network='/etc/init.d/network restart'

alias crash2="$nfs_dir/crash/crash -i /root/.crash //boot/vmlinux-$(uname -r).bz2"

CRASH="sudo /$images/chrism/crash/crash"
VMLINUX=$linux_dir/vmlinux
alias crash1="$CRASH -i /root/.crash $VMLINUX"
alias c=crash1

# -d8 to add debug info
if (( centos == 1 && jd_kernel == 0 )); then
	VMLINUX=/usr/lib/debug/lib/modules/3.10.0-${unum}.el7.x86_64/vmlinux
	alias c="$CRASH -i /root/.crash /usr/lib/debug/lib/modules/$(uname -r)/vmlinux"
fi

alias c0="$CRASH -i /root/.crash $crash_dir/vmcore.0 $VMLINUX"
alias c1="$CRASH -i /root/.crash $crash_dir/vmcore.1 $VMLINUX"
alias c2="$CRASH -i /root/.crash $crash_dir/vmcore.2 $VMLINUX"
alias c3="$CRASH -i /root/.crash $crash_dir/vmcore.3 $VMLINUX"
alias c4="$CRASH -i /root/.crash $crash_dir/vmcore.4 $VMLINUX"
alias c5="$CRASH -i /root/.crash $crash_dir/vmcore.5 $VMLINUX"
alias c6="$CRASH -i /root/.crash $crash_dir/vmcore.6 $VMLINUX"
alias c7="$CRASH -i /root/.crash $crash_dir/vmcore.7 $VMLINUX"
alias c8="$CRASH -i /root/.crash $crash_dir/vmcore.8 $VMLINUX"
alias c9="$CRASH -i /root/.crash $crash_dir/vmcore.9 $VMLINUX"


alias jd-ovs="del-br; br; ~chrism/bin/ct_lots_rule.sh $rep2 $rep3"

alias jd-vxlan="del-br; brx; ~chrism/bin/ct_lots_rule_vxlan.sh $rep2 $vx"
alias jd-vxlan-ttl="del-br; brx; ~chrism/bin/ct_lots_rule_vxlan-ttl.sh $rep2 $vx"

alias jd-vxlan2="~chrism/bin/ct_lots_rule_vxlan2.sh $rep2 $vx"
alias jd-ovs2="~chrism/bin/ct_lots_rule2.sh $rep2 $rep3 $rep4"
alias jd-ovs-ttl="del-br; br; ~chrism/bin/ct_lots_rule_ttl.sh $rep2 $rep3"
alias ovs-ttl="~chrism/bin/ovs-ttl.sh $rep2 $rep3"

alias pc="picocom -b $base_baud /dev/ttyS1"
alias pcu="picocom -b $base_baud /dev/ttyUSB0"

alias sw='vsconfig-sw; restart-ovs'
alias hw='vsconfig-hw; restart-ovs'

# bluefield
# mlxdump -d 81:00.0 fsdump --type=FT --no_zero
alias fsdump5="mlxdump -d $pci fsdump --type FT --gvmi=0 --no_zero=1"
alias fsdump52="mlxdump -d $pci2 fsdump --type FT --gvmi=1 --no_zero=1"

alias fsdump5="mlxdump -d $pci fsdump --type FT --gvmi=0 --no_zero"
alias fsdump52="mlxdump -d $pci2 fsdump --type FT --gvmi=1 --no_zero"

function fsdump
{
	fsdump5 > /root/1.txt
	fsdump52 > /root/2.txt
}

alias con='virsh console'
alias con1='virsh console vm1'
alias con2='virsh console vm2'
alias con3='virsh console vm3'
alias con4='virsh console vm4'
alias con5='virsh console vm5'
alias con6='virsh console vm6'
alias con7='virsh console vm7'
alias con8='virsh console vm8'

alias mount-image='mount /dev/mapper/centos74-root /mnt'
alias start1='virsh start vm1'
alias start2='virsh start vm2'
alias start3='virsh start vm3'

alias stop1='virsh destroy vm1'
alias stop2='virsh destroy vm2'
alias stop3='virsh destroy vm3'

alias start1c='virsh start vm1 --console'

alias restart1='stop1; sleep 5; start1'
alias restart2='stop2; sleep 5; start2'
alias restart2='stop3; sleep 5; start3'

alias start-all='start1; start2'
alias stop-all='stop1; stop2'
alias start-all3='start1; start2; start3'
alias stop-all3='stop1; stop2; stop3'
alias restart-all='stop-all; start-all'

alias dud='du -h -d 1'
alias dus='du -sh * | sort -h'

alias clone-git='git clone git@github.com:git/git.git'
alias clone-sflowtool='git clone https://github.com/sflow/sflowtool.git'
alias clone-gdb="git clone git://sourceware.org/git/binutils-gdb.git"
alias clone-ethtool='git clone https://git.kernel.org/pub/scm/network/ethtool/ethtool.git'
alias clone-ofed='git clone ssh://gerrit.mtl.com:29418/mlnx_ofed/mlnx-ofa_kernel-4.0.git'
alias clone-ofed5_0='git clone ssh://gerrit.mtl.com:29418/mlnx_ofed/mlnx-ofa_kernel-4.0.git --branch=mlnx_ofed_5_0'
alias clone-ofed5_1='git clone ssh://gerrit.mtl.com:29418/mlnx_ofed/mlnx-ofa_kernel-4.0.git --branch=mlnx_ofed_5_1'
alias clone-ofed5_2='git clone ssh://gerrit.mtl.com:29418/mlnx_ofed/mlnx-ofa_kernel-4.0.git --branch=mlnx_ofed_5_2'
alias clone-ofed='git clone ssh://gerrit.mtl.com:29418/mlnx_ofed/mlnx-ofa_kernel-4.0.git --branch=mlnx_ofed_5_0_2'
alias clone-ofed-bd='git clone ssh://gerrit.mtl.com:29418/mlnx_ofed/mlnx-ofa_kernel-4.0.git --branch=mlnx_ofed_4_6_3_bd'
alias clone-ofed-4.7='git clone ssh://gerrit.mtl.com:29418/mlnx_ofed/mlnx-ofa_kernel-4.0.git --branch=mlnx_ofed_4_7_3'
alias clone-ofed-4.6='git clone ssh://gerrit.mtl.com:29418/mlnx_ofed/mlnx-ofa_kernel-4.0.git --branch=mlnx_ofed_4_6_3'
alias clone-asap='git clone ssh://l-gerrit.mtl.labs.mlnx:29418/asap_dev_reg; cp ~/config_chrism_cx5.sh asap_dev_reg'
alias clone-iproute2-ct='git clone https://github.com/roidayan/iproute2 --branch=ct-one-table'
alias clone-iproute='git clone ssh://gerrit.mtl.com:29418/mlnx_ofed/iproute2'
alias clone-iproute2-upstream='git clone git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git'
alias clone-systemtap='git clone git://sourceware.org/git/systemtap.git'
alias clone-crash-upstream='git clone git@github.com:crash-utility/crash.git'
alias clone-crash='git clone https://github.com/mishuang2017/crash.git'
alias clone-sm='git clone https://github.com/mishuang2017/sm'
alias clone-bin='git clone https://github.com/mishuang2017/bin.git'
alias clone-c='git clone https://github.com/mishuang2017/c.git'
alias clone-rpmbuild='git clone git@github.com:mishuang2017/rpmbuild.git'
alias clone-ovs='git clone ssh://10.7.0.100:29418/openvswitch'
alias clone-ovs-ofed-5.2='git clone ssh://10.7.0.100:29418/openvswitch --branch=mlnx_ofed_5_2'
alias clone-ovs-upstream='git clone git@github.com:openvswitch/ovs.git'
alias clone-ovs-mishuang='git clone git@github.com:mishuang2017/ovs.git'
alias clone-ovs-ct='git clone https://github.com/roidayan/ovs --branch=ct-one-table-2.10'
alias clone-ovs-ct-one-table-2.10='git clone ssh://10.7.0.100:29418/openvswitch --branch=ct-one-table-2.10'
alias clone-ovs-ct2='git clone git@github.com:mishuang2017/ovs --branch=2.13.0-ct'
alias clone-linux='git clone ssh://chrism@l-gerrit.lab.mtl.com:29418/upstream/linux'
alias clone-linux-4.19-bd='git clone git@github.com:mishuang2017/linux --branch=4.19-bd'
alias clone-scripts='git clone ssh://chrism@l-gerrit.lab.mtl.com:29418/upstream/scripts'
alias clone-bcc='git clone https://github.com/iovisor/bcc.git'
alias clone-bpftrace='git clone https://github.com/iovisor/bpftrace'
alias clone-drgn='git clone https://github.com/osandov/drgn.git'	# pip3 install drgn
alias clone-wrk='git clone git@github.com:wg/wrk.git'
alias clone-netperf='git clone git@github.com:HewlettPackard/netperf.git'
alias pull='git pull origin master'
alias wget_teams='wget https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/teams_1.3.00.16851_amd64.deb'	# apt install ./teams_1.3.00.teams_1.3.00.16851_amd64.deb

alias clone-ubuntu-xenial='git clone git://kernel.ubuntu.com/ubuntu/ubuntu-xential.git'
alias clone-ubuntu='git clone git://kernel.ubuntu.com/ubuntu/ubuntu-bionic.git'
# https://packages.ubuntu.com/source/xenial/linux
# http://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux_4.4.0.orig.tar.gz
# http://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux_4.4.0-145.171.diff.gz

alias git-net='git remote add net git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git'
alias git-net-next='git remote add net-next git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git'
alias gg='git grep -n'

alias dmesg='dmesg -T'

# evolution, default value 1500=1.5s
alias evolution_mark_read='gsettings set org.gnome.evolution.mail mark-seen-timeout 1'

alias git-log='git log --tags --source'
alias v4.14='git checkout v4.14; git checkout -b 4.14'
alias v4.20='git checkout v4.20; git checkout -b 4.20'
alias v4.19='git checkout v4.19; git checkout -b 4.19'
alias v5.1='git checkout v5.1; git checkout -b 5.1'
alias v5.2='git checkout v5.2; git checkout -b 5.2'
alias v5.3='git checkout v5.3; git checkout -b 5.3'
alias v5.4='git checkout v5.4; git checkout -b 5.4'
alias v5.5='git checkout v5.5; git checkout -b 5.5'
alias v5.9='git checkout v5.9; git checkout -b 5.9'
alias v4.10='git checkout v4.10; git checkout -b 4.10'
alias v4.8='git checkout v4.8; git checkout -b 4.8'
alias v4.8-rc4='git checkout v4.8-rc4; git checkout -b 4.8-rc4'
alias v4.4='git checkout v4.4; git checkout -b 4.4'
alias v6000='git checkout rel-12_25_6000; git checkout -b 12_25_6000'
alias ab='rej; git am --abort'
alias gr='git add -u; git am --resolved'
alias gar='git add -A; git am --resolved'
alias gs='git status'
alias gc='git commit -a'
# alias amend='git commit --amend'
alias slog='git slog'
alias slog1='git slog -1'
alias slog2='git slog -2'
alias slog3='git slog -3'
alias slog4='git slog -4'
alias slog10='git slog -10'
alias git1='git slog v4.11.. drivers/net/ethernet/mellanox/mlx5/core/'
alias gita='git log --tags --source --author="chrism@mellanox.com"'
alias gitvlad='git log --tags --source --author="vladbu@mellanox.com"'
alias gitroi='git log --tags --source --author="roid@mellanox.com"'
alias gitpaul='git log --tags --source --author="paulb@mellanox.com"'
alias gityossi='git log --tags --source --author="yossiku@mellanox.com"'
alias gitelib='git log --tags --source --author="elibr@mellanox.com"'
alias git-linux-origin='git remote set-url origin ssh://chrism@l-gerrit.lab.mtl.com:29418/upstream/linux'
alias git-linus='git remote add linus git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git; git fetch --tags linus'
# alias git-vlad='git remote add vlad git@github.com:vbuslov/linux.git'
alias git-vlad-v5.4='git log --author=vladbu@mellanox.com --oneline v5.4..'
alias git-vlad-v5.3='git log --author=vladbu@mellanox.com --oneline v5.3..v5.4'
alias git-vlad-v5.2='git log --author=vladbu@mellanox.com --oneline v5.2..v5.3'
alias git-vlad-v5.1='git log --author=vladbu@mellanox.com --oneline v5.1..v5.2'
# git checkout v4.12

# for legacy

alias debug-esw='debugm 8; debug-file drivers/net/ethernet/mellanox/mlx5/core/eswitch.c'
alias debug-esw='debugm 8; debug-file drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c'
alias rx='rxdump -d 03:00.0 -s 0'
alias rx2='rxdump -d 03:00.0 -s 0 -m'
alias sx='sxdump -d 03:00.0 -s 0'

alias or='ssh root@10.209.32.230'
alias t="tcpdump -enn -i $link"
alias t1="tcpdump -enn -v -i $link"
alias t2="tcpdump -enn -vv -i $link"
alias t4="tcpdump -enn -vvvv -i $link"
alias ti='sudo tcpdump -enn -i'
alias mount-mswg='sudo mkdir -p /mswg; sudo mount 10.4.0.102:/vol/mswg/mswg /mswg/'
alias mount-swgwork='sudo mkdir -p /swgwork; sudo mount l1:/vol/swgwork /swgwork'

alias tvf1="tcpdump ip src host 1.1.1.14 -e -xxx -i $vf1"
alias tvf2="tcpdump ip src host 1.1.1.14 -e -xxx -i $vf2"
alias tvx="tcpdump ip dst host 1.1.13.2 -e -xxx -i $vx"

alias watch_netstat='watch -d -n 1 netstat -s'
alias w1='watch -d -n 1'
alias watch_buddy='watch -d -n 1 cat /proc/buddyinfo'
alias watch_coounters_tc_ct="watch -d -n 1 cat /sys/class/net/$link/device/counters_tc_ct"
alias watch_upcall='watch -d -n 1 ovs-appctl upcall/show'
alias watch_sar='watch -d -n 1 sar -n DEV 1'
# sar -n TCP 1
# pidstat -t -p 3794
alias ct=conntrack
alias rej='find . -name *rej -exec rm {} \;'
alias f='find . -name'

alias up="mlxlink -d $pci -p 1 -a UP"
alias down="mlxlink -d $pci -p 1 -a DN"
alias m1="mlxlink -d $pci"

alias modv='modprobe --dump-modversions'
alias ctl='sudo systemctl'
# alias dmesg='dmesg -T'
alias dmesg1='dmesg -HwT'

alias win='vncviewer 10.75.201.135:0'

# alias uperf="$nfs_dir/uperf-1.0.5/src/uperf"

alias chown-linux="sudo chown -R chrism.mtl $linux_dir"
alias chown1="sudo chown -R chrism.mtl ."
alias sb='tmux save-buffer'

alias sm="cd /$images/chrism"
alias sms="cd /$images/chrism/sm"
alias smip="cd /$images/chrism/iproute2"
alias smipu="cd /$images/chrism/iproute2-upstream"
alias smb2="cd /$images/chrism/bcc/tools"
alias smb="cd /$images/chrism/bcc/examples/tracing"
alias smk="cd /$images/chrism/sm/drgn"
alias smdo="cd ~chrism/sm/drgn/ovs"
alias d-ovs="sudo ~chrism/sm/drgn/ovs/ovs.py"
alias sk='cd /swgwork/chrism'

alias softirq="/$images/chrism/bcc/tools/softirqs.py 1"
alias hardirq="/$images/chrism/bcc/tools/hardirqs.py 5"

if [[ "$USER" == "mi" ]]; then
	kernel=$(uname -r | cut -d. -f 1-6)
	arch=$(uname -m)
fi

alias spec="cd /$images/mi/rpmbuild/SPECS"
alias sml="cd /$images/chrism/linux"
alias sml2="cd /$images/chrism/linux2"
alias sml3="cd /$images/chrism/linux3"
alias sm5="cd /$images/chrism/5.4"
alias 5c="cd /$images/chrism/5.4-ct"
alias sm-build="cdr; cd build"
alias smu="cd /$images/chrism/upstream"
alias smm="cd /$images/chrism/mlnx-ofa_kernel-4.0"
alias o5="cd /$images/chrism/ofed-5.0/mlnx-ofa_kernel-4.0"
alias o5-5.4="cd /$images/chrism/ofed-5.0/mlnx-ofa_kernel-4.0"
alias m7="cd /$images/chrism/ofed-4.7/mlnx-ofa_kernel-4.0"
alias m6="cd /$images/chrism/ofed-4.6/mlnx-ofa_kernel-4.0"
alias cd-test="cd $linux_dir/tools/testing/selftests/tc-testing/"
alias vi-action="vi $linux_dir/tools/testing/selftests/tc-testing/tc-tests/actions//tests.json"
alias vi-filter="vi $linux_dir/tools/testing/selftests/tc-testing/tc-tests/filters//tests.json"
alias smo="cd /$images/chrism/openvswitch"
alias smo2="cd /$images/chrism/ovs"
alias smo3="cd /$images/chrism/ovs_2.13"
alias smt="cd /$images/chrism/ovs-tests"
alias cfo="cd /$images/chrism/openvswitch; cscope -d"
alias ipa='ip a'
alias ipl='ip l'
alias ipal='ip a l'
alias smd='cd /usr/src/debug/kernel-3.10.0-327.el7/linux-3.10.0-327.el7.x86_64'
alias rmswp='find . -name *.swp -exec rm {} \;'
alias cd-drgn='cd /usr/local/lib64/python3.6/site-packages/drgn-0.0.1-py3.6-linux-x86_64.egg/drgn/helpers/linux/'
alias smdr="cd /$images/chrism/drgn/"

alias sm2="cd $nfs_dir"
alias smc="sm; cd crash; vi net.c"
alias smi='cd /var/lib/libvirt/images'
alias smi2='cd /etc/libvirt/qemu'

alias smn='cd /etc/sysconfig/network-scripts/'

alias bfdb='bridge fdb'
alias bfdb1='bridge fdb | grep 25'
alias vs='sudo ovs-vsctl'
alias of='sudo ovs-ofctl'
alias dp='sudo ovs-dpctl'
alias dpd='sudo ~chrism/bin/ovs-df.sh'
alias dpd-bond='dpd -m | grep -v arp | grep -v "bond0$" | grep offloaded | grep bond0'
alias dpd0='sudo ovs-dpctl dump-flows --name'
alias dpd1='sudo ovs-dpctl dump-flows --name | grep "in_port(enp4s0f0)"'
alias dpd2='sudo ovs-dpctl dump-flows --name | grep "in_port(enp4s0f0_1)"'
alias app='sudo ovs-appctl'
alias fdbs='sudo ovs-appctl fdb/show'
alias fdbi='sudo ovs-appctl fdb/show br-int'
alias fdbe='sudo ovs-appctl fdb/show br-ex'
alias fdb='of show br-int | grep addr; fdbi; of show br-ex | grep addr; fdbe'
alias fdb-br='of show br | grep addr; sudo ovs-appctl fdb/show br'
alias app1='sudo ovs-appctl dpctl/dump-flows'
alias appn='sudo ovs-appctl dpctl/dump-flows --names'
alias app-ct='sudo ovs-appctl app dpctl/dump-conntrack'

alias p1="ping $link_remote_ip"
alias p=p1
alias p2="ping $link_remote_ip2"

# tc -s filter show dev enp4s0f0_1 root
alias tcss="tc -stats filter show dev $link protocol ip parent ffff:"
alias tcss="tc -stats filter show dev $link ingress"
alias tcs2="tc filter show dev $link protocol arp parent ffff:"
alias tcs3="tc filter show dev $link protocol 802.1Q parent ffff:"

alias tcss-rep2="tc -stats filter show dev $rep2 parent ffff:"
alias tcss-rep2-ip="tc -stats filter show dev $rep2  protocol ip parent ffff:"
alias tcss-rep2-ipv6="tc -stats filter show dev $rep2  protocol ipv6 parent ffff:"
alias tcss-rep2-arp="tc -stats filter show dev $rep2  protocol arp parent ffff:"
alias rep2='tcss-rep2-ip'
alias rep2-all='tcss-rep2'

alias tcss-rep3="tc -stats filter show dev $rep3 parent ffff:"
alias tcss-rep3-ip="tc -stats filter show dev $rep3 protocol ip parent ffff:"
alias rep3='tcss-rep3-ip'

alias tcss-rep-port2="tc -stats filter show dev enp4s0f1_1 parent ffff:"
alias tcss-rep-ip-port2="tc -stats filter show dev enp4s0f1_1 protocol ip parent ffff:"

alias tcss-rep="tc -stats filter show dev $rep1 ingress"
alias tcss-rep-ip="tc -stats filter show dev $rep1 protocol ip parent ffff:"
alias tcss-rep-arp="tc -stats filter show dev $rep1 protocol arp parent ffff:"
alias rep='tcss-rep'

alias tl=tcss-link
alias tcss-link-ip="tc -stats filter show dev $link  protocol ip parent ffff:"
alias tcss-link-arp="tc -stats filter show dev $link  protocol arp parent ffff:"
alias tcss-link="tc -stats filter show dev $link parent ffff:"

alias tcss-vxlan="tc -stats filter show dev $vx_rep parent ffff:"
alias vxlan=tcss-vxlan
alias tcss-vxlan-arp="tc -stats filter show dev $vx_rep  protocol arp parent ffff:"
alias tcss-vxlan-all="tc -stats filter show dev $vx_rep ingress"

alias tcss-vx-ip="tc -stats filter show dev $vx  protocol ip parent ffff:"
alias tcss-vx-arp="tc -stats filter show dev $vx  protocol arp parent ffff:"
alias tcss-vx="tc -stats filter show dev $vx ingress"

# "tc -s filter show dev enp4s0f0_0 ingress"

alias tcs-rep="tc filter show dev $rep1 protocol ip parent ffff:"
alias tcs-arp-rep="tc filter show dev $rep1 protocol arp parent ffff:"

alias s='[[ $UID == 0 ]] && su - chrism'
alias susu='sudo su'
alias s2='su - mi'
alias s0='[[ $UID == 0 ]] && su chrism'
alias e=exit
alias vnc2='ssh chrism@10.7.2.14'
alias vnc='ssh chrism@10.75.68.111'
alias netstat1='netstat -ntlp'

alias 13='ssh -X root@10.75.205.13'
alias 14='ssh -X root@10.75.205.14'
alias i1='ssh -X root@10.130.41.1'
alias i2='ssh -X root@10.130.42.1'
alias i3='ssh -X root@10.130.43.1'

alias 15='ssh root@10.75.205.15'
alias vm1=15
alias 16='ssh root@10.75.205.16'
alias vm2=16
alias 17='ssh root@10.75.205.17'
alias vm3=17
alias 18='ssh root@10.75.205.18'
alias vm4=18
alias 9='ssh root@10.75.205.9'
alias vm5=9
alias 8='ssh root@10.75.205.8'
alias vm6=8

alias b3='lspci -d 15b3: -nn'

alias ..='cd ..'
alias ...='cd ../..'

alias lc='ls --color'
alias l='ls -lh'
alias ll='ls -lh'
alias df='df -h'

alias vi='vim'
alias vd='vimdiff'
alias vipr='vi ~/.profile'
alias virca='vi ~/.bashrc*'
alias visc='vi ~/.screenrc'
alias vv='vi ~/.vimrc'
alias vis='vi ~/.ssh/known_hosts'
alias vin='vi ~/sm/notes.txt'
alias vij='vi ~/Documents/jd.txt'
alias vi1='vi ~/Documents/ovs.txt'
alias vi2='vi ~/Documents/mirror.txt'
alias vip='vi ~/Documents/private.txt'
alias viperf='vi ~/Documents/perf.txt'
alias vime='sudo vim /boot/grub/menu.lst'
alias vig='sudo vim /boot/grub2/grub.cfg'
alias vig1='sudo vim /boot/grub/grub.conf'
alias vig2='sudo vim /etc/default/grub'
alias viu="vi $nfs_dir/uperf-1.0.5/workloads/netperf.xml"
alias vit='vi ~/.tmux.conf'
alias vic='vi ~/.crash'
alias viu='vi /etc/udev/rules.d/82-net-setup-link.rules'
alias vigdb='vi ~/.gdbinit'

alias   vi_sample="vi drivers/net/ethernet/mellanox/mlx5/core/en/tc_sample.c drivers/net/ethernet/mellanox/mlx5/core/en/tc_sample.h "
alias       vi_ct="vi drivers/net/ethernet/mellanox/mlx5/core/en/tc_ct.c drivers/net/ethernet/mellanox/mlx5/core/en/tc_ct.h "
alias      vi_cts="vi drivers/net/ethernet/mellanox/mlx5/core/en/tc_ct.c drivers/net/ethernet/mellanox/mlx5/core/en/tc_sample.c \
	              drivers/net/ethernet/mellanox/mlx5/core/en/tc_ct.h drivers/net/ethernet/mellanox/mlx5/core/en/tc_sample.h"
alias  vi_mod_hdr='vi drivers/net/ethernet/mellanox/mlx5/core/en/mod_hdr.c '
alias    vi_vport="vi drivers/net/ethernet/mellanox/mlx5/core/esw/vporttbl.c "
alias vi_offloads="vi drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c "
alias      vi_esw="vi drivers/net/ethernet/mellanox/mlx5/core/eswitch.h "
alias  vi_mapping='vi drivers/net/ethernet/mellanox/mlx5/core/en/mapping.c drivers/net/ethernet/mellanox/mlx5/core/en/mapping.h '
alias   vi_chains="vi drivers/net/ethernet/mellanox/mlx5/core/lib/fs_chains.c drivers/net/ethernet/mellanox/mlx5/core/lib/fs_chains.h "
alias    vi_en_tc="vi drivers/net/ethernet/mellanox/mlx5/core/en_tc.c "

alias vi_esw2="vi include/linux/mlx5/eswitch.h "

alias vi_netdev-offload-tc="vi lib/netdev-offload-tc.c"
alias vi-tc="vi lib/netdev-offload-tc.c"
alias vi-dpdk="vi lib/netdev-offload-dpdk.c"
alias vi_netdev-offload="vi lib/netdev-offload.c"
alias vi_dpif-netlink="vi lib/dpif-netlink.c"
alias vi_ovs_in='vi utilities/ovs-kmod-ctl.in'

alias vi_errno='vi include/uapi/asm-generic/errno.h '

alias vi_act_ct='vi net/sched/act_ct.c '


alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias ta='type -all'
# alias grep='grep --color=auto'
alias h='history'
alias screen='screen -h 1000'
alias path='echo -e ${PATH//:/\\n}'
alias x=~chrism/bin/x.py
alias cf=" cscope -d"
alias cfm="smm; cscope -d"
alias cf2='cd /auto/mtbcswgwork/chrism/iproute2; cscope -d'
alias cf3='sm3; cscope -d'
alias cfc='cd /usr/src/debug/*/*; cscope -d'

alias cd-download='cd /cygdrive/c/Users/chrism/Downloads'
alias cd-doc='cd /cygdrive/c/Users/chrism/Documents'
alias cdr="cd /lib/modules/$(uname -r)"
alias cd-swg='cd /swgwork/chrism'

alias nc-server='nc -l -p 80 < /dev/zero'
alias nc-client='nc localhost 80 > /dev/null'
alias nc-client='nc 1.1.1.1 80 > /dev/null'
alias nc-client="nc 192.168.1.$rhost_num 80 > /dev/null"

# password is windows password
alias mount-setup='mkdir -p /mnt/setup; mount  -o username=chrism //10.200.0.25/Setup /mnt/setup'


alias qlog='less /var/log/libvirt/qemu/vm1.log'
# alias vd='virsh dumpxml vm1'
alias simx='/opt/simx/bin/manage_vm_simx_support.py -n vm2'

alias vfs99="mlxconfig -d $pci set SRIOV_EN=1 NUM_OF_VFS=99"
alias vfs127="mlxconfig -d $pci set SRIOV_EN=1 NUM_OF_VFS=127"
alias vfs63="mlxconfig -d $pci set SRIOV_EN=1 NUM_OF_VFS=63"
alias vfs32="mlxconfig -d $pci set SRIOV_EN=1 NUM_OF_VFS=32"
alias vfs16="mlxconfig -d $pci set SRIOV_EN=1 NUM_OF_VFS=16"
alias vfs2="mlxconfig -d $pci2 set SRIOV_EN=1 NUM_OF_VFS=4"
alias vfq="mlxconfig -d $pci q"
alias vfq2="mlxconfig -d $pci2 q"
alias vfsm="mlxconfig -d $linik_bdf set NUM_VF_MSIX=16"
alias vfsm="mlxconfig -d $pci set NUM_VF_MSIX=30"

alias tune1="ethtool -C $link adaptive-rx off rx-usecs 64 rx-frames 128 tx-usecs 64 tx-frames 32"
alias tune2="ethtool -C $link adaptive-rx on"
alias tune3="ethtool -c $link"

alias lsblk_all='lsblk -o name,label,partlabel,mountpoint,size,uuid'

ETHTOOL=/images/chrism/ethtool/ethtool
function ethtool-rxvlan-off
{
	$ETHTOOL -k $link | grep rx-vlan-offload
	$ETHTOOL -K $link rxvlan off
	$ETHTOOL -k $link | grep rx-vlan-offload
}

alias eoff=ethtool-rxvlan-off

function ethtool-rxvlan-on
{
	$ETHTOOL -k $link | grep rx-vlan-offload
	$ETHTOOL -K $link rxvlan on
	$ETHTOOL -k $link | grep rx-vlan-offload
}

alias restart-virt='systemctl restart libvirtd.service'

export PATH=$PATH:~/bin
export PATH=/usr/local/bin:/usr/local/sbin/:/usr/bin/:/usr/sbin:/bin/:/sbin:~/bin
# export PATH=$PATH:/images/chrism/dpdk-stable-17.11.2/install
export EDITOR=vim
export TERM=xterm
[[ "$HOSTNAME" == "bc-vnc02" ]] && export TERM=screen
[[ "$HOSTNAME" == "vnc14.mtl.labs.mlnx" ]] && export TERM=screen
unset PROMPT_COMMAND

n_time=20
m_msg=64000
netperf_ip=192.168.1.13
alias np1="netperf -H $netperf_ip -t TCP_STREAM -l $n_time -- m $m_msg -p 12865 &"
alias np3="ip netns exec n1 netperf -H 1.1.1.13 -t TCP_STREAM -l $n_time -- m $m_msg -p 12865 &"
alias np4="ip netns exec n1 netperf -H 1.1.1.13 -t TCP_STREAM -l $n_time -- m $m_msg -p 12866 &"
alias np5="ip netns exec n1 netperf -H 1.1.1.13 -t TCP_STREAM -l $n_time -- m $m_msg -p 12867 &"

alias sshcopy='ssh-copy-id -i ~/.ssh/id_rsa.pub'

# ct + snat with br-int and br-ex and pf is in br-ex without vxlan
# use arp responder to get arp reply
# connection will be aborted
alias r9a='restart-ovs; sudo ~chrism/bin/test_router9-ar.sh; enable-ovs-debug'

# ct + snat with br-int and br-ex and pf is in br-ex without vxlan
# configure ip address on br-ex
alias r9='restart-ovs; sudo ~chrism/bin/test_router9-orig.sh; enable-ovs-debug'

alias r92='restart-ovs; sudo ~chrism/bin/test_router9-test2.sh; enable-ovs-debug'
alias rx='restart-ovs; sudo ~chrism/bin/test_router-vxlan.sh; enable-ovs-debug'
alias baidu='del-br; sudo ~chrism/bin/test_router-baidu.sh; enable-ovs-debug'	# vm2 underlay
alias dnat-no-ct='restart-ovs; sudo ~chrism/bin/test_router-dnat.sh; enable-ovs-debug'	# dnat
alias dnat-ct='del-br; sudo ~chrism/bin/test_router-dnat-ct.sh; enable-ovs-debug'	# dnat
alias dnat='del-br; sudo ~chrism/bin/test_router-dnat-ct-new.sh; enable-ovs-debug'	# dnat
alias dnat-trex='del-br; sudo ~chrism/bin/test_router-dnat-trex.sh; enable-ovs-debug'	# dnat
alias rx2='restart-ovs; sudo ~chrism/bin/test_router-vxlan2.sh; enable-ovs-debug'
alias r9t='restart-ovs; sudo ~chrism/bin/test_router9-test.sh; enable-ovs-debug'

alias r8='restart-ovs; sudo ~chrism/bin/test_router8.sh; enable-ovs-debug'	# ct + snat with br-int and br-ex and pf is not in br-ex, using iptable with vxlan
alias r7='restart-ovs; bru; sudo ~chrism/bin/test_router7.sh; enable-ovs-debug'	# ct + snat with more recircs
alias r6='sudo ~chrism/bin/test_router6.sh'	# ct + snat with Yossi's script for VF
alias r5='sudo ~chrism/bin/test_router5.sh'	# ct + snat with Yossi's script for PF
alias dnat2='sudo ~chrism/bin/dnat.sh'		# dnat only
alias r52='sudo ~chrism/bin/test_router5-2.sh'	# ct + snat with Yossi's script for PF, enhanced
alias r4='sudo ~chrism/bin/test_router4.sh'	# ct + snat, can't offload
alias r3='sudo ~chrism/bin/test_router3.sh'	# ct + snat, can't offload
alias r2='sudo ~chrism/bin/test_router2.sh'	# snat, can offload
alias r1='sudo ~chrism/bin/test_router.sh'	# veth arp responder

# single port and one IP address

# vm1 ip and vf1 ip and remote ip are in same subnet, create a linux bridge
alias bd1='sudo ~chrism/bin/single-port.sh; enable-ovs-debug'

alias bd2='sudo ~chrism/bin/single-port2.sh; enable-ovs-debug'	# dnat

# don't create linux bridge, use tc
alias bd3='sudo ~chrism/bin/single-port3.sh; enable-ovs-debug'

corrupt_dir=corrupt_lat_linux
alias cd-corrupt="cd /labhome/chrism/sm/prg/c/$corrupt_dir"
alias cd-netlink="cd /labhome/chrism/sm/prg/c/my_netlink2"
alias cd-mnl="cd /labhome/chrism/prg/sm/c/libmnl_genl2"
alias vi-corrupt="cd /labhome/chrism/sm/prg/c/$corrupt_dir; vi corrupt.c"
alias corrupt="/labhome/chrism/sm/prg/c/$corrupt_dir/corrupt"

[[ $UID == 0 ]] && echo 2 > /proc/sys/fs/suid_dumpable

# ================================================================================

function ip1
{
	local l=$link
	ip addr flush $l
	ip addr add dev $l $link_ip/24
	ip addr add $link_ipv6/64 dev $l
	ip link set $l up
}

function ip8
{
	local l=$link
	ip addr flush $l
	ip addr add dev $l 8.9.10.11/24
	ip link set $l up
	ip l d vxlan0 2> /dev/null
}

function ip200
{
	local l=$link
	ip addr flush $l
	ip addr add dev $l 1.1.1.200/16
	ip link set $l up
}

function ip2
{
	local l=$link2
	ip addr flush $l
	ip addr add dev $l $link2_ip/24
	ip addr add $link2_ipv6/64 dev $l
	ip link set $l up
}

function core
{
	ulimit -c unlimited
	echo "/tmp/core-%e-%p" > /proc/sys/kernel/core_pattern
	echo 2 > /proc/sys/fs/suid_dumpable
}

# coredumpctl gdb /usr/local/bin/bpftrace

function core-enable
{
	mkdir -p /tmp/cores
	chmod a+rwx /tmp/cores
	echo 2 > /proc/sys/fs/suid_dumpable
	echo "/tmp/cores/core.%e.%p.%h.%t" > /proc/sys/kernel/core_pattern
}

function vlan
{
	[[ $# != 3 ]] && return
	local link=$1 vid=$2 ip=$3 vlan=vlan$2

	modprobe 8021q
	ifconfig $link 0
	ip link add link $link name $vlan type vlan id $vid
	ip link set dev $vlan up
	ip addr add $ip/16 brd + dev $vlan
	ip addr add $link_ipv6/64 dev $vlan
}

alias vlan1="vlan $link $vid $link_ip"
alias vlan6="vlan $link $vid2 $link_ip"

function call
{
set -x
#	/bin/rm -f cscope.out > /dev/null;
#	/bin/rm -f tags > /dev/null;
#	cscope -R -b -k -q &
	cscope -R -b -k &
	ctags -R

set +x
}

function xall
{
	time make tags ARCH=x86 &
	time make cscope ARCH=x86
}

function cone
{
set -x
#	/bin/rm -f cscope.out > /dev/null;
#	/bin/rm -f tags > /dev/null;
#	cscope -R -b -k -q &
	time cscope -R -b &
	time ctags -R
set +x
}

# alias cu='time cscope -R -b -k'

function greps
{
	[[ $# != 1 ]] && return
#	grep include -Rn -e "struct $1 {" | sed 's/:/\t/'
	grep include -Rn -e "struct $1 {"
}

function ln-profile
{
	mv ~/.bashrc bashrc.orig
	ln -s ~chrism/.bashrc
	ln -s ~chrism/.vim
	ln -s ~chrism/.vimrc
	ln -s ~chrism/.profile
	ln -s ~chrism/.screenrc
	ln -s ~chrism/.tmux.conf
	ln -s ~chrism/.crash
}

function create-images
{
	mkdir -p /images/chrism
	chown chrism.mtl /images/chrism
}

function cloud_setup
{
	mkdir -p /images/chrism
	chown chrism.mtl /images/chrism

	yum install -y cscope tmux ctags rsync grubby iperf3 htop

	if ! test -f ~/.tmux.conf; then
		mv ~/.bashrc bashrc.orig
		ln -s ~chrism/.bashrc
		ln -s ~chrism/.tmux.conf
		ln -s ~chrism/.vimrc
		ln -s ~chrism/.vim
	fi

	yum -y install python3-devel dh-autoreconf xz-devel zlib-devel lzo-devel bzip2-devel
	yum_bcc
}

function cloud_install
{
	sm
	clone-drgn
	cd drgn
	sudo ./setup.py build
	sudo ./setup.py install

	clone-bcc
	install_bcc
}

function cloud_ofed_cp
{
	cp -r /swgwork/chrism/mlnx-ofa_kernel-4.0 /images/chrism
}

function bind5
{
set -x
	[[ $# != 1 ]] && return

	bdf=$(basename `readlink /sys/class/net/$link/device/virtfn$1`)
	echo $bdf
	echo $bdf > /sys/bus/pci/drivers/mlx5_core/bind
set +x
}

# start from 0
function unbind5
{
set -x
	[[ $# != 1 ]] && return

	bdf=$(basename `readlink /sys/class/net/$link/device/virtfn$1`)
	echo $bdf
	echo $bdf > /sys/bus/pci/drivers/mlx5_core/unbind
set +x
}
# alias vfs="cat /sys/class/net/$link/device/sriov_totalvfs"

# alias on-sriov1="echo $numvfs > /sys/devices/pci0000:00/0000:00:02.0/0000:04:00.0/sriov_numvfs"
# alias on-sriov2="echo $numvfs > /sys/devices/pci0000:00/0000:00:02.0/0000:04:00.1/sriov_numvfs"
alias on-sriov="echo $numvfs > /sys/class/net/$link/device/sriov_numvfs"
alias on-sriov2="echo $numvfs > /sys/class/net/$link2/device/sriov_numvfs"
alias on1='on-sriov; set_mac 1; un; ip link set $link vf 0 spoofchk on'
alias un2="unbind_all $link2"
alias off-sriov="echo 0 > /sys/devices/pci0000:00/0000:00:02.0/0000:04:00.0/sriov_numvfs"

function off-sriov2
{
	echo 0 > /sys/devices/pci0000:00/0000:00:02.0/0000:04:00.0/sriov_numvfs &
	echo 0 > /sys/devices/pci0000:00/0000:00:02.0/0000:04:00.0/sriov_numvfs
}

function bind_all
{
	echo
	echo "start bind_all /sys/bus/pci/drivers/mlx5_core/bind"
	local l=$1
	for (( i = 0; i < numvfs; i++)); do
		bdf=$(basename `readlink /sys/class/net/$l/device/virtfn$i`)
		echo "vf${i} $bdf"
		echo $bdf > /sys/bus/pci/drivers/mlx5_core/bind
	done
	echo "end bind_all"
}
alias bi="bind_all $link"
alias bi2="bind_all $link2"

function unbind_all
{
	local l=$1
	echo
	echo "start unbind_all /sys/bus/pci/drivers/mlx5_core/unbind"
	for (( i = 0; i < numvfs; i++)); do
		vf_bdf=$(basename `readlink /sys/class/net/$l/device/virtfn$i`)
		echo "vf${i} $vf_bdf"
		echo $vf_bdf > /sys/bus/pci/drivers/mlx5_core/unbind
	done
	echo "end unbind_all"
}
alias un="unbind_all $link"
alias un2="unbind_all $link2"

function off_test
{
	for i in 1 2 3 4; do
		echo 0 > /sys/class/net/$link/device/sriov_numvfs &
	done
}

function off_all
{
	local l
#	for l in $link; do
	for l in $link $link2; do
		[[ ! -d /sys/class/net/$l ]] && continue
		n=$(cat /sys/class/net/$l/device/sriov_numvfs)
		echo "$l has $n vfs"
		for (( i = 0; i < $n; i++)); do
			bdf=$(basename `readlink /sys/class/net/$l/device/virtfn$i`)
			echo $bdf
			echo $bdf > /sys/bus/pci/drivers/mlx5_core/unbind
		done
		if (( n != 0 )); then
			echo 0 > /sys/class/net/$l/device/sriov_numvfs
		fi
	done
#	if (( ofed == 1)); then
#		echo legacy > /sys/kernel/debug/mlx5/$pci/compat/mode 2 > /dev/null || echo "legacy"
#	fi
}

alias off=off_all

function off0
{
	local l=$link
	[[ $# == 1 ]] && l=$1
	echo 0 > /sys/class/net/$l/device/sriov_numvfs
}

function off_pci
{
	cd /sys/devices/pci0000:00/0000:00:02.0/0000:04:00.0
	echo 0 > sriov_numvfs
	cd -
}

function set-switchdev
{
set -x
	devlink dev eswitch show pci/$pci
	if [[ $# == 0 ]]; then
		devlink dev eswitch set pci/$pci mode switchdev
	fi
	if [[ $# == 1 && "$1" == "off" ]]; then
		devlink dev eswitch set pci/$pci mode legacy
	fi
	devlink dev eswitch show pci/$pci
set +x
}
alias dev=set-switchdev

function dev2
{
set -x
	devlink dev eswitch show pci/$pci2
	if [[ $# == 0 ]]; then
		devlink dev eswitch set pci/$pci2 mode switchdev
	fi
	if [[ $# == 1 && "$1" == "off" ]]; then
		devlink dev eswitch set pci/$pci2 mode legacy
	fi
	devlink dev eswitch show pci/$pci
set +x
}


function inline-mode
{
set -x
	bdf=$(basename `readlink /sys/class/net/$link/device`)
#	devlink dev eswitch show pci/$bdf mode
#	devlink dev eswitch show pci/$bdf inline-mode
	devlink dev eswitch set pci/$bdf inline-mode transport
set +x
}

alias tcq="tc -s qdisc show dev"
alias tcq1="tc -s qdisc show dev $link"

function drop_tc
{
	tc filter add dev ${link}_0 protocol ip parent ffff: \
		flower \
		skip_sw \
		dst_mac 02:25:d0:e2:18:50 \
		src_mac 02:25:d0:e2:18:51 \
		action drop
}

function ovs-drop
{
# 	ovs-ofctl add-flow br-int "table=0,in_port=$rep2,actions=drop"
	ovs-ofctl add-flow br-ex "table=0,in_port=$link,actions=drop"
}

function tc-drop
{
	TC=/$images/chrism/iproute2/tc/tc

	$TC qdisc del dev $link ingress
	ethtool -K $link hw-tc-offload on 
	$TC qdisc add dev $link ingress 

	tc filter add dev $link protocol ip parent ffff: \
		flower \
		skip_sw \
		dst_mac $link_mac \
		src_mac $remote_mac \
		action drop
}

# ovs-ofctl add-flow br -O openflow13 "in_port=2,dl_type=0x86dd,nw_proto=58,icmp_type=128,action=set_field:0x64->tun_id,output:5"

alias ofd="sudo ovs-ofctl dump-flows $br --color"
alias ofdi="sudo ovs-ofctl dump-flows br-int --color"
alias ofde="sudo ovs-ofctl dump-flows br-ex --color"
alias ofd2="sudo ovs-ofctl dump-flows br2 --color" 

function ofi
{
	ovs-ofctl dump-flows br-int table=$1 --color
}

alias drop3="ovs-ofctl add-flow $br 'nw_dst=1.1.3.2 action=drop'"
alias del3="ovs-ofctl del-flows $br 'nw_dst=1.1.3.2'"

alias drop1="ovs-ofctl add-flow $br 'nw_src=192.168.1.1 action=drop'"
alias normal1="ovs-ofctl add-flow $br 'nw_src=192.168.1.1 action=normal'"

alias drop2="ovs-ofctl add-flow $br 'nw_src=192.168.1.2 action=drop'"
alias normal2="ovs-ofctl add-flow $br 'nw_src=192.168.1.3 action=normal'"

mac1=02:25:d0:14:01:04
alias dropm="ovs-ofctl add-flow $br 'dl_dst=02:25:d0:14:01:04  action=drop'"
alias  delm="ovs-ofctl add-flow $br 'dl_dst=02:25:d0:14:01:04	action=drop'"
alias normalm="ovs-ofctl add-flow $br 'dl_dst=24:8a:07:88:27:9a  action=normal'"
alias normalm="ovs-ofctl add-flow $br 'dl_dst=24:8a:07:88:27:9a  table=0,priority=10,action=normal'"
alias delm="ovs-ofctl del-flows $br dl_dst=$mac1"

#     ovs-ofctl add-flow $BR "table=0, in_port=2, dl_type=0x0806, nw_dst=192.168.0.1, actions=load:0x2->NXM_OF_ARP_OP[], move:NXM_OF_ETH_SRC[]->NXM_OF_ETH_DST[], mod_dl_src:${MAC}, move:NXM_NX_ARP_SHA[]->NXM_NX_ARP_THA[], move:NXM_OF_ARP_SPA[]->NXM_OF_ARP_TPA[], load:0x248a07ad7799->NXM_NX_ARP_SHA[], load:0xc0a80001->NXM_OF_ARP_SPA[], in_port"

alias d="of dump-flows $br"
function of1
{
	[[ $# != 1 ]] && return
	restart-ovs
	num=$1
set -x
	for i in $(seq 10); do
#		of add-flow $br "table=0, in_port=1, dl_type=0x800, dl_dst=02:25:d0:14:01:03, tcp, nw_src=1.1.1.22, nw_dst=1.1.1.23, tp_src=$((num+i*2+2)), tp_dst=5201, actions=output:2"
		of add-flow $br "table=0, in_port=1, dl_type=0x800, dl_dst=02:25:d0:14:01:03, tcp, nw_src=1.1.1.22, tp_src=$((num+i*2+2)), tp_dst=5201, actions=output:2"
	done
set +x
	of dump-flows $br
}

# alias of1="of add-flow $br 'table=0, in_port=1, dl_type=0x800, dl_dst=02:25:d0:14:01:03, tcp, nw_src=1.1.1.22, nw_dst=1.1.1.23, tp_src=33304, tp_dst=5201, actions=output:3,2'"

alias make_core='make M=drivers/net/ethernet/mellanox/mlx5/core'

alias stap='/usr/local/bin/stap --all-modules -v'
stap_str_common="--all-modules -d /usr/sbin/ovs-vswitchd -d /usr/sbin/tc -d /usr/bin/ping -d /usr/sbin/ip -d /sbin/udevadm"
if (( ofed == 1 || kernel49 == 1 )); then
	stap_str="$stap_str_common -d /usr/lib64/libc-2.17.so -d /usr/lib64/libpthread-2.17.so"
	STAP="/usr/local/bin/stap -v"
elif (( debian == 1 )); then
	stap_str="$stap_str_common -d /lib/x86_64-linux-gnu/libc-2.27.so -d /lib/x86_64-linux-gnu/libpthread-2.27.so"
	STAP="/usr/local/bin/stap -v"
fi

# stap_str="-d /usr/lib64/libpthread-2.17.so -d //lib/modules/3.10.0-862.2.3.el7.x86_64.debug/extra/mlnx-ofa_kernel/drivers/infiniband/hw/mlx5/mlx5_ib.ko -d /usr/lib64/libibverbs.so.1.1.16.0	-d /usr/lib64/libmlx5.so.1.3.16.0  -d /images/chrism/dpdk-18.05/build/app/testpmd"

# make oldconfig
# make prepare

alias sta="$STAP $stap_str -DDEBUG_UNWIND"
alias sta-usr="/usr/bin/stap -v $stap_str"
function stm
{
	dir=/root/stap
	mkdir -p $dir

	if [[ $# == 1 ]]; then
		module=mlx5_core
		function=$1
		file=$dir/$1.stp
	elif [[ $# == 2 ]]; then
		module=$1
		function=$2
		file=$dir/$2.stp
	else
		return
	fi

	cat << EOF > $file
#!$STAP
global start
function timestamp:long() { return gettimeofday_us() - start }
probe begin { start = gettimeofday_us() }
global n = 1;

global i=0;
probe module("$module").function("$function")
{
	if ((execname() == argv_1) || argv_1 == "") {
		print_backtrace()
		printf("parms: %s\n", \$\$parms);
		printf("execname: %s\n", execname());
		printf("ts: %d, %d\n", timestamp()/1000000, n++);
		print_ubacktrace()
		printf("%d\n", i++);
	}
}
EOF

set -x
	cat $file
	cd $dir
	chmod +x $file
	$STAP -k $stap_str $file
set +x
}

function stmr
{
	dir=/root/stap
	mkdir -p $dir

	if [[ $# == 1 ]]; then
		module=mlx5_core
		function=$1
		file=$dir/$1.stp
	elif [[ $# == 2 ]]; then
		module=$1
		function=$2
		file=$dir/$1.stp
	else
		return
	fi

	cat << EOF > $file
#!$STAP
/* global start */
/* function timestamp:long() { return gettimeofday_us() - start } */
/* probe begin { start = gettimeofday_us() } */

/* global i=0; */
probe module("$module").function("$function").return
{
/*	print_backtrace() */
/*	printf("execname: %s\n", execname()); */
/*	printf("ts: %d\n", timestamp() / 1000000); */
/*	print_ubacktrace() */
/*	printf("%d\n", i++); */
	printf("%x\t%d\n", \$return, \$return);
}
EOF

set -x
	cat $file
	cd $dir
	chmod +x $file
	$STAP -k $stap_str $file
set +x
}

function st
{
	[[ $# != 1 ]] && return

	dir=/root/stap
	mkdir -p $dir
	file=$dir/$1.stp


	mod=$(grep -w $1 /proc/kallsyms | sed -n '1p' | awk '{print $4}' | tr -d ] | tr -d [)
	echo $mod

	if [[ "$mod" == "" ]]; then
		cat << EOF > $file
#!$STAP

global start
function timestamp:long() { return gettimeofday_us() - start }
probe begin { start = gettimeofday_us() }
global n = 1;

probe kernel.function("$1")
{
	if ((execname() == argv_1) || argv_1 == "") {
		print_backtrace()
		printf("parms: %s\n", \$\$parms);
		printf("execname: %s\n", execname());
		printf("ts: %d, %d\n", timestamp()/1000000, n++);
		print_ubacktrace()
		printf("\n");
	}
}
EOF
	else
		cat << EOF > $file
#!$STAP

global start
function timestamp:long() { return gettimeofday_us() - start }
probe begin { start = gettimeofday_us() }
global n = 1;

probe module("$mod").function("$1")
{
	if ((execname() == argv_1) || argv_1 == "") {
		print_backtrace()
		printf("parms: %s\n", \$\$parms);
		printf("execname: %s\n", execname());
		printf("ts: %d, %d\n", timestamp()/1000000, n++);
		print_ubacktrace()
		printf("\n");
	}
}
EOF
	fi

set -x
	cat $file
	cd $dir
	chmod +x $file
	$STAP -k $stap_str $file
set +x
}

function str
{
	dir=/root/stap
	mkdir -p $dir
	file=$dir/$1.stp

	if [[ $# == 2 ]]; then
		mod=$1
		fun=$2
		file=$dir/$2.stp
	fi
	if [[ $# == 1 ]]; then
		file=$dir/$1.stp
		fun=$1
	fi


	[[ $# == 1 ]] && {
		mod=$(grep -w $1 /proc/kallsyms | sed -n '1p' | awk '{print $4}' | tr -d ] | tr -d [)
		echo $mod
	}

	if [[ "$mod" == "" ]]; then
		cat << EOF > $file
#!$STAP

global start
function timestamp:long() { return gettimeofday_us() - start }
probe begin { start = gettimeofday_us() }
global n = 1;

probe kernel.function("$fun").return
{
	print_backtrace()
	printf("%x\t%d\t", \$return, \$return);
	printf("ts: %d, %d\n", timestamp()/1000000, n++);
}
EOF
	else
		cat << EOF > $file
#!/usr/local/bin/stap -v
 
global start
function timestamp:long() { return gettimeofday_us() - start }
probe begin { start = gettimeofday_us() }
global n = 1;

probe module("$mod").function("$fun").return
{
	print_backtrace()
	printf("%x\t%d\n", \$return, \$return);
	printf("ts: %d, %d\n", timestamp()/1000000, n++);
}
EOF
	fi

set -x
	cat $file
	cd $dir
	chmod +x $file
	$STAP -k $stap_str $file
set +x
}

function stap_test
{
	stap -ve 'probe begin { log("hello world") exit () }'
}

alias mlx5="cd $linux_dir/drivers/net/ethernet/mellanox/mlx5/core"
alias mlx2="cd $linux_dir/include/linux/mlx5"
alias mlx5="cd drivers/net/ethernet/mellanox/mlx5/core"
alias mlx2="cd include/linux/mlx5"
alias e1000e="cd drivers/net/ethernet/intel/e1000e"

function buildm
{
	module=mlx5_core;
	driver_dir=drivers/net/ethernet/mellanox/mlx5/core
	make M=$driver_dir -j
}

function mlx5_clean
{
	driver_dir=drivers/net/ethernet/mellanox/mlx5/core
	cd $linux_dir;
	make M=$driver_dir clean
}

function mybuild
{
	(( $UID == 0 )) && return
	test -f Kconfig || return
set -x; 
	module=mlx5_core;
	driver_dir=drivers/net/ethernet/mellanox/mlx5/core
	cd $linux_dir;
	make M=$driver_dir -j W=1 || {
# 	make M=$driver_dir -j C=2 || {
		make M=$driver_dir -j W=1 > /tmp/1.txt 2>& 1
		set +x
		return
	}

	if [[ $# != 0 ]]; then
		set +x
		return
	fi

	src_dir=$linux_dir/$driver_dir
	sudo /bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/$driver_dir

	sudo modprobe -r mlx5_ib
	sudo modprobe -r mlx5_core
	sudo modprobe -v mlx5_core
set +x
}

function mybuild_ib
{
set -x; 
	(( $UID == 0 )) && return
	module=mlx5_ib;
	driver_dir=drivers/infiniband/hw/mlx5
	cd $linux_dir;
	make M=$driver_dir -j || {
		set +x
		return
	}
	src_dir=$linux_dir/$driver_dir
	sudo /bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/$driver_dir
#	make modules_install -j

	sudo modprobe -r mlx5_ib
	sudo modprobe -r mlx5_core
	sudo modprobe -v mlx5_core

#	cd $src_dir;
#	make CONFIG_MLX5_CORE=m -C $linux_dir M=$src_dir modules -j;
#	/bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/drivers/net/ethernet/mellanox/mlx5/core
#	sudo rmmod mlx5_ib
#	sudo rmmod $module;
#	sudo modprobe mlx5_ib
#	sudo modprobe $module;
set +x
}
alias ib=mybuild_ib

mybuild_old () 
{
set -x; 
	cd $linux_dir;
	sudo make
	sudo make install

	sudo modprobe -r cls_flower
	sudo modprobe -r act_gact
	sudo /etc/init.d/openibd restart
set +x
}

if (( ofed == 1 )); then
	alias bu=mybuild_old
	alias bu=mybuild
else
	alias bu=mybuild
fi

build-mlx5-ib () 
{
set -x; 
	module=mlx5_ib;
	driver_dir=drivers/infiniband/hw/mlx5
	cd $linux_dir;
	make M=$driver_dir -j || return
	src_dir=$linux_dir/$driver_dir
	sudo /bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/$driver_dir

	sudo modprobe -r mlx5_ib
	sudo modprobe -r mlx5_core
	sudo modprobe -v mlx5_ib
set +x
}



alias b1="tc2; mybuild1 cls_flower"
alias bct="tc2; mybuild1 act_ct"
alias b_gact="tc2; mybuild1 act_gact"
alias b_mirred="tc2; mybuild1 act_mirred"
alias b_vlan="tc2; mybuild1 act_vlan"
alias b_pedit="tc2; mybuild1 act_pedit"

mybuild1 ()
{
	[[ $# == 0 ]] && return
	module=$1;
	driver_dir=net/sched
	cd $linux_dir;
	make M=$driver_dir -j || return
	src_dir=$linux_dir/$driver_dir
	sudo /bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/$driver_dir

	sudo modprobe -r $1
	sudo modprobe -v $1

}

alias bo=mybuild2
mybuild2 ()
{
set -x;
	start-ovs
	sudo ovs-vsctl del-br br
	sudo ovs-vsctl del-br br-int
	sudo ovs-vsctl del-br br-ex
	module=openvswitch
	driver_dir=net/openvswitch
	cd $linux_dir;
	make M=$driver_dir -j || return
	src_dir=$linux_dir/$driver_dir
	sudo /bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/$driver_dir

	sudo modprobe -r $module
	sudo modprobe -v $module
# 	brv
set +x
}

mybuild4 ()
{
	[[ $# == 0 ]] && return
set -x;
	module=$1;
	driver_dir=net/netfilter
	cd $linux_dir;
	make M=$driver_dir -j || return
	src_dir=$linux_dir/$driver_dir
	sudo /bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/$driver_dir

	sudo modprobe -r $1
	sudo modprobe -v $1

set +x
}
alias b4=mybuild4

function mybuild_psample
{
	local module=psample
	driver_dir=net/psample
	cd $linux_dir;
	make M=$driver_dir -j || return
	src_dir=$linux_dir/$driver_dir
	sudo /bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/$driver_dir

	sudo modprobe -r act_sample
	sudo modprobe -r $module
	sudo modprobe -v $module

}

alias bp=mybuild_psample

alias bnetfilter='b4 nft_gen_flow_offload'

# modprobe -rv cls_flower act_mirred
# modprobe -av cls_flower act_mirred

# modprobe -v cls_flower tuple_offload=0
function reprobe
{
set -x
#	sudo /etc/init.d/openibd stop
	sudo modprobe -r cls_flower
	sudo modprobe -r mlx5_fpga_tools
	sudo modprobe -r mlx5_ib
	sudo modprobe -r mlx5_core
	sudo modprobe -v mlx5_core
#	sudo modprobe -v mlx5_ib

#	/etc/init.d/network restart
set +x
}

function unload
{
set -x
	sudo modprobe -r mlx5_ib
	sudo modprobe -r mlx5_core
set +x
}

function reprobe-ib
{
	sudo modprobe -r mlx5_ib
	sudo modprobe -r mlx5_core
	sudo modprobe -v mlx5_core
	sudo modprobe -v mlx5_ib
}



function build_vxlan
{
set -x; 
	module=vxlan;
	src_dir=$linux_dir/drivers/net
	cd $dir_dir;
	make CONFIG_VXLAN=m -C $linux_dir M=$src_dir modules || {
		set +x	
		return
	}
set +x
}

function cp_vxlan
{
set -x; 
	module=vxlan;
	src_dir=$linux_dir/drivers/net
	/bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/drivers/net
	rmmod vport_vxlan
	rmmod $module;
	modprobe $module;
set +x
}

function build_ovs
{
set -x; 
	src_dir=$linux_dir/net/openvswitch
	cd $dir_dir;
	make -C $linux_dir M=$src_dir modules || {
		set +x	
		return
	}
set +x
}

function install-python3
{
	sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
	sudo yum -y install python36u
}

# need to install /auto/mtbcswgwork/chrism/libcap-ng-0.7.8 first
# pip3 install six
function install-ovs
{
set -x
	./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc
# 	./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc --with-debug
#	./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc --with-dpdk=$DPDK_BUILD
	make -j
	sudo make install -j
set +x
}

function io
{
	test -d ofproto || return
set -x
	make -j
	sudo make install
	restart-ovs
set +x
}

function my_start_ovs
{
set -x
	ovsdb-tool create /usr/local/etc/openvswitch/conf.db \
	    vswitchd/vswitch.ovsschema
	ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
	    --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
	    --private-key=db:Open_vSwitch,SSL,private_key \
	    --certificate=db:Open_vSwitch,SSL,certificate \
	    --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
	    --pidfile --detach --log-file
	
	ovs-vsctl --no-wait init

	ovs-vswitchd --pidfile --detach --log-file
set +x
}

function start-ovs
{
	sudo systemctl start openvswitch.service
}

function restart-ovs
{
	sudo systemctl restart openvswitch.service
}

function stop-ovs
{
set -x
	ovs-appctl exit --cleanup
	sudo systemctl stop openvswitch.service
set +x
}

function stop-ovs-only
{
	sudo systemctl stop openvswitch.service
}

# cleanup tc rules when stopping ovs
alias ovs_exit_cleanup='ovs-appctl exit --cleanup'

function tc_pedit
{
	TC=tc

set -x
	$TC qdisc del dev $rep2 ingress
	ethtool -K $rep2 hw-tc-offload on
	$TC qdisc add dev $rep2 ingress

	tc filter add dev $rep2 prio 1 protocol ip parent ffff: \
		flower skip_sw ip_proto tcp \
		action pedit ex \
		munge ip ttl set 0xee \
		pipe action mirred egress redirect dev $rep3
set +x
}

alias perf1='perf stat -e cycles:k,instructions:k -B --cpu=0-15 sleep 2'

# yum install -y libasan
# -fsanitize=address
function template-c
{
	(( $# == 0 )) && return

	local dir=~/prg/c p=$(basename $1)

	stat $dir/$p > /dev/null 2>&1 && return
	mkdir -p $dir/$p
	cd $dir/$p

cat << EOF > $p.c
#include <stdio.h>

int main(int argc, char *argv[])
{
	printf("hello, $p\n");

	return 0;
}
EOF

cat << EOF > Makefile
CC = gcc -g -m64
EXEC = $p
FILE = $p.c

all: \$(EXEC)
# 	\$(CC) \$(FILE) -o \$(EXEC)
# 	\$(CC) \$(FILE) -fsanitize=address -o \$(EXEC)
#	\$(CC) -Wall -Werror -ansi -pedantic-errors -g \$(FILE) -o \$(EXEC)

clean:
	rm -f \$(EXEC) *.elf *.gdb *.o core

run:
	./$p
EOF
}

function template-m
{
	(( $# == 0 )) && return

	local dir=~/prg/mod p=$(basename $1)

	stat $dir/$p > /dev/null 2>&1 && return
	mkdir -p $dir/$p
	cd $dir/$p

cat << EOF > $p.c
#include <linux/init.h>
#include <linux/module.h>

MODULE_LICENSE("Dual BSD/GPL");

static int ${p}_init(void)
{
	pr_info("$p enter\n");
	return 0;
}

static void ${p}_exit(void)
{
	pr_info("$p exit\n");
}

module_init(${p}_init);
module_exit(${p}_exit);

MODULE_AUTHOR("mishuang");
MODULE_DESCRIPTION("A Sample Hello World Module");
MODULE_ALIAS("A Sample module");
EOF

cat << EOF > Makefile
#
# Makefile for the ${p}.c
#

obj-m := ${p}.o
CURRENT_PATH := \$(shell pwd)
KERNEL_SRC :=/images/chrism/linux

KVERSION = \$(shell uname -r)
obj-m = ${p}.o

all:
	make -C /lib/modules/\$(KVERSION)/build M=\$(PWD) modules
clean:
	make -C /lib/modules/\$(KVERSION)/build M=\$(PWD) clean
	-sudo rmmod ${p}
	-sudo dmesg -CT

run:
	-sudo insmod ./${p}.ko
	-sudo dmesg -T
EOF
}


function debugm
{
	(( $# == 0 )) && {
		cat /sys/module/mlx5_core/parameters/debug_mask
		return
	}
	echo $1 > /sys/module/mlx5_core/parameters/debug_mask
}

function debug
{
	(( $# == 0 )) && {
		cat /proc/sys/kernel/printk
		return
	}
	echo $1 > /proc/sys/kernel/printk
}

function debug-file
{
	(( $# == 0 )) && return
	echo "file $1 +p" > /sys/kernel/debug/dynamic_debug/control
}

function debug-nofile
{
	(( $# == 0 )) && return
	echo "file $1 -p" > /sys/kernel/debug/dynamic_debug/control
}

function debug-m
{
	(( $# == 0 )) && return
	grep $1 /sys/kernel/debug/dynamic_debug/control
}

function printk8
{
	echo 8 > /proc/sys/kernel/printk
	echo 'module nf_conntrack +p' > /sys/kernel/debug/dynamic_debug/control
}

function headers_install
{
	sudo make headers_install ARCH=i386 INSTALL_HDR_PATH=/usr -j
}

function make-all
{
	[[ $UID == 0 ]] && break

	unset CONFIG_LOCALVERSION_AUTO
	make olddefconfig
	make -j $cpu_num2
	sudo make modules_install -j $cpu_num2
	sudo make install
	sudo make headers_install ARCH=i386 INSTALL_HDR_PATH=/usr

	/bin/rm -rf ~/.ccache
}
alias m=make-all
alias mm='sudo make modules_install -j; sudo make install; headers_install'
alias mi2='make -j; sudo make install_kernel -j; ofed-unload; reprobe; /bin/rm -rf ~chrism/.ccache/ 2> /dev/null'
alias mi="make -j $cpu_num2; sudo make install_kernel -j $cpu_num2; reprobe"

function mi2
{
set -x
	sudo echo 0 > /sys/class/net/$link/device/sriov_numvfs;
	make -j; sudo make install -j;
	/bin/rm -rf ./drivers/infiniband/hw/mlx5/mlx5_ib.ko;
	sudo /bin/rm -rf /lib/modules/3.10.0-957.el7.x86_64/extra/mlnx-ofa_kernel/drivers/infiniband/hw/mlx5/mlx5_ib.ko
	force-restart
set +x
}

alias make-local='./configure; make -j; sudo make install'
alias ml=make-local
alias make-usr='./configure --prefix=/usr; make -j; sudo make install'
alias mu=make-usr

function iperfs
{
	n=1
	[[ $# == 1 ]] && n=$1

	IPERF=iperf3;
	killall -KILL $IPERF;

	if (( n == 1 )); then
		$IPERF -s -p 7000
	else
		for ((i = 0; i < $n; i++)); do
			p=$((7000+i))
			echo $i
			$IPERF -s -p $p &
		done
	fi
}

function iperfc
{
set -x
	n=1
	[[ $# == 1 ]] && n=$1

	local udp=0
	(( udp == 1 )) && u="-u" || u=""
	t=1000
	ip=1.1.1.3
	IPERF=iperf3;
#	  killall -KILL $IPERF;

	if (( n == 1 )); then
		$IPERF -c $ip $u -t $t -p 7000
	else
		for ((i = 0; i < $n; i++)); do
			p=$((7000+i))
			echo $i
			$IPERF -c $ip $u -t $t -p $p &
		done
	fi
set +x
}

function iperfc-n1
{
set -x
	n=1
	[[ $# == 1 ]] && n=$1

	t=1000
	ip=1.1.1.19
	IPERF=iperf3;
#	  killall -KILL $IPERF;

	if (( n == 1 )); then
		exe n1 $IPERF -c $ip -u -t $t -p 7000
	else
		for ((i = 0; i < $n; i++)); do
			p=$((7000+i))
			echo $i
			exe n1 $IPERF -c $ip -u -t $t -p $p &
		done
	fi
set +x
}

function tc2
{
	local l
#	for link in p2p1 $rep1 $rep2 $vx_rep; do
	for l in $link $rep1 $rep2 $rep3 bond0; do
		ip link show $l > /dev/null 2>&1 || continue
		tc qdisc show dev $l ingress | grep ffff > /dev/null 2>&1
		if (( $? == 0 )); then
# 			sudo /bin/time -f %e tc qdisc del dev $l ingress
			sudo tc qdisc del dev $l ingress
			echo $l
		fi
	done

	for l in $link2 $rep1_2 $rep2_2 $rep3_2; do
		ip link show $l > /dev/null 2>&1 || continue
		tc qdisc show dev $l ingress | grep ffff > /dev/null 2>&1
		if (( $? == 0 )); then
# 			sudo /bin/time -f %e tc qdisc del dev $l ingress
			sudo tc qdisc del dev $l ingress
			echo $l
		fi
	done

	sudo tc action flush action gact
	for i in $vx $vx_rep; do
		ip link show $i > /dev/null 2>&1 || continue
		sudo ip l d $i
	done

	sudo modprobe -r act_ct
}

function block
{
set -x
	TC=tc
	TC=/images/chrism/iproute2/tc/tc

	$TC qdisc del dev $link ingress

	ethtool -K $link hw-tc-offload on 

	ip link set $link promisc on

	$TC qdisc add dev $link ingress_block 22 ingress
	$TC qdisc add dev $link2 ingress_block 22 ingress
	$TC filter add block 22 protocol ip pref 25 flower dst_ip 192.168.0.0/16 action drop
#	$TC filter add dev $link protocol ip pref 25 flower skip_hw src_mac $remote_mac dst_mac $link_mac action drop
set +x
}

function tc_nat1
{
	TC=/images/chrism/iproute2/tc/tc

	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

set -x

	$TC qdisc del dev $rep2 ingress
	ethtool -K $rep2 hw-tc-offload on
	$TC qdisc add dev $rep2 ingress

	$TC filter add dev $rep2 ingress prio 1 chain 0 proto ip flower $offload ip_flags nofrag ip_proto tcp \
		action ct pipe action goto chain 2
set +x
}

alias tc_nat.sh='sudo ~chrism/bin/tc_nat.sh'
alias tc_ct.sh='sudo ~chrism/bin/tc_ct.sh'

function tc_pf
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=/images/chrism/tc-scripts/tc
	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $link ingress

	ethtool -K $rep2 hw-tc-offload on 
	ethtool -K $link hw-tc-offload on 

	ip link set $rep2 promisc on
	ip link set $link promisc on

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $link ingress 

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=$remote_mac
	$TC filter add dev $rep2 prio 3 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $link
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $link
	$TC filter add dev $rep2 prio 1 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $link

# 	$TC filter add dev $rep2 prio 3 protocol ip  chain 100 parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $link
# 	$TC filter add dev $rep2 prio 2 protocol arp chain 100 parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $link
# 	$TC filter add dev $rep2 prio 1 protocol arp chain 100 parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $link

	src_mac=$remote_mac
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $link prio 3 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $link prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $link prio 1 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
set +x
}

function tc-mirror-pf
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=/images/chrism/tc-scripts/tc
	TC=tc
	TC=/images/chrism/iproute2/tc/tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $link ingress

	ethtool -K $rep2 hw-tc-offload on 
	ethtool -K $link hw-tc-offload on 

	ip link set $rep2 promisc on
	ip link set $link promisc on

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $link ingress 

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=$remote_mac
	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac \
		action mirred egress mirror dev $rep1	\
		action mirred egress redirect dev $link
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $link
	$TC filter add dev $rep2 prio 3 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $link
	src_mac=$remote_mac
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $link prio 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac \
		action mirred egress mirror dev $rep1	\
		action mirred egress redirect dev $rep2
	$TC filter add dev $link prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $link prio 3 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
set +x
}

function tc-vf
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $rep3 ingress

	ethtool -K $rep2 hw-tc-offload on 
	ethtool -K $rep3 hw-tc-offload on 

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $rep3 ingress 

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:01:03
	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: flower $offload  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: flower $offload  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 prio 3 protocol arp parent ffff: flower $offload  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep3
	src_mac=02:25:d0:$host_num:01:03
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $rep3 prio 1 protocol ip  parent ffff: flower $offload  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 2 protocol arp parent ffff: flower $offload  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 3 protocol arp parent ffff: flower $offload  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
set +x
}

function tc-vf-ttl
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $rep3 ingress

	ethtool -K $rep2 hw-tc-offload on 
	ethtool -K $rep3 hw-tc-offload on 

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $rep3 ingress 

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:01:03
	$TC filter add dev $rep2 prio 3 protocol ip  parent ffff: flower $offload  src_mac $src_mac dst_mac $dst_mac ip_proto tcp	\
		action pedit ex munge ip ttl set 0x20 pipe	\
		action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 prio 2 protocol ip  parent ffff: flower $offload  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3

	$TC filter add dev $rep2 prio 1 protocol arp parent ffff: flower $offload  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 prio 1 protocol arp parent ffff: flower $offload  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep3
	src_mac=02:25:d0:$host_num:01:03
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $rep3 prio 1 protocol ip  parent ffff: flower $offload  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 2 protocol arp parent ffff: flower $offload  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 3 protocol arp parent ffff: flower $offload  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
set +x
}

function tc-vf-frag
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $rep3 ingress

	ethtool -K $rep2 hw-tc-offload on 
	ethtool -K $rep3 hw-tc-offload on 

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $rep3 ingress 

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:01:03
	$TC filter add dev $rep2 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 protocol ip  parent ffff: flower $offload ip_flags frag/firstfrag src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 protocol ip  parent ffff: flower $offload ip_flags frag/nofirstfrag src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
#	$TC filter add dev $rep2 protocol ip  parent ffff: flower $offload  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
# set +x
#	return

	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: flower $offload  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 prio 3 protocol arp parent ffff: flower $offload  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep3
	src_mac=02:25:d0:$host_num:01:03
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $rep3 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 protocol ip  parent ffff: flower $offload ip_flags frag/firstfrag src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 protocol ip  parent ffff: flower $offload ip_flags frag/nofirstfrag src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2

	$TC filter add dev $rep3 prio 2 protocol arp parent ffff: flower $offload  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 3 protocol arp parent ffff: flower $offload  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
set +x
}



function tc-setup
{
	local l=$link
	[[ $# == 1 ]] && l=$1
	TC=tc
	TC=/images/chrism/iproute2/tc/tc
	$TC qdisc del dev $link ingress > /dev/null 2>&1
	ethtool -K $link hw-tc-offload on 
	$TC qdisc add dev $link ingress 
}

function tc-vf-eswitch
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $rep3_2 ingress

	ethtool -K $rep2 hw-tc-offload on 
	ethtool -K $rep3_2 hw-tc-offload on 

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $rep3_2 ingress 

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:02:03
	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: flower skip_sw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3_2
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3_2
	$TC filter add dev $rep2 prio 3 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep3_2
	src_mac=02:25:d0:$host_num:02:03
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $rep3_2 prio 1 protocol ip  parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3_2 prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3_2 prio 3 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
set +x
}

function tc_vf_chain
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $rep3 ingress

	ethtool -K $rep2 hw-tc-offload on 
	ethtool -K $rep3 hw-tc-offload on 

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $rep3 ingress 

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:01:03

	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $dst_mac action goto chain 1
	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: chain 1 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep3
	src_mac=02:25:d0:$host_num:01:03
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $rep3 prio 1 protocol ip  parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 2 protocol arp parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 2 protocol arp parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
set +x
}

function tc_sample_chain
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $rep3 ingress

	ethtool -K $rep2 hw-tc-offload on
	ethtool -K $rep3 hw-tc-offload on

	$TC qdisc add dev $rep2 ingress
	$TC qdisc add dev $rep3 ingress

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:01:03

	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $dst_mac \
		action sample rate $rate group 5 trunc 60 \
		action goto chain 1

	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: chain 1 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep3
	src_mac=02:25:d0:$host_num:01:03
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $rep3 prio 1 protocol ip  parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 2 protocol arp parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 2 protocol arp parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
set +x
}

function tc-ct
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $rep3 ingress

	ethtool -K $rep2 hw-tc-offload on 
	ethtool -K $rep3 hw-tc-offload on 

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $rep3 ingress 

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:01:03
#	tc filter add dev eth5 protocol ip parent ffff: chain 0 flower ct_state -trk    action ct    action goto chain 1
#	tc filter add dev eth5 protocol ip parent ffff: chain 1 flower ct_state +trk+est    action mirred egress redirect dev eth6

	tc filter add dev $rep2 prio 1 protocol ip parent ffff: chain 0 flower ct_state -trk		action ct pipe	action goto chain 1
	tc filter add dev $rep2 prio 1 protocol ip parent ffff: chain 1 flower ct_state +trk+est	action mirred egress redirect dev $rep3

#	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $dst_mac action goto chain 1
#	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: chain 1 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep3
	src_mac=02:25:d0:$host_num:01:03
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $rep3 prio 1 protocol ip  parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 2 protocol arp parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 2 protocol arp parent ffff: chain 0 flower $offload src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
set +x
}


function tc-vf-chain1
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $rep3 ingress

	ethtool -K $rep2 hw-tc-offload on 
	ethtool -K $rep3 hw-tc-offload on 

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $rep3 ingress 

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:01:03
	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: chain 1 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: chain 1 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: chain 1 flower $offload src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep3
	src_mac=02:25:d0:$host_num:01:03
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $rep3 prio 1 protocol ip  parent ffff: chain 1 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 2 protocol arp parent ffff: chain 1 flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 2 protocol arp parent ffff: chain 1 flower $offload src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
set +x
}

function tc-vf-ecmp
{
set -x
	offload=""
	[[ $# == 1 ]] && offload=$1
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=/images/chrism/tc-scripts/tc
	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $rep2_2 ingress

	ethtool -K $rep2 hw-tc-offload on 
	ethtool -K $rep2_2 hw-tc-offload on 

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $rep2_2 ingress 

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:02:02
	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2_2
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2_2
	$TC filter add dev $rep2 prio 3 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2_2
	src_mac=02:25:d0:$host_num:02:02
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $rep2_2 prio 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep2_2 prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep2_2 prio 3 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
set +x
}

function tc-vf-ecmp-mirror
{
set -x
	offload=""
	[[ $# == 1 ]] && offload=$1
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=/images/chrism/tc-scripts/tc
	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $rep2 ingress > /dev/null 2>&1
	$TC qdisc del dev $rep2_2 ingress > /dev/null 2>&1

	ethtool -K $rep2 hw-tc-offload on 
	ethtool -K $rep2_2 hw-tc-offload on 

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $rep2_2 ingress 

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:02:02
	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac	\
		action mirred egress mirror dev $rep1	\
		action mirred egress redirect dev $rep2_2
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2_2
	$TC filter add dev $rep2 prio 3 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2_2
	src_mac=02:25:d0:$host_num:02:02
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $rep2_2 prio 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac	\
		action mirred egress mirror dev $rep1	\
		action mirred egress redirect dev $rep2
	$TC filter add dev $rep2_2 prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep2_2 prio 3 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
set +x
}

function tc-mirror-vf
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	redirect=$rep2
	mirror=$rep1
	dest=$rep3

	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $dest ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $mirror ingress > /dev/null 2>&1

	ethtool -K $dest hw-tc-offload on 
	ethtool -K $redirect  hw-tc-offload on 
	ethtool -K $mirror  hw-tc-offload on 

	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $dest ingress 
	$TC qdisc add dev $mirror ingress 

	ip link set $redirect promisc on
	ip link set $dest promisc on
	ip link set $mirror promisc on

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:01:03
	$TC filter add dev $redirect prio 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $dest
	$TC filter add dev $redirect prio 2 protocol arp parent ffff: flower skip_hw src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $dest
	$TC filter add dev $redirect prio 3 protocol arp parent ffff: flower skip_hw src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $dest

	src_mac=02:25:d0:$host_num:01:03
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $dest prio 1 protocol ip parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $redirect
	$TC filter add dev $dest prio 2 protocol arp parent ffff: flower skip_hw src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $redirect
	$TC filter add dev $dest prio 3 protocol arp parent ffff: flower skip_hw src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $redirect

set +x
}

function tc-mirror-vf-bug
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	redirect=$rep2
	mirror=$rep1
	dest=$rep3

	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $dest ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $mirror ingress > /dev/null 2>&1

	ethtool -K $dest hw-tc-offload on 
	ethtool -K $redirect  hw-tc-offload on 
	ethtool -K $mirror  hw-tc-offload on 

	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $dest ingress 
	$TC qdisc add dev $mirror ingress 

	ip link set $redirect promisc on
	ip link set $dest promisc on
	ip link set $mirror promisc on

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:01:03
	$TC filter add dev $redirect prio 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac	\
		action mirred egress mirror dev $dest \
		action mirred egress redirect dev $dest
	$TC filter add dev $redirect prio 2 protocol arp parent ffff: flower skip_hw src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $dest
	$TC filter add dev $redirect prio 3 protocol arp parent ffff: flower skip_hw src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $dest

	src_mac=02:25:d0:$host_num:01:03
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $dest prio 1 protocol ip parent ffff: flower skip_hw src_mac $src_mac dst_mac $dst_mac	\
		action mirred egress mirror dev $redirect \
		action mirred egress redirect dev $redirect
	$TC filter add dev $dest prio 2 protocol arp parent ffff: flower skip_hw src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $redirect
	$TC filter add dev $dest prio 3 protocol arp parent ffff: flower skip_hw src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $redirect

set +x
}



# test with tc-vf
function tc-mirror-vf-test
{
set -x
	offload=""
	[[ "$offload" == "sw" ]] && offload="skip_hw"
	[[ "$offload" == "hw" ]] && offload="skip_sw"

	redirect=$rep2
	mirror=$rep1
	dest=$rep3

	TC=tc
	TC=/images/chrism/iproute2/tc/tc

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:01:03
	$TC filter change dev $redirect prio 1 handle 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $dest
#	$TC filter add dev $redirect prio 2 protocol arp parent ffff: flower skip_hw src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $dest
#	$TC filter add dev $redirect prio 3 protocol arp parent ffff: flower skip_hw src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $dest

set +x
	return

	src_mac=02:25:d0:$host_num:01:03
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $dest prio 1 protocol ip parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $redirect
	$TC filter add dev $dest prio 2 protocol arp parent ffff: flower skip_hw src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $redirect
	$TC filter add dev $dest prio 3 protocol arp parent ffff: flower skip_hw src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $redirect

set +x
}

alias tc3=tc-mirror-vf-test3
function tc-mirror-vf-test3
{
set -x
	offload=""
	[[ "$offload" == "sw" ]] && offload="skip_hw"
	[[ "$offload" == "hw" ]] && offload="skip_sw"

	redirect=$rep2
	mirror=$rep1
	dest=$rep3

	TC=tc
	TC=/images/chrism/iproute2/tc/tc

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:01:03
	$TC filter change dev $redirect prio 1 handle 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac	\
		action mirred egress redirect dev $dest
set +x
}

function tc-no-mirror
{
set -x
	offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	redirect=$rep2
	mirror=$rep1

	TC=tc

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1

	if [[ "$offload" == "skip_sw" ]]; then
		ethtool -K $link hw-tc-offload on 
		ethtool -K $redirect  hw-tc-offload on 
	fi
	if [[ "$offload" == "skip_hw" ]]; then
		ethtool -K $link hw-tc-offload off
		ethtool -K $redirect  hw-tc-offload off
	fi

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	ip link set $link promisc on

	src_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $redirect protocol ip  parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress redirect dev $link

	src_mac=$remote_mac
	$TC filter add dev $link protocol ip  parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol arp parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress redirect dev $redirect

set +x
}

function tc-mirror-link
{
set -x
	offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	redirect=$rep2
	mirror=$rep1

	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1

	if [[ "$offload" == "skip_sw" ]]; then
		ethtool -K $link hw-tc-offload on 
		ethtool -K $redirect  hw-tc-offload on 
	fi
	if [[ "$offload" == "skip_hw" ]]; then
		ethtool -K $link hw-tc-offload off
		ethtool -K $redirect  hw-tc-offload off
	fi

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	ip link set $link promisc on

	src_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $redirect protocol ip  parent ffff: flower skip_hw src_mac $src_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp parent ffff: flower skip_hw src_mac $src_mac	\
		action mirred egress redirect dev $link

	src_mac=$remote_mac
	$TC filter add dev $link protocol ip  parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol arp parent ffff: flower skip_hw src_mac $src_mac	\
		action mirred egress redirect dev $redirect

set +x
}

function tc-mirror-drop
{
set -x
	offload="skip_hw"

	redirect=$rep2
	mirror=$rep1

	TC=tc

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1

	if [[ "$offload" == "skip_sw" ]]; then
		ethtool -K $link hw-tc-offload on 
		ethtool -K $redirect  hw-tc-offload on 
	fi
	if [[ "$offload" == "skip_hw" ]]; then
		ethtool -K $link hw-tc-offload off
		ethtool -K $redirect  hw-tc-offload off
	fi

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	ip link set $link promisc on

	src_mac=02:25:d0:13:01:02
	$TC filter add dev $redirect protocol ip  parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress mirror dev $mirror \
		action drop

	src_mac=24:8a:07:88:27:9a
	$TC filter add dev $link protocol ip  parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol arp parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $redirect

set +x
}

function tc-vlan
{
set -x
	offload=""

	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2
	mirror=$rep1

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on 
	ethtool -K $redirect hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	ip link set $link promisc on

	src_mac=02:25:d0:$host_num:01:02	# local vm mac
	dst_mac=02:25:d0:$rhost_num:01:02	# remote vm mac
	$TC filter add dev $redirect protocol ip prio 1 handle 1 parent ffff: flower $offload src_mac $src_mac	dst_mac $dst_mac \
		action vlan push id $vid		\
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp prio 2 parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac	\
		action vlan push id $vid		\
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp prio 3 parent ffff: flower $offload src_mac $src_mac dst_mac $brd_mac	\
		action vlan push id $vid		\
		action mirred egress redirect dev $link

	src_mac=02:25:d0:$rhost_num:01:02	# remote vm mac
	dst_mac=02:25:d0:$host_num:01:02	# local vm mac
	$TC filter add dev $link protocol 802.1Q prio 1 handle 2 parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac vlan_ethtype 0x800 vlan_id $vid vlan_prio 0	\
		action vlan pop				\
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol 802.1Q prio 2 parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac vlan_ethtype 0x806 vlan_id $vid vlan_prio 0	\
		action vlan pop				\
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol 802.1Q prio 3 parent ffff: flower $offload src_mac $src_mac dst_mac $brd_mac vlan_ethtype 0x806 vlan_id $vid vlan_prio 0	\
		action vlan pop				\
		action mirred egress redirect dev $redirect

set +x
}

#
# local host 14
#
# n1
# vlan enp4s0f0np0v1 5 192.168.1.14
#

#
# remote host 13
#
# ip1
# ping 192.168.1.14
#

function tc_vlan_termtbl
{
set -x
	offload=""

	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $rep2 ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on
	ethtool -K $rep2 hw-tc-offload on

	$TC qdisc add dev $link ingress
	$TC qdisc add dev $rep2 ingress
	ip link set $link promisc on

	src_mac=$remote_mac
	dst_mac=02:25:d0:$host_num:01:02	# local vm mac
	$TC filter add dev $link protocol ip prio 1 handle 2 parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac \
		action vlan push id $vid		\
		action mirred egress redirect dev $rep2
	$TC filter add dev $link protocol arp prio 2 parent ffff: flower $offload \
		action vlan push id $vid		\
		action mirred egress redirect dev $rep2

	src_mac=02:25:d0:$host_num:01:02	# local vm mac
	dst_mac=$remote_mac
	$TC filter add dev $rep2 protocol 802.1Q prio 1 handle 2 parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac vlan_ethtype 0x800 vlan_id $vid vlan_prio 0 \
		action vlan pop \
		action mirred egress redirect dev $link
	$TC filter add dev $rep2 protocol 802.1Q prio 2 parent ffff: flower $offload vlan_ethtype 0x806 vlan_id $vid vlan_prio 0 \
		action vlan pop \
		action mirred egress redirect dev $link

	vlan=vlan$2
	ip netns exec n11 modprobe 8021q
	ip netns exec n11 ifconfig $vf2 0
	ip netns exec n11 ip l d vlan5
	ip netns exec n11 ip link add link $vf2 name $vlan type vlan id $vid
	ip netns exec n11 ip link set dev $vlan up
	ip netns exec n11 ip addr add $link_ip/16 brd + dev $vlan

set +x
}

function tc-qinq
{
set -x
	offload=""

	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2
	mirror=$rep1

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on 
	ethtool -K $redirect hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	ip link set $link promisc on

	src_mac=02:25:d0:$host_num:01:02	# local vm mac
	dst_mac=02:25:d0:$rhost_num:01:02	# remote vm mac
	$TC filter add dev $redirect protocol ip prio 1 handle 1 parent ffff: flower $offload src_mac $src_mac	dst_mac $dst_mac \
		action vlan push id $vid			\
		action vlan push protocol 802.1ad id $svid	\
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp prio 2 parent ffff: flower $offload \
		action vlan push id $vid			\
		action vlan push protocol 802.1ad id $svid	\
		action mirred egress redirect dev $link

	src_mac=02:25:d0:$rhost_num:01:02	# remote vm mac
	dst_mac=02:25:d0:$host_num:01:02	# local vm mac
	$TC filter add dev $link protocol 802.1ad prio 6 handle 2 parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac	\
		vlan_id $svid				\
		vlan_ethtype 802.1q cvlan_id $vid	\
		cvlan_ethtype ip			\
		action vlan pop				\
		action vlan pop				\
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol 802.1ad prio 5 parent ffff: flower $offload \
		vlan_id $svid				\
		vlan_ethtype 802.1q cvlan_id $vid	\
		cvlan_ethtype arp			\
		action vlan pop				\
		action vlan pop				\
		action mirred egress redirect dev $redirect
set +x
}

function tc-vlan-pf
{
set -x
	offload=""

	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2
	mirror=$rep1

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on 
	ethtool -K $redirect hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	ip link set $link promisc on

	src_mac=02:25:d0:$host_num:01:02	# local vm mac
	dst_mac=$remote_mac			# remote vm mac
	$TC filter add dev $redirect protocol ip prio 1 handle 1 parent ffff: flower $offload src_mac $src_mac	dst_mac $dst_mac \
		action vlan push id $vid		\
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp prio 2 parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac	\
		action vlan push id $vid		\
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp prio 3 parent ffff: flower $offload src_mac $src_mac dst_mac $brd_mac	\
		action vlan push id $vid		\
		action mirred egress redirect dev $link

	src_mac=$remote_mac			# remote vm mac
	dst_mac=02:25:d0:$host_num:01:02	# local vm mac
	$TC filter add dev $link protocol 802.1Q prio 1 handle 2 parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac vlan_ethtype 0x800 vlan_id $vid vlan_prio 0	\
		action vlan pop				\
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol 802.1Q prio 2 parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac vlan_ethtype 0x806 vlan_id $vid vlan_prio 0	\
		action vlan pop				\
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol 802.1Q prio 3 parent ffff: flower $offload src_mac $src_mac dst_mac $brd_mac vlan_ethtype 0x806 vlan_id $vid vlan_prio 0	\
		action vlan pop				\
		action mirred egress redirect dev $redirect

set +x
}

alias tcv=tc-mirror-vlan-without
function tc-mirror-vlan-with
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2
	mirror=$rep1

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1

	if [[ "$offload" == "skip_sw" ]]; then
		ethtool -K $link hw-tc-offload on 
		ethtool -K $redirect hw-tc-offload on 
	fi
	if [[ "$offload" == "skip_hw" ]]; then
		ethtool -K $link hw-tc-offload off
		ethtool -K $redirect hw-tc-offload off
	fi

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	ip link set $link promisc on

	src_mac=02:25:d0:$host_num:01:02	# local vm mac
	dst_mac=$remote_mac			# remote vm mac
	$TC filter add dev $redirect protocol ip  parent ffff: flower $offload src_mac $src_mac	dst_mac $dst_mac \
		action vlan push id $vid		\
		action mirred egress mirror dev $mirror	\
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp parent ffff: flower skip_hw src_mac $src_mac \
		action vlan push id $vid		\
		action mirred egress mirror dev $mirror	\
		action mirred egress redirect dev $link

	src_mac=$remote_mac			# remote vm mac
	dst_mac=02:25:d0:$host_num:01:02	# local vm mac
	$TC filter add dev $link protocol 802.1Q parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac vlan_ethtype 0x800 vlan_id $vid vlan_prio 0	\
		action mirred egress mirror dev $mirror	\
		action vlan pop				\
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol 802.1Q parent ffff: flower skip_hw src_mac $src_mac vlan_ethtype 0x806 vlan_id $vid vlan_prio 0	\
		action mirred egress mirror dev $mirror	\
		action vlan pop				\
		action mirred egress redirect dev $redirect

set +x
}

# test with tcv
function tc_mirror_vlan
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=tc
	TC=/images/chrism/iproute2/tc/tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $link ingress

	ethtool -K $rep2 hw-tc-offload on 
	ethtool -K $link hw-tc-offload on 

	ip link set $rep2 promisc on
	ip link set $link promisc on

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $link ingress 

	src_mac=02:25:d0:$host_num:01:02	# local vm mac
	dst_mac=$remote_mac			# remote vm mac
	$TC filter add dev $rep2 protocol ip prio 1 handle 1 parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac \
		action mirred egress mirror dev $rep1	\
		action vlan push id $vid		\
		action mirred egress redirect dev $link
set +x
}

# test with tcv
function vlan3
{
set -x
	redirect=$rep2
	mirror=$rep1
	TC=tc

	offload=""
	src_mac=02:25:d0:$host_num:01:02	# local vm mac
	dst_mac=$remote_mac			# remote vm mac
	$TC filter change dev $redirect protocol ip prio 1 handle 1 parent ffff: flower $offload src_mac $src_mac	dst_mac $dst_mac \
		action vlan push id $vid		\
		action mirred egress redirect dev $link
set +x
}

function tc-mirror-vlan-without
{
set -x
	offload=""

	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	offload=""

	TC=tc
	redirect=$rep2
	mirror=$rep1

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on 
	ethtool -K $redirect hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	ip link set $link promisc on

	src_mac=02:25:d0:$host_num:01:02	# local vm mac
	dst_mac=$remote_mac			# remote vm mac
	$TC filter add dev $redirect protocol ip handle 1 prio 1 parent ffff: flower $offload src_mac $src_mac	dst_mac $dst_mac \
		action mirred egress mirror dev $mirror	\
		action vlan push id $vid		\
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp parent ffff: flower skip_hw src_mac $src_mac	dst_mac $dst_mac \
		action mirred egress mirror dev $mirror	\
		action vlan push id $vid		\
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp parent ffff: flower skip_hw src_mac $src_mac	dst_mac $brd_mac \
		action mirred egress mirror dev $mirror	\
		action vlan push id $vid		\
		action mirred egress redirect dev $link

	src_mac=$remote_mac			# remote vm mac
	dst_mac=02:25:d0:$host_num:01:02	# local vm mac
	$TC filter add dev $link protocol 802.1Q handle 2 parent ffff: flower skip_hw src_mac $src_mac dst_mac $dst_mac vlan_ethtype 0x800 vlan_id $vid vlan_prio 0	\
		action vlan pop				\
		action mirred egress mirror dev $mirror	\
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol 802.1Q parent ffff: flower skip_hw src_mac $src_mac  dst_mac $dst_mac vlan_ethtype 0x806 vlan_id $vid vlan_prio 0	\
		action vlan pop				\
		action mirred egress mirror dev $mirror	\
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol 802.1Q parent ffff: flower skip_hw src_mac $src_mac  dst_mac $brd_mac vlan_ethtype 0x806 vlan_id $vid vlan_prio 0	\
		action vlan pop				\
		action mirred egress mirror dev $mirror	\
		action mirred egress redirect dev $redirect

set +x
}

alias tcx='tc-mirror-vxlan'
alias tcxo='tc-mirror-vxlan-offload'
function tc-mirror-vxlan
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2
	mirror=$rep1

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx #udp6zerocsumtx udp6zerocsumrx
	ifconfig $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on 
	ethtool -K $redirect  hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 
#	$TC qdisc add dev $link clsact
#	$TC qdisc add dev $redirect clsact
#	$TC qdisc add dev $vx clsact

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $mirror promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	# arp
	$TC filter add dev $redirect protocol arp parent ffff: prio 2 flower skip_hw	\
		src_mac $local_vm_mac	\
		action mirred egress mirror dev $mirror	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx
	$TC filter add dev $vx protocol arp parent ffff: prio 2 flower skip_hw	\
		src_mac $remote_vm_mac \
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress mirror dev $mirror	\
		action mirred egress redirect dev $redirect

	$TC filter add dev $redirect protocol ip  parent ffff: prio 1 flower $offload \
		src_mac $local_vm_mac	\
		dst_mac $remote_vm_mac	\
		action mirred egress mirror dev $mirror	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx
	$TC filter add dev $vx protocol ip  parent ffff: prio 1 flower $offload	\
		src_mac $remote_vm_mac	\
		dst_mac $local_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress mirror dev $mirror	\
		action mirred egress redirect dev $redirect
set +x
}

function tc-mirror-vxlan-debug
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2
	mirror=$rep1

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx #udp6zerocsumtx udp6zerocsumrx
	ifconfig $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on 
	ethtool -K $redirect  hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 
#	$TC qdisc add dev $link clsact
#	$TC qdisc add dev $redirect clsact
#	$TC qdisc add dev $vx clsact

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $mirror promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

#	$TC filter add dev $redirect protocol ip  parent ffff: prio 1 flower $offload \
	$TC filter add dev $redirect protocol ip  parent ffff: prio 1 flower skip_hw \
		src_mac $local_vm_mac	\
		dst_mac $remote_vm_mac	\
		action mirred egress mirror dev $mirror	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx
# set +x
#	return
	$TC filter add dev $redirect protocol arp parent ffff: prio 2 flower skip_hw	\
		src_mac $local_vm_mac	\
		action mirred egress mirror dev $mirror	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx

	$TC filter add dev $vx protocol ip  parent ffff: prio 3 flower $offload	\
		src_mac $remote_vm_mac	\
		dst_mac $local_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress mirror dev $mirror	\
		action mirred egress redirect dev $redirect
	$TC filter add dev $vx protocol arp parent ffff: prio 4 flower skip_hw	\
		src_mac $remote_vm_mac \
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress mirror dev $mirror	\
		action mirred egress redirect dev $redirect
set +x
}

function tc_vxlan_ct
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx #udp6zerocsumtx udp6zerocsumrx
	ip link set $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on
	ethtool -K $redirect  hw-tc-offload on

	$TC qdisc add dev $link ingress
	$TC qdisc add dev $redirect ingress
	$TC qdisc add dev $vx ingress
#	$TC qdisc add dev $link clsact
#	$TC qdisc add dev $redirect clsact
#	$TC qdisc add dev $vx clsact

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	# arp
	$TC filter add dev $redirect protocol arp parent ffff: prio 1 flower skip_hw	\
		src_mac $local_vm_mac	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx
	$TC filter add dev $vx protocol arp parent ffff: prio 1 flower skip_hw	\
		src_mac $remote_vm_mac \
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect


	$TC filter add dev $redirect protocol ip  parent ffff: chain 0 prio 2 flower $offload \
		src_mac $local_vm_mac	\
		dst_mac $remote_vm_mac	\
		ct_state -trk		\
		action ct pipe		\
		action goto chain 1
	$TC filter add dev $redirect protocol ip  parent ffff: chain 1 prio 2 flower $offload \
		src_mac $local_vm_mac	\
		dst_mac $remote_vm_mac	\
		ct_state +trk+new	\
		action ct commit	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx
	$TC filter add dev $redirect protocol ip  parent ffff: chain 1 prio 2 flower $offload \
		src_mac $local_vm_mac	\
		dst_mac $remote_vm_mac	\
		ct_state +trk+est	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx

	$TC filter add dev $vx protocol ip  parent ffff: chain 0 prio 2 flower $offload	\
		src_mac $remote_vm_mac	\
		dst_mac $local_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		ct_state -trk			\
		action ct pipe			\
		action goto chain 1
	$TC filter add dev $vx protocol ip  parent ffff: chain 1 prio 2 flower $offload	\
		src_mac $remote_vm_mac	\
		dst_mac $local_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		ct_state +trk+new		\
		action ct commit		\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect
	$TC filter add dev $vx protocol ip  parent ffff: chain 1 prio 2 flower $offload	\
		src_mac $remote_vm_mac	\
		dst_mac $local_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		ct_state +trk+est		\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect

set +x
}

alias test3=tc_vxlan_ct_mirror
function tc_vxlan_ct_mirror
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	mirror=$rep1
	redirect=$rep2

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx #udp6zerocsumtx udp6zerocsumrx
	ip link set $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on
	ethtool -K $redirect  hw-tc-offload on

	$TC qdisc add dev $link ingress
	$TC qdisc add dev $redirect ingress
	$TC qdisc add dev $vx ingress
#	$TC qdisc add dev $link clsact
#	$TC qdisc add dev $redirect clsact
#	$TC qdisc add dev $vx clsact

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $vx promisc on

	ip link set dev $vf1 up

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	# arp
# 	$TC filter add dev $redirect protocol arp parent ffff: prio 1 flower $offload src_mac $local_vm_mac	\
# 		action mirred egress mirror dev $mirror	\
# 		action tunnel_key set src_ip $link_ip dst_ip $link_remote_ip dst_port $vxlan_port id $vni	\
# 		action mirred egress redirect dev $vx
	$TC filter add dev $vx protocol arp parent ffff: prio 1 flower $offload	\
		src_mac $remote_vm_mac enc_src_ip $link_remote_ip enc_dst_ip $link_ip enc_dst_port $vxlan_port enc_key_id $vni	\
		action tunnel_key unset \
		action mirred egress mirror dev $mirror	\
		action mirred egress redirect dev $redirect

set +x
	return

	$TC filter add dev $redirect protocol ip  parent ffff: chain 0 prio 2 flower $offload \
		src_mac $local_vm_mac dst_mac $remote_vm_mac ct_state -trk \
		action ct pipe action goto chain 1
	$TC filter add dev $redirect protocol ip  parent ffff: chain 1 prio 2 flower $offload \
		src_mac $local_vm_mac dst_mac $remote_vm_mac ct_state +trk+new	\
		action ct commit action tunnel_key set src_ip $link_ip dst_ip $link_remote_ip dst_port $vxlan_port id $vni \
		action mirred egress redirect dev $vx
	$TC filter add dev $redirect protocol ip  parent ffff: chain 1 prio 2 flower $offload \
		src_mac $local_vm_mac dst_mac $remote_vm_mac ct_state +trk+est	\
		action tunnel_key set src_ip $link_ip dst_ip $link_remote_ip dst_port $vxlan_port id $vni	\
		action mirred egress redirect dev $vx

	$TC filter add dev $vx protocol ip  parent ffff: chain 0 prio 2 flower $offload	\
		src_mac $remote_vm_mac dst_mac $local_vm_mac enc_src_ip $link_remote_ip	enc_dst_ip $link_ip enc_dst_port $vxlan_port enc_key_id $vni \
		ct_state -trk \
		action ct pipe action goto chain 1
	$TC filter add dev $vx protocol ip  parent ffff: chain 1 prio 2 flower $offload	\
		src_mac $remote_vm_mac dst_mac $local_vm_mac enc_src_ip $link_remote_ip	enc_dst_ip $link_ip enc_dst_port $vxlan_port enc_key_id $vni \
		ct_state +trk+new	\
		action ct commit action tunnel_key unset action mirred egress redirect dev $redirect
	$TC filter add dev $vx protocol ip  parent ffff: chain 1 prio 2 flower $offload	\
		src_mac $remote_vm_mac dst_mac $local_vm_mac enc_src_ip $link_remote_ip	enc_dst_ip $link_ip enc_dst_port $vxlan_port enc_key_id $vni \
		ct_state +trk+est		\
		action tunnel_key unset	 action mirred egress redirect dev $redirect

set +x
}

alias test4=tc_vxlan_ct_test
function tc_vxlan_ct_test
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx #udp6zerocsumtx udp6zerocsumrx
	ip link set $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on
	ethtool -K $redirect  hw-tc-offload on

	$TC qdisc add dev $link ingress
	$TC qdisc add dev $redirect ingress
	$TC qdisc add dev $vx ingress
#	$TC qdisc add dev $link clsact
#	$TC qdisc add dev $redirect clsact
#	$TC qdisc add dev $vx clsact

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	$TC filter add dev $vx protocol ip  parent ffff: chain 1 prio 2 flower $offload	\
		src_mac $remote_vm_mac	\
		dst_mac $local_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		ct_state +trk+est		\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect

set +x
}


alias tun0='sudo ~chrism/sm/prg/c/tun/tun -i tun0 -s -d'

function tc-tap
{
set -x
	local tap=tun0
	[[ $# == 1 ]] && tap=$1
	tc-setup $tap
	tc filter add dev $tap protocol ip parent ffff: prio 10 flower ip_proto tcp dst_mac 00:11:22:33:44:55 action mirred egress redirect dev $link
set +x
}

function tc-vxlan-tap
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2
	tap=vnet1

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx #udp6zerocsumtx udp6zerocsumrx
	ip link set $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1
	$TC qdisc del dev $tap ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on 
	ethtool -K $redirect  hw-tc-offload on 
	ethtool -K $tap  hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 
	$TC qdisc add dev $tap ingress 
#	$TC qdisc add dev $link clsact
#	$TC qdisc add dev $redirect clsact
#	$TC qdisc add dev $vx clsact

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $vx promisc on
	ip link set $tap promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	$TC filter add dev $vx protocol ip  parent ffff: prio 1 flower $offload	\
		src_mac $remote_vm_mac	\
		dst_mac $local_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $link
set +x
}

# outer v6, inner v6
function tc-vxlan66
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx udp6zerocsumtx
	ip link set $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on 
	ethtool -K $redirect  hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 
#	$TC qdisc add dev $link clsact
#	$TC qdisc add dev $redirect clsact
#	$TC qdisc add dev $vx clsact

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	$TC filter add dev $redirect protocol ipv6 parent ffff: prio 1 flower $offload \
		src_mac $local_vm_mac		\
		dst_mac $remote_vm_mac		\
		action tunnel_key set		\
		src_ip $link_ipv6		\
		dst_ip $link_remote_ipv6	\
		dst_port $vxlan_port		\
		id $vni				\
		action mirred egress redirect dev $vx

	$TC filter add dev $vx protocol ipv6 parent ffff: prio 1 flower $offload	\
		src_mac $remote_vm_mac		\
		dst_mac $local_vm_mac		\
		enc_src_ip $link_remote_ipv6	\
		enc_dst_ip $link_ipv6		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect


	$TC filter add dev $redirect protocol ipv6 parent ffff: prio 2 flower $offload \
		src_mac $local_vm_mac		\
		action tunnel_key set		\
		src_ip $link_ipv6		\
		dst_ip $link_remote_ipv6	\
		dst_port $vxlan_port		\
		id $vni				\
		action mirred egress redirect dev $vx

	$TC filter add dev $vx protocol ipv6 parent ffff: prio 2 flower $offload	\
		src_mac $remote_vm_mac		\
		enc_src_ip $link_remote_ipv6	\
		enc_dst_ip $link_ipv6		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect

set +x
}

# outer v6, inner v4
function tc_vxlan64
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx udp6zerocsumtx
	ip link set $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on 
	ethtool -K $redirect  hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 
#	$TC qdisc add dev $link clsact
#	$TC qdisc add dev $redirect clsact
#	$TC qdisc add dev $vx clsact

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	$TC filter add dev $redirect protocol ip  parent ffff: prio 1 flower $offload \
		src_mac $local_vm_mac		\
		dst_mac $remote_vm_mac		\
		action tunnel_key set		\
		src_ip $link_ipv6		\
		dst_ip $link_remote_ipv6	\
		dst_port $vxlan_port		\
		id $vni				\
		action mirred egress redirect dev $vx

	$TC filter add dev $redirect protocol arp parent ffff: prio 2 flower skip_hw	\
		src_mac $local_vm_mac		\
		action tunnel_key set		\
		src_ip $link_ipv6		\
		dst_ip $link_remote_ipv6	\
		dst_port $vxlan_port		\
		id $vni				\
		action mirred egress redirect dev $vx

	$TC filter add dev $vx protocol ip  parent ffff: prio 1 flower $offload	\
		src_mac $remote_vm_mac		\
		dst_mac $local_vm_mac		\
		enc_src_ip $link_remote_ipv6	\
		enc_dst_ip $link_ipv6		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect
	$TC filter add dev $vx protocol arp parent ffff: prio 2 flower skip_hw	\
		src_mac $remote_vm_mac		\
		enc_src_ip $link_remote_ipv6	\
		enc_dst_ip $link_ipv6		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect
set +x
}

function tc_vxlan64_ct
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx udp6zerocsumtx
	ip link set $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on 
	ethtool -K $redirect  hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 
#	$TC qdisc add dev $link clsact
#	$TC qdisc add dev $redirect clsact
#	$TC qdisc add dev $vx clsact

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	# arp
	$TC filter add dev $redirect protocol arp parent ffff: prio 1 flower skip_hw	\
		src_mac $local_vm_mac		\
		action tunnel_key set		\
		src_ip $link_ipv6		\
		dst_ip $link_remote_ipv6	\
		dst_port $vxlan_port		\
		id $vni				\
		action mirred egress redirect dev $vx
	$TC filter add dev $vx protocol arp parent ffff: prio 1 flower skip_hw	\
		src_mac $remote_vm_mac		\
		enc_src_ip $link_remote_ipv6	\
		enc_dst_ip $link_ipv6		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect


	$TC filter add dev $redirect protocol ip  parent ffff: chain 0 prio 2 flower $offload \
		src_mac $local_vm_mac		\
		dst_mac $remote_vm_mac		\
		ct_state -trk			\
		action ct pipe			\
		action goto chain 1
	$TC filter add dev $redirect protocol ip  parent ffff: chain 1 prio 2 flower $offload \
		src_mac $local_vm_mac		\
		dst_mac $remote_vm_mac		\
		ct_state +trk+new		\
		action ct commit		\
		action tunnel_key set		\
		src_ip $link_ipv6		\
		dst_ip $link_remote_ipv6	\
		dst_port $vxlan_port		\
		id $vni				\
		action mirred egress redirect dev $vx
	$TC filter add dev $redirect protocol ip  parent ffff: chain 1 prio 2 flower $offload \
		src_mac $local_vm_mac		\
		dst_mac $remote_vm_mac		\
		ct_state +trk+est		\
		action tunnel_key set		\
		src_ip $link_ipv6		\
		dst_ip $link_remote_ipv6	\
		dst_port $vxlan_port		\
		id $vni				\
		action mirred egress redirect dev $vx


	local ip_version=ip
	$TC filter add dev $vx protocol $ip_version  parent ffff: chain 0 prio 2 flower $offload	\
		src_mac $remote_vm_mac		\
		dst_mac $local_vm_mac		\
		enc_src_ip $link_remote_ipv6	\
		enc_dst_ip $link_ipv6		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		ct_state -trk			\
		action ct pipe			\
		action goto chain 1
	$TC filter add dev $vx protocol $ip_version  parent ffff: chain 1 prio 2 flower $offload	\
		src_mac $remote_vm_mac		\
		dst_mac $local_vm_mac		\
		enc_src_ip $link_remote_ipv6	\
		enc_dst_ip $link_ipv6		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		ct_state +trk+new		\
		action ct pipe			\
		action ct commit		\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect
	$TC filter add dev $vx protocol $ip_version  parent ffff: chain 1 prio 2 flower $offload	\
		src_mac $remote_vm_mac		\
		dst_mac $local_vm_mac		\
		enc_src_ip $link_remote_ipv6	\
		enc_dst_ip $link_ipv6		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		ct_state +trk+est		\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect
set +x
}

function tc_vxlan64_ct_test
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx udp6zerocsumtx
	ip link set $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on 
	ethtool -K $redirect  hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 
#	$TC qdisc add dev $link clsact
#	$TC qdisc add dev $redirect clsact
#	$TC qdisc add dev $vx clsact

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

# 	$TC filter add dev $vx protocol ip  parent ffff: chain 0 prio 2 flower $offload	\
# 		src_mac $remote_vm_mac		\
# 		dst_mac $local_vm_mac		\
# 		enc_src_ip $link_remote_ipv6	\
# 		enc_dst_ip $link_ipv6		\
# 		enc_dst_port $vxlan_port	\
# 		enc_key_id $vni			\
# 		ct_state -trk			\
# 		action ct pipe			\
# 		action goto chain 1
	$TC filter add dev $vx protocol ip  parent ffff: chain 1 prio 2 flower $offload	\
		src_mac $remote_vm_mac		\
		dst_mac $local_vm_mac		\
		enc_src_ip $link_remote_ipv6	\
		enc_dst_ip $link_ipv6		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		ct_state +trk+est		\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect
set +x
}

# outer v4, inner v6
function tc-vxlan46
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx #udp6zerocsumtx udp6zerocsumrx
	ip link set $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on 
	ethtool -K $redirect  hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 
#	$TC qdisc add dev $link clsact
#	$TC qdisc add dev $redirect clsact
#	$TC qdisc add dev $vx clsact

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	$TC filter add dev $redirect protocol ipv6 parent ffff: prio 1 flower $offload \
		src_mac $local_vm_mac	\
		dst_mac $remote_vm_mac	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx

	$TC filter add dev $vx protocol ipv6 parent ffff: prio 1 flower $offload	\
		src_mac $remote_vm_mac	\
		dst_mac $local_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect



	$TC filter add dev $redirect protocol ipv6 parent ffff: prio 2 flower $offload \
		src_mac $local_vm_mac	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx

	$TC filter add dev $vx protocol ipv6 parent ffff: prio 2 flower $offload	\
		src_mac $remote_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect


set +x
}

# ovs-ofctl add-flow br -O openflow13 "in_port=2,dl_type=0x86dd,nw_proto=58,icmp_type=128,action=set_field:0x64->tun_id,output:5"
function tc-vxlan2
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx #udp6zerocsumtx udp6zerocsumrx
	ip link set $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on 
	ethtool -K $redirect  hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 
#	$TC qdisc add dev $link clsact
#	$TC qdisc add dev $redirect clsact
#	$TC qdisc add dev $vx clsact

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	$TC filter add dev $redirect protocol ipv6 parent ffff: prio 1 flower $offload \
		src_mac $local_vm_mac	\
		dst_mac $remote_vm_mac	\
		ip_proto icmpv6		\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx

	$TC filter add dev $vx protocol ipv6 parent ffff: prio 1 flower $offload	\
		src_mac $remote_vm_mac	\
		dst_mac $local_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect


	$TC filter add dev $redirect protocol ipv6 parent ffff: prio 2 flower $offload \
		src_mac $local_vm_mac	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx

	$TC filter add dev $vx protocol ipv6 parent ffff: prio 2 flower $offload	\
		src_mac $remote_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect


set +x
}

function ipn1
{
set -x
	ip n replace $link_remote_ip dev $link lladdr 11:22:33:44:55:66
set +x
}

function ipn2
{
set -x
	ip n replace $link_remote_ip dev $link lladdr 11:22:33:44:55:77
set +x
}

function tc-vxlan-cx4
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx #udp6zerocsumtx udp6zerocsumrx
	ifconfig $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on 
	ethtool -K $redirect  hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 
#	$TC qdisc add dev $link clsact
#	$TC qdisc add dev $redirect clsact
#	$TC qdisc add dev $vx clsact

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	$TC filter add dev $redirect protocol ip  parent ffff: prio 1 flower $offload \
		src_mac $local_vm_mac	\
		dst_mac $remote_vm_mac	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx

	$TC filter add dev $redirect protocol arp parent ffff: prio 2 flower skip_hw	\
		src_mac $local_vm_mac	\
		dst_mac $remote_vm_mac	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx

	$TC filter add dev $vx protocol ip  parent ffff: prio 3 flower $offload	\
		src_mac $remote_vm_mac	\
		dst_mac $local_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect
	$TC filter add dev $vx protocol arp parent ffff: prio 4 flower skip_hw	\
		src_mac $remote_vm_mac \
		dst_mac $local_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect
set +x
}

alias tcxd=tc-mirror-vxlan-drop
function tc-mirror-vxlan-drop
{
set -x
	offload="skip_hw"

	TC=tc
	redirect=$rep2
	mirror=$rep1

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx #udp6zerocsumtx udp6zerocsumrx
	ifconfig $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	if [[ "$offload" == "skip_sw" ]]; then
		ethtool -K $link hw-tc-offload on 
		ethtool -K $redirect  hw-tc-offload on 
	fi
	if [[ "$offload" == "skip_hw" ]]; then
		ethtool -K $link hw-tc-offload off
		ethtool -K $redirect  hw-tc-offload off
	fi

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 

	local_vm_mac=02:25:d0:13:01:02
	remote_vm_mac=$vxlan_mac

	$TC filter add dev $redirect protocol ip  parent ffff: prio 1 flower $offload	\
		src_mac $local_vm_mac	\
		action mirred egress mirror dev $mirror	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action drop
	$TC filter add dev $redirect protocol arp parent ffff: prio 2 flower $offload	\
		src_mac $local_vm_mac	\
		action mirred egress mirror dev $mirror	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx

	$TC filter add dev $vx protocol ip  parent ffff: prio 1 flower $offload	\
		src_mac $remote_vm_mac \
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress mirror dev $mirror	\
		action mirred egress redirect dev $redirect
	$TC filter add dev $vx protocol arp parent ffff: prio 2 flower $offload	\
		src_mac $remote_vm_mac \
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $redirect
set +x
}



function tc-mirror-vxlan-offload
{
set -x
	offload="skip_sw"

	TC=tc
	redirect=$rep2
	mirror=$rep1

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport 4789 external udp6zerocsumrx #udp6zerocsumtx udp6zerocsumrx
	ifconfig $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	if [[ "$offload" == "skip_sw" ]]; then
		ethtool -K $link hw-tc-offload on 
		ethtool -K $redirect  hw-tc-offload on 
	fi
	if [[ "$offload" == "skip_hw" ]]; then
		ethtool -K $link hw-tc-offload off
		ethtool -K $redirect  hw-tc-offload off
	fi

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 

	local_vm_mac=02:25:d0:e2:13:02
	remote_vm_mac=$vxlan_mac

	$TC filter add dev $redirect protocol ip  parent ffff: prio 1 flower $offload	\
		src_mac $local_vm_mac	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx

	$TC filter add dev $redirect protocol ip  parent ffff: prio 2 flower $offload	\
		src_mac $local_vm_mac	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $mirror

	$TC filter add dev $redirect protocol arp parent ffff: prio 3 flower $offload	\
		src_mac $local_vm_mac	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx



	$TC filter add dev $vx protocol ip  parent ffff: prio 1 flower $offload	\
		src_mac $remote_vm_mac \
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect

	$TC filter add dev $vx protocol arp parent ffff: prio 2 flower $offload	\
		src_mac $remote_vm_mac \
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect
set +x
}

function tc-mirror2
{ local link=$link
	local rep=$rep1
	offload="skip_sw"
	src_mac=02:25:d0:e2:14:01
	dst_mac=24:8a:07:88:27:ca
	$TC filter add dev $rep protocol ip  parent ffff: flower $offload dst_mac $dst_mac src_mac $src_mac action mirred egress redirect dev $rep2	# mirror to VF2
	src_mac=24:8a:07:88:27:ca
	dst_mac=02:25:d0:e2:14:01
	$TC filter add dev $link protocol ip  parent ffff: flower $offload dst_mac $dst_mac src_mac $src_mac action mirred egress redirect dev $rep2	# mirror to VF2
}

alias vf00="ip link set dev  $link vf 0 vlan 0 qos 0"
alias vf052="ip link set dev $link vf 0 vlan 52 qos 0"

alias vf10="ip link set dev  $link vf 1 vlan 0 qos 0"
alias vf152="ip link set dev $link vf 1 vlan 52 qos 0"

function get_rep
{
	[[ $# != 1 ]] && return
	if (( link_name == 1 )); then
		echo "${link}_$1"
		return
	elif (( link_name == 2 )); then
		echo "${link_pre}pf0vf$1"
		return
	elif (( link_name == 3 )); then
		i=$1
		echo "eth$((i+2))"
		return
	else
		echo "error"
		return
	fi
}

function get_rep2
{
	[[ $# != 1 ]] && return
	if (( link_name == 1 )); then
		echo "${link2}_$1"
		return
	elif (( link_name == 2 )); then
		echo ${link2_pre}pf1vf$1
		return
		echo "error"
	else
		return
	fi
}

function ovs-vlan-set
{
	ovs-vsctl set port $rep1 tag=$vid
}

function ovs-vlan-remove
{
	ovs-vsctl remove port $rep1 tag $vid
	ovs-vsctl remove port $rep2 tag $vid
	ovs-vsctl remove port $rep3 tag $vid
}

# To later disable mirroring, run:
#	ovs-vsctl clear bridge br0 mirrors


function mirror
{
	[[ $# != 2 ]] && return

	clear-mirror
	ovs-vsctl -- --id=@p get port $1 -- --id=@m create mirror name=m0 select-all=true output-port=@p -- set bridge $2 mirrors=@m
}

function mirror-dst
{
	clear-mirror
	ovs-vsctl -- set Bridge $br mirrors=@m \
	      -- --id=@p get Port $rep2 \
	      -- --id=@p3 get Port $rep3 \
	      -- --id=@p4 get Port $rep4 \
	      -- --id=@p5 get Port $rep5 \
	      -- --id=@m create Mirror name=mymirror select-dst-port=@p3,@p4,@p5 select-src-port=@p3,@p4,@p5 output-port=@p
	ovs-vsctl list mirror
}

alias mirror2="mirror $rep2 $br"

alias set-mirror="ovs-vsctl -- --id=@p get port $rep1 -- --id=@m create mirror name=m0 select-all=true output-port=@p -- set bridge $br mirrors=@m"
alias set-mirror2="ovs-vsctl -- --id=@p get port $rep2 -- --id=@m create mirror name=m0 select-all=true output-port=@p -- set bridge $br mirrors=@m"	# panic test
alias set-mirror-dst="ovs-vsctl -- --id=@p get port $rep1 -- --id=@p2 get port $rep2  -- --id=@m create mirror name=m0 select-dst-port=@p2 output-port=@p -- set bridge $br mirrors=@m"
alias set-mirror-src="ovs-vsctl -- --id=@p get port $rep1 -- --id=@p2 get port $rep2  -- --id=@m create mirror name=m0 select-src-port=@p2 output-port=@p -- set bridge $br mirrors=@m"

alias set-mirror-all="ovs-vsctl -- --id=@p get port $rep1 -- --id=@p2 get port $rep2  -- --id=@m create mirror name=m0 select-dst-port=@p2 select-src-port=@p2 output-port=@p -- set bridge $br mirrors=@m"
alias set-mirror-all2="ovs-vsctl -- --id=@p get port $rep1 -- --id=@p2 get port $rep2 -- --id=@p3 get port $rep3   -- --id=@m create mirror name=m0 select-dst-port=@p2 select-src-port=@p2 select-dst-port=@p3 select-src-port=@p3 output-port=@p -- set bridge $br mirrors=@m"

alias set-mirror-vlan="ovs-vsctl -- --id=@p get port $rep1 -- --id=@p2 get port $rep2  -- --id=@m create mirror name=m0 select-dst-port=@p2 select-src-port=@p2 output-port=@p output-vlan=5 -- set bridge $br mirrors=@m"
alias clear-mirror="ovs-vsctl clear bridge $br mirrors"
alias clear-mirror2="ovs-vsctl clear bridge $br2 mirrors"

alias set-mirror3="ovs-vsctl -- --id=@p get port $rep3 -- --id=@m create mirror name=m0 select-all=true output-port=@p -- set bridge $br mirrors=@m"
alias clear-mirror3="ovs-vsctl clear bridge $br mirrors"

alias mirror_list='ovs-vsctl list mirror'
alias mirror_clear="ovs-vsctl clear bridge $br mirrors"

function mirror_set
{
	ovs-vsctl clear bridge $br mirrors;

	ovs-vsctl add-port $br $rep1
	ifconfig $vf1 up
	ovs-vsctl -- --id=@p get port $rep1 -- --id=@m create mirror name=m0 select-all=true output-port=@p -- set bridge $br mirrors=@m
}

function mirror-br
{
set -x
	local rep
	ovs-vsctl add-br $br
#	ovs-vsctl add-port $br $vx -- set interface $vx type=vxlan options:remote_ip=$link_remote_ip options:key=$vni

	ip link set $rep1 up
	ovs-vsctl add-port $br $rep1	\
	    -- --id=@p get port $rep1	\
	    -- --id=@m create mirror name=m0 select-all=true output-port=@p \
	    -- set bridge $br mirrors=@m

	for (( i = 1; i < numvfs; i++)); do
		rep=$(get_rep $i)
#		vs add-port $br $rep tag=$vid
		vs add-port $br $rep
		ip link set $rep up
	done
	vs add-port $br $link

#	ovs-vsctl add-port $br $rep1 tag=$vid\
# set +x
#	return

#	ovs-ofctl add-flow $br 'nw_dst=1.1.1.14 action=drop'
set +x
}

function mirror-br-vlan
{
set -x
	local rep
	ovs-vsctl add-br $br
	vs add-port $br $link
	for (( i = 1; i < numvfs; i++)); do
		rep=$(get_rep $i)
		vs add-port $br $rep tag=$vid
		ip link set $rep up
	done

	ip link set $rep1 up
#	ovs-vsctl add-port $br $rep1 tag=$vid\
	ovs-vsctl add-port $br $rep1 \
	    -- --id=@p get port $rep1	\
	    -- --id=@m create mirror name=m0 select-all=true output-port=@p \
	    -- set bridge $br mirrors=@m
set +x
}

function mirror-br-vx
{
set -x
	local rep
	ovs-vsctl add-br $br
	for (( i = 0; i < numvfs; i++)); do
		rep=$(get_rep $i)
		vs add-port $br $rep
		ip link set $rep up
	done
	ovs-vsctl add-port $br $vx -- set interface $vx type=vxlan options:remote_ip=$link_remote_ip options:key=$vni \
	    -- --id=@p get port $vx	\
	    -- --id=@m create mirror name=m0 select-all=true output-port=@p \
	    -- set bridge $br mirrors=@m
set +x
}

function remove-tag
{
set -x
	[[ $# != 1 ]] && return
	ovs-vsctl remove port $1 tag $vid
set +x
}

function br-dot1q
{
set -x
	del-br
	vs add-br $br
	eoff
	vlan-limit
	vs add-port $br $link
	tag="tag=$svid vlan-mode=dot1q-tunnel"
	vs add-port $br $rep2 $tag
	[[ "$1" == "cmcc" ]] && ovs-vsctl set Port $rep2 other_config:qinq-ethtype=802.1q
set +x
}

function brx-dot1q
{
set -x
	del-br
	vs add-br $br
	eoff
	vlan-limit
	vxlan1
	tag="tag=$svid vlan-mode=dot1q-tunnel"
	vs add-port $br $rep2 $tag
	[[ "$1" == "cmcc" ]] && ovs-vsctl set Port $rep2 other_config:qinq-ethtype=802.1q
set +x
}

function brv
{
set -x
	del-br
	vs add-br $br
	vs add-port $br $link -- set Interface $link ofport_request=5
	tag="tag=$vid"
	for (( i = 0; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep $tag -- set Interface $rep ofport_request=$((i+1))
	done
set +x
}

alias idle2='ovs-vsctl set Open_vSwitch . other_config:max-idle=2'
alias idle10='ovs-vsctl set Open_vSwitch . other_config:max-idle=10000'
alias idle600='ovs-vsctl set Open_vSwitch . other_config:max-idle=600000'

function bru
{
set -x
	del-br
	idle10
	vs add-br $br
	vs add-port $br $link -- set Interface $link ofport_request=5
	#for (( i = 1; i < 2; i++)); do
	for (( i = 0; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done

# 	ifconfig $link 0
# 	ifconfig $br $link_ip/24 up
# 	ifconfig $link 192.168.1.13/24 up
set +x
}

function bru2
{
set -x
	del-br
	vs add-br $br -- set bridge br  other-config:hwaddr=\"24:8a:07:88:27:13\"
	ifconfig $link 8.9.10.2/24 up
	vs add-port $br $link -- set Interface $link ofport_request=5
	ip addr add dev $br 8.9.10.1/24;
	ip link set dev $br up
set +x
}

function bru3
{
set -x
	del-br
	vs add-br $br
	ifconfig $link 0
	vs add-port $br $link
	ifconfig $br $link_ip/24 up
	ifconfig $link $link_ip/24 up
set +x
}

function bru_bd
{
set -x
	del-br
	vs add-br $br
	ifconfig $link 0
	vs add-port $br $link
	ifconfig $br $link_ip/24 up
	ifconfig $link $link_ip/24 up
	ovs-ofctl add-flow $br "table=0,ip,icmp,in_port=$link,nw_src=192.168.1.14,nw_dst=192.168.1.13 actions=normal"
set +x
}

function br_vf
{
set -x
	del-br
	vs add-br $br
	for (( i = 1; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		ifconfig $rep up
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
set +x
}

alias br=br_vf

function br3
{
set -x
	del-br
	vs add-br $br
	for (( i = 1; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		ifconfig $rep up
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done

# 	ovs-ofctl add-flow $br table=0,priority=2,arp,action=normal

	ovs-ofctl del-flows $br
	ovs-ofctl add-flow $br table=0,priority=1,action=drop
	ovs-ofctl add-flow $br table=0,priority=2,in_port=2,dl_dst=02:25:d0:14:01:03,action=normal
	ovs-ofctl add-flow $br table=0,priority=2,in_port=3,dl_dst=02:25:d0:14:01:02,action=normal

	ovs-ofctl add-flow $br table=0,priority=2,in_port=2,dl_src=02:25:d0:14:01:02,dl_dst=ff:ff:ff:ff:ff:ff,action=normal
	ovs-ofctl add-flow $br table=0,priority=3,in_port=2,dl_src=02:25:d0:14:01:03,dl_dst=ff:ff:ff:ff:ff:ff,action=normal
set +x
}

function br2
{
set -x
	echo "numvfs=$numvfs"
	del-br
	vs add-br $br
	for (( i = 1; i < numvfs; i++)); do
		echo "i=$i"
		local rep=$(get_rep2 $i)
		ifconfig $rep up
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
set +x
}

function br0
{
set -x
	del-br
	vs add-br $br
	local rep=$rep1
	vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
set +x
}

function br_eth
{
set -x
	del-br
	vs add-br $br
	for (( i = 1; i <= numvfs; i++)); do
		local rep=eth$i
		ifconfig $rep up
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
set +x
}

# for bytedance
function brb
{
set -x
	int=br-int
	ex=br-ex
	del-br
	ovs-vsctl add-br $int
	ovs-vsctl add-br $ex

	ifconfig $int up
	ifconfig $ex 8.9.10.1/24 up
	ifconfig $link 8.9.10.13/24 up
	ssh 10.12.205.$rhost_num ifconfig $link 8.9.10.11/24 up

	ovs-vsctl add-port $int $rep2
	ovs-vsctl add-port $ex $link

	ovs-vsctl                           \
		-- add-port $int patch-int       \
		-- set interface patch-int type=patch options:peer=patch-ex  \
		-- add-port $ex patch-ex       \
		-- set interface patch-ex type=patch options:peer=patch-int
set +x
}

# for bytedance
function brb2
{
set -x
	int=br-int
	ex=br-ex
	del-br
	ovs-vsctl add-br $int
	ovs-vsctl add-br $ex

	ifconfig $int up
	ifconfig $ex $link_ip/24 up
	ifconfig $link 8.9.10.13/24 up
	ssh 10.12.205.14 ifconfig $link $link_remote_ip/24 up

	ovs-vsctl add-port $int $rep2
	ovs-vsctl add-port $int $vx		\
		-- set interface $vx type=vxlan	\
		options:remote_ip=$link_remote_ip	\
		options:key=$vni options:dst_port=$vxlan_port
	ovs-vsctl add-port $ex $link

	ovs-vsctl                           \
		-- add-port $int patch-int       \
		-- set interface patch-int type=patch options:peer=patch-ex  \
		-- add-port $ex patch-ex       \
		-- set interface patch-ex type=patch options:peer=patch-int
set +x
}

function brx
{
set -x
	del-br
	vs add-br $br
#  	for (( i = 0; i < numvfs; i++)); do
	for (( i = 1; i < 2; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
	vxlan1
# 	ifconfig $vf1 1.1.1.1/24 up
# 	sflow_create
set +x
}

function brx6
{
set -x
	del-br
	vs add-br $br
#  	for (( i = 0; i < numvfs; i++)); do
	for (( i = 1; i < 2; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
	vxlan6
# 	ifconfig $vf1 1.1.1.1/24 up
# 	sflow_create
set +x
}

function brx2
{
set -x
	del-br
	vs add-br $br
	for (( i = 0; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
	ovs-ofctl add-flow $br "table=0,ip,udp,in_port=$rep2,nw_src=1.1.1.1,nw_dst=1.1.1.200/255.255.0.0 actions=output:4"
	ovs-ofctl add-flow $br "table=0,ip,tcp,in_port=$rep2,nw_src=1.1.1.1,nw_dst=1.1.1.200/255.255.0.0 actions=output:4"
	vxlan1
set +x
}

function brx_ct
{
set -x
	del-br
	vs add-br $br
	for (( i = 0; i < numvfs; i++)); do
# 	for (( i = 1; i < 2; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
	vxlan1

	ovs-ofctl add-flow $br dl_type=0x0806,actions=NORMAL 

	ovs-ofctl add-flow $br "table=0,udp,ct_state=-trk actions=ct(table=1)" 
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+new actions=ct(commit),normal" 
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+est actions=normal" 

	ovs-ofctl add-flow $br "table=0,tcp,ct_state=-trk actions=ct(table=1)" 
	ovs-ofctl add-flow $br "table=1,tcp,ct_state=+trk+new actions=ct(commit),normal" 
	ovs-ofctl add-flow $br "table=1,tcp,ct_state=+trk+est actions=normal" 

# 	ovs-ofctl add-flow $br "table=1,tcp,ct_state=-trk-est-new actions=$rep1" 

	clear-mangle
set +x
}

function brx6_ct
{
set -x
	del-br
	vs add-br $br
# 	for (( i = 0; i < numvfs; i++)); do
	for (( i = 1; i < 2; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
	vxlan6

	ovs-ofctl add-flow $br dl_type=0x0806,actions=NORMAL

	ovs-ofctl add-flow $br "table=0,udp,ct_state=-trk actions=ct(table=1)"
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+new actions=ct(commit),normal"
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+est actions=normal"

	ovs-ofctl add-flow $br "table=0,tcp,ct_state=-trk actions=ct(table=1)"
	ovs-ofctl add-flow $br "table=1,tcp,ct_state=+trk+new actions=ct(commit),normal"
	ovs-ofctl add-flow $br "table=1,tcp,ct_state=+trk+est actions=normal"

# 	ovs-ofctl add-flow $br "table=1,tcp,ct_state=-trk-est-new actions=$rep1"

	clear-mangle
set +x
}



function brx-fin
{
set -x
	del-br
	vs add-br $br
	for (( i = 0; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
	vxlan1

	ovs-ofctl add-flow $br dl_type=0x0806,actions=NORMAL 

	ovs-ofctl add-flow $br "table=0,udp,ct_state=-trk actions=ct(table=1)" 
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+new actions=ct(commit),normal" 
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+est actions=normal" 

	ovs-ofctl add-flow $br "table=0,tcp,ct_state=-trk actions=ct(table=1)" 
	ovs-ofctl add-flow $br "table=1,priority=20,tcp,ct_state=+trk+new actions=ct(commit),normal" 
	ovs-ofctl add-flow $br "table=1,priority=10,tcp,ct_state=+trk+est actions=normal" 
	ovs-ofctl add-flow $br "table=1,priority=30,tcp,tcp_flags(1/1), actions=normal" 

	clear-mangle
set +x
}

function brx-ct-mangle
{
set -x
	del-br
	vs add-br $br
	for (( i = 0; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
	vxlan1

	ovs-ofctl add-flow $br dl_type=0x0806,actions=NORMAL 

	ovs-ofctl add-flow $br "table=0,udp,ct_state=-trk actions=ct(table=1)" 
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+new actions=ct(commit),normal" 
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+est actions=normal" 

	ovs-ofctl add-flow $br "table=0,tcp,ct_state=-trk actions=ct(table=1)" 
	ovs-ofctl add-flow $br "table=1,tcp,ct_state=+trk+new actions=ct(commit),normal" 
	ovs-ofctl add-flow $br "table=1,tcp,ct_state=+trk+est actions=normal" 

	set-mangle
set +x
}

function brex-ct
{
set -x
	del-br
	vs add-br $br
	for (( i = 0; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
	vxlan1

	ovs-ofctl add-flow $br dl_type=0x0806,actions=NORMAL 

	ovs-ofctl add-flow $br "table=0,udp,ct_state=-trk actions=ct(table=1)" 
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+new actions=ct(commit),normal" 
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+est actions=normal" 

	ovs-ofctl add-flow $br "table=0,tcp,ct_state=-trk actions=ct(table=1)" 
	ovs-ofctl add-flow $br "table=1,tcp,ct_state=+trk+new actions=ct(commit),normal" 
	ovs-ofctl add-flow $br "table=1,tcp,ct_state=+trk+est actions=normal" 

	clear-mangle
set +x
}

#
# we can offload the following rules, 2019/10/21
#
function brx-ct-tos-inherit
{
set -x
	del-br
	vs add-br $br
	for (( i = 0; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
	ovs-vsctl add-port $br $vx -- set interface $vx type=vxlan \
		options:remote_ip=$link_remote_ip  options:key=$vni options:dst_port=$vxlan_port options:tos=inherit

	ovs-ofctl add-flow $br dl_type=0x0806,actions=NORMAL 

	ovs-ofctl add-flow $br "table=0,udp,ct_state=-trk actions=ct(table=1)" 
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+new actions=ct(commit),normal" 
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+est actions=normal" 

	ovs-ofctl add-flow $br "table=0,tcp,ct_state=-trk actions=ct(table=1)" 
	ovs-ofctl add-flow $br "table=1,tcp,ct_state=+trk+new actions=ct(commit),normal" 
	ovs-ofctl add-flow $br "table=1,tcp,ct_state=+trk+est actions=normal" 

	clear-mangle
set +x
}

alias tos=brx-ct-tos-inherit
alias tos2=brx-ct-tos-inherit2

function brx-ct-tos-inherit2
{
set -x
	del-br
	vs add-br $br
	for (( i = 0; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
	ovs-vsctl add-port $br $vx -- set interface $vx type=vxlan \
		options:remote_ip=$link_remote_ip  options:key=$vni options:dst_port=$vxlan_port options:tos=inherit

	ovs-ofctl add-flow $br dl_type=0x0806,actions=NORMAL 

	ovs-ofctl add-flow $br "table=0,udp,ct_state=-trk actions=ct(table=1)" 
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+new actions=ct(commit),normal" 
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+est actions=dec_ttl,normal" 

	ovs-ofctl add-flow $br "table=0,tcp,ct_state=-trk actions=ct(table=1)" 
	ovs-ofctl add-flow $br "table=1,tcp,ct_state=+trk+new actions=ct(commit),normal" 
	ovs-ofctl add-flow $br "table=1,tcp,ct_state=+trk+est actions=dec_ttl,normal" 

	clear-mangle
set +x
}

function brx-ct-tos-set
{
set -x
	del-br
	vs add-br $br
	for (( i = 0; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
	ovs-vsctl add-port $br $vx -- set interface $vx type=vxlan \
		options:remote_ip=$link_remote_ip  options:key=$vni options:dst_port=$vxlan_port options:tos=0x20

	ovs-ofctl add-flow $br dl_type=0x0806,actions=NORMAL 

	ovs-ofctl add-flow $br "table=0,udp,ct_state=-trk actions=ct(table=1)" 
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+new actions=ct(commit),normal" 
	ovs-ofctl add-flow $br "table=1,udp,ct_state=+trk+est actions=normal" 

	ovs-ofctl add-flow $br "table=0,tcp,ct_state=-trk actions=ct(table=1)" 
	ovs-ofctl add-flow $br "table=1,tcp,ct_state=+trk+new actions=ct(commit),normal" 
	ovs-ofctl add-flow $br "table=1,tcp,ct_state=+trk+est actions=normal" 

	clear-mangle
set +x
}

alias bt='del-br; r; brx-ct'

function counter-tc-ct
{
set -x
# 	cat /sys/class/net/enp4s0f0/device/sriov/pf/counters_tc_ct
	cat /sys/class/net/enp4s0f0/device/counters_tc_ct
set +x
}

function create-br-vxlan-vlan
{
set -x
	local rep
	vs del-br $br
	vs add-br $br
	vxlan1
	ovs-vsctl add port $vx tag $vid
	tag="tag=$vid"
	for (( i = 0; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep $tag
	done
set +x
}

function create-br2
{
set -x
	local rep
	vs del-br $br2
	vs add-br $br2
	[[ "$1" == "vxlan" ]] && vxlan1-2
	[[ "$1" == "vlan" ]] && vs add-port $br $link2
	[[ "$1" == "vlan" ]] && tag="tag=$vid" || tag=""
	for (( i = 0; i < numvfs; i++)); do
		local rep=$(get_rep2 $i)
		vs add-port $br2 $rep $tag
	done
#	  vs add-port $br2 $link2
set +x
}

function create-brx2
{
set -x
	veth
	local rep
	vs del-br $br2
	vs add-br $br2
	vxlan1-2
	vs add-port $br2 veth0
set +x
}

# alias br2='create-br-ecmp normal'
function create-br-ecmp
{
set -x
	[[ $# != 1 ]] && return
	local rep
	vs del-br $br
	vs add-br $br
	[[ "$1" == "vxlan" ]] && vxlan1
	[[ "$1" == "vlan" ]] && vs add-port $br $link
	[[ "$1" == "vlan" ]] && tag="tag=$vid" || tag=""
	for (( i = 1; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep $tag
		ip link set $rep up

		rep=$(get_rep2 $i)
		vs add-port $br $rep $tag
		ip link set $rep up
	done
	vs add-port $br $rep1 $tag
	vs add-port $br $rep1_2 $tag
set +x
}

# rep=$(eval echo '$'rep"$i")
function del-br
{
	start-ovs
	sudo ovs-vsctl list-br | sudo xargs -r -l ovs-vsctl del-br
	sleep 1
	return
	sudo ip l d $vx_rep
	sudo ip l d dummy0 > /dev/null 2>&1
}

function vlan-ns
{
set -x
	[[ $# != 4 ]] && return
	local link=$1
	vid=$2
	ip=$3
	n=$4
	modprobe 8021q
	ip netns del $n
	ip netns add $n

	ip link set dev $link netns $n
	exe $n vconfig add $link $vid
	exe $n ifconfig $link up
	exe $n ifconfig ${link}.$vid $ip/24 up
set +x
}
alias vn1="ifconfig $vf1 0; vlan-ns $vf1 52 1.1.1.11 n1"
alias vn2="ifconfig $vf2 0; vlan-ns $vf2 52 1.1.1.12 n2"

alias iperfc1='n1 iperf3 -c 1.1.1.11 -u -t 1000 -p 7000'
alias iperfc1='n1 iperf3 -c 1.1.1.11 -t 1000 -p 7000'
alias iperfs1='n1 iperf3 -s -p 7000'

alias vlan-ns2="vlan-ns $link2 $vid $link_ip_vlan link2"

alias vf-test="for (( i = 0; i < 50; i++)); do echo -n $i; echo -n \" \"; vf $i; done"
alias vf-test2="for (( i = 0; i < 4; i++)); do echo -n $i; echo -n \" \"; vf $i; done"

# 1472
function netns
{
	local n=$1 link=$2 ip=$3
	ipv6=$(echo $n | sed 's/n//')
	ip netns del $n 2>/dev/null
	ip netns add $n
	ip link set dev $link netns $n
	ip netns exec $n ip link set mtu 1450 dev $link
	ip netns exec $n ip link set dev $link up
	ip netns exec $n ip addr add $ip/16 brd + dev $link

	(( $host_num == 14 )) && ipv6=$((ipv6+10))
	ip netns exec $n ip addr add 1::$ipv6/64 dev $link

#	ip netns exec $n ip r a 2.2.2.0/24 nexthop via 1.1.1.1 dev $link
}

# rep=$(eval echo '$'rep"$i")
function set_netns_all
{
	local vfn
	local ip
	local i
	local p=$1
	local start
	local ns_ip=1.1.$p

	echo
	echo "start set_netns_all"
	if (( machine_num == 1 )); then
		ns_ip=1.1.$p
	elif (( machine_num == 2 )); then
		ns_ip=1.1.$((p+2))
	fi

	for (( i = 1; i < numvfs; i++)); do
		ip=${ns_ip}.$((i))
		vfn=$(get_vf $host_num $p $((i+1)))
		echo "vf${i} name: $vfn, ip: $ip"
		netns n${p}${i} $vfn $ip
	done
	echo "end set_netns_all"
}

function netns_set_all_vf_channel
{
	local i
	local l
	local p=1
	n=1
	[[ $# == 1 ]] && n=$1

	echo
	echo "start netns_all_vf"

	for (( i = 1; i < 3; i++)); do
# 	for (( i = 1; i < numvfs; i++)); do
		ip netns exec n${p}${i} ethtool -L ${link}v$i combined $n
	done
	echo "end netns_all_vf"
}

function up_all_reps
{
	local port=$1
	local l
	local rep

	if (( $port == 1 )); then
		l=$link
	elif (( $port == 2 )); then
		l=$link2
	else
		echo "up_all_reps error"
		return
	fi

	echo
	echo "start up_all_reps"
	for (( i = 0; i < numvfs; i++)); do
		rep=$(get_rep $i)
		ifconfig $rep up
		echo "up $rep"
		if (( ecmp == 1 )); then
			ovs-vsctl add-port br-vxlan $rep
		fi
	done
	echo "end up_all_reps"
}

function set_all_rep_channel
{
	local l=$link
	local rep

	local n=1
	[[ $# == 1 ]] && n=$1

	echo
	echo "start set_all_rep_channel"
	for (( i = 0; i < numvfs; i++)); do
		rep=$(get_rep $i)
set -x
		ethtool -L $rep combined $n
set +x
	done
	echo "end set_all_rep_channel"
}

function hw_tc_all
{
	ETHTOOL=/usr/local/sbin/ethtool
	ETHTOOL=ethtool
	[[ $# != 1 ]] && return

	local port=$1
	local l
	local rep

	if (( $port == 1 )); then
		l=$link
	elif (( $port == 2 )); then
		l=$link2
	else
		echo "hw_tc_all error"
		return
	fi
	echo
	echo "start hw_tc_all"
	echo "hw-tc-offload on $l"
	$ETHTOOL -K $l hw-tc-offload on
	for (( i = 0; i < numvfs; i++)); do
		rep=$(get_rep $i)
		echo "hw-tc-offload on $rep"
		$ETHTOOL -K $rep hw-tc-offload on
	done
	echo "end hw_tc_all"
}

function start_vm_all
{
	n=$numvfs
	[[ $# == 1 ]] && n=$1

	for (( i = 1; i <= n ; i++)); do
		virsh start vm$i
	done
}

function set_mac
{
	local port=1
	[[ $# == 1 ]] && port=$1

	echo "=========== port $port ($numvfs) =========="
	local l
	local pci_addr

	if (( port == 1 )); then
		l=$link
		mac_prefix="02:25:d0:$host_num:$port"
	elif (( port == 2 )); then
		l=$link2
		mac_prefix="02:25:d0:$host_num:$port"
	fi

	echo "link: $l"
	mac_vf=1

	# echo "Set mac: "
	for vf in `ip link show $l | grep "vf " | awk {'print $2'}`; do
		local mac_addr=$mac_prefix:$(printf "%x" $mac_vf)
		echo "vf${vf} mac address: $mac_addr"
		ip link set $l vf $vf mac $mac_addr
		((mac_vf=mac_vf+1))
	done
}

alias n1p='n1 ping 8.9.10.11'
alias n1p1='n1 ping 8.9.10.1'
alias n1p10='n1 ping 8.9.10.10'
alias n1p8='n1 ping 192.168.0.200'

alias n1c500='time ip netns exec n11 /labhome/chrism/prg/c/corrupt/corrupt_lat_linux/corrupt -c 8.9.10.11 -l 500'
alias n1c50='time ip netns exec n11 /labhome/chrism/prg/c/corrupt/corrupt_lat_linux/corrupt -c 8.9.10.11 -l 50'
alias n1c8='time ip netns exec n11 /labhome/chrism/prg/c/corrupt/corrupt_lat_linux/corrupt -c 192.168.0.200 -t 600'
alias n1c='time ip netns exec n11 /labhome/chrism/prg/c/corrupt/corrupt_lat_linux/corrupt -c 8.9.10.11 -t 600'
alias n1c1='time ip netns exec n11 /labhome/chrism/prg/c/corrupt/corrupt_lat_linux/corrupt -c 8.9.10.11 -t 1'
alias n1i='time ip netns exec n11 iperf3 -c 8.9.10.11 -t 60000'
alias n1i8='time ip netns exec n11 iperf3 -c 192.168.0.200 -t 600'
alias n1u='n1 ping 8.9.10.11 -c 5; time ip netns exec n11 iperf3 -c 8.9.10.11 -t 600 -u'
alias n1iperf3='time ip netns exec n11 iperf3 -c 8.9.10.11 -t 600 -M 1200'
alias n1c2='time ip netns exec n11 /labhome/chrism/prg/c/corrupt/corrupt_lat_linux/corrupt -c 1.1.1.2 -t 6000'
alias n1u='n1 /labhome/chrism/prg/c/udp-client/udp-client-2 -c 8.9.10.11 -t 10000'

function n1-iperf
{
set -x
	i=0
	while :;do
		echo "============== $i ============="
		n1 iperf -c 1.1.1.1 -P 8 -i 1
		if (( i % 2 == 1 )); then
			sleep 40
		else
			sleep 5
		fi
		if (( i == 100 )); then
			break;
		fi
		i=$((i+1))
	done
set +x
}

alias exe='ip netns exec'
alias n0='exe n0'
alias n1='exe n1'
alias n2='exe n2'
alias n3='exe n3'
alias n4='exe n4'

alias n='exe link2 bash'

alias n0='exe n10'
alias n1='exe n11'
alias n2='exe n12'
alias n3='exe n13'

alias n20='exe n20'
alias n21='exe n21'

#  1062  echo 08000000,00000000,00000000 > /proc/irq/281/smp_affinity
#  1063  echo 10000000,00000000,00000000 > /proc/irq/282/smp_affinity
#  1064* echo 20000000,00000000,00000000 > /proc/irq/283/smp_affinity
#  1065  echo 40000000,00000000,00000000 > /proc/irq/284/smp_affinity
#  1066  echo 80000000,00000000,00000000 > /proc/irq/285/smp_affinity

function cpu32
{
	[[ $# != 1 ]] && return
	local i=$1

	printf "%08x" $((1<<$((i-1))))
}

function cpu
{
	[[ $# != 1 ]] && return
	local i=$1

	if (( i >= 1 && i <= 32 )); then
		echo "00000000,00000000,$(cpu32 $i)"
	fi
	if (( i >= 33 && i <= 64 )); then
		echo "00000000,$(cpu32 $((i-32))),00000000"
	fi
	if (( i >= 65 && i <= 96 )); then
		echo "$(cpu32 $((i-64))),00000000,00000000"
	fi
}

function set_all_vf_affinity
{
	local vf
	local n

	local cpu_num=$numvfs
	[[ $# == 1 ]] && cpu_num=$1

	curr_cpu=1
	for (( i = 1; i < numvfs; i++ )); do
		vf=$(get_vf_ns $((i)))
		echo "vf=$vf"
		for n in $(grep -w $vf /proc/interrupts | cut -f 1 -d":"); do
			echo "$n"
			echo "$(cpu $curr_cpu)" > /proc/irq/$n/smp_affinity
			if (( curr_cpu == cpu_num )); then
				curr_cpu=1
			else
				curr_cpu=$((curr_cpu+1))
			fi
		done
	done
}

function affinity_pf
{
	local pf
	local cpu_num=63

	[[ $# != 2 ]] && return
	[[ $# == 1 ]] && pf=$1
	[[ $# == 1 ]] && cpu_num=$1

	curr_cpu=1
	for n in $(grep -w mlx5_comp /proc/interrupts | cut -f 1 -d":"); do
		echo "$n"
		echo "$(cpu $curr_cpu)" > /proc/irq/$n/smp_affinity
		if (( curr_cpu == cpu_num )); then
			curr_cpu=1
		else
			curr_cpu=$((curr_cpu+1))
		fi
	done
}

function set_all_vf_channel_ns
{
	local c=1
	[[ $# == 1 ]] && c=$1
	p=1
	for (( i = 1; i < numvfs; i++)); do
		vfn=$(get_vf_ns $i)
		echo $vfn
set -x
		ip netns exec n1$i ethtool -L $vfn combined $c
set +x
	done
}

function sysctl_time_wait
{
	local t=10
	[[ $# == 1 ]] && t=$1
	for (( i = 1; i < numvfs; i++)); do
set -x
		ip netns exec n1$i sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=$t
set +x
	done
	sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=$t
}

function set_ns_nf
{
	local file=/tmp/nf.sh
	cat << EOF > $file
echo 1 > /proc/sys/net/netfilter/nf_conntrack_tcp_be_liberal;
echo 2000000 > /proc/sys/net/netfilter/nf_conntrack_max
# sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=60
EOF
	for (( i = 1; i < numvfs; i++)); do
set -x
		ip netns exec n1$i bash $file
set +x
	done
}

function ns_run
{
	for (( i = 1; i < numvfs; i++)); do
set -x
		ip netns exec n1$i ip route delete 8.9.10.0/24 via 192.168.0.254
set +x
	done
}

function set_all_vf_channel
{
	p=1
	for (( i = 0; i < numvfs; i++)); do
		vfn=$(get_vf $host_num $p $((i+1)))
set -x
		ethtool -L $vfn combined 1
set +x
	done
}

function start-switchdev-all
{
	start-ovs
	for i in $(seq $ports); do
		start-switchdev $i
	done
}

alias mystart=start-switchdev-all
alias restart='off; dmfs; mystart'
alias restart_smfs='off; smfs; mystart'

function start-switchdev
{
	local port=$1
	local mode=switchdev
	TIME=time
	TIME=""

	if (( numvfs > 99 )); then
		echo "numvfs = $numvfs, return to confirm"
		read
	fi

# 	smfs
	get_pci
	if [[ -z $pci ]]; then
		echo "pci is null"
		return
	fi

	if (( port == 1 )); then
		l=$link
		pci_addr=$pci
	elif (( port == 2 )); then
		l=$link2
		pci_addr=$pci2
	fi

	$TIME echo $numvfs > /sys/class/net/$l/device/sriov_numvfs

	set_mac $port

	$TIME unbind_all $l

	printf "\nenable switchdev mode for: $pci_addr\n"
	if (( centos72 == 1 )); then
		sysfs_dir=/sys/class/net/$link/compat/devlink
		echo switchdev >  $sysfs_dir/mode || echo "switchdev failed"
#		echo basic > $sysfs_dir/encap || echo "baisc failed"
	else
		devlink dev eswitch set pci/$pci_addr mode switchdev
#		devlink dev eswitch set pci/$pci_addr encap enable
	fi

# 	return

	sleep 1
	$TIME bind_all $l
	sleep 1

# 	set_all_vf_channel

	ip1

	sleep 1
	$TIME up_all_reps $port

# 	hw_tc_all $port

	$TIME set_netns_all $port
# 	set_ns_nf

# 	ethtool -K $link tx-vlan-stag-hw-insert off

# 	affinity_set

	return
}

function init_vf_ns
{
	for (( i = 1; i < numvfs; i++ )); do
set -x
		eval vf$((i+1))=$(get_vf_ns $i)
set +x
	done
}

function echo_test
{
set -x
	local sysfs_dir=/sys/class/net/$link/compat/devlink
	echo switchdev >  $sysfs_dir/mode
#	sleep 1
	cat $sysfs_dir/mode
	echo legacy >  $sysfs_dir/mode
set +x
}

function echo_dev
{
	local sysfs_dir=/sys/class/net/$link/compat/devlink
	echo switchdev >  $sysfs_dir/mode
	echo $?
}

function echo_dev2
{
	local sysfs_dir=/sys/class/net/$link2/compat/devlink
	echo switchdev >  $sysfs_dir/mode
	echo $?
}

function echo_dev3
{
	local sysfs_dir=/sys/class/net/$link/compat/devlink
	echo switchdev >  $sysfs_dir/mode || echo "switchdev failed" &
	echo switchdev >  $sysfs_dir/mode || echo "switchdev failed" &
	echo switchdev >  $sysfs_dir/mode || echo "switchdev failed" &
}

function echo_legacy
{
	local sysfs_dir=/sys/class/net/$link/compat/devlink
	echo legacy >  $sysfs_dir/mode
	echo $?
}

function echo_nic_netdev
{
	local sysfs_dir=/sys/class/net/$link/compat/devlink
	echo nic_netdev >  $sysfs_dir/uplink_rep_mode
	echo $?
}

function echo_nic_netdev2
{
	local sysfs_dir=/sys/class/net/$link2/compat/devlink
	echo nic_netdev >  $sysfs_dir/uplink_rep_mode
	echo $?
}

function echo_new_netdev
{
	local sysfs_dir=/sys/class/net/$link/compat/devlink
	echo new_netdev >  $sysfs_dir/uplink_rep_mode
	echo $?
}

function echo_new_netdev2
{
	local sysfs_dir=/sys/class/net/$link2/compat/devlink
	echo new_netdev >  $sysfs_dir/uplink_rep_mode
	echo $?
}



function echo_legacy2
{
	local sysfs_dir=/sys/class/net/$link2/compat/devlink
	echo legacy >  $sysfs_dir/mode
	echo $?
}

function test-nic-netdev
{
	off

	ip link show dev $link
	on-sriov
	un
	echo_nic_netdev
	dev
	ip link show dev $link
	bi

# 	on-sriov2
# 	un2
# 	echo_nic_netdev2
# 	dev2
# 	bi2

# 	reprobe
	force-restart
}

function test-new-netdev
{
	off

	ip link show dev $link
	on-sriov
	un
	echo_new_netdev
	dev
	ip link show dev $link
	bi

# 	on-sriov2
# 	un2
# 	echo_nic_netdev2
# 	dev2
# 	bi2

# 	reprobe
	force-restart
}


function stop-vm
{
	n=$numvfs
	[[ $# == 1 ]] && n=$1

	if (( port == 1 )); then
		for (( i = 1; i <= n; i++)); do
			virsh destroy vm$i
		done
	fi

	if (( port == 2 )); then
		for (( i = 1; i <= n; i++)); do
			virsh destroy vm1$i
		done
	fi
#	echo 0 > /sys/class/net/$link/device/sriov_numvfs
}

# BOOT_IMAGE=/vmlinuz-4.19.36+ root=/dev/mapper/fedora-root ro biosdevname=0 pci=realloc crashkernel=256M intel_iommu=on iommu=pt isolcpus=2,4,6,8,10,12,14 intel_idle.max_cstate=0 nohz_full=2,4,6,8,10,12,14 rcu_nocbs=2,4,6,8,10,12,14 intel_pstate=disable audit=0 nosoftlockup rcu_nocb_poll nopti

function grub
{
set -x
	local kernel
	[[ $# == 1 ]] && kernel=$1
	file=/etc/default/grub
	MKCONFIG=grub2-mkconfig
#	[[ -f /usr/local/sbin/grub-mkconfig ]] && MKCONFIG=/usr/local/sbin/grub-mkconfig
	sudo sed -i '/GRUB_DEFAULT/d' $file
	sudo sed -i '/GRUB_SAVEDEFAULT/d' $file
	sudo sed -i '/GRUB_CMDLINE_LINUX/d' $file
	sudo sed -i '/GRUB_TERMINAL_OUTPUT/d' $file
	sudo sed -i '/GRUB_SERIAL_COMMAND/d' $file
#	sudo echo "GRUB_DEFAULT=\"CentOS Linux ($kernel) 7 (Core)\"" >> $file

	# net.ifnames=0 to set name to eth0

	if (( host_num == 14)); then
		sudo echo "GRUB_CMDLINE_LINUX=\"intel_iommu=on iommu=bt net.ifnames=1 biosdevname=0 pci=realloc crashkernel=256M hugepagesz=2M hugepages=1024\"" >> $file
	fi
# 	sudo echo "GRUB_CMDLINE_LINUX=\"intel_iommu=on biosdevname=0 pci=realloc crashkernel=256M console=tty0 console=ttyS1,$base_baud kgdbwait kgdboc=ttyS1,$base_baud\"" >> $file
	if (( host_num == 13)); then
		sudo echo "GRUB_CMDLINE_LINUX=\"pcie_ports=native intel_iommu=on iommu=bt net.ifnames=1 biosdevname=0 pci=realloc isolcpus=8,10,12,14 intel_idle.max_cstate=0 nohz_full=8,10,12,14 intel_pstate=disable crashkernel=256M hugepagesz=2M hugepages=1024\"" >> $file
# 		sudo echo "GRUB_CMDLINE_LINUX=\"intel_iommu=on biosdevname=0 pci=realloc crashkernel=256M console=tty0 console=ttyS1,$base_baud kgdboc=ttyS1,$base_baud nokaslr\"" >> $file
	fi

	sudo echo "GRUB_TERMINAL_OUTPUT=\"console\"" >> $file
# 	sudo echo "GRUB_TERMINAL_OUTPUT=\"serial\"" >> $file
# 	sudo echo "GRUB_SERIAL_COMMAND=\"serial --speed=$base_baud --unit=1 --word=8 --parity=no --stop=1\"" >> $file

	sudo echo "GRUB_DEFAULT=saved" >> $file
	sudo echo "GRUB_SAVEDEFAULT=true" >> $file

	sudo /bin/rm -rf /boot/*.old
	sudo mv /boot/grub2/grub.cfg /boot/grub2/grub.cfg.orig
	sudo $MKCONFIG -o /boot/grub2/grub.cfg

set +x
	sudo cat $file
}

#======================roi========================

parse_git_branch() {
  local b=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  __branch=$b
  if [ -n "$b" ]; then
      echo "(git::$b)"
      #echo "(git::$b$(git_modified)$(git_commit_not_pushed))"
      #echo "(git::$b$(git_modified))"
  fi
  unset __branch
}

parse_svn_branch() {
    parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk '{print "(svn::"$1")" }'
}
parse_svn_url() {
    svn info 2>/dev/null | sed -ne 's#^URL: ##p'
}
parse_svn_repository_root() {
    svn info 2>/dev/null | sed -ne 's#^Repository Root: ##p'
}

git_modified() {
    local a=`git status -s --porcelain 2> /dev/null| grep "^\s*M"`
    if [ -n "$a" ]; then
	echo "*"
    fi
}

git_commit_not_pushed() {
    local a
    local rc
    if [ "$__branch" == "(no branch)" ]; then
	return
    fi
    # no remote branch
    if ! `git branch -r 2>/dev/null | grep -q $__branch` ; then
	echo "^^"
	return
    fi
    # commits not pushed
    a=`git log origin/$__branch..$__branch 2>/dev/null`
    rc=$?
    if [ "$rc" != 0 ] || [ -n "$a" ]; then
	echo "^"
    fi
}

BLACK="\[\033[0;38m\]"
BLACK="\[\033[0;0m\]"
RED="\[\033[0;31m\]"
RED_BOLD="\[\033[01;31m\]"
BLUE="\[\033[01;94m\]"
GREEN="\[\033[0;32m\]"

if [ "$EUID" = 0 ]; then
    __first_color=$RED
else
    __first_color=$GREEN
fi
export PS1="$__first_color\u$GREEN@\h $RED_BOLD\W $BLUE\$(parse_git_branch)\$(parse_svn_branch)$BLUE\\$ \${?##0} $BLACK"
unset __first_color
export PS1="$GREEN\u@\h $RED_BOLD\W $BLUE\$(parse_git_branch)\$(parse_svn_branch)$BLACK\$ "

# export PROMPT_COMMAND=__prompt_command

function __prompt_command() {
    local EXIT="$?"
    if [ "$EXIT" = 0 ]; then
	EXIT=""
    fi

    PS1="$__first_color\u$GREEN@\h $RED_BOLD\W $BLUE\$(parse_git_branch)\$(parse_svn_branch)$BLUE\\$ $EXIT $BLACK"
}

(( "$UID" == 0 )) && PS1="[\u@\h \W]# "
(( "$UID" == 0 )) && PS1="\e[1;31m[\u@\h \W]# \e[0m"	  # set background=dark
(( "$UID" == 0 )) && PS1="\e[0;31m[\u@\h \W]# \e[0m"	  # set background=light
(( "$UID" != 0 )) && PS1="[\u@\h \W]\$ "
(( "$UID" != 0 )) && PS1="\033[1;33m[\u@\h \W]$ \033[0m"
(( "$UID" != 0 )) && PS1="\033[0;33m[\u@\h \W]$ \033[0m"

# 30 is black
(( "$UID" != 0 )) && PS1="\[\e[0;34m\][\[\e[0m\]\[\e[0;34m\]\u\[\e[0m\]\[\e[0;34m\]@\[\e[0m\]\[\e[0;34m\]\h\[\e[0m\] \[\e[0;34m\]\W\[\e[0m\]\[\e[0;34m\]]\$\[\e[0m\] "	# blue
(( "$UID" != 0 )) && PS1="\[\e[0;33m\][\[\e[0m\]\[\e[0;33m\]\u\[\e[0m\]\[\e[0;33m\]@\[\e[0m\]\[\e[0;33m\]\h\[\e[0m\] \[\e[0;33m\]\W\[\e[0m\]\[\e[0;33m\]]\$\[\e[0m\] "	# green
(( "$UID" == 0 )) && PS1="\[\e[0;31m\][\[\e[0m\]\[\e[0;31m\]\u\[\e[0m\]\[\e[0;31m\]@\[\e[0m\]\[\e[0;31m\]\h\[\e[0m\] \[\e[0;31m\]\W\[\e[0m\]\[\e[0;31m\]]\\$\[\e[0m\] "	# orange

export PS1
export HISTSIZE=1000
export HISTFILESIZE=1000

#=====================================================================

function grepm
{
	[[ $# == 0 ]] && return
	git grep -n "$1" drivers/net/ethernet/mellanox/mlx5/core
}

function grepw
{
	[[ $# == 0 ]] && return
	git grep -nw "$1" drivers/net/ethernet/mellanox/mlx5/core
}

function grepm2
{
	[[ $# == 0 ]] && return
	git grep "$1" include/linux/mlx5
}

function int0
{
	local link=int0
	ip=1.1.1.11

	ovs-vsctl del-port $br $link
	ovs-vsctl add-port $br $link -- set interface $link type=internal
	ifconfig $link mtu 1450
	ifconfig $link $ip/24 up
}

alias tma='tmux attach'
[[ "$HOSTNAME" == "bc-vnc02" ]] && alias tma='screen -x'
[[ "$HOSTNAME" == "vnc14.mtl.labs.mlnx" ]] && alias tma='screen -x'
function tm
{
	[[ $# == 0 ]] && return
	local session=$1
	local cmd=$(which tmux) # tmux path

	if [ -z $cmd ]; then
		echo "You need to install tmux."
		return
	fi

	$cmd has -t $session

	if [ $? != 0 ]; then
		$cmd new -d -n cmd -s $session
		$cmd neww -n n1
		$cmd neww -n n2
		$cmd neww -n bash
		$cmd neww -n linux
		$cmd neww -n live
		$cmd neww -n build-ovs
		$cmd neww -n ovs
		$cmd neww -n drgn-run
		$cmd neww -n drgn
	fi

	$cmd att -t $session
}

function tcdelete
{
	local h
	if [[ $# == 0 ]]; then
		h=1
	else
		h=$1
	fi	
	tc filter del dev $link parent ffff: prio 1 handle $h flower
}

function tcda
{
set -x
	local h
	if [[ $# == 0 ]]; then
		h=262144
	else
		h=$1
	fi	
	for ((i = 1; i <= $h; i++)); do
		tc filter del dev $link parent ffff: prio 1 handle $i flower
	done
set +x
}

function tcchange
{
	TC=tc
	TC=/images/chrism/iproute2/tc/tc
#	tc filter change  dev $link prio 1 protocol ip handle 1 parent ffff: flower skip_hw src_mac e4:11:0:0:0:4 dst_mac e4:12:0:0:0:4 action drop
	$TC filter change dev $link prio 1 protocol ip handle 1 parent ffff: flower skip_hw src_mac e4:11:00:00:00:04 dst_mac e4:12:00:00:00:04 action drop
}

function tcm
{
#	tc2
	TC=/images/chrism/iproute2/tc/tc
	TC=tc
	tc qdisc delete dev $link ingress > /dev/null 2>&1
	sudo $TC qdisc add dev $link ingress
#	sudo $TC filter add  dev $link prio 1 protocol ip handle 0x80000001 parent ffff: flower skip_hw src_mac e4:11:0:0:0:2 dst_mac e4:12:0:0:0:2 action drop
#	sudo $TC filter add  dev $link prio 1 protocol ip handle 0x4 parent ffff: flower skip_hw src_mac e4:11:0:0:0:4 dst_mac e4:12:0:0:0:4 action drop
	sudo tc filter add  dev $link prio 1 protocol ip handle 1 parent ffff: flower skip_hw src_mac e4:11:0:0:0:1 dst_mac e4:12:0:0:0:1 action drop
	sudo tc filter add  dev $link prio 1 protocol ip handle 2 parent ffff: flower skip_hw src_mac e4:11:0:0:0:2 dst_mac e4:12:0:0:0:2 action drop
	sudo $TC filter show dev $link parent ffff:
}

function tcm2
{
#	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
#	tc2
	TC=tc
	sudo $TC qdisc add dev $link ingress
	sudo $TC filter add  dev $link prio 1 protocol ip handle 0x4 parent ffff: flower skip_hw src_mac e4:11:0:0:0:4 dst_mac e4:12:0:0:0:4 action drop
#	sudo tc filter add  dev $link prio 1 protocol ip handle 2 parent ffff: flower skip_hw src_mac e4:11:0:0:0:2 dst_mac e4:12:0:0:0:2 action drop
}

# Usage: /auto/mtbcswgwork/chrism/noodle/noodle [-s | -c host] [client(sender) options]
#  where options are:
#               -h help screen
#               -v report statistics, otherwise be silent
#               -p port (default 10005)
#               -l local port bind start (default random)
#               -L local ip address to bind (default ANY)
#               -c server host address
#               -C concurrent connections(100000 max)
#               -P use Packet Pacing for throttling. otherwise software is used
#               -n conn created per second
#               -t active time per connection in seconds. The connection will be //closed and a new connection will be created once time is up.
#               -T Total run time in secs, otherwise run forever or till killed
#               -r how many client threads. (This box has 16 cores available)
#               -R how many server threads. (This box has 16 cores available)
#               -M Modify pace, currently hard-coded to 10 rates
#               -y yield send factor
#               -S snd buffer size (KB)
#               -E rcv buffer size (KB)
#               -z bandwidth per conn (bits) or
#               -b bandwidth per conn (kbps) or
#               -B total bandwidth (kbps)

alias noodle=/auto/mtbcswgwork/chrism/noodle/noodle
alias noodle1='noodle -c 1.1.14.1 -p 9999 -C 10000 -n 100 -l 3000  -b 10 -r 10'
# noodle -p 1500 -l 2000 -C 40000 -n 5000  -r 8 -b 1
alias noodle1='noodle -c 8.9.10.11 -p 1500 -C 40000 -n 5000 -l 2000  -b 1 -r 8'

alias noodle_arp='arp -s 1.1.14.1 02:25:d0:e2:14:00; arp -a'
noodle_dst_port=1500
noodle_src_port=2000
noodle_conns=40000
function noodle2
{
	n=1
	if [[ $# == 1 ]]; then
		n=$1
	fi
	p=1
	for (( i = noodle_dst_port; i < noodle_dst_port + n; i ++)); do
set -x
		noodle -L 1.1.11.$p -c 1.1.14.1 -p $i -C $noodle_conns -n 5000 -l $noodle_src_port  -b 1 -r 8 &
		((p++))
set +x
	done
}

function tcnoodle
{
	d=1
	if [[ $# == 1 ]]; then
		d=$1
	fi
	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
	tc2
	sudo $TC qdisc add dev $link ingress
set -x
	for (( j = noodle_src_port; j < noodle_src_port + d; j ++)); do
		tc filter add dev $link prio 1 protocol ip parent ffff: flower skip_sw dst_mac 02:25:d0:e2:14:00 ip_proto udp dst_port $noodle_dst_port src_port $j action mirred egress redirect dev $rep1
	done
set +x
}

function tcnoodle2
{
	dir=nb
	/bin/rm -rf $dir
	mkdir -p $dir
	file=$dir/nb
	d=1
	n=0
	c=0
	if [[ $# == 1 ]]; then
		d=$1
	fi
	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
	for (( i = noodle_dst_port; i < noodle_dst_port + d; i ++)); do
		for (( j = noodle_src_port; j < noodle_src_port + noodle_conns; j ++)); do
			echo "filter add dev $link prio 1 protocol ip parent ffff: flower skip_sw dst_mac 02:25:d0:e2:14:00 ip_proto udp dst_port $i src_port $j action mirred egress redirect dev $rep1" >> $file.$n
			((c++))
			p=$((c%400000))
			if (( p == 0 )); then
				echo $n
				((n++))
			fi
		done
	done

	tc2
	sudo $TC qdisc add dev $link ingress

	set -x
	time for f in $file.*; do
		$TC -b $f
	done
	set +x
}

function noodle_check
{
set -x
	tcss | grep Sent > 1.txt
	awk '{if ($2 == 0) print $2}' 1.txt | tee > 2.txt
set +x
}

alias tdc="cd-test; sudo ./tdc.py -f tc-tests/filters/tests.json -d $link"
alias tdc-check='ip netns exec tcut tc action ls action gact'

function tc2actions-hw
{
	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
	tc2
	sudo $TC qdisc add dev $link ingress
set -x
	sudo $TC filter add dev $link prio 1 protocol 0x8100 parent ffff: flower skip_sw src_mac e4:11:1:1:1:1 dst_mac e4:12:1:1:1:1 vlan_ethtype ip action vlan pop action mirred egress redirect dev $rep1
set +x
}

function tc2actions
{
	TC=tc
	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
	tc2
	sudo $TC qdisc add dev $link ingress
set -x
	sudo $TC filter add dev $link prio 1 protocol 0x8100 parent ffff: flower skip_hw src_mac e4:11:1:1:1:1 dst_mac e4:12:1:1:1:1 vlan_ethtype ip action vlan pop action mirred egress redirect dev $rep1
set +x
}

# 250K e4:11:00:00:00:00 to e4:11:00:03:d0:8f

function tca
{
set -x
	[[ $# == 0 ]] && n=1 || n=$1

	file=/tmp/a.txt
#	local l=$rep2
	local l=$link

	TC=/images/chrism/iproute2/tc/tc
	TC=tc

#	$linux_dir/tools/testing/selftests/tc-testing/tdc_batch.py -n $n $link $file

	sudo ~chrism/bin/tdc_batch.py -o -n $n $l $file
	$TC qdisc add dev $l ingress
	ethtool -K $l hw-tc-offload on 
	time $TC -b $file
#	$TC action ls action gact
#	$TC actions flush action gact
set +x
}

function tca1
{
set -x
	TC=tc
	TC=/images/chrism/iproute2/tc/tc
	time $TC action add action ok index 1 action ok index 2 action ok index 3
	$TC action ls action gact
	$TC actions flush action gact
set +x
}

function tca3
{
set -x
	TC=/images/chrism/iproute2/tc/tc
	TC=tc
	time tc action add action ok index 1
	time tc action add action ok index 2
	time tc action add action ok index 3
	tc action ls action gact
	time tc action delete action ok index 1
	tc action ls action gact
	time tc action delete action ok index 2
	time tc action delete action ok index 3
set +x
}

alias tca-add='tc action add action ok index 0'
alias tca-flush='tc actions flush action gact'
alias tca-ls='tc action ls action gact'

function tca-delete
{
	if [[ $# == 0 ]]; then
		n=1
	else
		n=$1
	fi
	for ((i = 1; i <= n; i++)); do
		set -x
		tc actions delete action ok index $i
		set +x
	done
}

function tchw
{
	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
	tc2
	sudo ethtool -K $link hw-tc-offload on
	sudo $TC qdisc add dev $link ingress
set -x
	sudo $TC filter add  dev $link prio 1 protocol ip handle 0x1 parent ffff: flower skip_sw src_mac e4:11:0:0:0:2 dst_mac e4:12:0:0:0:2 action drop
#	sudo tc filter add  dev $link prio 1 protocol ip handle 2 parent ffff: flower skip_hw src_mac e4:11:0:0:0:2 dst_mac e4:12:0:0:0:2 action drop
set +x
}

# change action
function tcca
{
	tc filter change  dev $link prio 1 protocol ip handle 1 parent ffff: flower skip_hw src_mac e4:11:0:0:0:0 dst_mac e4:12:0:0:0:0 action pass
}

function tca2
{
set -x
	TC=/images/chrism/iproute2/tc/tc

	$TC actions flush action gact
	$TC actions add action pass index 1
	$TC actions list action gact
	$TC actions get action gact index 1
#	$TC actions del action gact index 1
	$TC actions flush action gact
set +x
}

alias td='tc action delete action ok index'
alias td1='tc action delete action ok index 1'

function tcd
{
set -x
	[[ $# == 0 ]] && n=1 || n=$1

	file=/tmp/a.txt

	TC=/images/chrism/iproute2/tc/tc
	TC=tc

#	$linux_dir/tools/testing/selftests/tc-testing/tdc_batch.py -n $n $link $file

	tc action ls action gact
	sudo ~chrism/bin/tdc_batch_act.py -d -n $n $file
	time $TC -b $file
	tc action ls action gact
set +x
}

alias tls='tc action ls action gact'

function tcb
{
set -x
	[[ $# == 0 ]] && n=1 || n=$1

	file=/tmp/b.txt

	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	sudo $TC qdisc del dev $link ingress > /dev/null 2>&1
	sudo $TC qdisc add dev $link ingress
	sudo ethtool -K $link hw-tc-offload on
#	$linux_dir/tools/testing/selftests/tc-testing/tdc_batch.py -n $n $link $file
#	sudo ~chrism/bin/tdc_batch.py -s -n $n $link $file	# for software only
	sudo ~chrism/bin/tdc_batch.py -o -n $n $link $file
	time $TC -b $file
#	sudo $TC filter show dev $link parent ffff:
set +x
}

function tcd
{
set -x
	[[ $# == 0 ]] && n=1 || n=$1

	file=/tmp/d.txt

	TC=tc
	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
	TC=/images/chrism/iproute2/tc/tc

#	$linux_dir/tools/testing/selftests/tc-testing/tdc_batch.py -n $n $link $file
#	sudo ~chrism/bin/tdc_batch.py -s -n $n $link $file
	time $TC -b $file
	sudo $TC filter show dev $link parent ffff:
set +x
}

function tcc
{
set -x
	[[ $# == 0 ]] && n=5 || n=$1

	file=~chrism/tc/test-file/2.txt

	TC=tc
	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
	TC=/images/chrism/iproute2/tc/tc

	sudo $TC qdisc del dev $link ingress > /dev/null 2>&1
#	sudo $TC qdisc add dev $link ingress
#	$linux_dir/tools/testing/selftests/tc-testing/tdc_batch.py -n $n $link $file
#	sudo ~chrism/bin/tdc_batch.py -s -n $n $link $file
	time $TC -b $file
#	sudo $TC filter show dev $link parent ffff:
set +x
}

dp=system@ovs-system
dp=system@dp1
function dp-test
{
set -x
	ovs-dpctl add-flow $dp \
		"in_port(1),eth(),eth_type(0x800),\
		ipv4(src=1.1.1.1,dst=2.2.2.2)" 2
	ovs-dpctl dump-flows $dp
#	ovs-dpctl del-flow $dp \
#		"in_port(1),eth(),eth_type(0x800),\
#		ipv4(src=1.1.1.1,dst=2.2.2.2)j
#	ovs-dpctl dump-flows $dp
set +x
}

function dp-delete
{
set -x
	ovs-dpctl del-flows $dp
set +x
}

function gdb1
{
	[[ $# == 0 ]] && return

	GDB=/usr/local/bin/gdb
	GDB=gdb
	local bin=$1
#	gdb -batch $(which $bin) $(pgrep $bin) -x ~chrism/g.txt
	sudo $GDB $(which $bin) $(pgrep $bin)
}

alias g='gdb1 ovs-vswitchd'

function n-revalidator-threads
{
	n=4
	[[ $# == 1 ]] && n=$1
	ovs-vsctl set Open_vSwitch . other_config:n-revalidator-threads=$n
}

function skip_hw
{
	ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"
	ovs-vsctl set Open_vSwitch . other_config:tc-policy=skip_hw
#	ovs-vsctl set Open_vSwitch . other_config:max-idle=600000 # (10 minutes) 
	restart-ovs
	vsconfig
}

function skip_sw
{
	ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"
	ovs-vsctl set Open_vSwitch . other_config:tc-policy=skip_sw
#	ovs-vsctl set Open_vSwitch . other_config:max-idle=600000 # (10 minutes) 
	restart-ovs
	vsconfig
}

function none
{
	vsconfig2
	ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"
	ovs-vsctl set Open_vSwitch . other_config:tc-policy=none

#	ovs-vsctl set Open_vSwitch . other_config:max-revalidator=5000
#	ovs-vsctl set Open_vSwitch . other_config:min_revalidate_pps=1
	restart-ovs
	vsconfig
}

function none1
{
	vsconfig2
	ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"
	ovs-vsctl set Open_vSwitch . other_config:tc-policy=none

	ovs-vsctl set Open_vSwitch . other_config:n-revalidator-threads=1
	ovs-vsctl set Open_vSwitch . other_config:n-handler-threads=1

	restart-ovs
	vsconfig
}

function vlan-limit
{
	ovs-vsctl set Open_vSwitch . other_config:vlan-limit=2
}

function vlan-limit1
{
	ovs-vsctl set Open_vSwitch . other_config:vlan-limit=1
}

# ofproto_flow_limit
function flow-limit
{
	ovs-vsctl set Open_vSwitch . other_config:flow-limit=1000000
}

# size_t n_handlers, n_revalidators;
function ovs_thread
{
	ovs-vsctl set Open_vSwitch . other_config:n-revalidator-threads=4
	ovs-vsctl set Open_vSwitch . other_config:n-handler-threads=2
}

function vsconfig-wrk-nginx
{
	ovs-vsctl set open_vswitch . other_config:hw-offload=True
	ovs-vsctl set open_vswitch . other_config:max-idle="30000"
	ovs-vsctl set open_vswitch . other_config:n-handler-threads="8"
	ovs-vsctl set open_vswitch . other_config:n-revalidator-threads="8"
	restart-ovs
	vsconfig
}

function none2
{
	ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"
	ovs-vsctl set Open_vSwitch . other_config:tc-policy=none
	ovs-vsctl set Open_vSwitch . other_config:max-idle=60000000
	restart-ovs
	vsconfig
}

function none3
{
	ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"
	ovs-vsctl set Open_vSwitch . other_config:tc-policy=none
	ovs-vsctl set Open_vSwitch . other_config:max-revalidator=100000000
	restart-ovs
	vsconfig
}

function vsconfig2
{
	ovs-vsctl clear Open_vSwitch . other_config
}

# /mswg/release/BUILDS/fw-4119/fw-4119-rel-16_24_0220-build-001/etc

function syndrome
{
	if [[ $# != 2 ]]; then
		echo "eg: # syndrome 16.24.0166 0x6231F3"
		return
	fi

	local ver=$(echo $1 | sed 's/\./_/g')
	local type
	if echo $ver | grep ^22; then
		type=4125
	elif echo $ver | grep ^16; then
		type=4119
	elif echo $ver | grep ^14; then
		type=4117
	else
		echo "wrong verions: $ver"
		return
	fi
	local file=/mswg/release/BUILDS/fw-$type/fw-$type-rel-$ver-build-001/etc/syndrome_list.log
	echo $file
	grep -i $2 $file
}

alias syn='syndrome 16.25.6000'
alias syn6='syndrome 22.28.2006'

# mlxfwup

function burn5
{
set -x
	mlxburn -d $pci -fw /root/fw-ConnectX5.mlx -conf_dir /root/customised_ini

	return

# 	mlxfwup -d $pci -f 16.27.1016
        mlxfwup -d $pci -f 16.28.1002

	return

	pci=0000:04:00.0
	version=fw-4119-rel-16_25_1000
	version=fw-4119-rel-16_25_0328
	version=last_revision
	version=fw-4119-rel-16_99_6110
	version=fw-4119-rel-16_25_6000
	version=fw-4119-rel-16_26_1200

# 	mkdir -p /mswg/
# 	sudo mount 10.4.0.102:/vol/mswg/mswg /mswg/
# 	yes | sudo mlxburn -d $pci -fw /mswg/release/fw-4119/$version/fw-ConnectX5.mlx -conf_dir /mswg/release/fw-4119/$version


#	yes | sudo mlxburn -d $pci -fw /mswg/release/fw-4119/last_revision/fw-ConnectX5.mlx -conf_dir /mswg/release/fw-4119/$version

#	[[ "$version" == "last_revision" ]] && /bin/rm -rf last_revision
#	/bin/rm -rf /root/fw
#	mkdir /root/fw
#	scp -r chrism@10.7.2.14:/mswg/release/fw-4119/$version/*.tgz /root/fw
#	cd /root/fw
#	tar zxvf *.tgz
#	yes | sudo mlxburn -d $pci -fw ./fw-ConnectX5.mlx -conf_dir .

	sudo mlxfwreset -y -d $pci reset
set +x
}

alias fwreset="sudo mlxfwreset -d $pci reset -y"

function burn5l
{
set -x
	pci=0000:04:00.0
	version=last_revision
	version=fw-4119-rel-16_24_0300
	version=fw-4119-rel-16_24_0166
#	yes | sudo mlxburn -d $pci -fw /root/$version/fw-ConnectX5.mlx -conf_dir /root/$version
	yes | sudo mlxburn -d $pci -fw /root/fw-ConnectX5.mlx -conf_dir /root/$version
	sudo mlxfwreset -d $pci reset
set +x
}

function burn4
{
set -x
	version=fw-4117-rel-14_23_8010
	version=last_revision
	version=fw-4117-rel-14_25_0292
	mkdir -p /mswg/
	sudo mount 10.4.0.102:/vol/mswg/mswg /mswg/
	yes | sudo mlxburn -d $pci -fw /mswg/release/fw-4117/$version/fw-ConnectX4Lx.mlx -conf_dir /mswg/release/fw-4117/$version
	sudo mlxfwreset -y -d $pci reset
set +x
}

alias gf1="git format-patch -o ~/tmp -1"

function gt
{
	[[ $# != 1 ]] && return
	[[ "$USER" != "chrism" ]] && return
	mkdir -p ~/t
	local file=$(git format-patch -1 $1 -o ~/t)
	vim $file
}

function ga
{
	[[ $# == 0 ]] && return
	rej
	local file=$(printf "/labhome/chrism/jd/vlad/*%02d-net*" $1)
	echo $file
	git apply --reject $file
}
alias cdv='cd ~/vlad'

# git reset HEAD~ file.c
# git show --stat
# git reset
# amend
# checkout
function git-ofed-reset
{
	[[ $# != 1 ]] && return
	local file=$1
	local file2
	echo $file | egrep "^a\/||^b\/" > /dev/null || return
	file2=$(echo $file | sed "s/^..//")
	git show --stat
	git reset HEAD~ $file2
	git commit --amend
	git show --stat
}

function git_ofed_reset
{
	local file="$1"
	git show --stat
	for i in "$file"; do
		git reset HEAD~ $i
	done
	git commit --amend
	git show --stat
}

function git_ofed_reset_all
{
	for i in backports/*; do
		if echo $i | egrep "0199-BACKPORT-drivers-net-ethernet-mellanox-mlx5-core-en_.patch|0200-BACKPORT-drivers-net-ethernet-mellanox-mlx5-core-en_.patch" > /dev/null 2>&1; then
			echo $i
			continue
		fi
		git reset HEAD~ $i
	done
}

function git-am
{
	[[ $# != 3 ]] && return
	local dir=$1
	local start=$2
	local end=$3
	local file

	for ((i = start; i <= end; i ++)); do
		file=$(printf "$dir/00%02d-*" $i)
		echo $file
		git am $file
	done
}

alias git-am1="git-am /labhome/chrism/bp/17"

function git-checkout
{
	[[ $# == 0 ]] && return
	git checkout $1
	git checkout -b $1
}

function git-revert
{
	local commit=$(git slog -1 | awk '{print $1}')
	git revert $commit
}

function git-patch
{
	[[ $# < 2 ]] && return
	local n=$2
	[[ $# == 1 ]] && n=1
	local dir=$1
	mkdir -p $dir
	git format-patch -o $dir -$n HEAD
}

function git-patch2
{
	[[ $# < 2 ]] && return
	local commit=$2
	local dir=$1
	mkdir -p $dir
	git format-patch -o $dir ${commit}..
}

function git-patch3
{
	[[ $# != 3 ]] && return
	local commit_old=$2
	local commit_new=$3
	local dir=$1
	mkdir -p $dir
	git format-patch -o $dir ${commit_old}..${commit_new}
}

function git_patch
{
	dir=~/stack_device
	mkdir -p $dir
	local n=$1
	if [[ $# == 0 ]]; then
		n=$(ls $dir | sort -n | tail -n 1 | cut -d _ -f 1)
		n=$((n+1))
	fi
	b=$(git branch | grep \* | cut -d ' ' -f2)
	commit=$(git slog | grep $b | grep -v HEAD | cut -f 1 -d " ")
	git format-patch -o $dir/$n $commit
}

function git_linux
{
	dir=~/sflow/mark
	mkdir -p $dir
	local n=$1
	if [[ $# == 0 ]]; then
		n=$(ls $dir | sort -n | tail -n 1 | cut -d _ -f 1)
		n=$((n+1))
	fi
	git format-patch -o $dir/$n 6f14b7d62cb5
}


linux_file=~/idr/
function checkout
{
set -x
	local list=$linux_file/out.txt
	local new_dir=$linux_file/out
	local linux_full_name
	local new_full

	while read line; do 
		echo $line
		dir=$(dirname $line)
		echo $dir
		echo

		linux_full_name=$linux_dir/$line
		new_full=$new_dir/$dir
		mkdir -p $new_full
		/bin/cp -f $linux_full_name $new_full
	done < $list
set +x
}

function checkin
{
set -x
	sml
	[[ $# != 1 ]] && return
	local list=$linux_file/$1
	local new_dir=$linux_file/2
	local linux_full_name
	local new_full

	while read line; do 
		echo $line
		linux_full_name=$linux_dir/$line
		new_full=$new_dir/$line
		/bin/cp -f $new_full $linux_full_name
	done < $list
set +x
}

function git-format-patch
{
	[[ $# != 2 ]] && return
	local patch_dir=$1
	local n=$2
	mkdir -p $patch_dir
#	git format-patch --cover-letter --subject-prefix="INTERNAL RFC net-next v9" -o $patch_dir -$n
#	git format-patch --cover-letter --subject-prefix="patch net-next" -o $patch_dir -$n
#	git format-patch --cover-letter --subject-prefix="patch net-next internal v11" -o $patch_dir -$n
#	git format-patch --cover-letter --subject-prefix="patch net internal" -o $patch_dir -$n
#	git format-patch --cover-letter --subject-prefix="patch iproute2 v10" -o $patch_dir -$n
#	git format-patch --cover-letter --subject-prefix="ovs-dev" -o $patch_dir -$n
# 	git format-patch --subject-prefix="branch-2.8/2.9 backport" -o $patch_dir -$n
	git format-patch --cover-letter --subject-prefix="ovs-dev][PATCH v5" -o $patch_dir -$n
# 	git format-patch --subject-prefix="PATCH net-next-internal v2" -o $patch_dir -$n
}

#
# please make sure the subject is correct, patch net-next 0/3...
#
function git-send-email
{
#	file=~/idr/m/4.txt
	file=/labhome/chrism/net/email.txt
	script=~/bin/send.sh

	echo "#!/bin/bash" > $script
	echo >> $script
# 	echo "git send-email $patch_dir/* --to=netdev@vger.kernel.org \\" >> $script
	echo "git send-email $patch_dir/* --to=roniba@mellanox.com \\" >> $script

	cat $file | while read line; do
		echo "	  --cc=$line \\" >> $script
	done

	echo "	  --suppress-cc=all" >> $script
	chmod +x $script
}

function git-send-email-test
{
	file=~/idr/m/3.txt
	file=/labhome/chrism/net/email.txt
	script=~/bin/send.sh

	echo "#!/bin/bash" > $script
	echo >> $script
	echo "git send-email --dry-run $patch_dir/* --to=chrism@mellanox.com \\" >> $script

	echo "	  --cc=mi.shuang@qq.com \\" >> $script
#	cat $file | while read line; do
#		echo "	  --cc=$line \\" >> $script
#	done

	echo "	  --suppress-cc=all" >> $script
	chmod +x $script
}



function panic
{
	echo 1 > /proc/sys/kernel/sysrq
	echo c > /proc/sysrq-trigger
}

function echo-g
{
	echo g > /proc/sysrq-trigger
}

alias cat-tty="stty < /dev/ttyS1"
alias cat-ttyu="stty < /dev/ttyUSB0"
alias cat-serial="cat /proc/tty/driver/serial"
alias cat-userial="cat /proc/tty/driver/usbserial"
alias echo-a="echo aaaa > /dev/ttyS1"
alias cat-a="cat /dev/ttyS1"
alias restart-getty="systemctl restart serial-getty@ttyS1.service"
alias stop-getty="systemctl stop serial-getty@ttyS1.service"
alias start-getty="systemctl start serial-getty@ttyS1.service"

function echo-suc
{
	cat /sys/module/mlx5_core/parameters/nr_mf_succ
}

NEXT=${NEXT:-0}
function ovs-add-flow
{
	printf -v j "%04d" $NEXT
	NEXT=$((NEXT+1))
	export NEXT=$NEXT
	UFID="ufid:ffffffff-ffff-ffff-ffff-ffffffff${j}"
	echo "ovs-appctl dpctl/add-flow \"ufid:ffffffff-ffff-ffff-ffff-ffffffff${j} $1\" drop"
	sudo ovs-appctl dpctl/add-flow "ufid:ffffffff-ffff-ffff-ffff-ffffffff${j} $1" drop
}

function app-test
{
#	ovs-add-flow "in_port(2),eth_type(0x800),eth(src=11:22:33:44:55:66)"
	time ovs-appctl offloads/test 1 50 100 1
}

function clog
{
	cdir=/var/crash
	file=vmcore-dmesg.txt
	dir=$(ls -lht $cdir | awk 'NR == 2 {print $NF}')
	less $cdir/$dir/$file
}

function setup-nic
{
	[[ $# != 2 ]] && return
	local link=$1
	local ip=$2
	local file=/etc/sysconfig/network-scripts/ifcfg-$link
	cat << EOF > $file
TYPE=Ethernet
BOOTPROTO=static
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=$link
UUID=69b82430-695f-4650-8249-813146f59b80
DEVICE=$link
ONBOOT=yes

IPADDR=10.12.205.$ip
GATEWAY=10.12.205.1
NETMASK=255.255.255.0
DNS1=10.12.68.102
DNS2=10.12.68.101

DOMAIN="mtbc.labs.mlnx labs.mlnx mlnx lab.mtl.com mtl.com"
EOF
}

alias pps1="ethtool -S $link | egrep \"rx_packets_phy|tx_packets_phy\""

function pps
{
	[[ $# == 1 ]] && t=$1 || t=3
	t1=$(ethtool -S $link | egrep tx_packets_phy | cut -f 2 -d:)
	r1=$(ethtool -S $link | egrep rx_packets_phy | cut -f 2 -d:)
	echo $t1 $r1
	sleep $t
	t2=$(ethtool -S $link | egrep tx_packets_phy | cut -f 2 -d:)
	r2=$(ethtool -S $link | egrep rx_packets_phy | cut -f 2 -d:)
	echo $t2 $r1
	echo $(((t2 - t1 + r2 - r1) / t))
	echo $(((t2 - t1 + r2 - r1) / t / 1000 / 1000))
}

function disable-tcp-offload
{
	local link=$1
	[[ $# != 1 ]] && return
set -x
	ethtool -K $link gro off
	ethtool -K $link gso off 
	ethtool -K $link tso off
	ethtool -K $link lro off 
set +x
}

function enable-tcp-offload
{
	local link=$1
	[[ $# != 1 ]] && return
set -x
	ethtool -K $link gro on
	ethtool -K $link gso on
	ethtool -K $link tso on
	ethtool -K $link lro on
set +x
}

function peer
{
set -x
	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add name $vx type vxlan id $vni dev $link  remote $link_remote_ip dstport $vxlan_port
#	ifconfig $vx $link_ip_vxlan/24 up
	ip addr add $link_ip_vxlan/16 brd + dev $vx
	ip addr add $link_ipv6_vxlan/64 dev $vx
	ip link set dev $vx up
	ip link set $vx address $vxlan_mac

#	ip link set vxlan0 up
#	ip addr add 1.1.1.2/16 dev vxlan0
#	ip addr add fc00:0:0:0::2/64 dev vxlan0
set +x
}

function peer8
{
set -x
	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add name $vx type vxlan id $vni dev $link  remote $link_remote_ip dstport $vxlan_port
#	ifconfig $vx $link_ip_vxlan/24 up
	ip addr add 8.9.10.11/16 brd + dev $vx
	ip addr add $link_ipv6_vxlan/64 dev $vx
	ip link set dev $vx up
	ip link set $vx address $vxlan_mac

#	ip link set vxlan0 up
#	ip addr add 1.1.1.2/16 dev vxlan0
#	ip addr add fc00:0:0:0::2/64 dev vxlan0
set +x
}

function peer10
{
set -x
	del-br
	ip l d vxlan0

	ifconfig $link 8.9.10.11/24 up
	ip link del $vx > /dev/null 2>&1
	ip link add name $vx type vxlan id $vni dev $link  remote 8.9.10.1 dstport $vxlan_port
#	ifconfig $vx $link_ip_vxlan/24 up
	ip addr add 192.168.0.200/16 brd + dev $vx
	ip addr add $link_ipv6_vxlan/64 dev $vx
	ip link set dev $vx up
	ip link set $vx address $vxlan_mac

#	ip link set vxlan0 up
#	ip addr add 1.1.1.2/16 dev vxlan0
#	ip addr add fc00:0:0:0::2/64 dev vxlan0
set +x
}

# if outer header is ipv6
function peer6
{
set -x
	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add name $vx type vxlan id $vni dev $link remote $link_remote_ipv6 dstport 4789 \
		udp6zerocsumtx udp6zerocsumrx
#	ifconfig $vx $link_ip_vxlan/24 up
	ip addr add $link_ip_vxlan/16 brd + dev $vx
	ip link set dev $vx up
#	ip link set dev $vx mtu 1000
	ip link set $vx address $vxlan_mac
	ip addr add $link_ipv6_vxlan/64 dev $vx

#	ip link set vxlan0 up
#	ip addr add 1.1.1.2/16 dev vxlan0
#	ip addr add fc00:0:0:0::2/64 dev vxlan0
set +x
}

# if outer header is ipv6, inner ip is 8.9.10.11
function peer6_8
{
set -x
	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add name $vx type vxlan id $vni dev $link remote $link_remote_ipv6 dstport 4789 \
		udp6zerocsumtx udp6zerocsumrx
#	ifconfig $vx $link_ip_vxlan/24 up
	ip addr add 8.9.10.11/24 brd + dev $vx
	ip link set dev $vx up
#	ip link set dev $vx mtu 1000
	ip link set $vx address $vxlan_mac
# 	ip addr add $link_ipv6_vxlan/64 dev $vx

set +x
}

function peer0
{
set -x
	n=link2
	ip netns del $n
	ip netns add $n
	exe $n ip link del $vx > /dev/null 2>&1
	ip link set dev $link2 netns $n
	exe $n ifconfig $link2 $link_remote_ip/24 up
	exe $n ip link add name $vx type vxlan id $vni dev $link2 remote $link_remote_ip dstport 4789
	exe $n ifconfig $vx $link_ip_vxlan/16 up
	exe $n ip link set $vx address $vxlan_mac

#	ip link set vxlan0 up
#	ip addr add 1.1.1.2/16 dev vxlan0
#	ip addr add fc00:0:0:0::2/64 dev vxlan0
set +x
}

function peer2
{
set -x
	ip netns exec link2 ip link set $link2 netns 1
#	ip link del $vx > /dev/null 2>&1
set +x
}



alias e1="enable-tcp-offload $link"
alias d1="disable-tcp-offload $link"

# Usage: ./pktgen_sample01_simple.sh [-vx] -i ethX
#   -i : ($DEV)       output interface/device (required)
#   -s : ($PKT_SIZE)  packet size
#   -d : ($DEST_IP)   destination IP
#   -m : ($DST_MAC)   destination MAC-addr
#   -t : ($THREADS)   threads to start
#   -f : ($F_THREAD)  index of first thread (zero indexed CPU number)
#   -c : ($SKB_CLONE) SKB clones send before alloc new SKB
#   -n : ($COUNT)     num messages to send per thread, 0 means indefinitely
#   -b : ($BURST)     HW level bursting of SKBs
#   -v : ($VERBOSE)   verbose
#   -x : ($DEBUG)     debug
#   -6 : ($IP6)       IPv6

function pktgen0
{
	sml
	cd ./samples/pktgen
	./pktgen_sample01_simple.sh -i $link -s 1 -m 02:25:d0:$rhost_num:01:02 -d 1.1.1.22 -t 1 -n 0
}

function pktgen1
{
	mac_count=1
	[[ $# == 1 ]] && mac_count=$1
	sml
	cd ./samples/pktgen
	export SRC_MAC_COUNT=$mac_count
	./pktgen_sample02_multiqueue.sh -i $link -s 1 -m 02:25:d0:$rhost_num:01:02 -d 1.1.1.22 -t 16 -n 0
}

function pktgen2
{
	sml
	cd ./samples/pktgen

	n=10
	[[ $# == 1 ]] && n=$1

	export UDP_SRC_MIN=10000
	export UDP_SRC_MAX=15000
	export UDP_DST_MIN=10000
	export UDP_DST_MAX=$((10000+n))
	i=0

	if [[ "$(hostname -s)" == "dev-r630-04" ]]; then
# 		while :; do
			./pktgen_sample02_multiqueue.sh -i $vf2 -s 1 -m 02:25:d0:13:01:02 -d 1.1.1.220 -t 8 -n 0	# vm1
# 			sleep 15
# 			i=$((i+1))
# 			echo "================= $i ===================="
# 		done
# 		./pktgen_sample02_multiqueue.sh -i $vf2 -s 1 -m 02:25:d0:13:01:02 -d 1.1.1.1 -t 4 -n 0
	fi
	if [[ "$(hostname -s)" == "dev-r630-03" ]]; then
		./pktgen_sample02_multiqueue.sh -i $vf2 -s 1 -m 02:25:d0:14:01:02 -d 1.1.3.1 -t 4 -n 0
	fi
}

function pktgen-pf
{
	sml
	cd ./samples/pktgen

	n=10
	[[ $# == 1 ]] && n=$1

	export UDP_SRC_MIN=1
	export UDP_SRC_MAX=65536
	export UDP_DST_MIN=80
	export UDP_DST_MAX=80
	i=0

	if [[ "$(hostname -s)" == "dev-r630-04" ]]; then
# 		while :; do
			./pktgen_sample02_multiqueue.sh -i $link -s 1 -m 02:25:d0:13:01:02 -d 1.1.1.1 -t 8 -n 0	# vm1
# 			sleep 15
# 			i=$((i+1))
# 			echo "================= $i ===================="
# 		done
# 		./pktgen_sample02_multiqueue.sh -i $vf2 -s 1 -m 02:25:d0:13:01:02 -d 1.1.1.1 -t 4 -n 0
	fi
	if [[ "$(hostname -s)" == "dev-r630-03" ]]; then
		./pktgen_sample02_multiqueue.sh -i $link -s 1 -m 24:8a:07:88:27:ca -d 192.168.1.14 -t 4 -n 0
	fi
}

function base
{
	if [[ $# == 0 ]]; then
		cat /proc/sys/net/ipv4/neigh/enp4s0f0/base_reachable_time_ms
	else
		cat /proc/sys/net/ipv4/neigh/enp4s0f0/base_reachable_time_ms
		echo $1 > /proc/sys/net/ipv4/neigh/enp4s0f0/base_reachable_time_ms
		cat /proc/sys/net/ipv4/neigh/enp4s0f0/base_reachable_time_ms
	fi
}

function used
{
	dpd > 1.txt
	awk '{print $4}' 1.txt | sort > 2.txt
}

# virsh net-edit default

#	<host mac='52:54:00:13:01:01' name='vm1' ip='192.168.122.11'/>
#	<host mac='52:54:00:13:01:02' name='vm2' ip='192.168.122.12'/>

# qemu-system-x86_64 -machine help

# destroy virbr0
function destroy-net
{
	virsh net-destroy default
	virsh net-undefine default
	systemctl restart libvirtd.service
}

function restart-libvirtd
{
set -x
	virsh net-destroy default
	sleep 1
	virsh net-start default
	sleep 1
	systemctl restart libvirtd.service
	sleep 1
set +x
}

function create-vm
{
	dir=/var/lib/libvirt/images/
	disk_name=myvm.qcow2
	vm_name=myvm
	cd $dir
	qemu-img create -f qcow2 $disk_name 1G
	virt-install --name $vm_name --memory 1024 --disk=$dir/$disk_name --pxe --check path_in_use=off
}

function netperf1
{
	killall -9 netperf
	pkill netperf

	[[ $# != 2 ]] && return
	n=$1
	ip=$2

	for ((i = 0; i < n; i ++)); do
		netperf -H $ip -l 10000 -t UDP_STREAM -- -m 1 &
	done
}

alias np1='netperf1 1'
alias np2='netperf1 2'
alias np4='netperf1 4'
alias np8='netperf1 8'
alias np16='netperf1 16'
alias np32='netperf1 32'
alias np64='netperf1 64'
alias np128='netperf1 128'
alias np256='netperf1 256'
alias np512='netperf1 512'

function netperf2
{
	killall -9 netperf
	pkill netperf

	[[ $# != 1 ]] && return
	n=$1
	ip=192.168.1.13

	for ((i = 0; i < n; i ++)); do
		netperf -H $ip -l 10 &
	done
}

# https://github.com/Mellanox/sockperf.git

sockperf_sever=1.1.1.1
function sockperf-server
{
	sockperf server --ip=$sockperf_server
}

function sockperf-server
{
	for i in $(seq 0 21) ; do sockperf tp --ip=$sockperf_server --port=1000$i --pps=max --msg-size=14 -t 60 --sender-affinity $i & done | grep Rate | awk '{SUM+=$6} END { print "Total: " SUM "Mpps" }'
}

function git-pop
{
	n=1
	[[ $# == 1 ]] && n=$1

	echo "remove patch"
	read
set -x
	for ((i = 0; i < n; i++)); do
		commit=$(git slog -2 | cut -d ' ' -f 1	| sed -n '2p')
		git reset --hard $commit
	done
set +x
}

alias git-com="git commit -a -m 'a'"

function am
{
	[[ $# != 4 ]] && return
	local start=$1
	local end=$2
	local cmd=$3
	local dir=$4

	for ((i = start; i <= end; i++)); do
		num=$(printf %4d $i | sed 's/ /0/g')
		$cmd $dir/${num}*
	done
}

function install-pip
{
	curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
	python get-pip.py
}

function install-libevent
{
	version=2.1.8-stable
	libevent=libevent-$version
	sm2
	cd $libevent
	./configure --prefix=/usr/local/libevent/$version
	make
	sudo make install
	sudo alternatives --install /usr/local/lib64/libevent libevent /usr/local/libevent/$version/lib 20018 \
	  --slave /usr/local/include/libevent libevent-include /usr/local/libevent/$version/include \
	  --slave /usr/local/bin/event_rpcgen.py event_rpcgen /usr/local/libevent/$version/bin/event_rpcgen.py
	sudo su -c 'echo "/usr/local/lib64/libevent" > /etc/ld.so.conf.d/libevent.conf'
	sudo ldconfig
}

function install-tmux2
{
	sm2
	cd tmux
	CFLAGS="-I/usr/local/include/libevent" LDFLAGS="-L/usr/local/lib64/libevent" ./configure --prefix=/usr/local/tmux/2.0
	make
	sudo make install
	sudo alternatives --install /usr/local/bin/tmux tmux /usr/local/tmux/2.0/bin/tmux 10600
}

function install-tmux
{
	install-libevent
	install-tmux2
}

function disable-virt
{
	virsh net-destroy  default
	virsh net-undefine default
	systemctl stop libvirtd
	systemctl disable libvirtd
}

function install-mft
{
	mkdir -p /mswg
	sudo mount 10.4.0.102:/vol/mswg/mswg /mswg/
#	/mswg/release/mft/latest/install.sh
	/mswg/release/mft/mftinstall
}

function mlxconfig-enable-sriov
{
	[[ $# != 1 ]] && return
	mlxconfig -d $1 set SRIOV_EN=1 NUM_OF_VFS=8
#	mlxconfig -d $1 set SRIOV_EN=1 NUM_OF_VFS=8 LINK_TYPE_P1=2 LINK_TYPE_P2=2
}

function mlxconfig-enable-ib
{
	mlxconfig -d $pci set LINK_TYPE_P1=1 LINK_TYPE_P2=1
	mlxconfig -d $pci2 set LINK_TYPE_P1=1 LINK_TYPE_P2=1
	sudo mlxfwreset -y -d $pci reset
}

function mlxconfig-enable-eth
{
	mlxconfig -d $pci set LINK_TYPE_P1=2 LINK_TYPE_P2=2
	mlxconfig -d $pci2 set LINK_TYPE_P1=2 LINK_TYPE_P2=2
	sudo mlxfwreset -y -d $pci reset
}

function mlxconfig-enable-prio-tag
{
	mlxconfig -d $pci set PRIO_TAG_REQUIRED_EN=1
	sudo mlxfwreset -y -d $pci reset
}

function mlxconfig-disable-prio-tag
{
	mlxconfig -d $pci set PRIO_TAG_REQUIRED_EN=0
	sudo mlxfwreset -y -d $pci reset
}

alias krestart='systemctl restart kdump'
alias kstatus='systemctl status kdump'
alias kstop='systemctl stop kdump'
alias kstart='systemctl start kdump'

function reboot1
{
	uname=$(uname -r)
#	pgrep vim && return

	[[ $# == 1 ]] && uname=$1

	sync
set -x
	sudo kexec -l /boot/vmlinuz-$uname --reuse-cmdline --initrd=/boot/initramfs-$uname.img
set +x
	sudo kexec -e
}

function disable-firewall
{
	systemctl stop iptables
	systemctl disable iptables

	systemctl stop firewalld
	systemctl disable firewalld
}

# 13
# SUBSYSTEM=="net", ACTION=="add", ATTR{phys_switch_id}=="248a078827ca", ATTR{phys_port_name}!="", NAME="enp4s0f0_$attr{phys_port_name}"
# SUBSYSTEM=="net", ACTION=="add", ATTR{phys_switch_id}=="248a078827cb", ATTR{phys_port_name}!="", NAME="enp4s0f1_$attr{phys_port_name}"
# 14
# SUBSYSTEM=="net", ACTION=="add", ATTR{phys_switch_id}=="248a0788279a", ATTR{phys_port_name}!="", NAME="enp4s0f0_$attr{phys_port_name}"
# SUBSYSTEM=="net", ACTION=="add", ATTR{phys_switch_id}=="248a0788279b", ATTR{phys_port_name}!="", NAME="enp4s0f1_$attr{phys_port_name}"

# /mswg/release/linux/ovs_release/scripts/udev
# /mswg/release/linux/ovs_release/scripts/udev2

alias udevadm_info="udevadm info --path=/sys/class/net/$link"
alias udevadm_info_a="udevadm info -a --path=/sys/class/net/$link"

alias udevadm_test="udevadm test-builtin net_id /sys/class/net/$link"
alias udevadm_info_rep="udevadm info -a --path=/sys/class/net/$rep2"

alias udevadm2="udevadm info -a --path=/sys/class/net/$link2"

function udev-old
{
	local l=$link
	[[ $# == 1 ]] && l=$1
	local file=/etc/udev/rules.d/82-net-setup-link.rules
	local id=$(ip -d link show $l | grep switchid | awk '{print $NF}')
	if [[ -z $id ]]; then
		echo "Please enable switchdev mode"
		return
	fi
#	echo $id
	cat << EOF > $file
SUBSYSTEM=="net", ACTION=="add", ATTR{phys_switch_id}=="$id", \
ATTR{phys_port_name}!="", NAME="${l}_\$attr{phys_port_name}"
EOF
	cat $file
}

mac_start=1
mac_end=26
mac_ns="ip netns exec n1"
mac_ns=""
function macvlan
{
	local l=$link
	if [[ $# == 1 ]]; then
		l=$1
	fi
	for ((i = mac_start; i <= mac_end; i++)); do
#		(( i == 13 )) && continue
		mf1=$(printf %x $i)
		local newlink=${l}.$i
		echo $newlink
		$mac_ns ip link add link $l address 00:11:11:11:11:$mf1 $newlink type macvlan
		$mac_ns ifconfig $newlink 1.1.11.$i/16 up
	done
}

function macvlan2
{
	local l=$link
	if [[ $# == 1 ]]; then
		l=$1
	fi
	for ((i = mac_start; i <= mac_end; i++)); do
		local newlink=${l}.$i
		echo $newlink
#		(( i == 13 )) && continue
		$mac_ns ip link delete link dev $newlink
	done
}

function vcpu
{
	[[ $# != 1 ]] && return
	n=$1

	for (( i = 0; i < n; i++)); do
		echo "	  <vcpupin vcpu='$i' cpuset='$((i*2))'/>"
	done
}

function watchi
{
	watch -d -n 1 "egrep \"mlx5_comp|CPU\" /proc/interrupts"
}

function watchr
{
	watch -d -n 1 "ethtool -S $link | grep \"rx[0-9]*_packets:\""
}

function 1_natan
{
	fw_path=/.autodirect/fwgwork/natano/fw2/mirror_and_decap_wa
	fw_path=/root/mirror_and_decap_wa
	galil_fw_path=${fw_path}_galil/
	mstdev=$pci
	mlxburn -d $mstdev -fw ${galil_fw_path}fw-ConnectX5.mlx -conf_dir ${galil_fw_path} -force
}

# unbind vf first
function q1
{
set -x
	modprobe vfio
	modprobe vfio-pci
	echo 15b3 101a >/sys/bus/pci/drivers/vfio-pci/new_id
	ls /dev/vfio

	pkill -9 qemu
	sleep 1
	qemu-system-x86_64 --enable-kvm \
		-S			\
		-cpu qemu64		\
		-name vm1		\
		-m 4096			\
		-hda /var/lib/libvirt/images/vm1.qcow2	\
		-smp 4,sockets=4,cores=1,threads=1	\
		-netdev user,id=nat1,hostfwd=tcp:127.0.0.1:8000-10.0.2.15:22	\
		-device e1000,netdev=nat1,mac=52:54:00:13:01:01			\
		-device vfio-pci,host=04:00.4,id=hostdev0,bus=pci.0,addr=0x9	\
		-vga std	\
		-vnc :1		\
		-serial "/dev/ttyS0" \
		-daemonize

set +x
}
alias sq1="ssh -p 8000 127.0.0.1"


function q2
{
set -x
	modprobe vfio
	modprobe vfio-pci
	echo 15b3 101a >/sys/bus/pci/drivers/vfio-pci/new_id
	ls /dev/vfio

	qemu-system-x86_64 --enable-kvm \
		-cpu qemu64 -smp 4 -name vm2 -m 1024 -hda /var/lib/libvirt/images/vm2.qcow2 \
		-netdev user,id=nat1,hostfwd=tcp:127.0.0.1:8001-10.0.2.16:22 \
		-device e1000,netdev=nat1,mac=52:54:00:13:01:02 \
		-device vfio-pci,host=04:00.3 \
		-vga std \
		-vnc :3 -daemonize
set +x
}
alias sq2="ssh -p 8001 127.0.0.1"

function qq1
{
	/usr/bin/qemu-system-x86_64 \
		-machine accel=kvm	\
		-name guest=vm1,debug-threads=on	\
		-S -object secret,id=masterKey0,format=raw,file=/var/lib/libvirt/qemu/domain-10-vm1/master-key.aes	\
		-machine pc-i440fx-2.10,accel=kvm,usb=off,dump-guest-core=off	\	
		-cpu Broadwell -m 3815 -realtime mlock=off -smp 1,sockets=1,cores=1,threads=1	\
		-uuid edc5bad7-f54b-43ec-957b-821d197d1a01 -no-user-config -nodefaults		\
		-chardev socket,id=charmonitor,path=/var/lib/libvirt/qemu/domain-10-vm1/monitor.sock,server,nowait	\
		-mon chardev=charmonitor,id=monitor,mode=control -rtc base=utc,driftfix=slew	\
		-global kvm-pit.lost_tick_policy=delay -no-hpet -no-shutdown	\
		-global PIIX4_PM.disable_s3=1 -global PIIX4_PM.disable_s4=1 -boot strict=on	\	
		-device ich9-usb-ehci1,id=usb,bus=pci.0,addr=0x6.0x7	\
		-device ich9-usb-uhci1,masterbus=usb.0,firstport=0,bus=pci.0,multifunction=on,addr=0x6	\
		-device ich9-usb-uhci2,masterbus=usb.0,firstport=2,bus=pci.0,addr=0x6.0x1	\
		-device ich9-usb-uhci3,masterbus=usb.0,firstport=4,bus=pci.0,addr=0x6.0x2	\
		-device virtio-serial-pci,id=virtio-serial0,bus=pci.0,addr=0x5	\
		-drive file=/var/lib/libvirt/images/vm1.qcow2,format=qcow2,if=none,id=drive-virtio-disk0	\
		-device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x7,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1	\
		-drive if=none,id=drive-ide0-0-0,readonly=on	\
		-device ide-cd,bus=ide.0,unit=0,drive=drive-ide0-0-0,id=ide0-0-0	\
		-netdev tap,fd=25,id=hostnet0,vhost=on,vhostfd=27	\
		-device virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:13:02:01,bus=pci.0,addr=0xa	\
		-netdev tap,fd=28,id=hostnet1,vhost=on,vhostfd=29	\
		-device virtio-net-pci,netdev=hostnet1,id=net1,mac=52:54:00:13:01:01,bus=pci.0,addr=0x3	\
		-chardev pty,id=charserial0	\
		-device isa-serial,chardev=charserial0,id=serial0	\
		-chardev socket,id=charchannel0,path=/var/lib/libvirt/qemu/channel/target/domain-10-vm1/org.qemu.guest_agent.0,server,nowait	\
		-device virtserialport,bus=virtio-serial0.0,nr=1,chardev=charchannel0,id=channel0,name=org.qemu.guest_agent.0	\
		-chardev spicevmc,id=charchannel1,name=vdagent	\
		-device virtserialport,bus=virtio-serial0.0,nr=2,chardev=charchannel1,id=channel1,name=com.redhat.spice.0	\
		-device usb-tablet,id=input0,bus=usb.0,port=1	\
		-spice port=5900,addr=127.0.0.1,disable-ticketing,image-compression=off,seamless-migration=on	\
		-device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vram64_size_mb=0,vgamem_mb=16,max_outputs=1,bus=pci.0,addr=0x2	\
		-device intel-hda,id=sound0,bus=pci.0,addr=0x4	\
		-device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0	\
		-chardev spicevmc,id=charredir0,name=usbredir	\
		-device usb-redir,chardev=charredir0,id=redir0,bus=usb.0,port=2	\
		-chardev spicevmc,id=charredir1,name=usbredir	\
		-device usb-redir,chardev=charredir1,id=redir1,bus=usb.0,port=3	\
		-device vfio-pci,host=04:00.2,id=hostdev0,bus=pci.0,addr=0x9	\
		-device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x8	\
		-msg timestamp=on
}

function tc_simple
{
	tc2
set -x
	tc qdisc add dev $link ingress
	tc filter add dev $link parent ffff: protocol ip prio 5 U32 match ip protocol 1 0xff flowid 1:1 action simple "Incoming ICMP" index 1 ok
	tc -s filter ls dev $link parent ffff:
set +x
}

function cx5-power-budget
{
	echo "MLNX_RAW_TLV_FILE" > /tmp/power_conf_tlv.cfg; echo "0x00000004 0x00000088 0x00000000 0xc0000000" >> /tmp/power_conf_tlv.cfg
	mlxconfig -d $pci -f /tmp/power_conf_tlv.cfg set_raw
	mlxconfig -d $pci2 -f /tmp/power_conf_tlv.cfg set_raw
	mlxfwreset -d $pci reset
	mlxfwreset -d $pci2 reset
}

### ecmp ###

# ip r replace 192.168.3.0/24 nexthop via 192.168.1.1 dev $link nexthop via 192.168.2.1 dev $link2

# ip r replace 8.2.10.0/24 nexthop via 7.1.10.1 dev $link nexthop via 7.2.10.1	dev $link2
# ip r replace 7.1.10.0/24 nexthop via 8.2.10.1 dev $link
# ip r replace 7.2.10.0/24 nexthop via 8.2.10.1 dev $link

function enable-multipath
{
	if (( ofed != 1 )); then
		devlink dev eswitch set pci/$pci multipath enable
	else
		echo enabled > /sys/kernel/debug/mlx5/$pci/compat/multipath
	fi
}

function disable-multipath
{
	devlink dev eswitch set pci/$pci multipath disable
}

function getnet()
{
	echo `ipcalc -n $1 | cut -d= -f2`/24
}

function cmd_on()
{
	local host=$1
	shift
	local cmd=$@
	echo "[$host] $cmd"
	sshpass -p 3tango ssh $host -C "$cmd"
}

clean_ovs="service openvswitch restart ; ovs-vsctl list-br | xargs -r -l ovs-vsctl del-br"
clean_vxlan="ip -br l show type vxlan | cut -d' ' -f1 | xargs -I {} ip l del {} 2>/dev/null"

HOST1="10.12.205.14"
HOST1_P1="enp4s0f0"
HOST1_P2="enp4s0f1"

HOST2="10.12.205.13"
HOST2_P1="enp4s0f0"

HOST1_TUN="6.0.10.14"
HOST1_P1_IP="7.1.10.14"
HOST1_P2_IP="7.2.10.14"

HOST2_TUN="9.0.10.13"
HOST2_P1_IP="8.2.10.13"

R1_P1_IP="7.1.10.1"
R1_P2_IP="7.2.10.1"
R1_P3_IP="8.2.10.1"

# HOST1_TUN_NET=`getnet $HOST1_TUN/24`
# HOST2_TUN_NET=`getnet $HOST2_TUN/24`

function ecmp
{
	echo "config $HOST1"
	cmd_on $HOST1 $clean_ovs
	cmd_on $HOST1 $clean_vxlan
	cmd_on $HOST1 "ovs-vsctl add-br ov1 ; ifconfig ov1 $HOST1_TUN/24 up"
	cmd_on $HOST1 "ifconfig $HOST1_P1 $HOST1_P1_IP/24 up ; ifconfig $HOST1_P2 $HOST1_P2_IP/24 up"
	cmd_on $HOST1 "ip r d $HOST2_TUN_NET"
	cmd_on $HOST1 "ip r a $HOST2_TUN_NET nexthop via $R1_P2_IP dev $HOST1_P2 weight 1 nexthop via $R1_P1_IP dev $HOST1_P1 weight 1"
	cmd_on $HOST1 "ovs-vsctl add-br br-vxlan"
	cmd_on $HOST1 "ovs-vsctl add-port br-vxlan vxlan40 -- set interface vxlan40 type=vxlan options:remote_ip=$HOST2_TUN options:local_ip=$HOST1_TUN options:key=40 options:dst_port=4789"
	cmd_on $HOST1 "ovs-vsctl add-port br-vxlan int0 -- set interface int0 type=internal"
	cmd_on $HOST1 "ifconfig int0 1.1.1.14/16 up"
	cmd_on $HOST1 "sysctl -w net.ipv4.fib_multipath_hash_policy=1"

	echo "config $HOST2"
	cmd_on $HOST2 $clean_ovs
	cmd_on $HOST2 $clean_vxlan
	cmd_on $HOST2 "ovs-vsctl add-br ov1 ; ifconfig ov1 $HOST2_TUN/24 up"
	cmd_on $HOST2 "ifconfig $HOST2_P1 $HOST2_P1_IP/24 up"
	cmd_on $HOST2 "ip r d $HOST1_TUN_NET"
	cmd_on $HOST2 "ip r a $HOST1_TUN_NET via $R1_P3_IP dev $HOST2_P1"
	cmd_on $HOST2 "ovs-vsctl add-br br-vxlan"
	cmd_on $HOST2 "ovs-vsctl add-port br-vxlan vxlan40 -- set interface vxlan40 type=vxlan options:remote_ip=$HOST1_TUN options:local_ip=$HOST2_TUN options:key=40 options:dst_port=4789"
	cmd_on $HOST2 "ovs-vsctl add-port br-vxlan int0 -- set interface int0 type=internal"
	cmd_on $HOST2 "ifconfig int0 1.1.1.13/16 up"
}

alias lag="cat /sys/kernel/debug/mlx5/$pci/lag_affinity"
alias lag0="echo 0 > /sys/kernel/debug/mlx5/$pci/lag_affinity"
alias lag1="echo 1 > /sys/kernel/debug/mlx5/$pci/lag_affinity"
alias lag2="echo 2 > /sys/kernel/debug/mlx5/$pci/lag_affinity"

alias show-links="ip link show dev $link; ip link show dev $link2"

function ip-r0
{
	cmd_on $HOST1 "ip r d $HOST2_TUN_NET"
	cmd_on $HOST1 "ip r a $HOST2_TUN_NET nexthop via $R1_P2_IP dev $HOST1_P2 weight 1 nexthop via $R1_P1_IP dev $HOST1_P1 weight 1"
}

function ip-r1
{
	cmd_on $HOST1 "ip r d $HOST2_TUN_NET"
	cmd_on $HOST1 "ip r a $HOST2_TUN_NET nexthop via $R1_P1_IP dev $HOST1_P1 weight 1"
}

function ip-r2
{
	cmd_on $HOST1 "ip r d $HOST2_TUN_NET"
	cmd_on $HOST1 "ip r a $HOST2_TUN_NET nexthop via $R1_P2_IP dev $HOST1_P2 weight 1"
}

function nic-mac
{
	for i in `ls -1 /sys/class/net/*/address`; do
		nic=`echo $i | cut -d/ -f 5`
		address=`cat $i | tr -d :`
		printf "$address\t$nic\n"
	done
}

function port-mirroring
{
	local HOST1=10.12.205.14
	local HOST1_P1=enp4s0f0
	local HOST1_P1_IP=1.1.1.14

	local HOST2=10.12.205.13
	local HOST2_P1=enp4s0f0
	# local HOST2_P1=enp4s0
	local HOST2_P1_IP=2.2.2.13


	echo "config $HOST1"
	cmd_on $HOST1 "ifconfig $HOST1_P1 $HOST1_P1_IP/24 up"
	cmd_on $HOST1 "ip r d 2.2.2.0/24"
	cmd_on $HOST1 "ip r a 2.2.2.0/24 nexthop via 1.1.1.1 dev $HOST1_P1"

	echo "config $HOST2"
	cmd_on $HOST2 "ifconfig $HOST2_P1 $HOST2_P1_IP/24 up"
	cmd_on $HOST2 "ip r d 1.1.1.0/24"
	cmd_on $HOST2 "ip r a 1.1.1.0/24 nexthop via 2.2.2.1 dev $HOST2_P1"
}

function port-mirroring
{
	local HOST1=10.12.205.14
	local HOST1_P1=enp4s0f0
	local HOST1_P1_IP=1.1.1.14

	local HOST2=10.12.205.13
	local HOST2_P1=enp4s0f0
	# local HOST2_P1=enp4s0
	local HOST2_P1_IP=2.2.2.13

	echo "config $HOST1"
	cmd_on $HOST1 "ifconfig $HOST1_P1 $HOST1_P1_IP/24 up"
	cmd_on $HOST1 "ip r d 2.2.2.0/24"

	echo "config $HOST2"
	cmd_on $HOST2 "ifconfig $HOST2_P1 $HOST2_P1_IP/24 up"
	cmd_on $HOST2 "ip r d 1.1.1.0/24"
}

# a=0xffff8807c993edf0; b=0x7c993edf0; printf -v c "%#x" $[a-b] ; echo $c

function sub
{
	[[ $# != 2 ]] && return
	a=0x$1
	b=0x$2
	printf -v c "%#x" $[a-b] ; echo $c
}

function enable-br
{
	echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables
}

###ofed###

alias fr=force-restart

function ofed-unload
{
	for i in ib_srpt ib_isert rpcrdma xprtrdma mlx5_fpga_tools; do
		lsmod | grep $i && sudo modprobe -r $i
	done
}

function force-stop
{
set -x
	sudo /etc/init.d/openibd stop
set +x
}

function force-start
{
set -x
# 	ofed-unload
	sudo /etc/init.d/openibd start
# 	sudo systemctl restart systemd-udevd.service
set +x
}

function force-restart
{
set -x
# 	ofed-unload
	force-stop
	force-start
# 	sudo systemctl restart systemd-udevd.service
set +x
}

if (( centos72 )); then
	function force-restart
	{
	set -x
		stop-ovs
		ofed-unload
		sudo /etc/init.d/openibd force-stop
		reprobe
		sleep 1
		pkill udev
		sleep 1
		sudo systemctl restart systemd-udevd.service
		sleep 1
		pgrep udev
	set +x
	}
fi

alias restart-udev='sudo systemctl restart systemd-udevd.service'

alias ofed-configure-memtrack='./configure --with-mlx5-core-and-en-mod --with-memtrack -j'
alias ofed-configure-all="./configure  --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlxfw-mod --with-mlx5-mod --with-ipoib-mod --with-srp-mod --with-iser-mod --with-isert-mod -j $cpu_num2"
alias ofed-configure="./configure --with-mlx5-core-and-ib-and-en-mod --with-mlxfw-mod -j $cpu_num2"

alias ofed-configure-5.3="./configure --with-mlx5-core-and-ib-and-en-mod --with-mlxfw-mod -j $cpu_num2 --kernel-version 5.3 --kernel-sources /.autodirect/mswg2/work/kernel.org/x86_64/linux-5.3 "
alias ofed-configure-5.0="./configure --with-mlx5-core-and-ib-and-en-mod --with-mlxfw-mod -j $cpu_num2 --kernel-version 5.0 --kernel-sources /.autodirect/mswg2/work/kernel.org/x86_64/linux-5.0 "
alias ofed-configure-4.17="./configure --with-mlx5-core-and-ib-and-en-mod --with-mlxfw-mod -j $cpu_num2 --kernel-version 4.17-rc1 --kernel-sources /.autodirect/mswg2/work/kernel.org/x86_64/linux-4.17-rc1 "
alias ofed-configure-5.9="./configure --with-mlx5-core-and-ib-and-en-mod --with-mlxfw-mod -j $cpu_num2 --kernel-version 5.9-rc2 --kernel-sources /.autodirect/mswg2/work/kernel.org/x86_64/linux-5.9-rc2 "
alias ofed-configure-4.14.3="./configure --with-mlx5-core-and-ib-and-en-mod --with-mlxfw-mod -j $cpu_num2 --kernel-version 4.14.3 --kernel-sources /.autodirect/mswg2/work/kernel.org/x86_64/linux-4.14.3 "
alias ofed-configure-693="./configure --with-mlx5-core-and-ib-and-en-mod --with-mlxfw-mod -j $cpu_num2 --kernel-version 3.10 --kernel-sources /.autodirect/mswg2/work/kernel.org/x86_64/linux-3.10.0-693.el7.x86_64 "
alias ofed-configure-4.12="./configure --with-mlx5-core-and-ib-and-en-mod --with-mlxfw-mod -j $cpu_num2 --kernel-version 4.12 --kernel-sources /.autodirect/mswg2/work/kernel.org/x86_64/linux-4.12-rc6 "

function ofed_configure
{
	smm
	./configure $(cat /etc/infiniband/info  | grep Configure | cut -d : -f 2 | sed 's/"//') -j $cpu_num2
}

function ofed_install
{
	build=OFED-internal-5.2-0.2.8 /mswg/release/ofed/ofed_install --force --basic
}

# alias ofed-configure2="./configure -j32 --with-linux=/mswg2/work/kernel.org/x86_64/linux-4.7-rc7 --kernel-version=4.7-rc7 --kernel-sources=/mswg2/work/kernel.org/x86_64/linux-4.7-rc7 --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlxfw-mod --with-ipoib-mod --with-mlx5-mod"

# ./configure --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlx5-mod --with-mlx4-mod --with-mlx4_en-mod --with-ipoib-mod --with-mlxfw-mod --with-srp-mod --with-iser-mod --with-isert-mod --with-innova-flex --kernel-sources=/images/kernel_headers/x86_64//linux-4.7-rc7 --kernel-version=4.7-rc7 -j 8

function fetch
{
	if [[ $# == 1 ]]; then
		repo=origin
		local branch=$1
		local new_branch=$1
	elif [[ $# == 2 ]]; then
		local repo=$1
		local branch=$2
		local new_branch=$2
	elif [[ $# == 3 ]]; then
		local repo=$1
		local branch=$2
		local new_branch=$3
	else
		return
	fi

	git fetch $repo $branch
	git checkout FETCH_HEAD
	git checkout -b $new_branch
}

function rebase
{
	b=$(test -f .git/index > /dev/null 2>&1 && git branch | grep \* | cut -d ' ' -f2)
	if [[ $# == 0 ]]; then
		repo=origin
		branch=$b
		echo $b
	elif [[ $# == 1 ]]; then
		repo=origin
		local branch=$1
	elif [[ $# == 2 ]]; then
		local repo=$1
		local branch=$2
	else
		return
	fi

	git fetch $repo $branch
	git rebase FETCH_HEAD
}

function tcs
{
	[[ $# != 1 ]] && return
	TC=/images/chrism/iproute2/tc/tc
	TC=tc
	$TC -s filter show dev $1 root
}

function tcs0
{
	[[ $# != 1 ]] && return
	TC=/images/chrism/iproute2/tc/tc
	TC=tc
	$TC -s filter show dev $1 chain 0 root
}

alias vlan-test="while true; do  tc-vlan; rep2; tcs $link; sleep 5; tcv; rep2; tcs $link;  sleep 5; done"
alias vlan-iperf=" iperf3 -c 1.1.1.1 -t 10000 -B 1.1.1.22 -P 1 --cport 6000 -i 0"
alias iperf10=" iperf3 -c 1.1.1.2 -t 10000 -B 1.1.1.22 -P 10 --cport 6000 -i 0"
alias iperf20=" iperf3 -c 1.1.1.2 -t 10000 -B 1.1.1.22 -P 20 --cport 6000 -i 0"
alias iperf1=" iperf3 -c 1.1.1.2 -t 10000 -B 1.1.1.22 -P 1 --cport 6000 -i 0"
alias iperf2=" iperf3 -c 1.1.1.2 -t 10000 -B 1.1.1.22 -P 2 --cport 6000 -i 0"

# alias iperf1=" iperf3 -c 1.1.1.23 -t 10000 -B 1.1.1.22 -P 2 --cport 6000 -i 0"

# alias ovs-enable-debug="ovs-appctl vlog/set tc:file:DBG netdev_tc_offloads:file:DBG"
function enable-ovs-debug
{
set -x
	sudo ovs-appctl vlog/set tc:file:DBG
	sudo ovs-appctl vlog/set dpif_netlink:file:DBG
	sudo ovs-appctl vlog/set netdev_tc_offloads:file:DBG

	sudo ovs-appctl vlog/set netlink:file:DBG
	sudo ovs-appctl vlog/set ofproto_dpif_xlate:file:DBG
	sudo ovs-appctl vlog/set ofproto_dpif_upcall:file:DBG

	sudo ovs-appctl vlog/set dpif_netdev:file:DBG
set +x
}

function q
{
set -x
	tc qdisc show dev $link
	tc qdisc show dev $rep2
	tc qdisc show dev $vx_rep
set +x
}

function tc-qos
{
set -x
	tc qdisc del dev $link root handle 1
	tc qdisc add dev $link root handle 1: cbq avpkt 1000 bandwidth 1Gbit
	tc class add dev $link parent 1: classid 1:1 cbq rate 10000Mbit allot 1500 bounded
	tc filter add dev $link parent 1: protocol ip   u32 match ip  protocol 6 0xff match ip dport 5001 0xffff flowid 1:1
set +x
}

function tc-unqos
{
	tc qdisc del dev $link root handle 1
}

# ping -I ens6 11.196.22.1 -c 100 -s 100 -i 0.05
function ping-all
{
set -x
	local s=32768
	local s=1000
	local c=100
	local iv=0.1

	local start1=10
	local start2=$((start1+1))
	local end=$((start1+numvfs-1))
	local end2=$((numvfs-1))
	for n in $(seq $start2 $end); do
		for i in $(seq 1 $end2); do
			if (( n - start1 != i)); then
				exe n$n ping 1.1.1.$i -i $iv -c $c -s $s &
			fi
			exe n$n ping 1.1.3.$i -i $iv -c $c -s $s &
		done
	done

	if (( ports == 1 )); then
set +x
		return
	fi

	start1=20
	start2=$((start1+1))
	end=$((start1+numvfs-1))
	for n in $(seq $start2 $end); do
		for i in $(seq 1 $end2); do
			if (( n - start1 != i)); then
				exe n$n ping 1.1.2.$i -i $iv -c $c -s $s &
			fi
			exe n$n ping 1.1.4.$i -i $iv -c $c -s $s &
		done
	done
set +x
}

# get vf name from namespace
function get_vf_ns
{
	[[ $# != 1 ]] && return
	local n=$1
	ns=n1$((n))
	ip netns exec $ns ls /sys/class/net | grep en
}

# vf1=$(get_vf $host_num 1 1)
# vf2=$(get_vf $host_num 1 2)

# vf1_2=$(get_vf $host_num 2 1)
# vf2_2=$(get_vf $host_num 2 2)

function hugepage
{
#	mkdir -p /mnt/huge
#	mount -t hugetlbfs nodev /mnt/huge
#	echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

set -x
	mkdir -p /mnt/huge_2M
	mount -t hugetlbfs -o pagesize=2M none /mnt/huge_2M/
	echo 8192 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
	mkdir -p /mnt/huge_1G
	mount -t hugetlbfs -o pagesize=1G none /mnt/huge_1G/
	echo 16 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
set +x
}

function vm1-dpdk
{
set -x
	echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
	cd /root/dpdk-stable-17.11.4/
	./x86_64-native-linuxapp-gcc/app/testpmd -c 0xf -n 4 -w 0000:00:09.0,txq_inline=896 --socket-mem=2048,0 -- --rxq=4 --txq=4 --nb-cores=3 -i set fwd macswap --forward-mode=macswap -i -a --rss-udp
set +x
}

function vm3-dpdk
{
	echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
	cd /root/dpdk-stable-17.11.4/
	./x86_64-native-linuxapp-gcc/app/testpmd -l 0-2 -n 4	-m=1024  -w 0000:00:09.0 -- -i --rxq=2 --txq=2	--nb-cores=2 -i --forward-mode=flowgen -i -a --rss-udp
# 	./x86_64-native-linuxapp-gcc/app/testpmd -l 0-6 -n 4	-m=4096  -w 0000:00:09.0 -- -i --rxq=4 --txq=4	--nb-cores=4 -i --forward-mode=flowgen -i -a --rss-udp
}

function 13-dpdk
{
set -x
	echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
	echo 1024 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
	cd /root/dpdk
	./x86_64-native-linuxapp-gcc/app/testpmd -c 0xf -n 4 -w 0000:04:00.3,txq_inline=896 --socket-mem=2048,0 -- --rxq=4 --txq=4 --nb-cores=3 -i set fwd macswap
set +x
}

function 14-dpdk
{
	echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
	echo 1024 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
	cd /root/dpdk
	 ./x86_64-native-linuxapp-gcc/app/testpmd -l 0-5 -n 4    -m=4096  -w 0000:04:00.3 -- -i --rxq=4 --txq=4  --nb-cores=4 -i --forward-mode=flowgen -i -a --rss-udp
}

function 14-dpdk-pf
{
	echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
	echo 1024 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
	cd /root/dpdk
	 ./x86_64-native-linuxapp-gcc/app/testpmd -l 0-5 -n 4    -m=4096  -w 0000:04:00.0 -- -i --rxq=4 --txq=4  --nb-cores=3 -i --forward-mode=flowgen -i -a --rss-udp
}

function 14-dpdk-icmpecho
{
set -x
	echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
	echo 1024 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
	cd /root/dpdk
	./x86_64-native-linuxapp-gcc/app/testpmd -c 0xf -n 4 -w 0000:04:00.0,txq_inline=896 --socket-mem=2048,0 -- --rxq=4 --txq=4 --nb-cores=1 -i set fwd icmpecho
set +x
}

function 14-dpdk-macswap
{
set -x
	echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
	echo 1024 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
	cd /root/dpdk
	./x86_64-native-linuxapp-gcc/app/testpmd -c 0xf -n 4 -w 0000:04:00.0,txq_inline=896 --socket-mem=2048,0 -- --rxq=4 --txq=4 --nb-cores=1 -i set fwd macswap
set +x
}

function clone-dpdk
{
	git clone https://github.com/DPDK/dpdk.git
	cd dpdk
	git checkout v18.08-rc3
	git checkout -b v18.08-rc3+
}

# ssh chrism@ dev-chrism-vm4
# echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
# /root/dpdk-stable-17.11.4/x86_64-native-linuxapp-gcc/app/testpmd -c 0xf -n 4 -w 0000:00:09.0,txq_inline=896 --socket-mem=2048,0 -- --rxq=4 --txq=4 --nb-cores=3 -i set fwd macswap
# testpmd> set fwd macswap
# testpmd> start
# testpmd> show port stats all

# ssh chrism@ dev-chrism-vm3
# echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
# /root/dpdk-stable-17.11.4/x86_64-native-linuxapp-gcc/app/testpmd -l 0-2 -n 4	-m=1024  -w 0000:00:09.0 -- -i --rxq=2 --txq=2	--nb-cores=2
# testpmd> set fwd flowgen
# testpmd> start
# testpmd> show port stats all

function disable-ipv6
{
	sysctl -a | grep disable_ipv6
	sysctl -w net.ipv6.conf.all.disable_ipv6=1
	sysctl -w net.ipv6.conf.default.disable_ipv6=1
	sysctl -a | grep disable_ipv6
}

function enable-ipv6
{
	sysctl -w net.ipv6.conf.all.disable_ipv6=0
	sysctl -w net.ipv6.conf.default.disable_ipv6=0
}

function book-noga
{
	noga -l -k 7a0d370e3a69f07c8741724a67ba6a6b -U chrism -n dev-r630-03 -t Server -L 168
	noga -l -k 7a0d370e3a69f07c8741724a67ba6a6b -U chrism -n dev-r630-04 -t Server -L 168
}

# if systemctl status NetworkManager > /dev/null 2>&1; then
#	systemctl stop NetworkManager
#	systemctl disable NetworkManager
#	/etc/init.d/network restart
# fi

function set-mangle
{
set -x
	iptables -F -t mangle
	iptables -t mangle -A OUTPUT -j DSCP --set-dscp 0x08
	iptables -L -t mangle
set +x
}

function clear-mangle
{
set -x
	iptables -F -t mangle
	iptables -L -t mangle
set +x
}

function clear-nat
{
	iptables -t nat -X
	iptables -t nat -F
	iptables -t nat -Z
}

function nat
{
# add defaut route in namespace
# ifconfig $rep2 1.1.1.254/24 up
# ip r add default via 1.1.1.254

set -x
	clear-nat
	iptables -t nat -A POSTROUTING -s 1.1.1.1/32 -j SNAT --to-source 8.9.10.1
	iptables -t nat -L
set +x
}

function nat-masq
{
set -x
	clear-nat
	iptables -t nat -A POSTROUTING -o $link -j MASQUERADE
	iptables -t nat -L
set +x
}

function nat-vf
{
set -x
	del-br
	ifconfig $rep2 1.1.1.254/24 up
	ip netns exec n11 ifconfig $vf2 1.1.1.1/24 up
	ip netns exec n11 ip r add default via 1.1.1.254

	clear-nat

 	iptables -t nat -A POSTROUTING -s 1.1.1.1/32 -j SNAT --to-source 8.9.10.13
	ifconfig $link 8.9.10.13/24 up
	ssh 10.75.205.14 ifconfig $link 8.9.10.11/24 up
set +x
}

function veth_nat
{
set -x
	echo 1 > /proc/sys/net/ipv4/ip_forward

	local n=n11
	ip link del veth0
	ip link add veth0 type veth peer name veth1
	ip link set dev veth0 up
	ip addr add 1.1.1.100/24 brd + dev veth0
	ip netns del $n 2>/dev/null
	ip netns add $n
	ip link set dev veth1 netns $n
	ip netns exec $n ip addr add 1.1.1.$host_num/24 brd + dev veth1
	ip netns exec $n ip link set dev veth1 up
	# run the following command after login to namespace
	ip netns exec $n ip route add default via 1.1.1.100

	del-br
	clear-nat

	iptables -t nat -A POSTROUTING -s 1.1.1.$host_num/32 -j SNAT --to-source 8.9.10.$host_num
	ifconfig $link 8.9.10.$host_num/24 up
# 	ssh 10.75.205.14 ifconfig $link 8.9.10.11/24 up
set +x
}

function veth2
{
set -x
	local n=1
	[[ $# == 1 ]] && n=$1

	local ns=n1$n
	local veth=veth$n
	local rep=veth_rep$n
	ip link del $rep 2> /dev/null
	ip link add $rep type veth peer name $veth
	ip link set dev $rep up
	ip addr add 1.1.$n.100/24 brd + dev $rep

	ip link set dev $veth address 02:25:d0:$host_num:01:$i
	ip netns del $ns > /dev/null 2>&1
	ip netns add $ns
	ip link set dev $veth netns $ns
	ip netns exec $ns ip addr add 1.1.$n.1/24 brd + dev $veth
	ip netns exec $ns ip link set dev $veth up
	ip netns exec $ns ip route add default via 1.1.$n.100
set +x
}

function veths_nat
{
set -x
	local n=1
	[[ $# == 1 ]] && n=$1

	echo 1 > /proc/sys/net/ipv4/ip_forward

	for (( i = 1; i <= n; i++ )); do
		veth2 $i
	done

	del-br
	clear-nat

	# if --to-source is the default router, veths can access internet
	iptables -t nat -A POSTROUTING -s 1.1.0.0/16 -j SNAT --to-source 8.9.10.1-8.9.10.10
	for (( i = 1; i <= 10; i ++ )); do
		ifconfig $link:$i 8.9.10.$i/24 up
	done
# 	ssh 10.75.205.14 ifconfig $link 8.9.10.11/24 up
set +x
}

function disable-networkmanager
{
	systemctl stop NetworkManager
	systemctl disable NetworkManager
}

alias ofed1='./ofed_scripts/backports_fixup_changes.sh'
alias ofed2='./ofed_scripts/ofed_get_patches.sh'

function ofed3
{
	[[ $# == 0 ]] && return

	git checkout $1
	./ofed_scripts/backports_copy_patches.sh
	git add backports
	git commit -s backports/
}

alias ofed='rej; git add -u; ofed1; ofed2'

alias ofed-meta='./devtools/add_metadata.sh'
alias ofed-meta-check='/images/chrism/mlnx-ofa_kernel-4.0//devtools/verify_metadata.sh -p /images/chrism/mlnx-ofa_kernel-4.0//metadata/Chris_Mi.csv'

# add $rep2 and uplink rep to bridge
# only $rep2 can initiate new tcp connection to remote host
function ct1
{
set -x
	bru

	sudo ovs-ofctl del-flows $br
	sudo ovs-ofctl add-flow $br table=0,arp,action=normal
	sudo ovs-ofctl add-flow $br table=0,icmp,action=normal
	sudo ovs-ofctl add-flow $br "table=0,tcp,ct_state=-trk actions=ct(table=1)"
	sudo ovs-ofctl add-flow $br "table=1, ct_state=+trk+new,tcp,in_port=$rep2 actions=ct(commit),normal"
	sudo ovs-ofctl add-flow $br "table=1, ct_state=+trk+est,tcp actions=normal"
set +x
}

# [root@dev-r630-03 bin]# dp dump-flows
# recirc_id(0xa),in_port(4),ct_state(+trk),ct_mark(0x1),eth(),eth_type(0x0800),ipv4(proto=6,frag=no), packets:63, bytes:4158, used:0.814s, flags:., actions:3
# recirc_id(0),in_port(3),eth(),eth_type(0x0800),ipv4(proto=6,frag=no), packets:64, bytes:4350, used:0.814s, flags:P., actions:2,ct(commit,mark=0x1/0xffffffff),4
# recirc_id(0),in_port(4),ct_state(-trk),eth(),eth_type(0x0800),ipv4(proto=6,frag=no), packets:63, bytes:4158, used:0.814s, flags:., actions:2,ct,recirc(0xa)

function ct2
{
set -x
	restart-ovs
	ovs-ofctl add-flow $br table=0,priority=1,action=drop
	ovs-ofctl add-flow $br table=0,arp,action=normal
	ovs-ofctl add-flow $br "table=0,in_port=2,tcp,action=ct(commit,exec(set_field:1->ct_mark)),3"
	ovs-ofctl add-flow $br "table=0,in_port=3,ct_state=-trk,tcp,action=ct(table=1)"
	ovs-ofctl add-flow $br "table=1,in_port=3,ct_state=+trk,ct_mark=1,tcp,action=2"
set +x
}

function ct3
{
set -x
	restart-ovs
	ovs-ofctl add-flow $br table=0,priority=1,action=drop
	ovs-ofctl add-flow $br table=0,priority=10,arp,action=normal
	ovs-ofctl add-flow $br "table=0,priority=100,ip,ct_state=-trk,action=ct(table=1),1"
	ovs-ofctl add-flow $br "table=1,in_port=2,ip,ct_state=+trk+new,action=ct(commit),3"
	ovs-ofctl add-flow $br "table=1,in_port=2,ip,ct_state=+trk+est,action=3"
	ovs-ofctl add-flow $br "table=1,in_port=3,ip,ct_state=+trk+new,action=drop"
	ovs-ofctl add-flow $br "table=1,in_port=3,ip,ct_state=+trk+est,action=2"
set +x
}

function ct3
{
set -x
	restart-ovs
	ovs-ofctl add-flow $br table=0,priority=1,action=drop
	ovs-ofctl add-flow $br table=0,priority=10,arp,action=normal
	ovs-ofctl add-flow $br "table=0,priority=100,ip,ct_state=-trk,action=ct(table=1),$br"
	ovs-ofctl add-flow $br "table=1,in_port=$rep2,ip,ct_state=+trk+new,action=ct(commit),$rep3"
	ovs-ofctl add-flow $br "table=1,in_port=$rep2,ip,ct_state=+trk+est,action=$rep3"
	ovs-ofctl add-flow $br "table=1,in_port=$rep3,ip,ct_state=+trk+new,action=drop"
	ovs-ofctl add-flow $br "table=1,in_port=$rep3,ip,ct_state=+trk+est,action=$rep2"
set +x
}

function ct-mark-icmp
{
set -x
	restart-ovs
	ovs-ofctl add-flow $br table=0,priority=1,action=drop
	ovs-ofctl add-flow $br table=0,arp,action=normal
	ovs-ofctl add-flow $br "table=0,in_port=$rep2,icmp,action=ct(commit,exec(set_field:1->ct_mark)),$rep3"
	ovs-ofctl add-flow $br "table=0,in_port=$rep3,ct_state=-trk,icmp,action=ct(table=1)"
	ovs-ofctl add-flow $br "table=1,in_port=$rep3,ct_state=+trk,ct_mark=1,icmp,action=$rep2"
set +x
}

function ct4
{
set -x
	restart-ovs
	local file=/tmp/of1.txt
	cat << EOF > $file
table=0,priority=1 action=drop
EOF
# table=0,priority=10,arp,action=normal
# table=0,priority=100,ip,ct_state=-trk,action=ct(table=1),1
# table=1,in_port=2,ip,ct_state=+trk+new,action=ct(commit),"
# table=1,in_port=2,ip,ct_state=+trk+est,action=3
# table=1,in_port=3,ip,ct_state=+trk+new,action=drop
# table=1,in_port=3,ip,ct_state=+trk+est,action=2

	ovs-ofctl add-flow -O openflow13 $br $file
set +x
}

# https://fedoraproject.org/wiki/Building_a_custom_kernel
# dnf download --source kernel

alias make-rpm='make -s -j32 rpm-pkg RPM_BUILD_NCPUS=32'

pkgrelease_file=/tmp/pkgrelease
function git-archive
{
	export CONFIG_LOCALVERSION_AUTO=y
	if (( ofed == 1 )); then
		local pkgrelease=$(make kernelrelease | cut -d- -f2)
		git archive --format=tar --prefix=linux-3.10.0-$pkgrelease/ -o linux-3.10.0-${pkgrelease}.tar HEAD
	fi
	if (( ofed == 0 )); then
		local pkgrelease=$(make kernelrelease)
		git archive --format=tar --prefix=linux-$pkgrelease/ -o linux-${pkgrelease}.tar HEAD
	fi
	echo $pkgrelease > $pkgrelease_file
}

function centos-cp
{
set -x
	local src=/labhome/chrism/rpmbuild/1.5.4
	local dst=/images/mi/rpmbuild
	local dst_sources=$dst/SOURCES
	local dst_specs=$dst/SPECS
#	local ldir=/images/chrism/linux
	local ldir=/images/vladbu/src/linux
	/bin/rm -rf $dst_sources/*.tar
	/bin/rm -rf $dst_sources/*.tar.xz
	/bin/rm -rf $dst/BUILD/*

	local pkgrelease=$(cat $pkgrelease_file)
	/bin/cp -f $ldir/linux-3.10.0-${pkgrelease}.tar $dst_sources
	/bin/cp -f $src/kernel-3.10.0-x86_64.config $dst_sources
	/bin/cp -f $src/kernel-3.10.0-x86_64-debug.config $dst_sources

	/bin/cp -f $src/kernel.spec $dst_specs
	sed -i "s/pkgrelease 693.21.1.el7/pkgrelease $pkgrelease/" $dst_specs/kernel.spec
set +x
}

function centos-yum-remove
{
	sudo yum remove -y rpm-build redhat-rpm-config asciidoc hmaccalc perl-ExtUtils-Embed pesign xmlto 
	sudo yum remove -y audit-libs-devel binutils-devel elfutils-devel elfutils-libelf-devel java-devel
	sudo yum remove -y ncurses-devel newt-devel numactl-devel pciutils-devel python-devel zlib-devel
}

function centos-yum
{
	sudo yum install -y rpm-build redhat-rpm-config asciidoc hmaccalc perl-ExtUtils-Embed pesign xmlto 
	sudo yum install -y audit-libs-devel binutils-devel elfutils-devel elfutils-libelf-devel java-devel
	sudo yum install -y ncurses-devel newt-devel numactl-devel pciutils-devel python-devel zlib-devel
}

#  rpmdev-setuptree
function centos-dir
{
	[[ "$USER" != "mi" ]] && return

	mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
	echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros
}
function centos-src
{
	cd ~/rpmbuild/SPECS
	rpmbuild -bp --target=$(uname -m) kernel.spec
}
function centos-build-nodebuginfo
{
	/bin/rm -rf /images/mi/rpmbuild/RPMS/x86_64/*
	cd ~/rpmbuild/SPECS
#	time rpmbuild -bb --target=`uname -m` kernel.spec 2> build-err.log | tee build-out.log
	time rpmbuild -bb --target=`uname -m` --without kabichk --with baseonly --without debug --without debuginfo kernel.spec 2> build-err.log | tee build-out.log
}

function centos-build
{
	/bin/rm -rf /images/mi/rpmbuild/RPMS/x86_64/*
	cd ~/rpmbuild/SPECS
#	time rpmbuild -bb --target=`uname -m` kernel.spec 2> build-err.log | tee build-out.log
	time rpmbuild -bb --target=`uname -m` --without kabichk --with baseonly --without debug kernel.spec 2> build-err.log | tee build-out.log
}

function centos-uninstall
{
	local kernel=3.10.0-g5c5c769.x86_64

	cd /images/mi/rpmbuild/RPMS/x86_64
#	sudo rpm -e kernel-headers-$kernel --nodeps
	sudo rpm -e kernel-debuginfo-common-x86_64-$kernel --nodeps
	sudo rpm -e kernel-tools-$kernel --nodeps
	sudo rpm -e kernel-tools-libs-$kernel --nodeps
}

alias install-kernel="sudo rpm -ivh kernel-*.rpm --force"

function centos-install
{
	cd /images/mi/rpmbuild/RPMS/x86_64
	install-kernel
}

function addflow2
{
	local file=/tmp/of.txt
	count=10000
	cur=0
	rm -f $file

	for ((k=0;k<=3;k++))
	do
	    for((i=0;i<=254;i++))
	    do
		for((j=0;j<=254;j++))
		do
		    echo "ovs-ofctl add-flow $br -O openflow13 \"table=0, priority=10, ip,nw_dst=10.$k.$i.$j, in_port=enp4s0f0_2, action=output:vxlan0\""
		    let cur+=1
		    [ $cur -eq $count ] && break;
		done
		[ $cur -eq $count ] && break;
	    done
	    [ $cur -eq $count ] && break;
	done >> $file

	br=br
	set -x
	bash $file
	ovs-ofctl dump-flows $br | wc -l
	set +x
}

function addflow
{
	local file=/tmp/of.txt
	count=1000
	[[ $# == 1 ]] && count=$1
	cur=0
	rm -f $file

	for ((k=0;k<=255;k++))
	do
	    for((i=0;i<=255;i++))
	    do
		for((j=0;j<=255;j++))
		do
		    echo "table=0,priority=10,ip,nw_dst=10.$k.$i.$j,in_port=enp4s0f0_0,action=output:enp4s0f0"
		    let cur+=1
		    [ $cur -eq $count ] && break;
		done
		[ $cur -eq $count ] && break;
	    done
	    [ $cur -eq $count ] && break;
	done >> $file

	br=br
	set -x
	ovs-ofctl add-flows $br -O openflow13 $file
	ovs-ofctl dump-flows $br | wc -l
	set +x
}

function addflow-mac
{
	local file=/tmp/of.txt
	count=1
	[[ $# == 1 ]] && count=$1
	cur=0
	rm -f $file

	~chrism/bin/of-mac.py -n $count $file

set -x
	br=br
	ovs-ofctl del-flows $br
	ovs-ofctl add-flows $br -O openflow13 $file
	ovs-ofctl dump-flows $br | wc -l
set +x
}

function addflow-port
{
	local file=/tmp/of.txt
	rm -f $file

	bru
	restart-ovs
	max_ip=1
	for(( ip = 200; ip < $((200+max_ip)); ip++)); do
		for(( src = 1; src < 65535; src++)); do

			# on kernel 5.4, remove priority

# 			echo "table=0,priority=1,udp,nw_src=1.1.1.$ip,tp_src=$src,in_port=enp4s0f0,action=output:enp4s0f0_1"
# 			echo "table=0,priority=1,udp,nw_dst=1.1.1.$ip,tp_dst=$src,in_port=enp4s0f0_1,action=output:enp4s0f0"

			# on kernel 4.19.36, add priority

			echo "table=0,priority=1,udp,nw_src=1.1.1.$ip,tp_src=$src,in_port=enp4s0f0,action=output:enp4s0f0_1"
			echo "table=0,priority=1,udp,nw_dst=1.1.1.$ip,tp_dst=$src,in_port=enp4s0f0_1,action=output:enp4s0f0"
		done
	done >> $file

	br=br
	set -x
	ovs-ofctl add-flows $br -O openflow13 $file
	ovs-ofctl dump-flows $br | wc -l
	set +x
}

function addflow-port2
{
	local file=/tmp/of.txt
	rm -f $file

	restart-ovs
	for(( src = 10000; src < 15000; src++)); do
		for(( dst = 10000; dst < 10050; dst++)); do
			echo "table=0,priority=10,udp,nw_dst=1.1.1.220,tp_dst=$dst,tp_src=$src,in_port=$link,action=output:$rep2"
		done
	done >> $file

	br=br
	set -x
	ovs-ofctl add-flows $br -O openflow13 $file
	ovs-ofctl dump-flows $br | wc -l
	set +x
}

function addflow_tcp_port
{
	local file=/tmp/of.txt
	rm -f $file

	bru
	restart-ovs
	max_ip=1
	for(( src = 42300; src < 43400; src++)); do
		echo "table=0,priority=1,tcp,tp_src=$src,in_port=$rep2,action=output:$link"
	done >> $file

	br=br
	set -x
	ovs-ofctl add-flows $br -O openflow13 $file
	ovs-ofctl dump-flows $br | wc -l
	set +x
}

function addflow-ip
{
	local file=/tmp/of.txt
	rm -f $file
	[[ $# != 1 ]] && return
	num=$1

	n=0
	restart-ovs
	for(( i = 0; i <= 255; i++)); do
		for(( j = 0; j <= 255; j++)); do
			for(( k = 0; k <= 255; k++)); do
				echo "table=0,priority=10,ip,nw_src=10.$i.$j.$k,in_port=enp4s0f0_1,action=output:enp4s0f0_2"
#				echo "table=0,priority=10,ip,nw_src=10.$i.$j.$k,dl_dst=02:25:d0:$host_num:01:03,in_port=enp4s0f0_1,action=output:enp4s0f0_2"
#				echo "table=0,priority=10,ip,nw_src=10.$i.$j.$k,dl_dst=24:8a:07:88:27:cb,in_port=enp4s0f0_1,action=output:enp4s0f0"
				(( n++ ))
				(( n >= num )) && break
			done
			(( n >= num )) && break
		done
		(( n >= num )) && break
	done >> $file

	br=br
	set -x
#	ovs-ofctl add-flow $br "dl_dst=00:00:00:00:00:00 table=0,priority=20,action=drop"
	ovs-ofctl add-flows $br -O openflow13 $file
	ovs-ofctl dump-flows $br | wc -l
	set +x
}
alias a3='addflow-ip 300000'
alias a25='addflow-ip 250000'
alias a10='addflow-ip 1000000'
alias a5='addflow-ip  500000'
alias a1='addflow-ip 100000'
alias a100='addflow-ip 100'

#     tc_filter add dev $VXLAN protocol ip parent ffff: prio 1 flower \
#                     enc_key_id 100 enc_dst_port 4789 src_mac $VM_DST_MAC \
#                     enc_src_ip $TUN_SRC_V4 \
#                     action drop
 
alias send='/labhome/chrism/prg/python/scapy/send.py'
alias visend='vi /labhome/chrism/prg/python/scapy/send.py'
alias sendm='/labhome/chrism/prg/python/scapy/m.py'

# alias make-dpdk='sudo make install T=x86_64-native-linuxapp-gcc -j DESTDIR=install'
# alias make-dpdk='sudo make install T=x86_64-native-linuxapp-gcc -j DESTDIR=/usr'

alias ofed_debian='./mlnxofedinstall --without-fw-update  --force-dkms --force'
# ./mlnxofedinstall  --upstream-libs --dpdk --without-fw-update
alias ofed_dpdk='./mlnxofedinstall  --upstream-libs --dpdk --without-fw-update --force --with-mft --with-mstflint'

# edit config/common_base  to enable mlx5
# CONFIG_RTE_LIBRTE_MLX5_PMD=y 

function make-dpdk
{
# 	cd $DPDK_DIR
#	make config T=x86_64-native-linuxapp-gcc
#	make -j32 T=x86_64-native-linuxapp-gcc

	export RTE_SDK=`pwd`
	export RTE_TARGET=x86_64-native-linuxapp-gcc
	make install T=x86_64-native-linuxapp-gcc -j16
}

# alias pmd1="$DPDK_DIR/build/app/testpmd -l 0-8 -n 4 --socket-mem=1024,1024 -w 04:00.0 -w 04:00.2 -- -i"
# alias pmd1k="$DPDK_DIR/build/app/testpmd1k -l 0-8 -n 4 --socket-mem=1024,1024 -w 04:00.0 -w 04:00.2 -- -i"
# alias pmd10k="$DPDK_DIR/build/app/testpmd10k -l 0-8 -n 4 --socket-mem=1024,1024 -w 04:00.0 -w 04:00.2 -- -i"
# alias pmd100k="$DPDK_DIR/build/app/testpmd100k -l 0-8 -n 4 --socket-mem=1024,1024 -w 04:00.0 -w 04:00.2 -- -i"
# alias pmd200k="$DPDK_DIR/build/app/testpmd200k -l 0-8 -n 4 --socket-mem=1024,1024 -w 04:00.0 -w 04:00.2 -- -i"

alias viflowgen="cd $DPDK_DIR; vim app/test-pmd/flowgen.c"
alias viflowgen2="vim app/test-pmd/flowgen.c"
alias vimacswap="vim app/test-pmd/macswap.c"
alias vicommon_base="cd $DPDK_DIR; vim config/common_base"

function ln-ofed
{
set -x
	ln -s ofed_scripts/Makefile
	ln -s ofed_scripts/makefile
	ln -s ofed_scripts/configure
set +x
}

pg_linux=/images/chrism/linux
uname -r | grep 3.10.0 > /dev/null && pg_linux=/images/chrism/linux-4.19
uname -r | grep 3.10.0-862 > /dev/null && pg_linux=/images/chrism/linux
alias gen='$pg_linux/samples/pktgen/pktgen_sample01_simple.sh'
alias genm='$pg_linux/samples/pktgen/pktgen_sample04_many_flows.sh'
alias gen2='gen -i $vf2 -m 02:25:d0:13:01:03 -d 1.1.1.23'
alias gen1='gen -i $vf1 -m 02:25:d0:13:01:03 -d 1.1.1.23'

# alias g1='genm -i $vf2 -m 24:8a:07:88:27:ca -d 192.168.1.14'
# alias g2='genm -i $vf2 -m 24:8a:07:88:27:9a -d 192.168.1.13'

# alias g3='genm -i $vf2 -m 02:25:d0:13:01:03 -d 1.1.1.23'
# alias g4='genm -i $vf2 -m 02:25:d0:14:01:03 -d 1.1.1.123'

function pgset1
{
	sml
	export PGDEV=/proc/net/pktgen/$vf2@0
#	source $pg_linux/samples/pktgen/functions.sh
	source $pg_linux/samples/pktgen/functions.sh
	pgset "flag !IPSRC_RND"
	pgset "delay 0"
	pgset "src_min 10.0.0.0"
	cat /$PGDEV
}

function set-10
{
	pgset1
	pgset "src_max 10.0.0.9"
}

function set1
{
	pgset1
	pgset "src_max 10.1.134.160"	#   100,000
}
function set2
{
	pgset1
	pgset "src_max 10.3.13.64"	#   200,000
}
function set25
{
	pgset1
	pgset "src_max 10.3.208.144"	#   250,000
}
function set3
{
	pgset1
	pgset "src_max 10.4.147.224"	#   300,000
}
function set27
{
	pgset1
	pgset "src_max 10.4.30.176"	# 270,000
}

function set5
{
	pgset1
	pgset "src_max 10.7.161.32"	# 270,000
}

function set10
{
	pgset1
	pgset "src_max 10.15.66.64"	# 1,000,000
}

function set100
{
	pgset1
	pgset "src_max 10.0.0.100"	# 100
}

function checkout1
{
	[[ $# != 1 ]] && return
	git branch
	git checkout net-nex5-mlx5
	git branch -D 1
	git branch 1
	git checkout 1
	git reset --hard $1
}

function vr
{
	[[ $# != 1 ]] && return
	local file=$(echo ${1%.*})
#	vimdiff ${file}*
	echo $file
	vim -O ${file} $1
}

function v
{
	[[ $# != 1 ]] && return
	local file=$(echo ${1%:*})
	if echo $file | grep :; then
		local file2=$(echo $file | sed "s/:/\ +/")
		vim $file2
	else
		local file2=$(echo $1 | sed "s/:/\ +/")
		vim $file2
	fi
}

function va
{
	[[ $# != 1 ]] && return
	local file=$1
	local file2
	echo $file | egrep "^a\/||^b\/" > /dev/null || return
	file2=$(echo $file | sed "s/^..//")
	vi $file2
}

function vt
{
	[[ $# != 1 ]] && return
	echo \"${1}\"
	local name=$(echo "$1" | cut -d \( -f 1)
	echo $name
}

function test_basic_L3
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	ip1="1.1.1.1"
	ip2="1.1.1.2"
	ip=ipv4

	ip1="2001:0db8:85a3::8a2e:0370:7334"
	ip2="2001:0db8:85a3::8a2e:0370:7335"
	ip=ipv6

	TC=/images/chrism/iproute2/tc/tc
	TC=tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $link ingress

	ethtool -K $rep2 hw-tc-offload on 
	ethtool -K $link hw-tc-offload on 

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $link ingress 

	local p=1
	for skip in "" skip_hw skip_sw ; do
		for nic in $link $rep2 ; do
			tc filter add dev $nic protocol $ip parent ffff: prio $p flower $offload \
				dst_mac e4:11:22:11:4a:51 \
				src_mac e4:11:22:11:4a:50 \
				src_ip $ip1 \
				dst_ip $ip2 \
				action drop
			p=$(( p + 1 ))
		done
	done
set +x
}

function tc-nomatch
{
set -x
	TC=tc
	$TC qdisc del dev $link ingress
	ethtool -K $link hw-tc-offload on 
	$TC qdisc add dev $link ingress 
	$TC filter add dev $link parent ffff: flower skip_sw action drop
set +x
}

alias from-test-stop=' ./test-all-dev.py --stop --from_test'
alias test-all='./test-all.py -g "test-tc-*" -e "test-tc-par*" -e "test-tc-traff*"'
alias test-all='./test-all.py -g "test-tc-*" -e "test-tc-par*" -e "test-tc-traff*" -e "test-tc-insert-rules-port2.sh" -e "test-tc-merged-esw-vf-pf.sh" -e "test-tc-merged-esw-vf-vf.sh" -e "test-tc-multi-prio-chains.sh" -e "test-tc-vf-remote-mirror.sh"'
alias test-all='./test-all.py -e "test-tc-par*" -e "test-tc-traff*" -e "test-tc-insert-rules-port2.sh" -e "test-tc-merged-esw-vf-pf.sh" -e "test-tc-merged-esw-vf-vf.sh" -e "test-tc-multi-prio-chains.sh" -e "test-tc-vf-remote-mirror.sh"'
alias test-all='./test-all.py -e "test-tc-par*" -e "test-tc-traff*"'
alias test-all='./test-all.py -e "test-all-dev.py"'
alias test-all-stop='./test-all.py -e "test-all-dev.py" --stop'
alias from-test='./test-all.py --from_test'
alias test-all='./test-all.py -e "test-all-dev.py" -e "*-ct-*" -e "*-ecmp-*" '

alias test-tc='./test-all.py -g "test-tc-*" -e test-tc-hairpin-disable-sriov.sh -e test-tc-hairpin-rules.sh'
alias test-tc='./test-all.py -g "test-tc-*"'

test1=test-tc-sample.sh
test1=test-ovs-ct-vxlan-vf-mirror.sh
alias test1="./$test1"
alias vi-test="vi ~chrism/asap_dev_reg/$test1"
alias term_test="./test-vxlan-rx-vlan-push-offload.sh"
alias psample='/labhome/chrism/asap_dev_reg/psample/psample'
alias stack_devices='././test-ovs-vf-tunnel.sh'

test2=test-ovs-sflow.sh
alias test2="./$test2"
alias vi-test2="vi ~chrism/asap_dev_reg/$test2"

function get-diff
{
	local v="-v"
	[[ "$1" == "config" ]] && v=""
	local dir=/labhome/chrism/backport/vlad/1
	for i in $dir/*; do
		if diffstat -l $i | grep $v "\.config" > /dev/null 2>&1 &&
		   diffstat -l $i | grep $v "\.gitignore" > /dev/null 2>&1; then
			echo $i
			git apply $i
		fi
	done

	if [[ "$1" == "config" ]]; then
		make arch=x86_64 listnewconfig
		sed -i "1i# x86_64" .config
		sed -i "s/x86 3/x86_64 3/g" .config
	fi

	git add -A
	git commit -a -m mlx
	git-patch ~/backport/ 1
}

function tc-bad-egdev-rules
{
set -x
	ip link del veth0
	ip link add veth0 type veth peer name veth1
	tc qdisc add dev veth0 ingress

	tc filter add dev veth0 protocol ip parent ffff: \
		flower \
			dst_mac e4:11:22:11:4a:51 \
		    action mirred egress redirect dev $rep2

	tc filter show dev veth0 ingress
set +x
}

# test-vf-veth-fwd.sh
function veth
{
set -x
	local n=1
	[[ $# != 1 ]] && return
	[[ $# == 1 ]] && n=$1

	local ns=n1$n
	local veth=veth$n
	local rep=veth_rep$n
	ip link del $rep 2> /dev/null
	ip link add $rep type veth peer name $veth
	ip link set dev $rep up
# 	ip addr add 1.1.1.$n/24 brd + dev $rep

	ip link set dev $veth address 02:25:d0:$host_num:01:$i
	ip netns del $ns > /dev/null 2>&1
	ip netns add $ns
	ip link set dev $veth netns $ns
	ip netns exec $ns ip addr add 1.1.1.$n/24 brd + dev $veth
	ip netns exec $ns ip link set dev $veth up
set +x
}

function veths
{
	local n=1
	[[ $# != 1 ]] && return
	[[ $# == 1 ]] && n=$1

	for (( i = 1; i <= n; i++ )); do
		veth $i
	done
}

function veths_delete
{
	local n=1
	[[ $# != 1 ]] && return
	[[ $# == 1 ]] && n=$1
	
	for (( i = 1; i <= n; i++ )); do
		local rep=veth_rep$i
		local ns=n1$i

set -x
		ip link del $rep 2> /dev/null
		ip netns del $ns > /dev/null 2>&1
set +x
	done
}

function veth-vm1
{
set -x
	local n=n11
	ip link del veth0
	ip link add veth0 type veth peer name veth1
	ip link set dev veth0 up
	brctl addif br0 veth0
	ip link set dev veth1 netns $n
	ip netns exec $n ip addr add 10.12.205.16/24 brd + dev veth1
	ip netns exec $n ip route add default via 10.12.205.1 dev veth1
	ip netns exec $n ip link set dev veth1 up
	ip netns exec $n /usr/sbin/sshd -o PidFile=/run/sshd-oob.pid
# 	ip netns exec $n hostname dev-chrism-vm1
	ip netns exec $n sysctl -w kernel.sched_rt_runtime_us=-1
set +x
}

function veth-vm1-2
{
	ip route add default via 10.12.205.1 dev veth1
	/usr/sbin/sshd -o PidFile=/run/sshd-oob.pid
	sysctl -w kernel.sched_rt_runtime_us=-1
}

alias n11-sshd='ip netns exec n11 /usr/sbin/sshd -o PidFile=/run/sshd-oob.pid'
alias n11-rt='ip netns exec n11 sysctl -w kernel.sched_rt_runtime_us=-1'

function veth1
{
	ovs-vsctl add-port $br veth0
}

function veth-flow
{
	ovs-ofctl add-flow $br "priority=20,dl_dst=11:11:11:11:11:11,actions=drop"
	for i in {6000..6009..1}; do
		ovs-ofctl add-flow br "priority=10,in_port=$rep2,tcp,tcp_src=$i,actions=output:veth0"
	done
}
alias iperf1='iperf3 -c 1.1.1.34 --cport 6000 -B 1.1.1.122 -P 10'

alias cd-trace='cd /sys/kernel/debug/tracing'
function trace1
{
	cd-trace
	echo kmem:kmalloc > set_event
	cat trace | awk '{print $9}' | cut -d = -f 2 | sort | uniq
}

function clear-trace
{
	cd-trace
	echo > trace
}

function git-author
{
	[[ $# != 1 ]] && return
	git log --tags --source --author="$1@mellanox.com"
}

function git-author2
{
	[[ $# != 1 ]] && return
	git log --tags --source --author="$1"
}

function ln-crash
{
	cd $crash_dir
	local dir=$(ls -td */ | head -1)
	local n=$(ls vmcore* | wc -l)
	if [[ -f ${dir}vmcore ]]; then
		ln -s ${dir}vmcore vmcore.$n
	else
		echo "no vmcore"
	fi
}

function diff1
{
set -x
	local dir=drivers/net/ethernet/mellanox/mlx5/core/
	colordiff -u /images/mi/rpmbuild/BUILD/kernel-3.10.0-693.21.1.el7/linux-3.10.0-693.21.1.el7.x86_64/$dir/$1 /home1/chrism/linux-4.19/$dir/$1 | less -r
set +x
}

function replace1
{
	local n=1
	local l=$link
	[[ $# == 1 ]] && n=$1
	tc qdisc del dev $l ingress;
	tc qdisc add dev $l ingress;
	ethtool -K $l hw-tc-offload on 
	for i in $(seq $n); do
		echo $i
		tc filter replace dev $l protocol 0x806 parent ffff: prio 8 handle 0x1 flower dst_mac e4:11:22:11:4a:51 src_mac e4:11:22:11:4a:50 action drop
		tcs $l
	done
}

function tc-udp2
{
	local file=/tmp/udp.txt
	/bin/rm -f $file
	local num=1
	local n=0
	local l=$rep2
	[[ $# == 1 ]] && num=$1
	tc qdisc del dev $l ingress > /dev/null 2>&1;
	tc qdisc add dev $l ingress;
	ethtool -K $l hw-tc-offload on 

	for(( i = 0; i <= 255; i++)); do
		for(( j = 0; j <= 255; j++)); do
			for(( k = 0; k <= 255; k++)); do
				echo "filter add dev $l prio 1 protocol ip parent ffff: flower skip_sw ip_proto udp src_ip 10.$i.$j.$k dst_mac 02:25:d0:$host_num:01:03 action mirred egress redirect dev enp4s0f0_2"
				(( n++ ))
				(( n >= num )) && break
			done
			(( n >= num )) && break
		done
		(( n >= num )) && break
	done >> $file

	echo "begin"

	TC=/images/chrism/iproute2/tc/tc
	time $TC -b $file
}

# split -l 100000 /tmp/udp.txt tc
# for i in tc*; do
#	echo $i; time tc -b $i &
# done

function tc-udp
{
	local file=/tmp/udp.txt
	/bin/rm -f $file
	local num=1
	local n=0
	local l=$rep2
	[[ $# == 1 ]] && num=$1
	tc qdisc del dev $l ingress > /dev/null 2>&1;
	tc qdisc add dev $l ingress;
	ethtool -K $l hw-tc-offload on 

	time for(( i = 0; i <= 255; i++)); do
		for(( j = 0; j <= 255; j++)); do
			for(( k = 0; k <= 255; k++)); do
				echo "filter add dev $l prio 1 protocol ip parent ffff: flower skip_hw ip_proto udp src_ip 10.$i.$j.$k action mirred egress redirect dev enp4s0f0_2"
				(( n++ ))
				(( n >= num )) && break
			done
			(( n >= num )) && break
		done
		(( n >= num )) && break
	done >> $file

	return

	echo "begin"

	TC=/images/chrism/iproute2/tc/tc
	time $TC -b $file
}

function replace
{
	local l=$link
	tc filter replace dev $l protocol 0x806 parent ffff: prio 8 handle 0x1 flower dst_mac e4:11:22:11:4a:51 src_mac e4:11:22:11:4a:50 action drop
	tcs $l
}

# 1546524
function tc1
{
	local n=1
	local l=$link
	[[ $# == 1 ]] && n=$1
	tc qdisc del dev $l ingress;
	tc qdisc add dev $l ingress;
	ethtool -K $l hw-tc-offload on 
	tc filter add dev $link prio 1 protocol all parent ffff: flower skip_sw action mirred egress redirect dev $rep2
}
alias cp-rpm='scp mi@10.12.205.13:~/rpmbuild/RPMS/x86_64/* .'

function tc-panic
{
set -x
	tc qdisc del dev $rep2 ingress > /dev/null 2>&1
	tc qdisc add dev $rep2 ingress
	ethtool -K $rep2 hw-tc-offload on 
	tc filter add dev $rep2 protocol ip parent ffff: prio 1 flower src_mac e4:11:22:33:44:50 dst_mac e4:11:22:33:44:70 \
		action mirred egress mirror dev $rep3 pipe	\
		action tunnel_key set src_ip 192.168.10.1 dst_ip 192.168.10.2 id 100 dst_port 4789	\
		action mirred egress redirect dev vxlan_sys_4789
set +x
}

alias gdb-kcore="/usr/bin/gdb $linux_dir/vmlinux /proc/kcore"

function add-symbol-file
{
	cd /sys/module/mlx5_core/sections
	local text=$(cat .text)
	local data=$(cat .data)
	local bss=$(cat .bss)
	echo "add-symbol-file /lib/modules/$(uname -r)/kernel/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.ko $text -s .data $data  -s .bss $bss"
}

# list	*(mlx5e_stats_flower+0x3f)
function gdb-mlx5
{
	local mod=$(modinfo -n mlx5_core)
	gdb $mod
}

function gdb-flower
{
	local mod=$(modinfo -n cls_flower)
	gdb $mod
}

function gdb-nf
{
	local mod=$(modinfo -n nf_conntrack)
	gdb $mod
}

function gdbm
{
	[[ $# != 1 ]] && return
	local mod=$(modinfo -n $1)
	gdb $mod
}

function dpkg_unlock
{
	sudo rm /var/lib/dpkg/lock
	sudo rm /var/cache/apt/archives/lock
	sudo dpkg --configure -a
}

function ct-tcp-dev
{
	cd /root/dev
	./test-ct-tcp.sh
}

function ct-ext
{
	tc-setup $rep2
	tc filter add dev $rep2 ingress protocol ip prio 2 flower dst_mac $mac1 e4:11:22:33:44:50  action ct action goto chain 1 
}

function tc_ct
{
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

set -x

	TC=/images/chrism/iproute2/tc/tc;

	$TC qdisc del dev $rep2 ingress > /dev/null 2>&1;
	ethtool -K $rep2 hw-tc-offload on;
	$TC qdisc add dev $rep2 ingress

	$TC qdisc del dev $rep3 ingress > /dev/null 2>&1;
	ethtool -K $rep3 hw-tc-offload on;
	$TC qdisc add dev $rep3 ingress

	mac1=02:25:d0:$host_num:01:02
	mac2=02:25:d0:$host_num:01:03
	echo "add arp rules"
	$TC filter add dev $rep2 ingress protocol arp prio 1 flower $offload \
		action mirred egress redirect dev $rep3

	$TC filter add dev $rep3 ingress protocol arp prio 1 flower $offload \
		action mirred egress redirect dev $rep2

	echo "add ct rules"
	$TC filter add dev $rep2 ingress protocol ip chain 0 prio 2 flower $offload \
		dst_mac $mac2 ct_state -trk \
		action ct pipe action goto chain 1

	$TC filter add dev $rep2 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac2 ct_state +trk+new \
		action ct commit \
		action mirred egress redirect dev $rep3

	$TC filter add dev $rep2 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac2 ct_state +trk+est \
		action mirred egress redirect dev $rep3



	$TC filter add dev $rep3 ingress protocol ip chain 0 prio 2 flower $offload \
		dst_mac $mac1 ct_state -trk \
		action ct pipe action goto chain 1

	$TC filter add dev $rep3 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac1 ct_state +trk+new \
		action ct commit \
		action mirred egress redirect dev $rep2

	$TC filter add dev $rep3 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac1 ct_state +trk+est \
		action mirred egress redirect dev $rep2

set +x
}

function tc_ct_pf
{
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

set -x

	TC=/images/chrism/iproute2/tc/tc;

	$TC qdisc del dev $rep2 ingress > /dev/null 2>&1;
	ethtool -K $rep2 hw-tc-offload on;
	$TC qdisc add dev $rep2 ingress

	$TC qdisc del dev $link ingress > /dev/null 2>&1;
	ethtool -K $link hw-tc-offload on;
	$TC qdisc add dev $link ingress

	mac1=02:25:d0:$host_num:01:02
	mac2=$remote_mac
	echo "add arp rules"
	$TC filter add dev $rep2 ingress protocol arp prio 1 flower $offload \
		action mirred egress redirect dev $link

	$TC filter add dev $link ingress protocol arp prio 1 flower $offload \
		action mirred egress redirect dev $rep2

	echo "add ct rules"
	$TC filter add dev $rep2 ingress protocol ip chain 0 prio 2 flower $offload \
		dst_mac $mac2 ct_state -trk \
		action ct pipe action goto chain 1

	$TC filter add dev $rep2 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac2 ct_state +trk+new \
		action ct commit \
		action mirred egress redirect dev $link

	$TC filter add dev $rep2 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac2 ct_state +trk+est \
		action mirred egress redirect dev $link

	$TC filter add dev $link ingress protocol ip chain 0 prio 2 flower $offload \
		dst_mac $mac1 ct_state -trk \
		action ct pipe action goto chain 1

	$TC filter add dev $link ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac1 ct_state +trk+new \
		action ct commit \
		action mirred egress redirect dev $rep2

	$TC filter add dev $link ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac1 ct_state +trk+est \
		action mirred egress redirect dev $rep2

set +x
}

function bond_block_id
{
	id=$(tc qdisc show dev bond0 | grep ingress_block | cut -d ' ' -f 7)
	echo $id
}

function tc_ct_bond
{
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

set -x

	TC=/images/chrism/iproute2/tc/tc;

	bond=bond0
	block_id=22

	$TC qdisc del dev $rep2 ingress > /dev/null 2>&1;
	ethtool -K $rep2 hw-tc-offload on;
	$TC qdisc add dev $rep2 ingress

	for i in $link $link2; do
		$TC qdisc del dev $i ingress_block 22 ingress &>/dev/null
		$TC qdisc del dev $i ingress > /dev/null 2>&1;
		ethtool -K $i hw-tc-offload on;
		$TC qdisc add dev $i ingress_block 22 ingress
	done

	mac1=02:25:d0:$host_num:01:02
	mac2=$remote_mac
	echo "add arp rules"
	$TC filter add dev $rep2 ingress protocol arp prio 1 flower $offload \
		action mirred egress redirect dev $bond

	$TC filter add block $block_id ingress protocol arp prio 1 flower $offload \
		action mirred egress redirect dev $rep2

	echo "add ct rules"
	$TC filter add dev $rep2 ingress protocol ip chain 0 prio 2 flower $offload \
		dst_mac $mac2 ct_state -trk \
		action ct pipe action goto chain 1

	$TC filter add dev $rep2 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac2 ct_state +trk+new \
		action ct commit \
		action mirred egress redirect dev $bond

	$TC filter add dev $rep2 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac2 ct_state +trk+est \
		action mirred egress redirect dev $bond


	$TC filter add block $block_id ingress protocol ip chain 0 prio 2 flower $offload \
		dst_mac $mac1 ct_state -trk \
		action ct pipe action goto chain 1

	$TC filter add block $block_id ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac1 ct_state +trk+new \
		action ct commit \
		action mirred egress redirect dev $rep2

	$TC filter add block $block_id ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac1 ct_state +trk+est \
		action mirred egress redirect dev $rep2

set +x
}

function tc_ct_pf_sample
{
	rate=1
	full=1
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

set -x

	TC=/images/chrism/iproute2/tc/tc;

	$TC qdisc del dev $rep2 ingress > /dev/null 2>&1;
	ethtool -K $rep2 hw-tc-offload on;
	$TC qdisc add dev $rep2 ingress

	$TC qdisc del dev $link ingress > /dev/null 2>&1;
	ethtool -K $link hw-tc-offload on;
	$TC qdisc add dev $link ingress

	mac1=02:25:d0:$host_num:01:02
	mac2=$remote_mac
	if (( full == 1 )); then
		echo "add arp rules"
		$TC filter add dev $rep2 ingress protocol arp prio 1 flower $offload \
			action mirred egress redirect dev $link

		$TC filter add dev $link ingress protocol arp prio 1 flower $offload \
			action mirred egress redirect dev $rep2

		echo "add ct rules"
		$TC filter add dev $rep2 ingress protocol ip chain 0 prio 2 flower $offload \
			dst_mac $mac2 ct_state -trk \
			action ct pipe action goto chain 1

		$TC filter add dev $rep2 ingress protocol ip chain 1 prio 2 flower $offload \
			dst_mac $mac2 ct_state +trk+new \
			action ct commit \
			action mirred egress redirect dev $link

		$TC filter add dev $rep2 ingress protocol ip chain 1 prio 2 flower $offload \
			dst_mac $mac2 ct_state +trk+est \
			action mirred egress redirect dev $link
	fi

	$TC filter add dev $link ingress protocol ip chain 0 prio 2 flower $offload \
		dst_mac $mac1 ct_state -trk \
		action sample rate $rate group 5 trunc 60 \
		action ct pipe action goto chain 1

	if (( full == 1 )); then
		$TC filter add dev $link ingress protocol ip chain 1 prio 2 flower $offload \
			dst_mac $mac1 ct_state +trk+new \
			action ct commit \
			action mirred egress redirect dev $rep2

		$TC filter add dev $link ingress protocol ip chain 1 prio 2 flower $offload \
			dst_mac $mac1 ct_state +trk+est \
			action mirred egress redirect dev $rep2
	fi

set +x
}

alias s3=tc_ct_pf_sample

function tc_ct_vf_sample
{
	rate=1
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

set -x

	TC=/images/chrism/iproute2/tc/tc;

	$TC qdisc del dev $rep2 ingress > /dev/null 2>&1;
	ethtool -K $rep2 hw-tc-offload on;
	$TC qdisc add dev $rep2 ingress

	$TC qdisc del dev $rep3 ingress > /dev/null 2>&1;
	ethtool -K $rep3 hw-tc-offload on;
	$TC qdisc add dev $rep3 ingress

	mac1=02:25:d0:$host_num:01:02
	mac2=02:25:d0:$host_num:01:03
	echo "add arp rules"
	$TC filter add dev $rep2 ingress protocol arp prio 1 flower $offload \
		action mirred egress redirect dev $rep3

	$TC filter add dev $rep3 ingress protocol arp prio 1 flower $offload \
		action mirred egress redirect dev $rep2

	echo "add ct rules"
	$TC filter add dev $rep2 ingress protocol ip chain 0 prio 2 flower $offload \
		dst_mac $mac2 ct_state -trk \
		action sample rate $rate group 5 trunc 60 \
		action ct pipe action goto chain 1

	$TC filter add dev $rep2 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac2 ct_state +trk+new \
		action ct commit \
		action mirred egress redirect dev $rep3

	$TC filter add dev $rep2 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac2 ct_state +trk+est \
		action mirred egress redirect dev $rep3

	$TC filter add dev $rep3 ingress protocol ip chain 0 prio 2 flower $offload \
		dst_mac $mac1 ct_state -trk \
		action ct pipe action goto chain 1

	$TC filter add dev $rep3 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac1 ct_state +trk+new \
		action ct commit \
		action mirred egress redirect dev $rep2

	$TC filter add dev $rep3 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac1 ct_state +trk+est \
		action mirred egress redirect dev $rep2


set +x
}

alias s4=tc_ct_vf_sample

function tc_ct_sample
{
	rate=1
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

set -x

	TC=/images/chrism/iproute2/tc/tc;

	$TC qdisc del dev $rep2 ingress > /dev/null 2>&1;
	ethtool -K $rep2 hw-tc-offload on;
	$TC qdisc add dev $rep2 ingress

	$TC qdisc del dev $rep3 ingress > /dev/null 2>&1;
	ethtool -K $rep3 hw-tc-offload on;
	$TC qdisc add dev $rep3 ingress

	mac1=02:25:d0:$host_num:01:02
	mac2=02:25:d0:$host_num:01:03
	echo "add arp rules"
	$TC filter add dev $rep2 ingress protocol arp prio 1 flower $offload \
		action mirred egress redirect dev $rep3
	$TC filter add dev $rep3 ingress protocol arp prio 1 flower $offload \
		action mirred egress redirect dev $rep2

	echo "add ct rules"
	$TC filter add dev $rep2 ingress protocol ip chain 0 prio 2 flower $offload \
		dst_mac $mac2 ct_state -trk \
		action sample rate $rate group 5 trunc 60 \
		action ct pipe action goto chain 1

	$TC filter add dev $rep2 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac2 ct_state +trk+new \
		action ct commit \
		action mirred egress redirect dev $rep3

	$TC filter add dev $rep2 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac2 ct_state +trk+est \
		action mirred egress redirect dev $rep3

	$TC filter add dev $rep3 ingress protocol ip chain 0 prio 2 flower $offload \
		dst_mac $mac1 ct_state -trk \
		action ct pipe action goto chain 1

	$TC filter add dev $rep3 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac1 ct_state +trk+new \
		action ct commit \
		action mirred egress redirect dev $rep2

	$TC filter add dev $rep3 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac1 ct_state +trk+est \
		action mirred egress redirect dev $rep2

set +x
}

function br_ct
{
        local proto

	del-br
	ovs-vsctl add-br $br
	ovs-vsctl add-port $br $rep2
	ovs-vsctl add-port $br $rep3

	ovs-ofctl add-flow $br in_port=$rep2,dl_type=0x0806,actions=output:$rep3
	ovs-ofctl add-flow $br in_port=$rep3,dl_type=0x0806,actions=output:$rep2

	proto=udp
	ovs-ofctl add-flow $br "table=0, $proto,ct_state=-trk actions=ct(table=1)"
	ovs-ofctl add-flow $br "table=1, $proto,ct_state=+trk+new actions=ct(commit),normal"
	ovs-ofctl add-flow $br "table=1, $proto,ct_state=+trk+est actions=normal"

	proto=tcp
	ovs-ofctl add-flow $br "table=0, $proto,ct_state=-trk actions=ct(table=1)"
	ovs-ofctl add-flow $br "table=1, $proto,ct_state=+trk+new actions=ct(commit),normal"
	ovs-ofctl add-flow $br "table=1, $proto,ct_state=+trk+est actions=normal"

	proto=icmp
	ovs-ofctl add-flow $br "table=0, $proto,ct_state=-trk actions=ct(table=1)"
	ovs-ofctl add-flow $br "table=1, $proto,ct_state=+trk+new actions=ct(commit),normal"
	ovs-ofctl add-flow $br "table=1, $proto,ct_state=+trk+est actions=normal"

	ovs-ofctl dump-flows $br
}


function br_qa_ct
{
set -x
	del-br
	ovs-vsctl add-br $br
	ovs-vsctl add-port $br $link
	ovs-vsctl add-port $br $rep2
	ovs-vsctl add-port $br $rep3

	mac=98:03:9b:13:f4:48
	ovs-ofctl del-flows $br 
	ovs-ofctl add-flow $br "arp,action=normal"
	ovs-ofctl add-flow $br "table=0,in_port=$rep2,ip,udp,action=ct(table=1)"
	ovs-ofctl add-flow $br "table=0,in_port=$link,ip,udp,action=ct(table=1)"
	ovs-ofctl add-flow $br "table=1,in_port=$rep2,ip,udp,ct_state=+trk+new,ip,udp,action=ct(commit),$link"
	ovs-ofctl add-flow $br "table=1,in_port=$rep2,ip,udp,ct_state=+trk+est,ip,udp,action=$link"
	ovs-ofctl add-flow $br "table=1,in_port=$link,ip,udp,ct_state=+trk+new,ip,udp,action=ct(commit),$rep2"
	ovs-ofctl add-flow $br "table=1,in_port=$link,ip,udp,ct_state=+trk+est,ip,udp,action=$rep2"

	ovs-ofctl add-flow $br "table=0,in_port=$rep2,ip,tcp,action=ct(table=1)"
	ovs-ofctl add-flow $br "table=0,in_port=$link,ip,tcp,action=ct(table=1)"
	ovs-ofctl add-flow $br "table=1,in_port=$rep2,ip,tcp,ct_state=+trk+new,ip,tcp,action=ct(commit),$link"
	ovs-ofctl add-flow $br "table=1,in_port=$rep2,ip,tcp,ct_state=+trk+est,ip,tcp,action=$link"
	ovs-ofctl add-flow $br "table=1,in_port=$link,ip,tcp,ct_state=+trk+new,ip,tcp,action=ct(commit),$rep2"
	ovs-ofctl add-flow $br "table=1,in_port=$link,ip,tcp,tp_src=0x1389/0xf000,ct_state=+trk+est,ip,tcp,action=$rep2"
set +x
}

# ovs-ofctl del-flows ovs-sriov2
# ovs-ofctl add-flow ovs-sriov2 'arp,action=normal'
# ovs-ofctl add-flow ovs-sriov2 'table=0,in_port=enp66s0f1_1,ip,udp,action=ct(table=1,zone=1)'
# ovs-ofctl add-flow ovs-sriov2 'table=0,in_port=enp66s0f1,ip,udp,action=ct(table=1,zone=1)'
# ovs-ofctl add-flow ovs-sriov2 'table=1,in_port=enp66s0f1_1,ip,udp,dl_src=e4:0b:01:42:02:03,dl_dst=e4:0c:01:42:02:03,ct_state=+trk+new,ct_zone=1,action=ct(commit),enp66s0f1'
# ovs-ofctl add-flow ovs-sriov2 'table=1,in_port=enp66s0f1_1,ip,udp,dl_src=e4:0b:01:42:02:03,dl_dst=e4:0c:01:42:02:03,ct_state=+trk+est,ct_zone=1,action=enp66s0f1'
# ovs-ofctl add-flow ovs-sriov2 'table=1,in_port=enp66s0f1,ip,udp,dl_src=e4:0c:01:42:02:03,dl_dst=e4:0b:01:42:02:03,tp_src=0x1389/0xf000,ct_state=+trk+new,ct_zone=1,action=enp66s0f1_1'
# ovs-ofctl add-flow ovs-sriov2 'table=1,in_port=enp66s0f1,ip,udp,dl_src=e4:0c:01:42:02:03,dl_dst=e4:0b:01:42:02:03,tp_src=0x1389/0xf000,ct_state=+trk+est,ct_zone=1,action=enp66s0f1_1'

function br_qa
{
set -x
	del-br
	ovs-vsctl add-br $br
	ovs-vsctl add-port $br $link
	ovs-vsctl add-port $br $rep2
	ovs-vsctl add-port $br $rep3

# 	ovs-ofctl del-flows $br 
# 	ovs-ofctl add-flow $br "arp,action=normal"
	ovs-ofctl add-flow $br "table=0,in_port=$rep2,ip,udp,action=ct(table=1,zone=1)"
	ovs-ofctl add-flow $br "table=0,in_port=$link,ip,udp,action=ct(table=1,zone=1)"
	ovs-ofctl add-flow $br "table=1,in_port=$rep2,ip,udp,ct_state=+trk+new,ip,udp,action=ct(commit,zone=1),$link"
	ovs-ofctl add-flow $br "table=1,in_port=$rep2,ip,udp,ct_state=+trk+est,ip,udp,ct_zone=1,action=$link"
	ovs-ofctl add-flow $br "table=1,in_port=$link,ip,udp,ct_state=+trk+new,ip,udp,ct_zone=1,action=$rep2"
	ovs-ofctl add-flow $br "table=1,in_port=$link,ip,udp,ct_state=+trk+est,ip,udp,ct_zone=1,action=$rep2"
set +x
}

function br_qa2
{
set -x
	del-br
	ovs-vsctl add-br $br
	ovs-vsctl add-port $br $link
	ovs-vsctl add-port $br $rep2
	ovs-vsctl add-port $br $rep3

# 	ovs-ofctl del-flows $br 
# 	ovs-ofctl add-flow $br "arp,action=normal"
	ovs-ofctl add-flow $br "table=0,in_port=$rep2,ip,udp,action=ct(table=1,zone=1)"
	ovs-ofctl add-flow $br "table=0,in_port=$link,ip,udp,action=ct(table=1,zone=1)"
	ovs-ofctl add-flow $br "table=1,in_port=$rep2,ip,udp,ct_state=+trk+new,ip,udp,ct_zone=1,action=ct(commit),$link"
	ovs-ofctl add-flow $br "table=1,in_port=$rep2,ip,udp,ct_state=+trk+est,ip,udp,ct_zone=1,action=$link"
	ovs-ofctl add-flow $br "table=1,in_port=$link,ip,udp,ct_state=+trk+new,ip,udp,ct_zone=1,action=$rep2"
	ovs-ofctl add-flow $br "table=1,in_port=$link,ip,udp,ct_state=+trk+est,ip,udp,ct_zone=1,action=$rep2"
set +x
}

function br-pf-ct
{
	del-br
	ovs-vsctl add-br $br
	ovs-vsctl add-port $br $rep2
	ovs-vsctl add-port $br $link

	ovs-ofctl add-flow $br dl_type=0x0806,actions=NORMAL 

	proto=udp
	ovs-ofctl add-flow $br "table=0, $proto,ct_state=-trk actions=ct(table=1)"
	ovs-ofctl add-flow $br "table=1, $proto,ct_state=+trk+new actions=ct(commit),normal"
	ovs-ofctl add-flow $br "table=1, $proto,ct_state=+trk+est actions=normal"

	proto=tcp
	ovs-ofctl add-flow $br "table=0, $proto,ct_state=-trk actions=ct(table=1)"
	ovs-ofctl add-flow $br "table=1, $proto,ct_state=+trk+new actions=ct(commit),normal"
	ovs-ofctl add-flow $br "table=1, $proto,ct_state=+trk+est actions=normal"

	ovs-ofctl dump-flows $br
}

# do dnat using ct(nat(dst))
function br-dnat
{
	del-br
	ovs-vsctl add-br $br
	ovs-vsctl add-port $br $rep2
	ovs-vsctl add-port $br $link

	ovs-ofctl add-flow $br dl_type=0x0806,actions=NORMAL 

#     ovs-ofctl1 add-flow ovs-br -O openflow13 "table=0,in_port=$rep2,ip,udp,action=ct(table=1,zone=1,nat)"
#     ovs-ofctl1 add-flow ovs-br -O openflow13 "table=0,in_port=$link,ip,udp,ct_state=-trk,ip,action=ct(table=1,zone=1,nat)"
# 
#     ovs-ofctl1 add-flow ovs-br -O openflow13 "table=1,in_port=$rep2,ip,udp,ct_state=+trk+new,ct_zone=1,ip,action=ct(commit,nat(dst=$IP2:$NAT_PORT)),$link"
#     ovs-ofctl1 add-flow ovs-br -O openflow13 "table=1,in_port=$rep2,ip,udp,ct_state=+trk+est,ct_zone=1,ip,action=$link"
#     ovs-ofctl1 add-flow ovs-br -O openflow13 "table=1,in_port=$link,ip,udp,ct_state=+trk+est,ct_zone=1,ip,action=$rep2"

	ovs-ofctl add-flow $br -O openflow13 "table=0,in_port=$link,ip,udp,action=ct(table=1,zone=1,nat)"
	ovs-ofctl add-flow $br -O openflow13 "table=0,in_port=$rep2,ip,udp,ct_state=-trk,ip,action=ct(table=1,zone=1,nat)"

	ovs-ofctl add-flow $br -O openflow13 "table=1,in_port=$link,ip,udp,ct_state=+trk+new,ct_zone=1,ip,action=ct(commit,nat(dst=1.1.1.220:1-60000)),$rep2"
	ovs-ofctl add-flow $br -O openflow13 "table=1,in_port=$link,ip,udp,ct_state=+trk+est,ct_zone=1,ip,action=$rep2"
	ovs-ofctl add-flow $br -O openflow13 "table=1,in_port=$rep2,ip,udp,ct_state=+trk+new,ct_zone=1,ip,action=ct(commit),$link"
	ovs-ofctl add-flow $br -O openflow13 "table=1,in_port=$rep2,ip,udp,ct_state=+trk+est,ct_zone=1,ip,action=$link"

	ovs-ofctl dump-flows $br
}

# do dnat using CT and header rewrite
function br-dnat2
{
	IPERF_PORT=5001
	# trex default dest port is 12
	NEW_PORT=12
	ROUTE_IP=192.168.1.13
	VM_IP=1.1.1.220

	del-br
	ovs-vsctl add-br $br
	ovs-vsctl add-port $br $rep2
	ovs-vsctl add-port $br $link

	ovs-ofctl add-flow $br "table=0,priority=2,in_port=$link,ip,udp,tp_dst=$NEW_PORT,nw_dst=$ROUTE_IP actions=mod_nw_dst:$VM_IP,mod_tp_dst:$IPERF_PORT,ct(table=2)"
	ovs-ofctl add-flow $br "table=2,priority=1,ct_state=+trk+new,ip,udp actions=ct(commit),$rep2"
	ovs-ofctl add-flow $br "table=2,priority=2,ct_state=+trk+est,ip,udp actions=$rep2"

	ovs-ofctl add-flow $br "table=0,priority=2,ip,udp,in_port=$rep2,nw_src=$VM_IP,tp_src=$IPERF_PORT actions=ct(table=3)"
	ovs-ofctl add-flow $br "table=3,priority=1,ct_state=+trk+new,ip,udp actions=ct(commit),mod_nw_src:$ROUTE_IP,mod_tp_src:$NEW_PORT,$link"
	ovs-ofctl add-flow $br "table=3,priority=1,ct_state=+trk+est,ip,udp actions=mod_nw_src:$ROUTE_IP,mod_tp_src:$NEW_PORT,$link"
}

# do dnat without CT
function br-dnat3
{
	local file=/tmp/of.txt
	rm -f $file

	IPERF_PORT=5001
	# trex default dest port is 12
	NEW_PORT=12
	ROUTE_IP=192.168.1.13
	VM_IP=1.1.1.220

	del-br
	ovs-vsctl add-br $br
	ovs-vsctl add-port $br $rep2
	ovs-vsctl add-port $br $link

	i=0
	for(( j = 1; j < 255; j++)); do
		for(( k = 1; k < 255; k++)); do
			i=$((i+1))
			echo "table=0,priority=2,in_port=$link,ip,udp,tp_dst=$NEW_PORT,nw_src=192.168.$j.$k,nw_dst=$ROUTE_IP actions=mod_nw_dst:$VM_IP,mod_tp_dst:$i,$rep2"
		done
	done >> $file

# 	ovs-ofctl add-flow $br "table=0,priority=2,ip,udp,in_port=$rep2,nw_src=$VM_IP,tp_src=$IPERF_PORT actions=mod_nw_src:$ROUTE_IP,mod_tp_src:$NEW_PORT,$link"

	set -x
	ovs-ofctl add-flows $br -O openflow13 $file
	ovs-ofctl dump-flows $br | wc -l
	set +x
}

# [chrism@vnc14 ~]$ cat  /.autodirect/mgwork/maord/scripts/set_bond.sh
#!/usr/bin/env bash
# 
# device=$1
# device2=$2
# num_vfs=$3
# 
# 
# ifenslave -d bond0 $device $device1
# rmmod bonding
# 
# $(dirname "$0")/set_switchdev.sh $device $num_vfs
# sleep 10
# $(dirname "$0")/set_switchdev.sh $device2 $num_vfs
# sleep 10
# modprobe bonding mode=4 miimon=100
# ifconfig bond0 up
# ifconfig $device down
# ifconfig $device2 down
# ip link set $device master bond0
# ip link set $device2 master bond0
# ifconfig $device up
# ifconfig $device2 up

function bond_delete_old
{
	ifenslave -d bond0 $link $link2 2> /dev/null
	sleep 1
	rmmod bonding
	sleep 1
}

function bond_delete
{
	ip link set dev $link down
	ip link set dev $link2 down
	ip link set dev bond0 down
	ip link delete bond0
}

function bond_cleanup
{
	un
	un2
	bond_delete
	dev off
	dev2 off
	off
}

function bond_switchdev
{
	nic=$1
	off_all
	smfs
	on-sriov
	sleep 1
	on-sriov2
	sleep 1
	un
	sleep 1
	un2
	sleep 1

	if [[ "$nic" == "nic" ]]; then
		echo "enable nic_netdev"
		echo_nic_netdev
		echo_nic_netdev2
	fi

	dev
	sleep 1
	dev2
	sleep 1
	set_mac
	set_mac 2
}

function bond_create
{
set -x
# 	ifenslave -d bond0 $link $link2 2> /dev/null
# 	sleep 1
# 	rmmod bonding
# 	sleep 1
# 	modprobe bonding mode=4 miimon=100
# 	sleep 1

	ip link set dev $link down
	ip link set dev $link2 down

# 	ip link add name bond0 type bond
# 	ip link set dev bond0 type bond mode active-backup miimon 100
	ip link add name bond0 type bond mode active-backup miimon 100
# 	ip link set dev bond0 type bond mode 802.3ad
	ip link set dev $link master bond0
	ip link set dev $link2 master bond0
	ip link set dev bond0 up
	ip link set dev $link up
	ip link set dev $link2 up

	ifconfig $link 0
	ifconfig $link2 0
	ifconfig bond0 1.1.1.200/16 up

set +x
}

function bond_br
{
set -x
	restart-ovs
	del-br
	ovs-vsctl add-br $br
	ovs-vsctl add-port $br bond0
	for (( i = 0; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		ovs-vsctl add-port $br $rep
# 		local rep=$(get_rep2 $i)
# 		ovs-vsctl add-port $br $rep
	done
# 	ovs-ofctl add-flow $br "in_port=bond0,dl_dst=2:25:d0:13:01:01 action=$rep1"
set +x
	up_all_reps 1
	up_all_reps 2

# 	bond_br_ct_pf
}

function bond_br_ct_pf
{
        local proto

	bond=bond0

	ovs-ofctl add-flow $br dl_type=0x0806,actions=NORMAL

	ovs-ofctl add-flow $br "table=0, ip,ct_state=-trk actions=ct(table=1)"
	ovs-ofctl add-flow $br "table=1, ip,ct_state=+trk+new actions=ct(commit),normal"
	ovs-ofctl add-flow $br "table=1, ip,ct_state=+trk+est actions=normal"

	ovs-ofctl dump-flows $br
}

function bond_setup
{
	off
	bond_delete
	bond_switchdev
	bond_create

	ifconfig bond0 0
	bi
	sleep 1
	bi2
	sleep 1
	set_netns_all 1

	bond_br
}

alias cd-scapy='cd /labhome/chrism/prg/python/scapy'

alias udp13=/labhome/chrism/prg/python/scapy/udp13.py
alias udp13-2=/labhome/chrism/prg/python/scapy/udp13-2.py
alias udp14=/labhome/chrism/prg/python/scapy/udp14.py

alias reboot='echo reboot; read; reboot'

# two way traffic
alias udp-server-2='/labhome/chrism/sm/prg/c/udp-server/udp-server-2'
alias udp-client-2='/labhome/chrism/sm/prg/c/udp-client/udp-client-2'

# one way traffic
alias udp-server='/labhome/chrism/sm/prg/c/udp-server/udp-server'
alias udp-client="/labhome/chrism/sm/prg/c/udp-client/udp-client"
alias udp-client-example="/labhome/chrism/sm/prg/c/udp-client/udp-client -c 192.168.1.$rhost_num -i 1 -t 10000"

function udp1
{
	local n=1
	[[ $# == 1 ]] && n=$1
	pkill udp-client
	for (( i = 0; i < n; i++ )); do
		udp-client -c 1.1.1.23 -t 10000 -i 1
	done
}

function udp2
{
    local n=1;
    [[ $# == 1 ]] && n=$1;
    pkill udp-client;
    for ((i = 0; i < n; i++ ))
    do
	/labhome/chrism/prg/c/udp-client/udp-client -c 1.1.3.2 -t 10000 -i 1;
    done
}

function dr
{
set -x
	tc-setup $rep2
	src_mac=02:25:d0:$host_num:01:02
#	tc filter add dev $rep2 ingress protocol arp flower  src_mac $src_mac action mirred egress redirect dev $rep3
	tc filter add dev $rep2 ingress protocol arp flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
#	tc filter add dev $rep2 ingress prio 2 protocol arp flower   src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
set +x
}

function ip-n8
{
set -x
	ip n change 1.1.1.23 lladdr 02:25:d0:13:01:08 dev enp4s0f3
set +x
}

function ip-n7
{
set -x
	ip n change 1.1.1.23 lladdr 02:25:d0:13:01:07 dev enp4s0f3
set +x
}


function tc-wrong
{
set -x
	tc-setup $rep2
	tc filter add dev $rep2 ingress protocol arp flower src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $vx_rep
set +x
}

# tc_get_tfilter will be called
function tc-filter-get
{
	tc -s filter get dev $rep2 handle 1 protocol ip prio 1 parent ffff: flower
}

# tc_del_tfilter will be called
function tc-filter-del
{
	 tc filter del dev $rep2 handle 1 protocol ip prio 1 parent ffff: flower
}

# /proc/sys/net/ipv4/icmp_ratelimit

# test-vf-vf-fwd-fl_classify.sh
function fl_classify
{
set -x
	tc-setup $rep1
	tc-setup $rep2
	tc filter add dev enp4s0f0_0 ingress protocol ip prio 1 flower skip_sw dst_mac 02:25:d0:13:01:01 action mirred egress redirect dev enp4s0f0_1
	tc filter add dev enp4s0f0_1 ingress protocol ip prio 1 flower skip_sw dst_mac 02:25:d0:13:01:02 action mirred egress redirect dev enp4s0f0_0
	tc filter add dev enp4s0f0_0 ingress protocol ip prio 1 flower skip_sw dst_mac 02:25:d0:13:01:01 action mirred egress redirect dev enp4s0f0_1
set +x
}

# nf_ct_tcp_be_liberal
function jd-proc
{
	echo 1 > /proc/sys/net/netfilter/nf_conntrack_tcp_be_liberal
	cat /proc/sys/net/netfilter/nf_conntrack_tcp_be_liberal
	echo 2000000 > /proc/sys/net/netfilter/nf_conntrack_max
}

function no-liberal
{
	echo 0 > /proc/sys/net/netfilter/nf_conntrack_tcp_be_liberal
	cat /proc/sys/net/netfilter/nf_conntrack_tcp_be_liberal
}

function cat-liberal
{
	cat /proc/sys/net/netfilter/nf_conntrack_tcp_be_liberal
}

function jd-hugepage
{
	echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
}

/bin/cp ~/.bashrc ~/.bashrc.bak

function restart-net
{
	/etc/init.d/network restart
}

function change-mtu
{
	local mtu=$1
	ifconfig $rep2 mtu $mtu
	ifconfig $rep2
	n1 ifconfig $vf2 mtu $mtu
	n1 ifconfig $vf2
}

function test-mtu
{
	local i=0
	while true; do
		echo "============ $i ==========="
		change-mtu 576
		sleep 5
		change-mtu 1450
		sleep 5
		((i++))
	done
}

alias an0='ssh root@mtl-stm-az-125.mtl.labs.mlnx'
alias 23='ssh root@10.196.23.1'
alias 24='ssh root@10.196.24.1'
alias 25='ssh root@10.196.23.5'
alias 26='ssh root@10.196.24.5'

# if [[ $USER == "root" && "$(virt-what)" == "kvm" ]]; then
#	echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
#	alias p0='/root/testpmd0 -l 0-2 -n 4  -m=1024  -w 0000:00:09.0 -- -i --rxq=2 --txq=2  --nb-cores=2'
#	alias p1='/root/dpdk-stable-17.11.4/x86_64-native-linuxapp-gcc/app/testpmd -l 0-2 -n 4	-m=1024  -w 0000:00:09.0 -- -i --rxq=2 --txq=2	--nb-cores=2'
#	alias p2='/root/dpdk-stable-17.11.4/x86_64-native-linuxapp-gcc/app/testpmd -c 0xf -n 4 -w 0000:00:09.0,txq_inline=896 --socket-mem=2048,0 -- --rxq=4 --txq=4 --nb-cores=3 -i set fwd macswap'
# fi

alias gitr='git format-patch -o ~/backport/r -1'
alias log1=' git log lib/rhashtable.c'

alias cs='corrupt -s'
alias cc='corrupt -c 1.1.1.2 -t 100000'
alias cc2='corrupt -c 1.1.3.2 -t 100000 -l 2'
alias cc3='corrupt -c 1.1.1.23 -t 100000'
alias cc122='corrupt -c 1.1.1.122 -t 100000'

alias msg='tail -f /var/log/messages'

alias rc0='scp ~chrism/.bashrc chrism@10.7.2.14:~'

alias hping='hping3 -S -s 10001 -p 12345 1.1.1.122'
alias f1="sudo flint -d $pci q"

alias cd-miniflow-cache='cd /sys/kernel/slab/mlx5_miniflow_cache'
alias cd-wq='cd /sys/devices/virtual/workqueue'
function counters_tc_ct
{
	while :; do
# 		cat /sys/class/net/$link/device/sriov/pf/counters_tc_ct | grep in_hw
		cat /sys/class/net/$link/device/counters_tc_ct | grep in_hw
		sleep 1
	done
}
alias co=counters_tc_ct

function co2
{
	idle2
	sleep 2
	idle10
	co
}

function counters_tc_ct10
{
	while :; do
		cat /sys/class/net/$link/device/sriov/pf/counters_tc_ct | grep in_hw
# 		cat /sys/class/net/$link/device/counters_tc_ct | grep in_hw
		sleep 10
	done | tee co.txt
}
alias co10=counters_tc_ct10

alias dis="ethtool -S $link | grep dis"

function autoprobe-show
{
	cat /sys/class/net/$link/device/sriov_drivers_autoprobe
}

function autoprobe
{
	cat /sys/class/net/$link/device/sriov_drivers_autoprobe
	echo 1 > /sys/class/net/$link/device/sriov_drivers_autoprobe
	cat /sys/class/net/$link/device/sriov_drivers_autoprobe
}

function autoprobe-disable
{
	cat /sys/class/net/$link/device/sriov_drivers_autoprobe
	echo 0 > /sys/class/net/$link/device/sriov_drivers_autoprobe
	cat /sys/class/net/$link/device/sriov_drivers_autoprobe
}

function eth0
{
	echo 0 > /sys/class/net/eth0_65534/device/sriov_numvfs
}

alias scapy-traffic-tester.py='~chrism/asap_dev_reg/scapy-traffic-tester.py'

scapy_time=1000

src_ip=1.1.1.22
dst_ip=1.1.1.122
scapy_device=ens9

src_ip=192.168.1.13
dst_ip=192.168.1.14
scapy_device=$link

alias scapyc="scapy-traffic-tester.py -i $scapy_device --src-ip $src_ip --dst-ip $dst_ip --inter 1 --time $scapy_time --pkt-count $scapy_time"
alias scapyl="scapy-traffic-tester.py -i $scapy_device -l --src-ip $src_ip --inter 1 --time $scapy_time --pkt-count $scapy_time"

# alias test2="modprobe -r mlx5_core; modprobe -v mlx5_core; ip link set dev $link up"

function git-push
{
	[[ $# != 2 ]] && return
	git push origin HEAD:refs/for/$1/$2
}

function load-ofed
{
set -x
	modprobe devlink
	cdr
	local dir=/lib/modules/$(uname -r)
	insmod $dir/extra/mlnx-ofa_kernel/compat/mlx_compat.ko
	insmod $dir/extra/mlnx-ofa_kernel/drivers/infiniband/core/ib_core.ko
	insmod $dir/extra/mlnx-ofa_kernel/drivers/infiniband/core/ib_uverbs.ko
	insmod $dir/extra/mlnx-ofa_kernel/drivers/net/ethernet/mellanox/mlxfw/mlxfw.ko
	insmod $dir/extra/mlnx-ofa_kernel/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.ko
	insmod $dir/extra/mlnx-ofa_kernel/drivers/infiniband/hw/mlx5/mlx5_ib.ko
set +x
}

function yum_bcc
{
	local cmd=yum
	sudo $cmd install -y bison cmake ethtool flex git iperf libstdc++-static \
	  python-netaddr python-pip gcc gcc-c++ make zlib-devel \
	  elfutils-libelf-devel
	sudo $cmd install -y luajit luajit-devel  # for Lua support
	sudo $cmd install -y \
	  http://repo.iovisor.org/yum/extra/mageia/cauldron/x86_64/netperf-2.7.0-1.mga6.x86_64.rpm
	sudo pip install pyroute2
	sudo $cmd install -y clang clang-devel llvm llvm-devel llvm-static ncurses-devel
}

function install_bcc
{
	sm
	mkdir -p bcc/build; cd bcc/build
	cmake .. -DCMAKE_INSTALL_PREFIX=/usr
	time make -j
	sudo make install
}

function install-bpftrace
{
	sm
	cd bpftrace
	unset CXXFLAGS
	mkdir -p build; cd build; cmake -DCMAKE_BUILD_TYPE=DEBUG ..
	unset CXXFLAGS
	make -j
	unset CXXFLAGS
	make install
}

BCC_DIR=/images/chrism/bcc
BCC_DIR=/usr/share/bcc
alias trace="sudo $BCC_DIR/tools/trace -t"
alias execsnoop="sudo $BCC_DIR/tools/execsnoop"
alias tcpaccept="sudo $BCC_DIR/tools/tcpaccept"
alias funccount="sudo $BCC_DIR/tools/funccount -i 1"
alias fl="$BCC_DIR/tools/funclatency"

function trace1
{
	[[ $# != 1 ]] && return
	sudo $BCC_DIR/tools/trace -t "$1 \"%lx\", arg1"
}

function trace2
{
	[[ $# != 1 ]] && return
	sudo $BCC_DIR/tools/trace -t "$1 \"%lx\", arg2"
}

function tracer2
{
	[[ $# != 1 ]] && return
	local file=/tmp/bcc_$$.sh
cat << EOF > $file
$BCC_DIR/tools/trace -t 'r::$1 "ret: %d", retval' "$1 \"ifindex: %lx\", arg2"
EOF
	echo $file
	sudo bash $file
}

function trace3
{
	[[ $# != 1 ]] && return
	sudo $BCC_DIR/tools/trace -t "$1 \"%lx\", arg3"
}

function trace4
{
	[[ $# != 1 ]] && return
	sudo $BCC_DIR/tools/trace -t "$1 \"%lx\", arg4"
}

function trace5
{
	[[ $# != 1 ]] && return
	sudo $BCC_DIR/tools/trace -t "$1 \"%lx\", arg5"
}

function trace6
{
	[[ $# != 1 ]] && return
	sudo $BCC_DIR/tools/trace -t "$1 \"%lx\", arg6"
}

alias fc1='funccount miniflow_merge_work -i 1'
alias fc2='funccount mlx5e_del_miniflow_list -i 1'

function fco
{
	[[ $# != 1 ]] && return
	sudo $BCC_DIR/tools/funccount /usr/sbin/ovs-vswitchd:$1 -i 1
}

function tracerx
{
	[[ $# != 1 ]] && return
	local file=/tmp/bcc_$$.sh
cat << EOF > $file
$BCC_DIR/tools/trace 'r::$1 "%lx", retval'
EOF
	echo $file
	sudo bash $file
}

function tracer
{
	[[ $# != 1 ]] && return
	local file=/tmp/bcc_$$.sh
cat << EOF > $file
$BCC_DIR/tools/trace 'r::$1 "%d", retval'
EOF
	echo $file
	sudo bash $file
}

function traceo
{
	[[ $# < 1 ]] && return
	local file=/tmp/bcc_$$.sh
cat << EOF > $file
$BCC_DIR/tools/trace -t 'ovs-vswitchd:$1 "%d", arg1'
EOF
	if [[ $# == 2 ]]; then
		sed -i 's/$/& -U/g' $file
	fi
	cat $file
	echo $file
	sudo bash $file
}

function tracecmd
{
	[[ $# < 2 ]] && return
	local file=/tmp/bcc_$$.sh
cat << EOF > $file
$BCC_DIR/tools/trace -t '$1:$2 "%lx", arg1'
EOF
	if [[ $# == 2 ]]; then
		sed -i 's/$/& -U/g' $file
	fi
	cat $file
	echo $file
	sudo bash $file
}

function tracecmd2
{
	[[ $# < 2 ]] && return
	local file=/tmp/bcc_$$.sh
cat << EOF > $file
$BCC_DIR/tools/trace -t '$1:$2 "%lx", arg2'
EOF
	if [[ $# == 2 ]]; then
		sed -i 's/$/& -U/g' $file
	fi
	cat $file
	echo $file
	sudo bash $file
}

alias trace-of="tracecmd ovs-ofctl"

function traceo2
{
	[[ $# < 1 ]] && return
	local file=/tmp/bcc_$$.sh
cat << EOF > $file
$BCC_DIR/tools/trace 'ovs-vswitchd:$1 "%lx", arg2'
EOF
	if [[ $# == 2 ]]; then
		sed -i 's/$/& -U/g' $file
	fi
	cat $file
	echo $file
	sudo bash $file
}

function traceo3
{
	[[ $# < 1 ]] && return
	local file=/tmp/bcc_$$.sh
cat << EOF > $file
$BCC_DIR/tools/trace 'ovs-vswitchd:$1 "%llx", arg3'
EOF
	if [[ $# == 2 ]]; then
		sed -i 's/$/& -U/g' $file
	fi
	cat $file
	echo $file
	sudo bash $file
}

function traceor
{
	[[ $# < 1 ]] && return
	local file=/tmp/bcc_$$.sh
cat << EOF > $file
$BCC_DIR/tools/trace 'r:ovs-vswitchd:$1 "%lx", retval'
EOF
	if [[ $# == 2 ]]; then
		sed -i 's/$/& -U/g' $file
	fi
	cat $file
	echo $file
	sudo bash $file
}

function bcc-mlx5e_xmit
{
	 trace -K -U 'mlx5e_xmit "%s", arg2'
}

#
# test configuration:
# ovs port: uplink rep, rep2, no vid
# set $vf2 vid 50
# set remote uplink vid 40
#
function tc-vlan-modify
{
	tc-setup $rep2
	tc-setup $link
set -x
	tc filter add dev $rep2 protocol 802.1q ingress prio 1 flower skip_sw \
		dst_mac $remote_mac \
		vlan_id $vid \
		action vlan modify id $vid2 pipe \
		action mirred egress redirect dev $link
	tc filter add dev $rep2 protocol 802.1q ingress prio 1 flower skip_sw \
		dst_mac $brd_mac \
		vlan_id $vid \
		action vlan modify id $vid2 pipe \
		action mirred egress redirect dev $link

	tc filter add dev $link protocol 802.1q ingress prio 1 flower skip_sw \
		dst_mac 02:25:d0:$host_num:01:02 \
		vlan_id $vid2 \
		action vlan modify id $vid pipe \
		action mirred egress redirect dev $rep2
	tc filter add dev $link protocol 802.1q ingress prio 1 flower skip_sw \
		dst_mac $brd_mac \
		vlan_id $vid2 \
		action vlan modify id $vid pipe \
		action mirred egress redirect dev $rep2
set +x
}

function tc-vlan-modify2
{
	tc-setup $rep2
	tc-setup $link
set -x
	tc filter add dev $rep2 protocol 802.1q ingress prio 1 flower skip_sw \
		dst_mac $remote_mac \
		vlan_id $vid \
		action vlan pop pipe action vlan push id $vid2 pipe \
		action mirred egress redirect dev $link
	tc filter add dev $rep2 protocol 802.1q ingress prio 1 flower skip_sw \
		dst_mac $brd_mac \
		vlan_id $vid \
		action vlan pop pipe action vlan push id $vid2 pipe \
		action mirred egress redirect dev $link

	tc filter add dev $link protocol 802.1q ingress prio 1 flower skip_sw \
		dst_mac 02:25:d0:$host_num:01:02 \
		vlan_id $vid2 \
		action vlan pop pipe action vlan push id $vid pipe \
		action mirred egress redirect dev $rep2
	tc filter add dev $link protocol 802.1q ingress prio 1 flower skip_sw \
		dst_mac $brd_mac \
		vlan_id $vid2 \
		action vlan pop pipe action vlan push id $vid pipe \
		action mirred egress redirect dev $rep2
set +x
}

alias ip-set-rate2="ip link set $link vf 0 rate 100"
alias ip-set-rate="ip link set $link vf 0 max_tx_rate 300 min_tx_rate 200"
alias group0="echo 0 > /sys/class/net/$link/device/sriov/0/group"
alias group1="echo 2 > /sys/class/net/$link/device/sriov/0/group"
alias group2="echo 100 > /sys/class/net/$link/device/sriov/groups/2/max_tx_rate"

alias cd-sriov="cd /sys/class/net/$link/device/sriov"

function dist
{
	local file=/etc/depmod.d/dist.conf
	if [[ -f $file ]]; then
		echo "$file exists"
		return
	fi

	mkdir -p /etc/depmod.d
cat << EOF > $file
#
# depmod.conf
#

# override default search ordering for kmod packaging
search updates extra built-in weak-updates
EOF
	depmod -a
}

function set-time
{
set -x
	cd /etc
	/bin/rm -rf  localtime
	ln -s ../usr/share/zoneinfo/Asia/Shanghai  localtime
set +x
}

# dos2unix -o *
function dos
{
	local name
	local num=11
	for i in $(seq $num); do
		name=$(printf "%02d_$num" $i)
		echo $name
		dos2unix -n *${name}* ${name}.patch
	done
}

b=$(test -f .git/index > /dev/null 2>&1 && git branch | grep \* | cut -d ' ' -f2)

function branch
{
	test -f .git/index > /dev/null 2>&1 || return
	git branch | grep \* | cut -d ' ' -f2
}

function tc1
{
	tc-setup $rep2
#	tc filter add dev $rep2 protocol ip parent ffff: prio 1 flower skip_hw dst_mac cc:cc:cc:cc:cc:cc action drop
	tc filter add dev $rep2 protocol ip parent ffff: prio 1 flower skip_sw dst_mac aa:bb:cc:dd:ee:ff action simple sdata '"unsupported action"'
}

function git-send-ovs
{
	run="--dry-run"
	[[ "$1" == "run" ]] && run=""
	git send-email				\
		$run				\
		--to blp@ovn.org		\
		--to fbl@sysclose.org		\
		--to ovs-dev@openvswitch.org	\
		--cc simon.horman@netronome.com	\
		--cc roid@mellanox.com		\
		/labhome/chrism/ovs/vxlan7/0001-netdev-vport-Use-the-dst_port-in-tunnel-netdev-name.patch
}

function rule
{
	on-sriov
	tc-setup $link
	tc filter add dev $link parent ffff: prio 1 flower skip_sw action drop
}

function vt
{
	[[ $# != 1 ]] && return
	local f=$(echo \"$1\" | cut -d "(" -f 1)
	echo $f
#	vi -t $f
}

function install-tools
{
	sm
	clone-crash
	cd crash
	make -j

	sm
	clone-systemtap
	cd systemtap
	make-local

	if (( centos == 0 )); then
		sm
		clone-bcc
		install-bcc
	fi
}

function install-debuginfo
{
	yum --enablerepo=base-debuginfo install -y kernel-debuginfo-$(uname -r)
}

function qinq-br
{
	ovs-vsctl list-br | xargs -r -l ovs-vsctl del-br
	vlan-limit
	eoff
	ovs-vsctl add-br $br
	for (( i = 0; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done

	ovs-vsctl add-br br2
	ovs-vsctl add-port br2 $link -- set Interface $link ofport_request=5

	ovs-vsctl		\
		-- add-port $br patch1	\
		-- set interface patch1 type=patch options:peer=patch2	\
		-- add-port br2 patch2	\
		-- set interface patch2 type=patch options:peer=patch1
}

# ovs-ofctl -O OpenFlow13 add-flow ovs-br0 in_port=patch0,actions=push_vlan:0x88a8,mod_vlan_vid=1000,output=ens2f1
# ovs-ofctl -O OpenFlow13 add-flow ovs-br0 dl_vlan=1000,actions=strip_vlan,patch0
# 
# 
# ovs-ofctl -O OpenFlow13 add-flow ovs-br1 in_port=patch1,arp,dl_vlan=6,actions=strip_vlan,ens2f1_0,ens2f1_1
# ovs-ofctl -O OpenFlow13 add-flow ovs-br1 in_port=patch1,arp,dl_vlan=3,actions=strip_vlan,ens2f1_1,ens2f1_0
# 
# ovs-ofctl -O OpenFlow13 add-flow ovs-br1 dl_vlan=6,dl_dst=e4:11:22:33:25:50,actions=strip_vlan,ens2f1_0
# ovs-ofctl -O OpenFlow13 add-flow ovs-br1 dl_vlan=3,dl_dst=e4:11:22:33:25:50,actions=strip_vlan,ens2f1_0
# ovs-ofctl -O OpenFlow13 add-flow ovs-br1 dl_vlan=6,dl_dst=e4:11:22:33:25:51,actions=strip_vlan,ens2f1_1
# 
# ovs-ofctl -O Openflow13 add-flow ovs-br1 in_port=ens2f1_0,dl_dst=e4:11:22:33:25:51,actions=output=ens2f1_1
# ovs-ofctl -O Openflow13 add-flow ovs-br1 in_port=ens2f1_0,ipv4,actions=push_vlan:0x8100,mod_vlan_vid=6,output=patch1
# ovs-ofctl -O Openflow13 add-flow ovs-br1 in_port=ens2f1_0,arp,actions=output=ens2f1_1,push_vlan:0x8100,mod_vlan_vid=6,output=patch1
# 
# ovs-ofctl -O Openflow13 add-flow ovs-br1 in_port=ens2f1_1,dl_dst=e4:11:22:33:25:50,actions=output=ens2f1_0
# ovs-ofctl -O Openflow13 add-flow ovs-br1 in_port=ens2f1_1,ipv4,actions=push_vlan:0x8100,mod_vlan_vid=3,output=patch1
# ovs-ofctl -O Openflow13 add-flow ovs-br1 in_port=ens2f1_1,arp,actions=output=ens2f1_0,push_vlan:0x8100,mod_vlan_vid=3,output=patch1

alias rxvlan-off="ethtool -K $link rxvlan off"
 
alias vm-vlan="ip l d vlan5 &> /dev/null; vlan $vf2 5 1.1.$host_num.1"
alias vm-ip="ip l d vlan5 &> /dev/null; ip addr add dev $vf2 1.1.$host_num.1/16"
alias q-rule=qinq-rule
function qinq-rule
{
set -x
	qinq-br
	ovs-ofctl -O OpenFlow13 add-flow br2 in_port=patch2,actions=push_vlan:0x88a8,mod_vlan_vid=$svid,output=$link
	ovs-ofctl -O OpenFlow13 add-flow br2 dl_vlan=$svid,actions=strip_vlan,patch2

	ovs-ofctl -O OpenFlow13 add-flow $br in_port=patch1,arp,dl_vlan=$vid,actions=strip_vlan,$rep2
	ovs-ofctl -O OpenFlow13 add-flow $br dl_vlan=$vid,dl_dst=02:25:d0:$host_num:01:02,priority=10,actions=strip_vlan,$rep2
	ovs-ofctl -O Openflow13 add-flow $br in_port=$rep2,ipv4,actions=push_vlan:0x8100,mod_vlan_vid=$vid,output=patch1
set +x
}

function br-veth
{
	ip link del host1 &> /dev/null
	ip link del host1_rep &> /dev/null
	ip netns del n11 &> /dev/null

	ip netns add n11

	ovs-vsctl list-br | xargs -r -l ovs-vsctl del-br
	if lsb_release -a | grep Ubuntu > /dev/null; then
		service ovs-vswitchd restart
	else
		service openvswitch restart
	fi
	ovs-vsctl list-br | xargs -r -l ovs-vsctl del-br
	sleep 1

	ip link add host1 type veth peer name host1_rep
	ip link set host1 netns n11
	ip netns exec n11 ifconfig host1 1.1.$host_num.1/16 up
	ifconfig host1_rep 0 up

	ovs-vsctl add-br $br
	ovs-vsctl add-port $br host1_rep -- set Interface host1_rep ofport_request=2
# 	ovs-vsctl add-port $br $link -- set Interface $link ofport_request=5
}

alias wget8="wget 8.9.10.11:8000"
function http-server
{
	python -m SimpleHTTPServer
}

function msglvl
{
	ethtool -s $link msglvl 0x004
}

function kmsg() {
	local m=$@
	if [ -w /dev/kmsg ]; then
		echo -e ":test: $m" >>/dev/kmsg
	fi
}

drgn_dir=~chrism//sm/drgn

function _flowtable
{
	i=0
	n=0
	[[ $# == 1 ]] && n=$1
	cd $drgn_dir
	while :; do
		echo "======== $i ======="
		sudo $drgn_dir/_flowtable.py
		i=$((i+1))
		if (( n == i )); then
			break;
		fi
		sleep 2
	done
}

function dev_table
{
	cd $drgn_dir
	sudo $drgn_dir/dev_table.py
}

function bus_type
{
	cd $drgn_dir
	sudo $drgn_dir/bus_type.py
}
alias bus=bus_type

function buf
{
	cd $drgn_dir
	sudo $drgn_dir/buf.py
}

function num_rules
{
	cd $drgn_dir
	sudo $drgn_dir/num_rules.py
}

function tc.py
{
	cd $drgn_dir
	sudo $drgn_dir/tc.py
}

function pedit
{
	cd $drgn_dir
	sudo $drgn_dir/pedit.py
}

function miniflow_wq
{
	cd $drgn_dir
	sudo $drgn_dir/miniflow_wq.py
}

function encap
{
	cd $drgn_dir
	sudo $drgn_dir/encap.py
}

function flow
{
	i=0
	n=0
	[[ $# == 1 ]] && n=$1
	cd $drgn_dir
	while :; do
		echo "======== $i ======="
		sudo $drgn_dir/flow.py
		i=$((i+1))
		if (( n == i )); then
			break;
		fi
		sleep 2
	done
}

function flow2
{
	cd $drgn_dir/ct
	sudo ./esw_chains_priv.py
}

function ct_list
{
	i=0
	n=0
	[[ $# == 1 ]] && n=$1
	cd $drgn_dir
	while :; do
		echo "======== $i ======="
		sudo $drgn_dir/ct_list.py
		i=$((i+1))
		if (( n == i )); then
			break;
		fi
		sleep 2
	done
}

function mlx5e_tc_flow
{
	i=0
	n=0
	[[ $# == 1 ]] && n=$1
	cd $drgn_dir
	while :; do
		echo "======== $i ======="
		sudo $drgn_dir/mlx5e_tc_flow.py
		i=$((i+1))
		if (( n == i )); then
			break;
		fi
		sleep 2
	done
}

function dr1
{
	cd $drgn_dir
set -x
	sudo ./_flowtable.py
	sudo ./mlx5e_tc_flow.py
	sudo ./ct_list.py  | grep mlx5e_tc
set +x
}

function while-dp
{
	while :; do
		echo "============================"
		dpd | grep drop
		sleep 2
	done
}

# UDP 5353
# sssd.service
function disable-avahi-daemon.service
{
	sudo systemctl stop avahi-daemon.service
	sudo systemctl disable avahi-daemon.service

	sudo systemctl stop sssd.service
	sudo systemctl disable sssd.service
}

alias udps="UDPServer.py --ipAddress=1.1.1.1 --port=4000 --clients 1.1.3.1 --successRate=100.0 --max_delay=10 --size=100 --packets=100"
alias udpc="UDPClient.py --serverAddr 1.1.1.1 --port=4000 --size=100 --packets=100 --sleep=0.1"

function set_combined
{
	n=4
	if [[ $# == 1 ]]; then
		n=$1
	fi
set -x
	ethtool -l $link
	ethtool -L $link combined $n
	ethtool -l $link
set +x
}

function perf-rx
{
	mlnx_perf -t 3 -i $link | grep -iE "rx_|---"
}

function perf-tx
{
	mlnx_perf -t 3 -i $link | grep -iE "tx_|---"
}

function taskset1
{
	for i in {0..7}; do
		taskset -c $i iperf -c 1.1.1.122 -i 1 -t 1000 &
	done
}

function fin
{
	local l=$link
	[[ $# == 1 ]] && l=$1
	tcpdump -i $l "tcp[tcpflags] & (tcp-fin) != 0" -nn
}

alias fin2="fin $rep2"

alias proc-iperf="cd /proc/$(pidof iperf)/fd"

function ipna
{
set -x
	if (( host_num == 13 )); then
		ip n d 192.168.1.14 dev enp4s0f0
		ip n a 192.168.1.14 lladdr 24:8a:07:88:27:ca dev $link
	fi
	if (( host_num == 14 )); then
		ip n d 192.168.1.13 dev enp4s0f0
		ip n a 192.168.1.13 lladdr 24:8a:07:88:27:9a dev $link
	fi
set +x
}

function ipnd
{
set -x
	if (( host_num == 13 )); then
		ip n d 192.168.1.14 dev enp4s0f0
	fi
	if (( host_num == 14 )); then
		ip n d 192.168.1.13 dev enp4s0f0
	fi
set +x
}

function rx-tx-on
{
set -x
	ethtool -K $link rx on tx on
set +x
}

function rx-tx-off
{
set -x
	ethtool -K $link rx off tx off
set +x
}

function msi
{
	a=$((1144-127))
	a=$((1536-127))
	b=$((a/240))
	echo $b
}
# cat /etc/trex_cfg.yaml

### Config file generated by dpdk_setup_ports.py ###

# - version: 2
#   interfaces: ['04:00.0', '04:00.1']
#   port_info:
#       - dest_mac: 02:25:d0:13:01:02
#         src_mac:  24:8a:07:88:27:ca
#       - dest_mac: 24:8a:07:88:27:ca # MAC OF LOOPBACK TO IT'S DUAL INTERFACE
#         src_mac:  24:8a:07:88:27:cb
# 
#   platform:
#       master_thread_id: 0
#       latency_thread_id: 1
#       dual_if:
#         - socket: 0
#           threads: [2,4,6,8,10,12,14]

alias cd-trex='cd /images/chrism/DPIX'
alias vit1='vi /images/chrism/DPIX/AsapPerfTester/TestParams/AsapPerfTestParams.py'
alias vitx='vi /images/chrism/DPIX/AsapPerfTester/TestParams/IpVarianceVxlan.py'
alias vit2='vi /images/chrism/DPIX/dpdk_conf/frame_size_-_64.dpdk.conf'
function trex
{
	cd-trex
	./asapPerfTester.py --confFile  ./AsapPerfTester/TestParams/AsapPerfTestParams.py  --logsDir AsapPerfTester/logs --noGraphicDisplay
}

function trex_loop
{
	cd-trex
	i=0
	while : ; do
		trex
		(( i++ == 100 )) && break
		echo "=============== $i ==============="
		sleep 10
	done
}

function trex-vxlan
{
	cd-trex
	./asapPerfTester.py --confFile  ./AsapPerfTester/TestParams/IpVarianceVxlan.py  --logsDir AsapPerfTester/logs --noGraphicDisplay
}

function trex-vxlan2
{
	cd-trex
	i=0
	while : ; do
		./asapPerfTester.py --confFile  ./AsapPerfTester/TestParams/IpVarianceVxlan.py  --logsDir AsapPerfTester/logs --noGraphicDisplay
		(( i++ == 100 )) && break
		echo "=============== $i ==============="
		sleep 60
	done
}

function trex-pf
{
	cd-trex
	i=0
	while : ; do
		./asapPerfTester.py --confFile  ./AsapPerfTester/TestParams/AsapPerfTestParams.py  --logsDir AsapPerfTester/logs --noGraphicDisplay
		(( i++ == 200 )) && break
		echo "=============== $i ==============="
		sleep 40
	done
}

function affinity
{
	irq=$(grep $link /proc/interrupts | awk '{print $1}' | sed 's/://')
	echo $irq
	for i in $irq; do
		echo $i
		cat /proc/irq/$i/smp_affinity
		echo
	done
}

# 9,11,13,15
function affinity_set
{
	irq=$(grep $link /proc/interrupts | awk '{print $1}' | sed 's/://')
	echo $irq
	n=3
	for i in $irq; do
		echo $i
		cat /proc/irq/$i/smp_affinity
		x=$(irq $n)
		echo $x > /proc/irq/$i/smp_affinity
		cat /proc/irq/$i/smp_affinity
		n=$((n+2))
		echo
	done
}

function irq
{
	[[ $# != 1 ]] && return
	n=1
	for i in {1..16}; do
		if [[ $1 == $i ]]; then
			printf "%x\n" $n
			return
		fi
		n=$((n*2))
	done
}


alias numa="cat /sys/class/net/$link/device/numa_node"

# ip a | grep 10.12.205.15 && hostname dev-chrism-vm1

function trex_arp
{
set -x
	if (( host_num == 13 )); then
		arp -d 192.168.1.14
# 		arp -s 192.168.1.14 24:8a:07:88:27:ca
		arp -s 192.168.1.14 b8:59:9f:bb:31:82
	fi

	if (( host_num == 14 )); then
		arp -d 192.168.1.13
# 		arp -s 192.168.1.13 24:8a:07:88:27:9a
		arp -s 192.168.1.13 b8:59:9f:bb:31:66
	fi
set +x
}

function arp2
{
set -x
	if (( host_num == 13 )); then
		arp -d 1.1.1.2
		arp -s 1.1.1.2 24:8a:07:88:27:ca
	fi

	if (( host_num == 14 )); then
		arp -d 1.1.1.1
		arp -s 1.1.1.1 24:8a:07:88:27:9a
	fi
set +x
}



function test-panic
{
set -x
	while :; do
		ovs-vsctl del-port $rep2 $br
		ovs-vsctl del-port $link $br
		ovs-vsctl add-port $rep2 $br
		ovs-vsctl add-port $link $br
		sleep 5
	done
set +x
}

alias vm='v drivers/net/ethernet/mellanox/mlx5/core/miniflow.c:1010'

alias top-ovs=" top -p $(pgrep ovs-)"

function siblings
{
	for ((i = 0; i < $(nproc); i++)); do
		echo -n "$i: "
		cat /sys/devices/system/cpu/cpu$i/topology/thread_siblings_list
	done
}

alias iperf-dnat='iperf -c 8.9.10.10 -p 9999 -i 1 -t 10000'

function restart-ovs-1
{
    n=0

    while :; do
        echo $n
        restart-ovs
	ovs-ofctl add-flow br "table=0,in_port=$link,actions=2,21,22,23,24,25,26,22,23,24,30,31,32,33,34,35,36,32,33,34,40,41,42,43,44,45,46,42,43,44,45,46,47,48,49,50"
	ovs-ofctl add-flow br "table=0,in_port=$rep2,actions=21,22,23,24,25,26,22,23,24,30,31,32,33,34,35,36,32,33,34,40,41,42,43,44,45,46,42,43,44,45,46,47,48,49,50"
        sudo ovs-appctl vlog/set netlink_socket:file:DBG;
        sudo ovs-appctl vlog/set tc:file:DBG
        sudo ovs-appctl vlog/set dpif_netlink:file:DBG
        sudo ovs-appctl vlog/set netdev_tc_offloads:file:DBG
        n=$((n+1))
        sleep 60
    done
}

function ethtool-tx
{
	while :; do
		tx=$(ethtool -S $link | grep -w tx_packets | cut -d":" -f 2)
		delta=$((tx-tx_old))
		echo $delta
		tx_old=$tx
		sleep 1
	done
}

function ethtool-rx
{
	while :; do
		tx=$(ethtool -S eth0 | grep -w rx_packets | cut -d":" -f 2)
		delta=$((tx-tx_old))
		echo $delta
		tx_old=$tx
		sleep 1
	done
}

function clear-br-ct
{
set -x
	ip link set dev br_tc down
	brctl  delbr br_tc
set +x
}

function tc-nat
{
set -x
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	del-br 2> /dev/null
	tc2 2> /dev/null
	tc-setup $rep2 2> /dev/null
	tc-setup $link 2> /dev/null

	tc filter add dev $rep2 ingress prio 1 chain 0 proto ip flower $offload ct_state -trk action ct pipe action goto chain 1
	tc filter add dev $rep2 ingress prio 1 chain 1 proto ip flower $offload ct_state +trk+new \
		action ct commit pipe action mirred egress redirect dev $link
	tc filter add dev $rep2 ingress prio 1 chain 1 proto ip flower $offload ct_state +trk+est \
		action ct pipe action mirred egress redirect dev $link

	tc filter add dev $link ingress prio 1 chain 0 proto ip flower $offload ct_state -trk action ct pipe action goto chain 1
	tc filter add dev $link ingress prio 1 chain 1 proto ip flower $offload ct_state +trk+est \
		action ct pipe action mirred egress redirect dev $rep2
set +x
}

function tc-nat2
{
set -x
	tc2
	tc-setup $rep2
	tc-setup $link

	tc filter add dev $rep2 ingress \
		prio 1 chain 0 proto ip \
		flower ip_proto tcp ct_state -trk \
		action ct zone 2 pipe \
		action goto chain 2
	tc filter add dev $rep2 ingress \
		prio 1 chain 2 proto ip \
		flower ct_state +trk+new \
		action ct zone 2 commit mark 0xbb nat src addr 8.9.10.10 pipe \
		action mirred egress redirect dev $link
	tc filter add dev $rep2 ingress \
		prio 1 chain 2 proto ip \
		flower ct_zone 2 ct_mark 0xbb ct_state +trk+est \
		action ct nat pipe \
		action mirred egress redirect dev $link

	tc filter add dev $link ingress \
		prio 1 chain 0 proto ip \
		flower ip_proto tcp ct_state -trk \
		action ct zone 2 pipe \
		action goto chain 1
	tc filter add dev $link ingress \
		prio 1 chain 1 proto ip \
		flower ct_zone 2 ct_mark 0xbb ct_state +trk+est \
		action ct nat pipe \
		action mirred egress redirect dev $rep2
set +x
}

alias show-bond='cat /proc/net/bonding/bond0'

alias cd-ports='cd /sys/class/infiniband/mlx5_0/ports'
function cat-ports
{
	port=1
	[[ $# == 1 ]] && port=$1
	cat /sys/class/infiniband/mlx5_0/ports/$port/counters/port_xmit_discards
}

function ka
{
	[[ $# != 1 ]] && return
	addr=$(echo $1 | sed 's/0x//')
	sudo grep $addr /proc/kallsyms
}

function inject
{
set -x
	cd /root/aer-inject-0.1/
	./aer-inject ./test/cx3/aer1
set +x
}

function dmfs
{
set -x
	if (( ofed_mlx5 == 1 )); then
		echo dmfs > /sys/class/net/$link/compat/devlink/steering_mode 
	else
		devlink dev param set pci/$pci name flow_steering_mode value "dmfs" \
			cmode runtime || echo "Failed to set steering sw"
	fi

set +x
}

function smfs
{
set -x
	if (( ofed_mlx5 == 1 )); then
		echo smfs > /sys/class/net/$link/compat/devlink/steering_mode
	else
		devlink dev param set pci/$pci name flow_steering_mode value "smfs" \
			cmode runtime || echo "Failed to set steering sw"
	fi
set +x
}

function get-fs
{
set -x
	if (( ofed_mlx5 == 1 )); then
		cat /sys/class/net/$link/compat/devlink/steering_mode
	else
		devlink dev  param show  pci/$pci name flow_steering_mode
	fi
set +x
}

function tune-eth2
{
set -x
	ethtool -L $rep2 combined 4
	ethtool -l $rep2
	ethtool -g $rep2

	ethtool -G $rep2 rx 8192
	ethtool -G $rep2 tx 8192

	ethtool -G $link rx 8192
	ethtool -G $link tx 8192

	n1 ethtool -G $vf2 rx 8192
	n1 ethtool -G $vf2 tx 8192
set +x
}

function isolcpus
{
        [[ $# != 2 ]] && return
        for (( i = $1; i <= $2; i++ )); do
                printf "%d," $i
        done
}

alias vi_nginx='vi /usr/local/nginx/conf/nginx.conf'
alias nginx_reload='/usr/local/nginx/sbin/nginx -s reload'
alias nginx='/usr/local/nginx/sbin/nginx'

# net.netfilter.nf_conntrack_generic_timeout = 600
# net.netfilter.nf_conntrack_icmp_timeout = 30
# net.netfilter.nf_conntrack_tcp_timeout_close = 10
# net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
# net.netfilter.nf_conntrack_tcp_timeout_established = 432000
# net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
# net.netfilter.nf_conntrack_tcp_timeout_last_ack = 30
# net.netfilter.nf_conntrack_tcp_timeout_max_retrans = 300
# net.netfilter.nf_conntrack_tcp_timeout_syn_recv = 60
# net.netfilter.nf_conntrack_tcp_timeout_syn_sent = 120
# net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
# net.netfilter.nf_conntrack_tcp_timeout_unacknowledged = 300
# net.netfilter.nf_conntrack_udp_timeout = 30
# net.netfilter.nf_conntrack_udp_timeout_stream = 180

# net.netfilter.nf_conntrack_generic_timeout=60
# net.netfilter.nf_conntrack_icmp_timeout=10
#net.netfilter.nf_conntrack_tcp_timeout_close=10
# net.netfilter.nf_conntrack_tcp_timeout_close_wait=20
# net.netfilter.nf_conntrack_tcp_timeout_established=1800
# net.netfilter.nf_conntrack_tcp_timeout_fin_wait=30
#net.netfilter.nf_conntrack_tcp_timeout_last_ack=30
#net.netfilter.nf_conntrack_tcp_timeout_max_retrans=300
# net.netfilter.nf_conntrack_tcp_timeout_syn_recv=30
# net.netfilter.nf_conntrack_tcp_timeout_syn_sent=60
# net.netfilter.nf_conntrack_tcp_timeout_time_wait=60
#net.netfilter.nf_conntrack_tcp_timeout_unacknowledged=300
#net.netfilter.nf_conntrack_udp_timeout=30
# net.netfilter.nf_conntrack_udp_timeout_stream=60

function sysctl_get_nf
{
# 	for i in	\
# 			net.netfilter.nf_conntrack_generic_timeout	\
# 			net.netfilter.nf_conntrack_icmp_timeout	\
# 			net.netfilter.nf_conntrack_tcp_timeout_close	\
# 			net.netfilter.nf_conntrack_tcp_timeout_close_wait	\
# 			net.netfilter.nf_conntrack_tcp_timeout_established	\
# 			net.netfilter.nf_conntrack_tcp_timeout_fin_wait	\
# 			net.netfilter.nf_conntrack_tcp_timeout_last_ack	\
# 			net.netfilter.nf_conntrack_tcp_timeout_max_retrans	\
# 			net.netfilter.nf_conntrack_tcp_timeout_syn_recv	\
# 			net.netfilter.nf_conntrack_tcp_timeout_syn_sent	\
# 			net.netfilter.nf_conntrack_tcp_timeout_time_wait	\
# 			net.netfilter.nf_conntrack_tcp_timeout_unacknowledged	\
# 			net.netfilter.nf_conntrack_udp_timeout	\
# 			net.netfilter.nf_conntrack_udp_timeout_stream; do
# 		sysctl $i
# 	done

	sysctl -a | grep conntrack | grep timeout
}

function sysctl_set_nf
{
set -x
	sysctl -w net.netfilter.nf_conntrack_generic_timeout=60
	sysctl -w net.netfilter.nf_conntrack_icmp_timeout=10
	sysctl -w net.netfilter.nf_conntrack_tcp_timeout_close_wait=20
	sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established=1800
	sysctl -w net.netfilter.nf_conntrack_tcp_timeout_fin_wait=30
	sysctl -w net.netfilter.nf_conntrack_tcp_timeout_syn_recv=30
	sysctl -w net.netfilter.nf_conntrack_tcp_timeout_syn_sent=60
	sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=60
	sysctl -w net.netfilter.nf_conntrack_udp_timeout_stream=60

	[[ $# == 0 ]] && return

	sysctl -w net.netfilter.nf_conntrack_generic_timeout=600
	sysctl -w net.netfilter.nf_conntrack_icmp_timeout=30
	sysctl -w net.netfilter.nf_conntrack_tcp_timeout_close_wait=60
	sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established=432000
	sysctl -w net.netfilter.nf_conntrack_tcp_timeout_fin_wait=120
	sysctl -w net.netfilter.nf_conntrack_tcp_timeout_syn_recv=60
	sysctl -w net.netfilter.nf_conntrack_tcp_timeout_syn_sent=120
	sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=120
	sysctl -w net.netfilter.nf_conntrack_udp_timeout_stream=180

set +x
}

alias est='conntrack -L | grep EST'
alias ct8='conntrack -L | grep 8.9.10'
alias tcp_timeout="sysctl -a | grep conntrack | grep tcp_timeout"

function wrk_tune
{
 	set_all_vf_channel_ns 1
	set_all_vf_affinity 96
}

# ovs snat rule
alias wrk_rule="~chrism/bin/test_router5-snat-all-ofed5-2.sh $link $((numvfs-1))"
alias wrk_rule2="~chrism/bin/test_router5-snat-all-ofed5-logan.sh $link $((numvfs-1))"

function wrk_setup
{
	off
	sleep 1
	smfs
	restart

# 	ovs-vsctl set open_vswitch . other_config:max-idle="300000"
	ovs-vsctl set open_vswitch . other_config:n-handler-threads="8"
	ovs-vsctl set open_vswitch . other_config:n-revalidator-threads="8"

# 	wrk_rule
	wrk_rule2

	init_vf_ns
	set_all_rep_channel 63

# 	wrk_tune
}

alias wrk_loop="while :; do wrk_run0 ; sleep 30; done"

function wrk_run0
{
        local port=0
        local time=30
        num_ns=1
	num_cpu=96
	num_cpu=16
        [[ $# == 1 ]] && num_ns=$1

	/bin/rm -rf  /tmp/result-*
        cd /root/wrk-nginx-container
        for (( cpu = 0; cpu < num_cpu; cpu++ )); do
                n=$((n%num_ns))
                local ns=n1$((n+1))
                n=$((n+1))
                ip=1.1.1.200
                ip=8.9.10.11
set -x
                ip netns exec $ns taskset -c $cpu /images/chrism/wrk/wrk -d $time -t 1 -c 30 --latency --script=counter.lua http://[$ip]:$((80+port)) > /tmp/result-$cpu &
set +x

                port=$((port+1))
                if (( $port >= 9 )); then
                        port=0
                fi
        done

        i=1
        while :; do
                echo $i
                i=$((i+1))
                sleep 1
                (( i == time )) && break
        done
        sleep 5
        cat /tmp/result-* | grep Requests | awk '{printf("%d+",$2)} END{print(0)}' | bc -l

}

function wrk_run1
{
        local port=0
        local time=30
        num_ns=1
	num_cpu=1
        [[ $# == 1 ]] && num_cpu=$1

	/bin/rm -rf  /tmp/result-*
        cd /root/wrk-nginx-container
        for (( cpu = 0; cpu < num_cpu; cpu++ )); do
                n=$((n%num_ns))
                local ns=n1$((n+1))
                n=$((n+1))
                ip=1.1.1.200
                ip=8.9.10.11
set -x
                ip netns exec $ns taskset -c $cpu /images/chrism/wrk/wrk -d $time -t 1 -c 30 --latency --script=counter.lua http://[$ip]:$((80+port)) > /tmp/result-$cpu &
set +x

                port=$((port+1))
                if (( $port >= 9 )); then
                        port=0
                fi
        done

        i=1
        while :; do
                echo $i
                i=$((i+1))
                sleep 1
                (( i == time )) && break
        done
        sleep 5
        cat /tmp/result-* | grep Requests | awk '{printf("%d+",$2)} END{print(0)}' | bc -l

}



function wrk_pf
{
        local port=0
        local time=30
        num_ns=1
	num_cpu=1
	sever=2
        [[ $# == 1 ]] && num_cpu=$1
        if [[ $# == 2 ]]; then
		num_cpu=$1
		server=$2
	fi

	/bin/rm -rf  /tmp/result-*
        cd /root/wrk-nginx-container
        for (( cpu = 0; cpu < num_cpu; cpu++ )); do
                n=$((n%num_ns))
                local ns=n1$((n+1))
                n=$((n+1))
                ip=1.1.1.200
                ip=8.9.10.11
                ip=192.168.1.$server
set -x
		taskset -c $cpu /images/chrism/wrk/wrk -d $time -t 1 -c 30 --latency --script=counter.lua http://[$ip]:$((80+port)) > /tmp/result-$cpu &
set +x

                port=$((port+1))
                if (( $port >= 9 )); then
                        port=0
                fi
        done

        i=1
        while :; do
                echo $i
                i=$((i+1))
                sleep 1
                (( i == time )) && break
        done
        sleep 5
        cat /tmp/result-* | grep Requests | awk '{printf("%d+",$2)} END{print(0)}' | bc -l
}

function wrk_loop
{
	n=0
	for (( i = 0; i < 1000; i++ )); do
		wrk_run0 $(((n%15)+1))
		n=$((n+1))
	done
}

# best performance, conneciton=60, set all VFs affinity to cpu 0-11
# wrk_run 84 12
# 3157681

function wrk_run
{
	local port=0
	local n=1
	local start=0

	local thread=1

	local time=30
	local connection=60

	if [[ $# == 1 ]]; then
		n=$1
	elif [[ $# == 2 ]]; then
		n=$1
		start=$2
	elif [[ $# == 3 ]]; then
		n=$1
		start=$2
		time=$3
	elif [[ $# == 4 ]]; then
		n=$1
		start=$2
		time=$3
		connection=$4
	fi
	total=0

	end=$((start+n))

	cd /root/wrk-nginx-container

	/bin/rm -rf  /tmp/result-*
	WRK=/usr/bin/wrk
	WRK=/images/chrism/wrk/wrk
	for (( cpu = start; cpu < end; cpu++ )); do
# 	for (( cpu = 2; cpu < 3; cpu++ )); do
		ns=n1$((cpu+1-start))
		cpu1=$cpu
set -x
		ip netns exec $ns taskset -c $cpu1 $WRK -d $time -t $thread -c $connection  --latency --script=counter.lua http://[8.9.10.11]:$((80+port)) > /tmp/result-$cpu &
set +x
		port=$((port+1))
		if (( $port >= 9 )); then
			port=0
		fi
		total=$((total+1))
		(( total == n )) && break
	done
	i=1
	while :; do
		echo $i
		i=$((i+1))
		sleep 1
		(( i == time )) && break
	done
	sleep 3
	cat /tmp/result-* | grep Requests | awk '{printf("%d+",$2)} END{print(0)}' | bc -l
}

function wrk_run2
{
set -x
	local thread=1
	local time=30
	local connection=30

	cd /root/wrk-nginx-container

	/bin/rm -rf  /tmp/result-*
	WRK=/usr/bin/wrk
	WRK=/images/chrism/wrk/wrk

	local port=0
	for (( cpu = 0; cpu < 12; cpu++ )); do
		ns=n1$((cpu+1))
		ip netns exec $ns taskset -c $cpu $WRK -d $time -t $thread -c $connection  --latency --script=counter.lua http://[8.9.10.11]:$((80+port)) > /tmp/result-$cpu &
		port=$((port+1))
		if (( $port >= 9 )); then
			port=0
		fi
	done

	port=0
	for (( cpu = 24; cpu < 36; cpu++ )); do
		ns=n1$((cpu+1))
		ip netns exec $ns taskset -c $cpu $WRK -d $time -t $thread -c $connection  --latency --script=counter.lua http://[8.9.10.11]:$((80+port)) > /tmp/result-$cpu &
		port=$((port+1))
		if (( $port >= 9 )); then
			port=0
		fi
	done

	sleep $((time+3))
	cat /tmp/result-* | grep Requests | awk '{printf("%d+",$2)} END{print(0)}' | bc -l
set +x
}

function taskset_ovs
{
	taskset -pac 0-11,48-59 `pidof ovs-vswitchd`
}

function show_irq_affinity_vf
{
	local vf
	local n

	local cpu_num=$numvfs
	[[ $# == 1 ]] && cpu_num=$1

	curr_cpu=1
	for (( i = 1; i < numvfs; i++ )); do
		vf=$(get_vf_ns $((i)))
		echo "vf$i=$vf"
		show_irq_affinity.sh $vf
	done
}

function run-wrk1
{
set -x
	cd /root/wrk-nginx-container
	WRK=/images/chrism/wrk/wrk
# 	$WRK -d 60 -t 1 -c 1  --latency --script=counter.lua http://[8.9.10.11]:80
	$WRK -d 1 -t 1 -c 1  --latency --script=counter.lua http://[1.1.1.200]:80
set +x
}

# keepalive_requests

function run-wrk2
{
	port=0

# 	cd /root/container-test
set -x
	cd wrk-nginx-container

	WRK=/usr/bin/wrk
	WRK=/images/chrism/wrk/wrk
# 	for i in {0..50}; do
		for cpu in {0..23}; do
# 			taskset -c $cpu $WRK -d 60 -t 1 -c 30  --latency --script=counter.lua http://[8.9.10.11]:8$port > /tmp/result-$cpu &

			taskset -c $cpu $WRK -d 60 -t 1 -c 30  --latency --script=counter.lua http://[8.9.10.11]:8$port > /tmp/result-$cpu &
# 			taskset -c $cpu $WRK -d 60 -t 1 -c 30  --latency --script=counter.lua http://[1.1.1.200]:8$port > /tmp/result-$cpu &
			port=$((port+1))
			if (( $port > 9 )); then
				port=0
			fi
		done
		wait %1
		sleep 10
		cat /tmp/result-* | grep Requests | awk '{printf("%d+",$2)} END{print(0)}' | bc -l
# 		sleep 90
# 	done
set +x
}

# for nginx
function worker_cpu_affinity
{
	n=96
	[[ $# == 1 ]] && n=$1
	for (( i = 1; i <= $n; i++ )); do
		for (( j = 1; j <= $n; j++ )); do
			if (( i == j )); then
				printf "1"
			else
				printf "0"
			fi
		done
		printf " "
	done
}

function wrk-result
{
	cat /tmp/result-* | grep Requests | awk '{printf("%d+",$2)} END{print(0)}' | bc -l
}

function tc-5t
{
	cd /root/dev
	./test-tc-perf-update.sh 5t 100000 2
}

function github_push
{
	git remote rm origin
	git remote add origin git@github.com:mishuang2017/sm.git
# 	git remote add origin https://github.com/mishuang2017/sm.git
	git push -u origin master
}

function modules
{
	modules=$(lsmod | awk '{print $1}')
	for i in $modules; do
		cd /lib/modules/5.4.19+
set -x
		find . -name $i.ko.xz
set +x
	done
}

function install_libkdumpfile
{
	sm
	git clone https://github.com/ptesarik/libkdumpfile
	cd libkdumpfile/
	sudo yum install -y python-devel
	autoreconf -fi
	make-usr
}

# sflow

alias vi-sflow='vi ~/sm/sflow/note.txt'

function tc_sample
{
set -x
	rate=1
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=tc
	TC=/images/chrism/iproute2/tc/tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $rep3 ingress

	ethtool -K $rep2 hw-tc-offload on
	ethtool -K $rep3 hw-tc-offload on

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $rep3 ingress 

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:01:03
	$TC filter add dev $rep2 ingress protocol ip  prio 2 flower $offload src_mac $src_mac dst_mac $dst_mac \
		action sample rate $rate group 5 trunc 60 \
		action mirred egress redirect dev $rep3
# 	$TC filter add dev $rep2 ingress protocol arp prio 1 flower $offload \
# 		action mirred egress redirect dev $rep3

	src_mac=02:25:d0:$host_num:01:03
	dst_mac=02:25:d0:$host_num:01:02
# 	$TC filter add dev $rep3 ingress protocol ip  prio 2 flower $offload src_mac $src_mac dst_mac $dst_mac \
# 		action sample rate $rate group 6 trunc 60 \
# 		action mirred egress redirect dev $rep2
# 	$TC filter add dev $rep3 ingress protocol arp prio 1 flower $offload \
# 		action mirred egress redirect dev $rep2
set +x
}

function tc_sample1
{
set -x
	rate=2
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	TC=tc
	TC=/images/chrism/iproute2/tc/tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $rep3 ingress

	ethtool -K $rep2 hw-tc-offload on
	ethtool -K $rep3 hw-tc-offload on

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $rep3 ingress 

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:01:03
	$TC filter add dev $rep2 ingress protocol ip  prio 2 flower $offload src_mac $src_mac dst_mac $dst_mac \
		action sample rate $rate group 5 \
		action mirred egress redirect dev $rep3
set +x
}

function tc_sample_encap
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2
	rate=2

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx #udp6zerocsumtx udp6zerocsumrx
	ip link set $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on
	ethtool -K $redirect  hw-tc-offload on

	$TC qdisc add dev $link ingress
	$TC qdisc add dev $redirect ingress
	$TC qdisc add dev $vx ingress

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	$TC filter add dev $redirect protocol ip  parent ffff: prio 1 flower $offload \
		src_mac $local_vm_mac	\
		dst_mac $remote_vm_mac	\
		action sample rate $rate group 5 trunc 60 \
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx
set +x
}

function tc_sample_decap
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx #udp6zerocsumtx udp6zerocsumrx
	ip link set $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on
	ethtool -K $redirect  hw-tc-offload on

	$TC qdisc add dev $link ingress
	$TC qdisc add dev $redirect ingress
	$TC qdisc add dev $vx ingress

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	$TC filter add dev $vx protocol ip  parent ffff: prio 1 flower $offload	\
		src_mac $remote_vm_mac	\
		dst_mac $local_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action sample rate 2 group 5 trunc 128	\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect

set +x
}

function tc_sample_vxlan
{
set -x
	offload=""
	[[ "$1" == "hw" ]] && offload="skip_sw"
	[[ "$1" == "sw" ]] && offload="skip_hw"

	TC=tc
	redirect=$rep2
	rate=1

	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add $vx type vxlan dstport $vxlan_port external udp6zerocsumrx #udp6zerocsumtx udp6zerocsumrx
	ip link set $vx up

	$TC qdisc del dev $link ingress > /dev/null 2>&1
	$TC qdisc del dev $redirect ingress > /dev/null 2>&1
	$TC qdisc del dev $vx ingress > /dev/null 2>&1

	ethtool -K $link hw-tc-offload on
	ethtool -K $redirect  hw-tc-offload on

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	$TC filter add dev $redirect protocol ip  parent ffff: prio 2 flower $offload \
		src_mac $local_vm_mac	\
		dst_mac $remote_vm_mac	\
		action sample rate $rate group 5 \
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni \
		action mirred egress redirect dev $vx

	$TC filter add dev $redirect protocol arp parent ffff: prio 1 flower skip_hw	\
		src_mac $local_vm_mac	\
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx

	$TC filter add dev $vx protocol ip  parent ffff: prio 3 flower $offload	\
		src_mac $remote_vm_mac	\
		dst_mac $local_vm_mac	\
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action sample rate $rate group 6 \
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect
	$TC filter add dev $vx protocol arp parent ffff: prio 1 flower skip_hw	\
		src_mac $remote_vm_mac \
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset	pipe	\
		action mirred egress redirect dev $redirect


set +x
}

function sample1
{
	group=4
	[[ $# == 1 ]] && group=$1
	TC=tc
	TC=/images/chrism/iproute2/tc/tc

	$TC qdisc del dev $link ingress
	$TC qdisc add dev $link handle ffff: ingress
set -x
	$TC filter add dev $link parent ffff: matchall action sample rate 12 group $group
set +x
}

function sflow_clear
{
	ovs-vsctl -- clear Bridge $br sflow
}

function sflow_list
{
	ovs-vsctl list sflow
}

function sflow_create
{
	local rate=1

	[[ $# == 1 ]] && rate=$1

	local header=60
	local polling=1000
	if (( host_num == 13 )); then
		ovs-vsctl -- --id=@sflow create sflow agent=eno1 target=\"10.75.205.14:6343\" header=$header sampling=$rate polling=$polling -- set bridge br sflow=@sflow
	fi
	if (( host_num == 14 )); then
set -x
		ovs-vsctl -- --id=@sflow create sflow agent=eno1 target=\"10.75.205.13:6343\" header=$header sampling=$rate polling=$polling -- set bridge br sflow=@sflow
# 		ovs-vsctl -- --id=@sflow create sflow agent=$link target=\"192.168.1.13:6343\" header=$header sampling=$rate polling=$polling -- set bridge br sflow=@sflow
set +x
	fi
	if (( host_num == 41 )); then
		ovs-vsctl -- --id=@sflow create sflow agent=eno1 target=\"10.236.0.242:6343\" header=$header sampling=$rate polling=$polling -- set bridge br sflow=@sflow
	fi
}

function sflow_create_vxlan
{
	local polling=1000

	if (( host_num == 14 )); then
		ovs-vsctl -- --id=@sflow create sflow agent=eno1 target=\"1.1.1.200:6343\" header=128 sampling=2 polling=$polling -- set bridge br sflow=@sflow
	fi
}

function sflowtool1
{
	sflowtool -p 6343 -L localtime,srcIP,dstIP
}

function sflowtool6
{
	sflowtool -p 6343 -L localtime,srcIP,dstIP,srcIP6,dstIP6
}

function sflowtool2
{
	sflowtool -p 6343 -L localtime,srcIP,dstIP,inputPort,outputPort,sampledPacketSize,IPProtocol
}

function sflowtool_tcpdump
{
	sflowtool -p 6343 -t | tcpdump -r -
}

function ovs_run_test
{
	make check TESTSUITEFLAGS=$1
}

ip1=10.141.34.7
ip2=10.141.34.8

# ip1=10.236.149.183
# ip2=10.236.149.184
function test_setup
{
set -x
	hostname1=c-141-34-1-007
	hostname2=c-141-34-1-008
	test_config=10.141.34.7-8_cx5

# 	hostname1=c-236-149-180-183
# 	hostname2=c-236-149-180-184
# 	test_config=10.236.149.183-184_cx5

	test_file=/.autodirect/sw_regression/linux/sw_ovs/conf/mars/cloud-topologies/connectx5/VF/sw_steering/kernel/vxlan_vlan_ipv4/default.xml
	python /auto/swgwork/isram/tools/ofed/prepareSetup.py	\
		-clusterIPs "$ip1 $ip2"			\
		-e "$hostname1 $hostname2"		\
		-t $test_config				\
		-c "$test_file --custom_configs None"

# 	python /auto/swgwork/isram/tools/ofed/prepareSetup.py	\
# 		-clusterIPs "10.141.34.7 10.141.34.8"		\
# 		-e "c-141-34-1-007 c-141-34-1-008"		\
# 		-t 10.141.34.7-8_cx5				\
# 		-c "/.autodirect/sw_regression/linux/sw_ovs/conf/mars/cloud-topologies/connectx5/VF/sw_steering/kernel/vxlan_vlan_ipv4/default.xml --custom_configs None"
set +x
}

function test_cleanup
{
set -x
	/opt/python/2.7.3/bin/python2.7 /opt/python/2.7.3/bin/SetupCleanup.py --clusterIPs $ip1 $ip2
set +x
}

######## uuu #######

[[ -f /usr/bin/lsb_release ]] || return

[[ "$USER" == "chrism" ]] && alias s='sudo su -'
alias vig='sudo vim /boot/grub/grub.cfg'

[[ "$(hostname -s)" == "xiaomi" ]] && host_num=200
if (( host_num == 200 )); then
	link=wlp2s0
fi

function root-login
{
	file=/etc/ssh/sshd_config
	sed -i '/PermitRootLogin/d' $file
	echo "PermitRootLogin yes" >> $file
	/etc/init.d/ssh restart
}

function reboot1
{
set -x
	local uname=$(uname -r)

	[[ $# == 1 ]] && uname=$1

	sudo kexec -l /boot/vmlinuz-$uname --reuse-cmdline --initrd=/boot/initrd.img-$uname
	sudo kexec -e
set +x
}

function grub
{
set -x
	local kernel
	[[ $# == 1 ]] && kernel=$1
	file=/etc/default/grub
	MKCONFIG=grub-mkconfig
	sudo sed -i '/GRUB_CMDLINE_LINUX/d' $file
	sudo echo "GRUB_CMDLINE_LINUX=\"intel_iommu=on biosdevname=0 pci=realloc crashkernel=256M processor.max_cstate=1 intel_idle.max_cstate=0\"" >> $file
	# for crashkernel, configure /etc/default/grub.d/kdump-tools.cfg

	sudo /bin/rm -rf /boot/*.old
	sudo mv /boot/grub/grub.cfg /boot/grub/grub.cfg.orig
	sudo $MKCONFIG -o /boot/grub/grub.cfg

set +x
	sudo cat $file
}

function disable-gdm3
{
	# service --status-all
	systemctl stop gdm3
	systemctl disable gdm3
	systemctl set-default multi-user.target
}

function ln-crash
{
	cd $crash_dir
	local dir=$(ls -td $(date +%Y)*/ | head -1)
	local n=$(ls vmcore* | wc -l)
	ln -s ${dir}dump* vmcore.$n
}

# uncomment the following for built-in kernel
# VMLINUX=/usr/lib/debug/boot/vmlinux-$(uname -r)
alias crash1="$CRASH -i /root/.crash $VMLINUX"

alias c0="$CRASH -i /root/.crash $crash_dir/vmcore.0 $VMLINUX"
alias c1="$CRASH -i /root/.crash $crash_dir/vmcore.1 $VMLINUX"
alias c2="$CRASH -i /root/.crash $crash_dir/vmcore.2 $VMLINUX"
alias c3="$CRASH -i /root/.crash $crash_dir/vmcore.3 $VMLINUX"
alias c4="$CRASH -i /root/.crash $crash_dir/vmcore.4 $VMLINUX"
alias c5="$CRASH -i /root/.crash $crash_dir/vmcore.5 $VMLINUX"
alias c6="$CRASH -i /root/.crash $crash_dir/vmcore.6 $VMLINUX"
alias c7="$CRASH -i /root/.crash $crash_dir/vmcore.7 $VMLINUX"
alias c8="$CRASH -i /root/.crash $crash_dir/vmcore.8 $VMLINUX"
alias c9="$CRASH -i /root/.crash $crash_dir/vmcore.9 $VMLINUX"

alias ls='ls --color=auto'

function install-dbgsym
{
	echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse
	deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse
	deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list.d/ddebs.list

	sudo apt install ubuntu-dbgsym-keyring

	sudo apt-get update
	sudo apt -y install linux-image-$(uname -r)-dbgsym
}

function start-ovs
{
	sudo systemctl start openvswitch-switch.service
	return
	smo
# 	mkdir -p /etc/openvswitch
# 	ovsdb-tool create /etc/openvswitch/conf.db vswitchd/vswitch.ovsschema
set -x
	ovsdb-server /etc/openvswitch/conf.db -vconsole:emer -vsyslog:err -vfile:info --remote=punix:/usr/local/var/run/openvswitch/db.sock --private-key=db:Open_vSwitch,SSL,private_key --certificate=db:Open_vSwitch,SSL,certificate --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert --no-chdir --log-file=/usr/local/var/log/openvswitch/ovsdb-server.log --pidfile=/usr/local/var/run/openvswitch/ovsdb-server.pid --detach --monitor
	ovs-vswitchd unix:/usr/local/var/run/openvswitch/db.sock -vconsole:emer -vsyslog:err -vfile:info --mlockall --no-chdir --log-file=/usr/local/var/log/openvswitch/ovs-vswitchd.log --pidfile=/usr/local/var/run/openvswitch/ovs-vswitchd.pid --detach --monitor
	sudo systemctl start ovsdb-server.service
	sudo systemctl start ovs-vswitchd.service
set +x
}

function restart-ovs
{
	sudo systemctl restart openvswitch-switch.service
}

function stop-ovs
{
	sudo systemctl stop openvswitch-switch.service
	sudo systemctl stop ovsdb-server.service
}

function ovs-dpkg
{
	export CFLAGS='-g -O0'
	DEB_BUILD_OPTIONS="parallel=40 nocheck" dpkg-buildpackage -b -us -uc
}

e=enp0s31f6

function br-hp
{
	del-br
	sudo ovs-vsctl add-br $br
	sudo ovs-vsctl add-port $br $e
	sudo ifconfig $br 1.1.1.1/24 up
}
alias br1=br-hp
alias pi200='ssh pi@192.168.31.200'
alias pi100='ssh pi@192.168.31.100'
alias pi='ssh pi@1.1.1.2'

function chrome
{
	sudo google-chrome --proxy-server="10.75.205.14:79" --no-sandbox
}

function sound
{
	sudo modprobe -v snd_hda_intel
}

function make_ovs_deb
{
	DEB_BUILD_OPTIONS='parallel=16' fakeroot debian/rules binary
}

function load_psample
{
	psample=`find /lib/modules/$(uname -r) -name psample.ko*`
	echo $psample
	if test -n $psample; then
		module=`basename $psample | cut -d . -f 1`
		echo $module
	fi
}

alias status='systemctl status openvswitch-switch'
alias status2='systemctl status openvswitch-nonetwork.service'
