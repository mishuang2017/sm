# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

numvfs=3

[[ "$(hostname -s)" == "dev-r630-03" ]] && host_num=13
[[ "$(hostname -s)" == "dev-r630-04" ]] && host_num=14
[[ "$(hostname -s)" == "gen-h-vrt-015" ]] && host_num=5
[[ "$(hostname -s)" == "gen-h-vrt-016" ]] && host_num=6
[[ "$(hostname -s)" == "dev-chrism-vm1" ]] && host_num=15
[[ "$(hostname -s)" == "dev-chrism-vm2" ]] && host_num=16
[[ "$(hostname -s)" == "dev-chrism-vm3" ]] && host_num=17
[[ "$(hostname -s)" == "dev-chrism-vm4" ]] && host_num=18

if (( host_num == 13 )); then
	export DISPLAY=MTBC-CHRISM:0.0

	link=enp4s0f0
	link2=enp4s0f1
	rhost_num=14
	link_remote_ip=192.168.1.$rhost_num
	link_remote_ip2=192.168.2.$rhost_num
	link_remote_ipv6=1::$rhost_num
	remote_mac=24:8a:07:88:27:ca

	vf1=enp4s0f2
	vf2=enp4s0f3
	vf3=enp4s0f4

elif (( host_num == 14 )); then
	export DISPLAY=MTBC-CHRISM:0.0

	link=enp4s0f0
	link2=enp4s0f1
	rhost_num=13
	link_remote_ip=192.168.1.$rhost_num
	link_remote_ip2=192.168.2.$rhost_num
	link_remote_ipv6=1::$rhost_num
	remote_mac=24:8a:07:88:27:9a

	vf1=enp4s0f2
	vf2=enp4s0f3
	vf3=enp4s0f4

elif (( host_num == 5 )); then
	link=enp129s0f0
	link2=enp129s0f1

	vf1=enp129s0f2
	vf2=enp129s0f3
	vf3=enp129s0f4

elif (( host_num == 6 )); then
	link=enp129s0f0
	link2=enp129s0f1

	vf1=enp129s0f2
	vf2=enp129s0f3
	vf3=enp129s0f4

elif (( host_num == 15 )); then
	link=ens9
elif (( host_num == 16 )); then
	link=ens9
elif (( host_num == 17 )); then
	link=ens9
elif (( host_num == 18 )); then
	link=ens9
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

nfs_dir='/auto/mtbcswgwork/chrism'
crash_dir=/var/crash
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

if [[ "$UID" == "0" ]]; then
	dmidecode | grep "Red Hat" > /dev/null 2>&1
	rh=$?
fi

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

rep1=${link}_0
rep2=${link}_1
rep3=${link}_2
rep4=${link}_3
rep5=${link}_4

rep1_2=${link2}_0
rep2_2=${link2}_1
rep3_2=${link2}_2
rep4_2=${link2}_3
rep5_2=${link2}_4

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
# modprobe mlx5_core > /dev/null 2>&1
function get_pci
{
	if [[ -e /sys/class/net/$link/device && -f /usr/sbin/lspci ]]; then
		pci=$(basename $(readlink /sys/class/net/$link/device))
		pci_id=$(echo $pci | cut -b 6-)
		lspci -d 15b3: -nn | grep $pci_id | grep 1019 > /dev/null && cx5=1
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

alias vsconfig="ovs-vsctl get Open_vSwitch . other_config"
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
alias ovs-log=' tail -f  /var/log/openvswitch/ovs-vswitchd.log'
alias ovs2-log=' tail -f /var/log/openvswitch/ovsdb-server.log'

alias p23="ping 1.1.1.23"
alias p6="ping6 2017::14"

alias 3.10='cd /usr/src/debug/kernel-3.10.0-327.el7/linux-3.10.0-327.el7.x86_64'
alias restart-network='/etc/init.d/network restart'

alias crash2="$nfs_dir/crash/crash -i /root/.crash //boot/vmlinux-$(uname -r).bz2"

CRASH=/$images/chrism/crash/crash
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


alias jd-ovs="~chrism/bin/ct_lots_rule.sh $rep2 $rep3"
alias jd-vxlan="~chrism/bin/ct_lots_rule_vxlan.sh $rep2 $vx"
alias jd-vxlan2="~chrism/bin/ct_lots_rule_vxlan2.sh $rep2 $vx"
alias jd-ovs2="~chrism/bin/ct_lots_rule2.sh $rep2 $rep3 $rep4"
alias jd-ovs-ttl="~chrism/bin/ct_lots_rule_ttl.sh $rep2 $rep3"
alias ovs-ttl="~chrism/bin/ovs-ttl.sh $rep2 $rep3"

alias pc="picocom -b $base_baud /dev/ttyS1"
alias pcu="picocom -b $base_baud /dev/ttyUSB0"

alias rq='echo g > /proc/sysrq-trigger'

alias sw='vsconfig-sw; restart-ovs'
alias hw='vsconfig-hw; restart-ovs'

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

alias clone-gdb="git clone git://sourceware.org/git/binutils-gdb.git"
alias clone-ethtool='git clone https://git.kernel.org/pub/scm/network/ethtool/ethtool.git'
alias clone-ofed='git clone ssh://gerrit.mtl.com:29418/mlnx_ofed/mlnx-ofa_kernel-4.0.git'
alias clone-asap='git clone ssh://l-gerrit.mtl.labs.mlnx:29418/asap_dev_reg; cp ~/config_chrism_cx5.sh asap_dev_reg'
alias clone-iproute2='git clone http://gerrit:8080/upstream/iproute2'
alias clone-iproute2-upstream='git clone git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git'
alias clone-systemtap='git clone git://sourceware.org/git/systemtap.git'
alias clone-crash-upstream='git clone git@github.com:crash-utility/crash.git'
alias clone-crash='git clone git@github.com:mishuang2017/crash.git'
alias clone-rpmbuild='git clone git@github.com:mishuang2017/rpmbuild.git'
alias clone-ovs='git clone ssh://10.7.0.100:29418/openvswitch'
alias clone-ovs-upstream='git clone git@github.com:openvswitch/ovs.git'
alias clone-linux='git clone ssh://chrism@l-gerrit.lab.mtl.com:29418/upstream/linux'
alias clone-bcc='git clone https://github.com/iovisor/bcc.git'
alias clone-bpftrace='git clone https://github.com/iovisor/bpftrace'
alias clone-drgn='git clone https://github.com/osandov/drgn.git'

alias clone-ubuntu-xenial='git clone git://kernel.ubuntu.com/ubuntu/ubuntu-xential.git'
alias clone-ubuntu='git clone git://kernel.ubuntu.com/ubuntu/ubuntu-bionic.git'
# https://packages.ubuntu.com/source/xenial/linux
# http://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux_4.4.0.orig.tar.gz
# http://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux_4.4.0-145.171.diff.gz

alias git-net='git remote add david git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git'
alias gg='git grep -n'

alias dmesg='dmesg -T'

alias git-log='git log --tags --source'
alias v4.20='git checkout v4.20; git checkout -b 4.20'
alias v5.1='git checkout v5.1; git checkout -b 5.1'
alias v5.2='git checkout v5.2; git checkout -b 5.2'
alias v4.10='git checkout v4.10; git checkout -b 4.10'
alias v4.8='git checkout v4.8; git checkout -b 4.8'
alias v4.8-rc4='git checkout v4.8-rc4; git checkout -b 4.8-rc4'
alias v4.4='git checkout v4.4; git checkout -b 4.4'
alias ab='rej; git am --abort'
alias gr='git add -u; git am --resolved'
alias gar='git add -A; git am --resolved'
alias gs='git status'
alias gc='git commit -a'
alias amend='git commit --amend'
alias slog='git slog'
alias slog1='git slog -1'
alias slog2='git slog -2'
alias slog3='git slog -3'
alias slog4='git slog -4'
alias slog10='git slog -10'
alias git1='git slog v4.11.. drivers/net/ethernet/mellanox/mlx5/core/'
alias gita='git log --tags --source --author="chrism@mellanox.com"'
alias gitvlad='git log --tags --source --author="vladbu@mellanox.com"'
alias gitelib='git log --tags --source --author="elibr@mellanox.com"'
alias git-linux-origin='git remote set-url origin ssh://chrism@l-gerrit.lab.mtl.com:29418/upstream/linux'
alias git-linus='git remote add linus git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git; git fetch --tags linus'
alias git-vlad='git remote add vlad git@github.com:vbuslov/linux.git'
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
alias ti='tcpdump -enn -i'
alias tvf="ip netns exec n0 tcpdump -enn -i $vf1"
alias tvf2="ip netns exec n1 tcpdump -en -i $vf2"
alias trep="tcpdump -en -i $rep1"
alias mount-mswg='sudo mkdir -p /mswg; sudo mount 10.4.0.102:/vol/mswg/mswg /mswg/'
alias mount-swgwork='sudo mkdir -p /swgwork; sudo mount l1:/vol/swgwork /swgwork'

alias tvf1="tcpdump ip src host 1.1.1.14 -e -xxx -i $vf1"
alias tvf2="tcpdump ip src host 1.1.1.14 -e -xxx -i $vf2"
alias tvx="tcpdump ip dst host 1.1.13.2 -e -xxx -i $vx"

alias watch-netstat='watch -d -n 1 netstat -s'
alias w1='watch -d -n 1'
alias w2="watch -d -n 1 cat /sys/class/net/enp4s0f0/device/sriov/pf/counters_tc_ct"
alias w2='watch -d -n 1 cat /proc/buddyinfo'
alias w3='watch -d -n 1 ovs-appctl upcall/show'
alias w4='watch -d -n 1 sar -n DEV 1'
# sar -n TCP 1
# pidstat -t -p 3794
alias ct=conntrack
alias rej='find . -name *rej -exec rm {} \;'
alias f='find . -name'

alias up="mlxlink -d $pci -p 1 -a UP"
alias down="mlxlink -d $pci -p 1 -a DN"
alias m1="mlxlink -d $pci"

alias modv='modprobe --dump-modversions'
alias 154='ssh mishuang@10.12.66.154'
alias ctl=systemctl
# alias dmesg='dmesg -T'
alias dmesg1='dmesg -HwT'

alias 13c='ssh root@10.12.206.25'
alias 14c='ssh root@10.12.206.26'

alias switch='ssh admin@10.12.67.39'

alias r=restart

alias slave='lnst-slave'
alias classic='rpyc_classic.py'	# used to update mac address
alias lv='lnst-ctl -d --pools=dev13_14 run recipes/ovs_offload/03-vlan_in_host.xml'
alias lh='lnst-ctl -d --pools=dev13_14 run recipes/ovs_offload/header_rewrite.xml'
alias iso='cd /mnt/d/software/iso'

alias win='vncviewer 10.12.201.153:0'

# alias uperf="$nfs_dir/uperf-1.0.5/src/uperf"

alias chown1="sudo chown -R chrism.mtl $linux_dir"
alias chown2="sudo chown -R chrism.mtl ."
alias sb='tmux save-buffer'

alias sm="cd /$images/chrism"
alias sm3="cd /$images/chrism/iproute2"
alias sm1="cd $linux_dir"
alias smb2="cd /$images/chrism/bcc/tools"
alias smb="cd /$images/chrism/bcc/examples/tracing"
alias sm7="cd /$images/chrism/rh_debug/BUILD/kernel-3.10.0-1055.el7/linux-3.10.0-1055.el7.x86_64"

if [[ "$USER" == "mi" ]]; then
	kernel=$(uname -r | cut -d. -f 1-6)
	arch=$(uname -m)
fi

function sm7
{
	local dir

	dir=/$images/mi/rpmbuild/BUILD/kernel-3.10.0-327.el7/linux-3.10.0-327.el7.x86_64
	if test -d $dir; then
		cd $dir
	fi
	dir=/$images/mi/rpmbuild/BUILD/kernel-3.10.0-327.el7/linux-3.10.0-327.el7.centos.x86_64
	if test -d $dir; then
		cd $dir
	fi
}
alias sm4="cd /$images/mi/rpmbuild/BUILD/kernel-3.10.0-693.21.1.el7/linux-3.10.0-693.21.1.el7.x86_64"
alias cf4='sm4; cscope -d'
alias sm5="cd /$images/mi/rpmbuild/BUILD/kernel-3.10.0-862.11.6.el7/linux-3.10.0-862.11.6.el7.x86_64"
alias cf5='sm5; cscope -d'

alias spec="cd /$images/mi/rpmbuild/SPECS"
alias sml="cd /$images/chrism/linux"
alias smu="cd /$images/chrism/upstream"
alias sm9="cd /$images/chrism/linux-4.9"
alias smy="cd /images/chrism/yossi"
alias sm14="cd /images/chrism/linux-4.14.78"
alias smm="cd /images/chrism/mlnx-ofa_kernel-4.0"
alias smm2="cd /images/chrism/mlnx-ofa_kernel-4.0-2"
alias cd-test="cd $linux_dir/tools/testing/selftests/tc-testing/"
alias vi-action="vi $linux_dir/tools/testing/selftests/tc-testing/tc-tests/actions//tests.json"
alias vi-filter="vi $linux_dir/tools/testing/selftests/tc-testing/tc-tests/filters//tests.json"
alias smo="cd /$images/chrism/openvswitch"
alias smo2="cd /$images/chrism/ovs-ct-2.10"
alias smt="cd /$images/chrism/ovs-tests"
alias cfo="cd /$images/chrism/openvswitch; cscope -d"
alias ipa='ip a'
alias ipl='ip l'
alias ipal='ip a l'
alias smd='cd /usr/src/debug/kernel-3.10.0-327.el7/linux-3.10.0-327.el7.x86_64'
alias rmswp='find . -name *.swp -exec rm {} \;'
alias rmswp1='find . -name *.swp -exec rm {} \;'
alias cd-drgn='cd /usr/local/lib64/python3.6/site-packages/drgn-0.0.1-py3.6-linux-x86_64.egg/drgn/helpers/linux/'
alias smdr="cd /$images/chrism/drgn/"

alias mount-fedora="mount /dev/mapper/fedora-root /mnt"
alias cfl="cd /$images/chrism/linux; cscope -d"

alias sm2="cd $nfs_dir"
alias smc="sm; cd crash; vi net.c"
alias smi='cd /var/lib/libvirt/images'
alias smi2='cd /etc/libvirt/qemu'

alias smn='cd /etc/sysconfig/network-scripts/'
alias mr='modprobe -r'

alias vs='sudo ovs-vsctl'
alias of='sudo ovs-ofctl'
alias dp='sudo ovs-dpctl'
alias dpd='sudo ovs-dpctl dump-flows --name'
alias app='sudo ovs-appctl'
alias app1='sudo ovs-appctl dpctl/dump-flows'
alias appn='sudo ovs-appctl dpctl/dump-flows --names'

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

alias suc='[[ $UID == 0 ]] && su - chrism'
alias s=suc
# [[ "$USER" == "chrism" ]] && alias s='sudo su -'
alias s2='su - mi'
alias s0='[[ $UID == 0 ]] && su chrism'
alias e=exit
alias 160='ssh root@10.200.0.160'
alias ka=killall
alias vnc2='ssh chrism@10.7.2.14'
alias vnc='ssh chrism@10.12.68.111'
alias netstat1='netstat -ntlp'

alias f7="ssh root@l-csi-0937h.mtl.labs.mlnx"
alias f8="ssh root@l-csi-0938h.mtl.labs.mlnx"

alias 13='ssh root@10.12.205.13'
alias 14='ssh root@10.12.205.14'

alias 15='ssh root@10.12.205.15'
alias vm1=15
alias 16='ssh root@10.12.205.16'
alias vm2=16
alias 17='ssh root@10.12.205.17'
alias vm3=17
alias 18='ssh root@10.12.205.18'
alias vm4=18
alias 9='ssh root@10.12.205.9'
alias vm5=9
alias 8='ssh root@10.12.205.8'
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
alias virc='vi ~/.bashrc'
alias virca='vi ~/.bashrc*'
alias visc='vi ~/.screenrc'
alias vv='vi ~/.vimrc'
alias rc='. ~/.bashrc'
alias vis='vi ~/.ssh/known_hosts'
alias vin='vi ~/sm/notes.txt'
alias vij='vi ~/Documents/jd.txt'
alias vi1='vi ~/Documents/ovs.txt'
alias vi2='vi ~/Documents/mirror.txt'
alias vib='vi ~/Documents/bug.txt'
alias vip='vi ~/Documents/private.txt'
alias vig='sudo vim /boot/grub2/grub.cfg'
alias vig1='sudo vim /boot/grub/grub.conf'
alias vig2='sudo vim /etc/default/grub'
alias viu="vi $nfs_dir/uperf-1.0.5/workloads/netperf.xml"
alias vit='vi ~/.tmux.conf'
alias vic='vi ~/.crash'
alias viu='vi /etc/udev/rules.d/82-net-setup-link.rules'
alias vigdb='vi ~/.gdbinit'

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

# password is windows password
alias mount-setup='mkdir -p /mnt/setup; mount  -o username=chrism //10.200.0.25/Setup /mnt/setup'


alias qlog='less /var/log/libvirt/qemu/vm1.log'
# alias vd='virsh dumpxml vm1'
alias simx='/opt/simx/bin/manage_vm_simx_support.py -n vm2'

alias vfs="mlxconfig -d $pci set SRIOV_EN=1 NUM_OF_VFS=127"
alias vfs="mlxconfig -d $pci set SRIOV_EN=1 NUM_OF_VFS=16"
alias vfq="mlxconfig -d $pci q"
alias vfq2="mlxconfig -d $pci2 q"
alias vfsm="mlxconfig -d $linik_bdf set NUM_VF_MSIX=6"

alias tune1="ethtool -C $link adaptive-rx off rx-usecs 64 rx-frames 128 tx-usecs 64 tx-frames 32"
alias tune2="ethtool -C $link adaptive-rx on"
alias tune3="ethtool -c $link"

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

alias eon=ethtool-rxvlan-on

alias ethtool2=/images/chrism/ethtool/ethtool

# alias a=ovs-arp-responder.sh

alias restart-virt='systemctl restart libvirtd.service'

export PATH=$PATH:~/bin
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

alias r8='brb; restart-ovs; sudo ~chrism/bin/test_router8.sh'	# ct + snat with br-int and br-ex
alias r7='sudo ~chrism/bin/test_router7.sh'	# ct + snat with more recircs
alias r6='sudo ~chrism/bin/test_router6.sh'	# ct + snat with Yossi's script for VF
alias r5='sudo ~chrism/bin/test_router5.sh'	# ct + snat with Yossi's script for PF
alias r4='sudo ~chrism/bin/test_router4.sh'	# ct + snat, can't offload
alias r3='sudo ~chrism/bin/test_router3.sh'	# ct + snat, can't offload
alias r2='sudo ~chrism/bin/test_router2.sh'	# snat, can offload
alias r1='sudo ~chrism/bin/test_router.sh'	# veth arp responder

corrupt_dir=corrupt_lat_linux
alias cd-corrupt="cd /labhome/chrism/prg/c/corrupt/$corrupt_dir"
alias corrupt="/labhome/chrism/prg/c/corrupt/$corrupt_dir/corrupt"

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
}

function ip2
{
	local l=$link2
	ip addr flush $l
	ip addr add dev $l $link2_ip/24
	ip addr add $link2_ipv6/64 dev $l
	ip link set $l up
}

trap cleanup EXIT
function cleanup
{
set +x
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

alias cu='time cscope -R -b -k'

function greps
{
	[[ $# != 1 ]] && return
	sm1
#	grep include -Rn -e "struct $1 {" | sed 's/:/\t/'
	grep include -Rn -e "struct $1 {"
}

function profile
{
	local host=$1
	who=mi
	[[ $# != 1 ]] && return
	sshcopy who@host
	scp ~/.bashrc $who@$host:~/bashrc
	scp ~/.profile $who@$host:~
	scp ~/.vimrc $who@$host:~
	scp -r ~/.vim $who@$host:~
	scp ~/.screenrc $who@$host:~
	scp ~/.tmux.conf $who@$host:~
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

	mkdir -p /images/chrism
	chown chrism.mtl /images/chrism
}

function unprofile
{
	cd /root
	unlink ~/.bashrc
	mv bashrc.orig .bashrc
}

function rc2
{
	unlink ~/.bashrc
	mv ~/bashrc.orig ~/.bashrc
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
mac_prefix="02:25:d0:e2:18"
function set-mac2
{
	[[ $# != 1 ]] && return

	local vf=$1
	local mac_vf=$((vf+5))
	ip link set $link vf $vf mac $mac_prefix:$mac_vf
}

alias on-sriov1="echo $numvfs > /sys/devices/pci0000:00/0000:00:02.0/0000:04:00.0/sriov_numvfs"
alias on-sriov2="echo $numvfs > /sys/devices/pci0000:00/0000:00:02.0/0000:04:00.1/sriov_numvfs"
alias on-sriov="echo $numvfs > /sys/class/net/$link/device/sriov_numvfs"
alias on1='on-sriov; set-mac 1; un; ip link set $link vf 0 spoofchk on'
alias un2="unbind_all $link2"
alias off_sriov="echo 0 > /sys/devices/pci0000:00/0000:00:02.0/0000:04:00.0/sriov_numvfs"

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
alias bi='bind_all $link'

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

function off_all
{
	local l
#	for l in $link; do
	for l in $link $link2 eth0; do
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

alias ofd="ovs-ofctl dump-flows $br"
alias ofdi="ovs-ofctl dump-flows br-int"
alias ofd2="ovs-ofctl dump-flows br2" 

alias drop3="ovs-ofctl add-flow $br 'nw_dst=1.1.3.2 action=drop'"
alias del3="ovs-ofctl del-flows $br 'nw_dst=1.1.3.2'"

alias drop1="ovs-ofctl add-flow $br 'nw_src=192.168.1.1 action=drop'"
alias normal1="ovs-ofctl add-flow $br 'nw_src=192.168.1.1 action=normal'"

alias drop2="ovs-ofctl add-flow $br 'nw_src=192.168.1.2 action=drop'"
alias normal2="ovs-ofctl add-flow $br 'nw_src=192.168.1.3 action=normal'"

mac1=02:25:d0:14:01:04
alias dropm="ovs-ofctl add-flow $br 'dl_dst=02:25:d0:14:01:04  action=drop'"
# alias delm="ovs-ofctl add-flow $br 'dl_dst=02:25:d0:14:01:04	action=drop'"
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
stap_str_common="--all-modules -d /usr/sbin/ovs-vswitchd -d /usr/sbin/tc -d /usr/bin/ping -d /usr/sbin/ip"
if (( ofed == 1 || kernel49 == 1 )); then
	stap_str="$stap_str_common -d /usr/lib64/libc-2.17.so -d /usr/lib64/libpthread-2.17.so"
	STAP="/usr/local/bin/stap -v"
else
	stap_str="$stap_str_common -d /usr/lib64/libc-2.26.so -d /usr/lib64/libpthread-2.26.so"
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

function buildm
{
	module=mlx5_core;
	driver_dir=drivers/net/ethernet/mellanox/mlx5/core
	make M=$driver_dir -j 32
}

function mybuild
{
set -x; 
	(( $UID == 0 )) && return
	module=mlx5_core;
	driver_dir=drivers/net/ethernet/mellanox/mlx5/core
	cd $linux_dir;
	make M=$driver_dir -j 32 || {
		set +x
		return
	}
	src_dir=$linux_dir/$driver_dir
	sudo /bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/$driver_dir
#	make modules_install -j 32

	sudo modprobe -r mlx5_ib
	sudo modprobe -r mlx5_core
	sudo modprobe -v mlx5_core

#	cd $src_dir;
#	make CONFIG_MLX5_CORE=m -C $linux_dir M=$src_dir modules -j 32;
#	/bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/drivers/net/ethernet/mellanox/mlx5/core
#	sudo rmmod mlx5_ib
#	sudo rmmod $module;
#	sudo modprobe mlx5_ib
#	sudo modprobe $module;
set +x
}

function mybuild_ib
{
set -x; 
	(( $UID == 0 )) && return
	module=mlx5_ib;
	driver_dir=drivers/infiniband/hw/mlx5
	cd $linux_dir;
	make M=$driver_dir -j 32 || {
		set +x
		return
	}
	src_dir=$linux_dir/$driver_dir
	sudo /bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/$driver_dir
#	make modules_install -j 32

	sudo modprobe -r mlx5_ib
	sudo modprobe -r mlx5_core
	sudo modprobe -v mlx5_core

#	cd $src_dir;
#	make CONFIG_MLX5_CORE=m -C $linux_dir M=$src_dir modules -j 32;
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
	alias b=mybuild_old
	alias b=mybuild
else
	alias b=mybuild
fi

build-mlx5-ib () 
{
set -x; 
	module=mlx5_ib;
	driver_dir=drivers/infiniband/hw/mlx5
	cd $linux_dir;
	make M=$driver_dir -j 32 || return
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
	make M=$driver_dir -j 32 || return
	src_dir=$linux_dir/$driver_dir
	sudo /bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/$driver_dir

	sudo modprobe -r $1
	sudo modprobe -v $1

}

alias bo=mybuild2
mybuild2 ()
{
set -x;
	sudo ovs-vsctl del-br $br
	module=openvswitch
	driver_dir=net/openvswitch
	cd $linux_dir;
	make M=$driver_dir -j 32 || return
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
	make M=$driver_dir -j 32 || return
	src_dir=$linux_dir/$driver_dir
	sudo /bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/$driver_dir

	sudo modprobe -r $1
	sudo modprobe -v $1

set +x
}
alias b4=mybuild4

alias bnetfilter='b4 nft_gen_flow_offload'

# modprobe -rv cls_flower act_mirred
# modprobe -av cls_flower act_mirred

# modprobe -v cls_flower tuple_offload=0
function reprobe
{
#	sudo /etc/init.d/openibd stop
	sudo modprobe -r cls_flower
	sudo modprobe -r mlx5_fpga_tools
	sudo modprobe -r mlx5_ib
	sudo modprobe -r mlx5_core
	sudo modprobe -v mlx5_core
#	sudo modprobe -v mlx5_ib

#	/etc/init.d/network restart
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
function install-ovs
{
set -x
	./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc
#	./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc --with-dpdk=$DPDK_BUILD
	make -j 32
	sudo make install -j 32
set +x
}

function io
{
set -x
	make -j 32
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
	sudo systemctl stop openvswitch.service
}

function gita
{
	git log --no-merges --author="torvalds@linux-foundation.org" --name-only --pretty=format:""
}

function fetch-net
{
set -x
	[[ $# != 1 ]] && return
	git fetch origin net-next-mlx5
	git checkout FETCH_HEAD
	git checkout -b $1
set +x
}

function tct
{
	tc-setup $rep2
	tc filter add dev $rep2 protocol ip parent ffff: prio 1 \
		flower skip_sw ip_proto tcp \
		action pedit ex \
		munge ip ttl set 0xee \
		pipe action mirred egress redirect dev $rep3
}

function u0
{
	if [[ $# == 0 ]]; then
		echo "Please specify remote ip"
		return
	fi
	if [[ $# == 1 ]]; then
		export h=$1
	fi

	export s=64k
	export n=1
	export proto=tcp
	export t=120
	uperf -m $nfs_dir/uperf-1.0.5/workloads/netperf.xml
}

alias u3='u0 1.1.1.3'
alias u5='u2 1.1.1.5'


function u1
{
set -x
	if [[ $# == 0 ]]; then
		export h=$link_remote_ip
		export n=1
	fi
	if (( $# >=  1 )); then
		export h=$1
		export n=1
	fi
	if (( $# >= 2 )); then
		export h=$1
		export n=$2
	fi

	echo $h
	echo $s

	export n=1
	export s=64k
	export proto=tcp
	export t=120000000
	uperf -m $nfs_dir/uperf-1.0.5/workloads/netperf.xml
set +x
}

alias u4="u1 $link_remote_ip"

function u2
{
set -x
	if [[ $# == 0 ]]; then
		export h=192.168.1.14
		export s=8k
	fi
	if (( $# >=  1 )); then
		export h=$1
		export s=8k
	fi
	if (( $# >= 2 )); then
		export h=$1
		export s=$2
	fi

	export n=16
	export s=64k
	export proto=tcp
	export t=1200000
	ip netns exec n1 uperf -m $nfs_dir/uperf-1.0.5/workloads/netperf.xml
set +x
}

alias u11='u2 1.1.1.11'
alias u6='u2 1.1.1.6'
alias u4='u2 1.1.1.4'
alias u3='u2 1.1.1.3'

alias perf1='perf stat -e cycles:k,instructions:k -B --cpu=0-15 sleep 2'

function tc-htb1
{
	tc qdisc add dev p2p1 root handle 1: htb default 20
	tc qdisc show dev p2p1

	tc class add dev p2p1 parent 1:0 classid 1:10 htb rate 200kbit ceil 200kbit prio 1 mtu 1500
	tc class add dev p2p1 parent 1:0 classid 1:20 htb rate 824kbit ceil 1024kbit prio 2 mtu 1500
	tc class show dev p2p1
}

function tc-htb2
{
	tc class delete dev p2p1 parent 1:0 classid 1:10 htb rate 200kbit ceil 200kbit prio 1 mtu 1500
	tc class delete dev p2p1 parent 1:0 classid 1:20 htb rate 824kbit ceil 1024kbit prio 2 mtu 1500
	tc class show dev p2p1

	tc qdisc delete dev p2p1 root handle 1: htb default 20
	tc qdisc show dev p2p1
}

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
OBJS = $p.o
FILE = $p.c

all: \$(EXEC)
	\$(CC) \$(FILE) -fsanitize=address -o \$(EXEC)
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

function make-all
{
	[[ $UID == 0 ]] && break

	local cpu_num=$(cat /proc/cpuinfo  | grep processor | wc -l)
	cpu_num=$((cpu_num*2))
	unset CONFIG_LOCALVERSION_AUTO
	make olddefconfig
	make -j $cpu_num
#	sudo make headers_install
	sudo make modules_install -j $cpu_num
	sudo make install

	/bin/rm -rf ~/.ccache
}
alias m=make-all
alias m-reboot='make-all; reboot1'
alias mm='sudo make modules_install -j32; sudo make install'
alias mi='make -j 32; sudo make install -j 32'
alias m32='make -j 32'

function mi2
{
set -x
	sudo echo 0 > /sys/class/net/$link/device/sriov_numvfs;
	make -j 32; sudo make install -j 32;
	/bin/rm -rf ./drivers/infiniband/hw/mlx5/mlx5_ib.ko;
	sudo /bin/rm -rf /lib/modules/3.10.0-957.el7.x86_64/extra/mlnx-ofa_kernel/drivers/infiniband/hw/mlx5/mlx5_ib.ko
	force-restart
set +x
}

alias make-local='./configure; make -j 32; sudo make install'
alias ml=make-local
alias make-usr='./configure --prefix=/usr; make -j 32; sudo make install'
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
	for l in $link $rep1 $rep2 $rep3; do
		ip link show $l > /dev/null 2>&1 || continue
		tc qdisc show dev $l ingress | grep ffff > /dev/null 2>&1
		if (( $? == 0 )); then
			sudo /bin/time -f %e tc qdisc del dev $l ingress
			echo $l
		fi
	done

	for l in $link2 $rep1_2 $rep2_2 $rep3_2; do
		ip link show $l > /dev/null 2>&1 || continue
		tc qdisc show dev $l ingress | grep ffff > /dev/null 2>&1
		if (( $? == 0 )); then
			sudo /bin/time -f %e tc qdisc del dev $l ingress
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

function tc-pf
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
#	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $link
#	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $link
#	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $link
	$TC filter add dev $rep2 prio 1 protocol ip  chain 100 parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $link
	$TC filter add dev $rep2 prio 2 protocol arp chain 100 parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $link
	$TC filter add dev $rep2 prio 2 protocol arp chain 100 parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $link
	src_mac=$remote_mac
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $link prio 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $link prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $link prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
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
	[[ $# != 1 ]] && return
	TC=/images/chrism/iproute2/tc/tc
	TC=tc
	local link=$1
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

function tc-vf-chain
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

	tc filter add dev $rep2 prio 1 protocol ip parent ffff: chain 0 flower ct_state -trk		action ct    action goto chain 1
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
function vlan2
{
set -x
	redirect=$rep2
	mirror=$rep1
	TC=tc

	offload=""
	src_mac=02:25:d0:$host_num:01:02	# local vm mac
	dst_mac=$remote_mac			# remote vm mac
	$TC filter change dev $redirect protocol ip prio 1 handle 1 parent ffff: flower $offload src_mac $src_mac	dst_mac $dst_mac \
		action mirred egress mirror dev $mirror	\
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

function tc-vxlan
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
		action mirred egress redirect dev $redirect
	$TC filter add dev $vx protocol arp parent ffff: prio 2 flower skip_hw	\
		src_mac $remote_vm_mac \
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect


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
function tc-vxlan64
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
	echo "${link}_$1"
}

function get_rep2
{
	[[ $# != 1 ]] && return
	echo "${link2}_$1"
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

function bru
{
set -x
	del-br
	vs add-br $br
	vs add-port $br $link -- set Interface $link ofport_request=5
# 	for (( i = 0; i < numvfs; i++)); do
	for (( i = 1; i < 2; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
set +x
}

function br
{
set -x
	del-br
	vs add-br $br
	for (( i = 0; i < numvfs; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
set +x
}

function br0
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

function brb
{
set -x
	int=br-int
	ex=br-ex
	del-br
	ovs-vsctl add-br $int
	ovs-vsctl add-br $ex

	ifconfig $int up
	ifconfig $ex 100.64.0.1/24 up
	ifconfig $link 8.9.10.13/24 up
	ssh 10.12.205.14 ifconfig $link 8.9.10.11/24 up

	ovs-vsctl add-port $int $rep2
# 	ovs-vsctl add-port $int $link

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
	for (( i = 1; i <= 1; i++)); do
		local rep=$(get_rep $i)
		vs add-port $br $rep -- set Interface $rep ofport_request=$((i+1))
	done
	vxlan1
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

alias br2='create-br-ecmp normal'
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
	ovs-vsctl list-br | xargs -r -l ovs-vsctl del-br
	sleep 1
	return
	ip l d $vx_rep
	ip l d dummy0 > /dev/null 2>&1
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
	ip netns exec $n ifconfig $link mtu 1450
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
	if (( host_num == 13 )); then
		ns_ip=1.1.$p
	elif (( host_num == 14 )); then
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
		rep=${l}_$i
		ifconfig $rep up
		echo "up $rep"
		if (( ecmp == 1 )); then
			ovs-vsctl add-port br-vxlan $rep
		fi
	done
	echo "end up_all_reps"
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
		rep=${l}_$i
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

function set-mac
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

alias leg='start-switchdev legacy'
alias start='start-switchdev vm'
alias start='start-switchdev-all'
alias start-vm='start-switchdev 1 vm'
alias start-vf='start-switchdev vf'
alias start-bind='start-switchdev bind'
alias restart='off; start'
# alias r1='off; tc2; reprobe; modprobe -r cls_flower; start'
alias mystart=start-switchdev-all
function start-switchdev
{
	local port=$1
	local mode=switchdev
	if (( numvfs > 99 )); then
		echo "numvfs = $numvfs, return to confirm"
		read
	fi
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

	time echo $numvfs > /sys/class/net/$l/device/sriov_numvfs

	set-mac $port

	time unbind_all $l

	echo "enable switchdev mode for: $pci_addr"
	if (( centos72 == 1 )); then
		sysfs_dir=/sys/class/net/$link/compat/devlink
		echo switchdev >  $sysfs_dir/mode || echo "switchdev failed"
		if (( cx5 == 0 )); then
			echo transport > $sysfs_dir/inline 2>/dev/null|| echo "transport failed"
		fi
#		echo basic > $sysfs_dir/encap || echo "baisc failed"
	else
		devlink dev eswitch set pci/$pci_addr mode switchdev
		if (( cx5 == 0 )); then
			devlink dev eswitch set pci/$pci_addr inline-mode transport
		fi
#		devlink dev eswitch set pci/$pci_addr encap enable
	fi

#	local time=0
#	while ! ip link show $link > /dev/null; do
#		sleep 1
#		(( time ++ ))
#		(( time > 10 )) && return
#	done
	sleep 1
	time bind_all $l
	sleep 1

	ip1

	sleep 1
	time up_all_reps $port
	hw_tc_all $port

	time set_netns_all $port

#	iptables -F
#	iptables -Z
#	iptables -X

	return
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

function echo_legacy2
{
	local sysfs_dir=/sys/class/net/$link2/compat/devlink
	echo legacy >  $sysfs_dir/mode
	echo $?
}

function start-switchdev-all
{
#	enable-multipath
#	ifconfig $link2 up

	start-ovs
	for i in $(seq $ports); do
		start-switchdev $i
	done
	ip1
	ip2
#	ethtool -K $link hw-tc-offload on > /dev/null 2>&1
	
#	(( host_num == 13 )) && jd-vxlan2
#	(( host_num == 14 )) && jd-vxlan
#	jd-vxlan
#	jd-ovs

#	create-br-all

#	ifconfig $(get_vf $host_num 1 1) up
#	ifconfig $rep1 up

#	if (( ports == 2 )); then
#		ifconfig $(get_vf $host_num 2 1) up
#		ifconfig $rep1_2 up
#	fi

#	brx
#	add-reps
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

	if (( host_num == 14)); then
		sudo echo "GRUB_CMDLINE_LINUX=\"intel_iommu=on biosdevname=0 pci=realloc crashkernel=256M\"" >> $file
	fi
# 	sudo echo "GRUB_CMDLINE_LINUX=\"intel_iommu=on biosdevname=0 pci=realloc crashkernel=256M console=tty0 console=ttyS1,$base_baud kgdbwait kgdboc=ttyS1,$base_baud\"" >> $file
	if (( host_num == 13)); then
		sudo echo "GRUB_CMDLINE_LINUX=\"intel_iommu=on biosdevname=0 pci=realloc crashkernel=256M console=tty0 console=ttyS1,$base_baud kgdboc=ttyS1,$base_baud nokaslr\"" >> $file
	fi

	sudo echo "GRUB_TERMINAL_OUTPUT=\"console\"" >> $file
# 	sudo echo "GRUB_TERMINAL_OUTPUT=\"serial\"" >> $file
# 	sudo echo "GRUB_SERIAL_COMMAND=\"serial --speed=$base_baud --unit=1 --word=8 --parity=no --stop=1\"" >> $file

	if [[ $# == 0 ]]; then
		sudo echo "GRUB_DEFAULT=saved" >> $file
		sudo echo "GRUB_SAVEDEFAULT=true" >> $file
	else
		sudo echo "GRUB_DEFAULT=$kernel" >> $file
	fi

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
(( "$UID" == 0 )) && PS1="\e[0;31m[\u@\h \W]# \e[0m"	  # set background=light
(( "$UID" == 0 )) && PS1="\e[1;31m[\u@\h \W]# \e[0m"	  # set background=dark
(( "$UID" != 0 )) && PS1="[\u@\h \W]\$ "
(( "$UID" != 0 )) && PS1="\033[0;33m[\u@\h \W]$ \033[0m"
(( "$UID" != 0 )) && PS1="\033[1;33m[\u@\h \W]$ \033[0m"

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
		$cmd new -d -n linux -s $session
		$cmd neww -n build
		$cmd neww -n list
		$cmd neww -n patch
		$cmd neww -n 4.19
		$cmd neww -n live
		$cmd neww -n stm
		$cmd neww -n bash
		$cmd neww -n bash	# 8
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

alias noodle=/auto/mtbcswgwork/chrism/noodle/noodle
alias noodle1='noodle -c 1.1.14.1 -p 9999 -C 10000 -n 100 -l 3000  -b 10 -r 10'
# noodle -p 1500 -l 2000 -C 40000 -n 5000  -r 8 -b 1
alias noodle1='noodle -c 1.1.14.1 -p 1500 -C 40000 -n 5000 -l 2000  -b 1 -r 8'

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
	$GDB $(which $bin) $(pgrep $bin)
}

alias g='gdb1 ovs-vswitchd'

# ovs-vsctl set Open_vSwitch . other_config:n-revalidator-threads=5
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

function none1
{
	ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"
	ovs-vsctl set Open_vSwitch . other_config:tc-policy=none
	ovs-vsctl set Open_vSwitch . other_config:max-idle=30000
#	ovs-vsctl set Open_vSwitch . other_config:max-revalidator=5000
#	ovs-vsctl set Open_vSwitch . other_config:min_revalidate_pps=1
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
function ovs-thread
{
	ovs-vsctl set Open_vSwitch . other_config:n-revalidator-threads=1
	ovs-vsctl set Open_vSwitch . other_config:n-handler-threads=1
}

function none
{
	ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"
	ovs-vsctl set Open_vSwitch . other_config:tc-policy=none
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
	ovs-vsctl remove Open_vSwitch . other_config hw-offload
	ovs-vsctl remove Open_vSwitch . other_config tc-policy
	ovs-vsctl remove Open_vSwitch . other_config max-idle
	ovs-vsctl remove Open_vSwitch . other_config max-revalidator
	ovs-vsctl remove Open_vSwitch . other_config min_revalidate_pps
	ovs-vsctl remove Open_vSwitch . other_config vlan-limit
	ovs-vsctl remove Open_vSwitch . other_config n-revalidator-threads
	ovs-vsctl remove Open_vSwitch . other_config n-handler-threads
	ovs-vsctl remove Open_vSwitch . other_config flow-limit
	restart-ovs
	vsconfig
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
	if echo $ver | grep ^16; then
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

# mlxfwup

function burn5
{
set -x
	pci=0000:04:00.0
	version=last_revision
	version=fw-4119-rel-16_25_1000
	version=fw-4119-rel-16_99_6804
	version=fw-4119-rel-16_25_0328

	mkdir -p /mswg/
	sudo mount 10.4.0.102:/vol/mswg/mswg /mswg/
	yes | sudo mlxburn -d $pci -fw /mswg/release/fw-4119/$version/fw-ConnectX5.mlx -conf_dir /mswg/release/fw-4119/$version

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

function git-patch
{
	[[ $# > 2 ]] && return
	local n=$2
	[[ $# == 1 ]] && n=1
	local dir=$1
	mkdir -p $dir
	git format-patch -o $dir -$n HEAD
}

function git-patch2
{
	[[ $# > 2 ]] && return
	local commit=$2
	[[ $# == 1 ]] && n=1
	local dir=$1
	mkdir -p $dir
#	git format-patch -o $dir c00f5a7..
	git format-patch -o $dir ${commit}..
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
	sm1
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

patch_dir2=~/batch/review11
patch_dir=~/ovs/2.9
alias smp="cd $patch_dir"
alias smp2="cd $patch_dir2"

# Jamal Hadi Salim <jhs@mojatatu.com>
# Lucas Bates <lucasb@mojatatu.com>

function git-format-patch
{
	[[ $# != 1 ]] && return
#	git format-patch --cover-letter --subject-prefix="INTERNAL RFC net-next v9" -o $patch_dir -$1
#	git format-patch --cover-letter --subject-prefix="patch net-next" -o $patch_dir -$1
#	git format-patch --cover-letter --subject-prefix="patch net-next internal v11" -o $patch_dir -$1
#	git format-patch --cover-letter --subject-prefix="patch net internal" -o $patch_dir -$1
#	git format-patch --cover-letter --subject-prefix="patch iproute2 v10" -o $patch_dir -$1
#	git format-patch --cover-letter --subject-prefix="ovs-dev" -o $patch_dir -$1
	git format-patch --subject-prefix="branch-2.8/2.9 backport" -o $patch_dir -$1
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
	echo "git send-email $patch_dir/* --to=netdev@vger.kernel.org \\" >> $script

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

# if outer header is ipv6
function peer6
{
set -x
	ip1
	ip link del $vx > /dev/null 2>&1
	ip link add name $vx type vxlan id $vni dev $link remote $link_remote_ipv6 dstport 4789 \
		udp6zerocsumtx udp6zerocsumrx
#	ifconfig $vx $link_ip_vxlan/24 up
	ip addr add $link_ip_vxlan/24 brd + dev $vx
	ip link set dev $vx up
#	ip link set dev $vx mtu 1000
	ip link set $vx address $vxlan_mac
	ip addr add $link_ipv6_vxlan/64 dev $vx

#	ip link set vxlan0 up
#	ip addr add 1.1.1.2/16 dev vxlan0
#	ip addr add fc00:0:0:0::2/64 dev vxlan0
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
	sm1
	cd ./samples/pktgen
	./pktgen_sample01_simple.sh -i $link -s 1 -m 02:25:d0:$rhost_num:01:02 -d 1.1.1.22 -t 1 -n 0
}

function pktgen1
{
	mac_count=1
	[[ $# == 1 ]] && mac_count=$1
	sm1
	cd ./samples/pktgen
	export SRC_MAC_COUNT=$mac_count
	./pktgen_sample02_multiqueue.sh -i $link -s 1 -m 02:25:d0:$rhost_num:01:02 -d 1.1.1.22 -t 16 -n 0
}

function pktgen2
{
	sm1
	cd ./samples/pktgen
	./pktgen_sample02_multiqueue2.sh -i $link -s 1 -m 02:25:d0:e2:14:01 -d 1.1.1.2 -t 1 -n 0
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

function restart-net
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
	sleep 1
	sync
	sleep 1
	sync
	sleep 1
	cmdline=$(cat /proc/cmdline | cut -d " " -f 2-)
set -x
	sudo kexec -l /boot/vmlinuz-$uname --append="BOOT_IMAGE=/vmlinuz-$uname $cmdline" --initrd=/boot/initramfs-$uname.img
set +x
	sudo kexec -e
}

alias reboot3='reboot1 3.10.0+'

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

alias udevadm1="udevadm info -a --path=/sys/class/net/$link"
alias udevadm2="udevadm info -a --path=/sys/class/net/$link2"

alias udevadm_1="udevadm info -a --path=/sys/class/net/$rep2"

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

function udev3
{
	cd /etc/udev/rules.d
	cp ~chrism/udev3/82-net-setup-link.rules .
	cd ..
	cp ~chrism/udev3/vf-net-link-name.sh .
}

function udev
{
	cd /etc/udev/rules.d
	cp ~chrism/udev2/82-net-setup-link.rules .
	cd ..
	cp ~chrism/udev2/vf-net-link-name.sh .
}

function udev2
{
	/bin/rm -rf /etc/udev/rules.d/82-net-setup-link.rules
	/bin/rm -rf /etc/udev/vf-net-link-name.sh
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

function q1
{
set -x
	modprobe vfio
	modprobe vfio-pci
	echo 15b3 101a >/sys/bus/pci/drivers/vfio-pci/new_id
	ls /dev/vfio

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
	ofed-unload
	sudo /etc/init.d/openibd force-stop
set +x
}

function force-start
{
set -x
	ofed-unload
	sudo /etc/init.d/openibd force-start
# 	sudo systemctl restart systemd-udevd.service
set +x
}

function force-restart
{
set -x
	ofed-unload
	sudo /etc/init.d/openibd force-stop
	sudo /etc/init.d/openibd force-start
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

alias ofed-configure='./configure --with-mlx5-core-and-ib-and-en-mod -j 32'
alias ofed-configure1='./configure --with-mlx5-core-and-en-mod -j 32'

alias ofed-configure2='./configure --with-core-mod --with-mlx5-mod --with-mlxfw-mod -j 32'

alias ofed-configure3='./configure --with-mlx5-core-and-en-mod --with-core-mod --with-ipoib-mod --with-mlx5-mod -j 32'
alias ofed-configure-memtrack='./configure --with-mlx5-core-and-en-mod --with-memtrack -j 32'
alias ofed-configure-all2='./configure --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlxfw-mod --with-mlx4-mod --with-mlx4_en-mod --with-mlx5-mod --with-ipoib-mod --with-innova-flex --with-e_ipoib-mod -j32'

# centos 7.4
alias ofed-configure='./configure --with-mlx5-core-and-ib-and-en-mod -j 32'
# Redhat 7.5
alias ofed-configure5="./configure -j32 --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlxfw-mod --with-ipoib-mod --with-mlx5-mod"

alias ofed-configure-all='./configure -j32  --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlxfw-mod --with-mlx4-mod --with-mlx4_en-mod --with-mlx5-mod --with-ipoib-mod --with-srp-mod --with-iser-mod --with-isert-mod'

alias ofed-configure='./configure --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlxfw-mod --with-mlx5-mod --with-ipoib-mod --with-innova-flex --with-e_ipoib-mod -j32'

# alias ofed-configure2="./configure -j32 --with-linux=/mswg2/work/kernel.org/x86_64/linux-4.7-rc7 --kernel-version=4.7-rc7 --kernel-sources=/mswg2/work/kernel.org/x86_64/linux-4.7-rc7 --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlxfw-mod --with-ipoib-mod --with-mlx5-mod"

# ./configure --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlx5-mod --with-mlx4-mod --with-mlx4_en-mod --with-ipoib-mod --with-mlxfw-mod --with-srp-mod --with-iser-mod --with-isert-mod --with-innova-flex --kernel-sources=/images/kernel_headers/x86_64//linux-4.7-rc7 --kernel-version=4.7-rc7 -j 8

function fetch
{
	if [[ $# == 1 ]]; then
		repo=origin
		local branch=$1
	elif [[ $# == 2 ]]; then
		local repo=$1
		local branch=$2
	else
		return
	fi

	git fetch $repo $branch
	git checkout FETCH_HEAD
	git checkout -b $branch
}

alias git-lx='git apply  ~/sm/kgdb/lx-symbole.patch'

function fetch-13
{
	[[ $# == 0 ]] && return
	git branch -D 13
	git fetch 13 $1
	git checkout FETCH_HEAD
	git checkout -b 13
}

function tcs
{
	[[ $# != 1 ]] && return
	TC=/images/chrism/iproute2/tc/tc
	TC=tc
	$TC -s filter show dev $1 root
}

alias vlan-test="while true; do  tc-vlan; rep2; tcs $link; sleep 5; tcv; rep2; tcs $link;  sleep 5; done"
alias vlan-iperf=" iperf3 -c 1.1.1.1 -t 10000 -B 1.1.1.22 -P 1 --cport 6000 -i 0"
alias iperf10=" iperf3 -c 1.1.1.2 -t 10000 -B 1.1.1.22 -P 10 --cport 6000 -i 0"
alias iperf20=" iperf3 -c 1.1.1.2 -t 10000 -B 1.1.1.22 -P 20 --cport 6000 -i 0"
alias iperf1=" iperf3 -c 1.1.1.2 -t 10000 -B 1.1.1.22 -P 1 --cport 6000 -i 0"
alias iperf2=" iperf3 -c 1.1.1.2 -t 10000 -B 1.1.1.22 -P 2 --cport 6000 -i 0"

# alias iperf1=" iperf3 -c 1.1.1.23 -t 10000 -B 1.1.1.22 -P 2 --cport 6000 -i 0"

alias ovs-enable-debug="ovs-appctl vlog/set tc:file:DBG netdev_tc_offloads:file:DBG"
function enable-ovs-debug
{
set -x
	sudo ovs-appctl vlog/set tc:file:DBG
	sudo ovs-appctl vlog/set dpif_netlink:file:DBG
	sudo ovs-appctl vlog/set netdev_tc_offloads:file:DBG
set +x
}

function q
{
set -x
	tc qdisc show dev $rep2
	tc qdisc show dev $vx_rep
set +x
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
	cd $dir1
	cd ../$dir2
	cd ../../../
	for a in $(find . -name address); do
		local mac=$(cat $a)
		if [[ "$mac" == "02:25:d0:$h:$p:$n" ]]; then
			dirname $a | xargs basename
		fi
	done
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
	iptables -t nat -A POSTROUTING -s 100.64.0.10/32 -j SNAT --to-source 8.9.10.1
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
	ssh 10.12.205.14 ifconfig $link 8.9.10.11/24 up
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

function ct1
{
set -x
	sudo ovs-ofctl add-flow $br table=0,arp,action=normal
	sudo ovs-ofctl add-flow $br table=0,icmp,action=normal
	sudo ovs-ofctl add-flow $br "table=0,tcp,ct_state=-trk actions=ct(table=1)"
	sudo ovs-ofctl add-flow $br "table=1, ct_state=+trk+new,tcp,in_port=$link actions=ct(commit),normal"
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

	restart-ovs
	for(( src = 2000; src < 52000; src++)); do
		for(( dst = 1000; dst < 1020; dst++)); do
			echo "table=0,priority=10,udp,nw_dst=1.1.1.23,tp_dst=$dst,tp_src=$src,in_port=enp4s0f0_1,action=output:enp4s0f0_2"
		done
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

alias send='/labhome/chrism/prg/python/scapy/send.py'
alias visend='vi /labhome/chrism/prg/python/scapy/send.py'
alias sendm='/labhome/chrism/prg/python/scapy/m.py'

# alias make-dpdk='sudo make install T=x86_64-native-linuxapp-gcc -j 32 DESTDIR=install'
# alias make-dpdk='sudo make install T=x86_64-native-linuxapp-gcc -j 32 DESTDIR=/usr'

function make-dpdk
{
	cd $DPDK_DIR
#	make config T=x86_64-native-linuxapp-gcc
#	make -j32 T=x86_64-native-linuxapp-gcc

	export RTE_SDK=`pwd`
	export RTE_TARGET=x86_64-native-linuxapp-gcc
	make install T=x86_64-native-linuxapp-gcc -j8
}

# alias pmd1="$DPDK_DIR/build/app/testpmd -l 0-8 -n 4 --socket-mem=1024,1024 -w 04:00.0 -w 04:00.2 -- -i"
# alias pmd1k="$DPDK_DIR/build/app/testpmd1k -l 0-8 -n 4 --socket-mem=1024,1024 -w 04:00.0 -w 04:00.2 -- -i"
# alias pmd10k="$DPDK_DIR/build/app/testpmd10k -l 0-8 -n 4 --socket-mem=1024,1024 -w 04:00.0 -w 04:00.2 -- -i"
# alias pmd100k="$DPDK_DIR/build/app/testpmd100k -l 0-8 -n 4 --socket-mem=1024,1024 -w 04:00.0 -w 04:00.2 -- -i"
# alias pmd200k="$DPDK_DIR/build/app/testpmd200k -l 0-8 -n 4 --socket-mem=1024,1024 -w 04:00.0 -w 04:00.2 -- -i"

alias viflowgen="cd $DPDK_DIR; vim app/test-pmd/flowgen.c"
alias vimacswap="cd $DPDK_DIR; vim app/test-pmd/macswap.c"
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


alias g1='genm -i $vf2 -m 24:8a:07:88:27:ca -d 192.168.1.14'
alias g2='genm -i $vf2 -m 24:8a:07:88:27:9a -d 192.168.1.13'

alias g3='genm -i $vf2 -m 02:25:d0:13:01:03 -d 1.1.1.23'
alias g4='genm -i $vf2 -m 02:25:d0:14:01:03 -d 1.1.1.123'

function pgset1
{
	sm1
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

alias pull1='git pull origin jd-kernel-unlocked-driver'
function checkout2
{
	[[ $# != 1 ]] && return
	git branch
	git checkout jd-kernel-unlocked-driver
	git branch -D 1
	git branch 1
	git checkout 1
	git reset --hard $1
	git am ~/backport/0001-disable-trace.patch
	git am ~/backport/delay/0001-mlx5_flow_stats_work.patch
}

function vr
{
	[[ $# != 1 ]] && return
	local file=$(echo ${1%.*})
#	vimdiff ${file}*
	vim -O ${file}*
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

alias err='make -j 32 > /tmp/err.txt 2>&1; vi /tmp/err.txt'

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

test1=test-eswitch-add-del-flows-during-flows-cleanup.sh
alias test1="./$test1"
alias vi-test="vi ~chrism/asap_dev_reg/$test1"

test2=test-ovs-qinq-2.sh
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
	local n=ns1
	ip link del veth0
	ip link add veth0 type veth peer name veth1
	ip link set dev veth0 up
	ip addr add 1.1.1.33/24 brd + dev veth0
	ip netns del $n 2>/dev/null
	ip netns add $n
	ip link set dev veth1 netns $n
	ip netns exec $n ip addr add 1.1.1.34/24 brd + dev veth1
	ip netns exec $n ip link set dev veth1 up
set +x
}
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

alias ct-udp=ct-tcp
function ct-tcp
{
	offload=""
	[[ "$1" == "sw" ]] && offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

	tc-setup $rep2
	tc-setup $rep3

	mac1=02:25:d0:$host_num:01:02
	mac2=02:25:d0:$host_num:01:03
	echo "add arp rules"
	tc filter add dev $rep2 ingress protocol arp prio 1 flower $offload \
		action mirred egress redirect dev $rep3

	tc filter add dev $rep3 ingress protocol arp prio 1 flower $offload \
		action mirred egress redirect dev $rep2

	echo "add ct rules"
	tc filter add dev $rep2 ingress protocol ip prio 2 flower $offload \
		dst_mac $mac2 ct_state -trk \
		action ct action goto chain 1

	tc filter add dev $rep2 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac2 ct_state +trk+new \
		action mirred egress redirect dev $rep3

	tc filter add dev $rep2 ingress protocol ip chain 1 prio 2 flower $offload \
		dst_mac $mac2 ct_state +trk+est \
		action mirred egress redirect dev $rep3

	# chain0,ct -> chain1,fwd
	tc filter add dev $rep3 ingress protocol ip prio 2 flower $offload \
		dst_mac $mac1 \
		action ct action goto chain 1

	tc filter add dev $rep3 ingress protocol ip prio 2 chain 1 flower $offload \
		action mirred egress redirect dev $rep2
}

function br-ct
{
	local proto=udp
	local proto=tcp

	ovs-vsctl add-br $br
	ovs-vsctl add-port $br $rep2
	ovs-vsctl add-port $br $rep3

	ovs-ofctl add-flow $br in_port=$rep2,dl_type=0x0806,actions=output:$rep3
	ovs-ofctl add-flow $br in_port=$rep3,dl_type=0x0806,actions=output:$rep2

	ovs-ofctl add-flow $br "table=0, $proto,ct_state=-trk actions=ct(table=1)"
	ovs-ofctl add-flow $br "table=1, $proto,ct_state=+trk+new actions=ct(commit),normal"
	ovs-ofctl add-flow $br "table=1, $proto,ct_state=+trk+est actions=normal"

	ovs-ofctl dump-flows $br
}

alias cd-scapy='cd /labhome/chrism/prg/python/scapy'

alias udp13=/labhome/chrism/prg/python/scapy/udp13.py
alias udp13-2=/labhome/chrism/prg/python/scapy/udp13-2.py
alias udp14=/labhome/chrism/prg/python/scapy/udp14.py

alias reboot='echo reboot; read; reboot'

# two way traffic
alias udp-server-2='/labhome/chrism/prg/c/udp-server/udp-server-2'
alias udp-client-2='/labhome/chrism/prg/c/udp-client/udp-client-2'

# one way traffic
alias udp-server='/labhome/chrism/prg/c/udp-server/udp-server'
alias udp-client="/labhome/chrism/prg/c/udp-client/udp-client -c 192.168.1.$rhost_num -i 1 -t 10000"

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

function jd-proc
{
	echo 1 > /proc/sys/net/netfilter/nf_conntrack_tcp_be_liberal
	echo 2000000 > /proc/sys/net/netfilter/nf_conntrack_max
}

function jd-hugepage
{
	echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
}

/bin/cp ~/.bashrc ~/.bashrc.bak

function net
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

alias rc23='scp ~chrism/.bashrc root@10.196.23.1:~/'
alias rc24='scp ~chrism/.bashrc root@10.196.24.1:~'
alias rc25='scp ~chrism/.bashrc root@10.196.23.5:~'
alias rc26='scp ~chrism/.bashrc root@10.196.24.5:~'
alias rc0='scp ~chrism/.bashrc chrism@10.7.2.14:~'
alias rc1='scp ~chrism/.bashrc chrism@10.12.205.13:~'

function rca
{
	rc23
	rc24
}

alias hping='hping3 -S -s 10001 -p 12345 1.1.1.122'

function updown
{
set -x
	while true; do
		ifconfig $link down
		sleep 20
		ifconfig $link up
		sleep 1
#		ip route add 10.254.0.0/15 via 10.255.8.193 dev p6p1
		ip1
		sleep 10
	done
set +x
}

alias f1="sudo flint -d $pci q"
alias cat1="cat /sys/class/net/$link/device/sriov/pf/counters_tc_ct"

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

function test-ibd
{
	restart
	br
	restart-ovs
	(( host_num == 13 )) && ip netns exec n11 ping 1.1.1.2 -c 5
	(( host_num == 14 )) && ip netns exec n11 ping 1.1.3.2 -c 5
#	off
}

function test-ibd2
{
	restart
	brx
	restart-ovs
#	ip netns exec n11 ping 1.1.1.200 -c 5
	(( host_num == 13 )) && ip netns exec n11 ping 1.1.3.1 -c 5
	(( host_num == 14 )) && ip netns exec n11 ping 1.1.1.1 -c 5
#	off
}

alias ibd='/etc/init.d/openibd restart'
alias ibd2='/etc/init.d/openibd force-restart'


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

function sun1
{
	cd /.autodirect/mtrsysgwork/sundost/asap_dev_reg
	WITH_VMS=1 ./load-r-vrt-24-120.sh cx5
}

alias sus='su sundost'

function sun2
{
	cd /.autodirect/mtrsysgwork/sundost/asap_dev_reg
	./r-vrt-24-120_cx5/update-r-vrt-24-120_cx5.py
}

function sun3
{
	cd /.autodirect/mtrsysgwork/sundost/asap_dev_reg
	lnst-ctl -d -C lnst-ctl.conf --pools r-vrt-24-120_cx5/ run recipes/ovs_offload/1_virt_ovs_vxlan_flow_key.xml
}

function yum-bcc
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

function install-bcc
{
	sm
	mkdir -p bcc/build; cd bcc/build
	cmake .. -DCMAKE_INSTALL_PREFIX=/usr
	time make -j 32
	sudo make install
}

function install-bpftrace
{
	sm
	cd bpftrace
	unset CXXFLAGS
	mkdir -p build; cd build; cmake -DCMAKE_BUILD_TYPE=DEBUG ..
	unset CXXFLAGS
	make -j 32
	unset CXXFLAGS
	make install
}

function trace1
{
	[[ $# != 1 ]] && return
	$BCC_DIR/tools/trace.py "$1 \"%lx\", arg1"
}

BCC_DIR=/images/chrism/bcc
alias trace="$BCC_DIR/tools/trace.py"
alias execsnoop="$BCC_DIR/tools/execsnoop.py"
alias funccount="$BCC_DIR/tools/funccount.py"

function tracer
{
	[[ $# != 1 ]] && return
	local file=/tmp/bcc_$$.sh
cat << EOF > $file
$BCC_DIR/tools/trace.py 'r::$1 "%lx", retval'
EOF
	echo $file
	bash $file
}

function traceo
{
	[[ $# < 1 ]] && return
	local file=/tmp/bcc_$$.sh
cat << EOF > $file
$BCC_DIR/tools/trace.py 'ovs-vswitchd:$1 "%lx", arg1'
EOF
	if [[ $# == 2 ]]; then
		sed -i 's/$/& -U/g' $file
	fi
	cat $file
	echo $file
	bash $file
}

function traceo2
{
	[[ $# < 1 ]] && return
	local file=/tmp/bcc_$$.sh
cat << EOF > $file
$BCC_DIR/tools/trace.py 'ovs-vswitchd:$1 "%lx", arg2'
EOF
	if [[ $# == 2 ]]; then
		sed -i 's/$/& -U/g' $file
	fi
	cat $file
	echo $file
	bash $file
}

function traceo3
{
	[[ $# < 1 ]] && return
	local file=/tmp/bcc_$$.sh
cat << EOF > $file
$BCC_DIR/tools/trace.py 'ovs-vswitchd:$1 "%llx", arg3'
EOF
	if [[ $# == 2 ]]; then
		sed -i 's/$/& -U/g' $file
	fi
	cat $file
	echo $file
	bash $file
}

function traceor
{
	[[ $# < 1 ]] && return
	local file=/tmp/bcc_$$.sh
cat << EOF > $file
$BCC_DIR/tools/trace.py 'r:ovs-vswitchd:$1 "%lx", retval'
EOF
	if [[ $# == 2 ]]; then
		sed -i 's/$/& -U/g' $file
	fi
	cat $file
	echo $file
	bash $file
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

cat << EOF > $file
#
# depmod.conf
#

# override default search ordering for kmod packaging
search updates extra built-in weak-updates
EOF
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
	make -j 32

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
	ovs-vsctl add-port $br host1_rep tag=$vid -- set Interface host1_rep ofport_request=2
	ovs-vsctl add-port $br $link -- set Interface $link ofport_request=5
}

alias wget8="wget 8.9.10.11:8000"
function http-server
{
	python -m SimpleHTTPServer
}

######## ubuntu #######

[[ -f /usr/bin/lsb_release ]] || return

alias vig='sudo vim /boot/grub/grub.cfg'

function root-login
{
	local file=/etc/ssh/sshd_config
	sudo sed -i '/PermitRootLogin/d' $file
	sudo echo "PermitRootLogin yes" >> $file
	/etc/init.d/ssh restart
}

function reboot1
{
set -x
	local uname=$(uname -r)

	[[ $# == 1 ]] && uname=$1

	local cmdline=$(cat /proc/cmdline | cut -d " " -f 2-)
	sudo kexec -l /boot/vmlinuz-$uname --append="BOOT_IMAGE=/vmlinuz-$uname $cmdline" --initrd=/boot/initrd.img-$uname
	return
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
	sudo sed -i '/GRUB_DEFAULT/d' $file
	sudo sed -i '/GRUB_SAVEDEFAULT/d' $file
	sudo sed -i '/GRUB_CMDLINE_LINUX/d' $file
	sudo echo "GRUB_CMDLINE_LINUX=\"intel_iommu=on biosdevname=0 pci=realloc\"" >> $file
	# for crashkernel, configure /etc/default/grub.d/kdump-tools.cfg

	if [[ $# == 0 ]]; then
		sudo echo "GRUB_DEFAULT=saved" >> $file
		sudo echo "GRUB_SAVEDEFAULT=true" >> $file
	else
		sudo echo "GRUB_DEFAULT=$kernel" >> $file
	fi

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
	sudo systemctl restart ovs-vswitchd.service
}

function stop-ovs
{
	sudo systemctl stop ovs-vswitchd.service
	sudo systemctl stop ovsdb-server.service
}
