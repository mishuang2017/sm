# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

numvfs=3
vni=200
vni=100
vid=50
vxlan_port=4789
vxlan_mac=24:25:d0:e2:00:00
ecmp=0

# Append to history
shopt -s histappend
old=0
uname -r | grep 3.10 > /dev/null 2>&1 && old=1

if [[ "$UID" == "0" ]]; then
	dmidecode | grep "Red Hat" > /dev/null 2>&1
	rh=$?
fi

if [[ "$(hostname -s)" == "bc-vnc02" ]]; then
	host_num=20
elif [[ "$(hostname -s)" == "dev-r630-03" ]]; then
	host_num=13
elif [[ "$(hostname -s)" == "dev-r630-04" ]]; then
	host_num=14
elif [[ "$(hostname -s)" == "dev-chrism-vm1" ]]; then
	host_num=15
elif [[ "$(hostname -s)" == "dev-chrism-vm2" ]]; then
	host_num=16
elif (( rh == 0 )); then
	host_num=9
fi

# export DISPLAY=:0.0
# export DISPLAY=MTBC-CHRISM:0.0

nfs_dir='/auto/mtbcswgwork/chrism'

if (( host_num == 9 )); then
	link=ens9
elif (( host_num == 13 )); then
	link=enp4s0f0
	link2=enp4s0f1
	link_ip=8.2.10.13
	link_ip=192.168.1.13
	link2_ip=8.1.10.13
	link_remote_ip=192.168.1.14
	link_ipv6=2017::13

	br=br-vxlan
	vx=vxlan0

	ns_ip1=1.1.1.3
	ns_ip2=1.1.1.4

	vf1=enp4s0f2
	vf2=enp4s0f3
	vf3=enp4s0f4

	link_mac=24:8a:07:88:27:ca
	link_mac2=24:8a:07:88:27:cb

	remote_mac=$link_mac2
	remote_mac=24:8a:07:88:27:9a
	remote_mac=7c:fe:90:13:d3:b2

	if (( old == 0 )); then
		linux_dir=/home1/chrism/linux
	else
		linux_dir=/home1/chrism/mlnx-ofa_kernel-4.0
	fi
elif (( host_num == 14 )); then
	link=enp4s0f0
	link=enp4s0
	link2=enp4s0f1
	link_ip=7.1.10.14
	link_ip=192.168.1.14
	link2_ip=7.2.10.14
	link_ipv6=2017::14
	link_remote_ip=192.168.1.13

	br=br-vxlan
	vx=vxlan0

	link_mac=24:8a:07:88:27:9a
	link_mac2=24:8a:07:88:27:9b

	link_mac=ec:0d:9a:88:a1:b2
	link_mac2=ec:0d:9a:88:a1:b3

	remote_mac=$link_mac2
	remote_mac=24:8a:07:88:27:ca

	ns_ip1=1.1.1.5
	ns_ip2=1.1.1.6

	vf1=enp4s0f2
	vf2=enp4s0f3

	vf1=enp4s0f1
	vf2=enp4s0f2

	if (( old == 0 )); then
		linux_dir=/home1/chrism/linux
	else
		linux_dir=/home1/chrism/mlnx-ofa_kernel-4.0
	fi
elif (( host_num == 15 )); then
	link=ens9
	link_ip=1.1.1.13
	link_ip=192.168.1.14
	link_remote_ip=192.168.1.13
	linux_dir=/home1/chrism/linux
elif (( host_num == 16 )); then
	link=ens9
	link_ip=1.1.1.3
	link_remote_ip=1.1.1.13
	linux_dir=/home1/chrism/linux
elif (( host_num == 20 )); then
	linux_dir=/auto/mtbcswgwork/chrism/linux
fi

rep1=${link}_0
rep2=${link}_1
rep3=${link}_2

vm1_ip=192.168.122.11
vm2_ip=192.168.122.12

link_ip_vlan=1.1.1.1
link_ip_vxlan=1.1.1.1

brd_mac=ff:ff:ff:ff:ff:ff

if (( old == 1 )); then
	vx_rep=dummy_4789
else
	vx_rep=vxlan_sys_4789
fi

alias ssh='ssh -o "StrictHostKeyChecking no"'

if [[ -e /sys/class/net/$link/device ]]; then
	pci=$(basename $(readlink /sys/class/net/$link/device))
	pci2=$(basename $(readlink /sys/class/net/$link2/device) 2> /dev/null)
fi

alias a1="ip l show $link | grep ether; ip link set dev $link address $link_mac;  ip l show $link | grep ether"
alias a2="ip l show $link | grep ether; ip link set dev $link address $link_mac2; ip l show $link | grep ether"

alias vxlan1="ovs-vsctl add-port $br $vx -- set interface $vx type=vxlan options:remote_ip=$link_remote_ip  options:key=$vni"
alias vxlan2="ovs-vsctl del-port $br $vx"
alias vx='vxlan2; vxlan1'

alias ip1="ifconfig $link 0; ip addr add dev $link $link_ip/24; ip link set $link up"
alias ipmirror="ifconfig $link 0; ip addr add dev $link $link_ip_vlan/16; ip link set $link up"
alias ip2="ifconfig $link2 0; ip addr add dev $link2 $link2_ip/24; ip link set $link2 up"

alias vsconfig='ovs-vsctl get Open_vSwitch . other_config'
alias vsconfig-idle='ovs-vsctl set Open_vSwitch . other_config:max-idle=30000'
alias vsconfig-hw='ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"'
alias vsconfig-sw='ovs-vsctl set Open_vSwitch . other_config:hw-offload="false"'
alias vsconfig-skip_sw='ovs-vsctl set Open_vSwitch . other_config:tc-policy=skip_sw'
alias vsconfig-skip_hw='ovs-vsctl set Open_vSwitch . other_config:tc-policy=skip_hw'
alias vsconfig-none='ovs-vsctl set Open_vSwitch . other_config:tc-policy=none'
alias ovs-log=' tail -f  /var/log/openvswitch/ovs-vswitchd.log'
alias ovs2-log=' tail -f /var/log/openvswitch/ovsdb-server.log'

alias p4="ping 1.1.1.14"
alias p6="ping6 2017::14"

alias crash2="$nfs_dir/crash/crash -i /root/.crash //boot/vmlinux-$(uname -r).bz2"


if (( old == 1 )); then
	CRASH=/root/bin/crash
	CRASH=$nfs_dir/crash/crash
else
	CRASH=$nfs_dir/crash/crash-upstream
	CRASH=$nfs_dir/crash/crash
	CRASH=/home1/chrism/crash/crash
fi

if (( host_num == 15 )); then
	CRASH=/root/bin/crash
fi
CRASH=~chrism/bin/crash

alias crash1="$CRASH -i /root/.crash $linux_dir/vmlinux"
alias c=crash1

alias gdb-kcore="gdb $linux_dir/vmlinux /proc/kcore"

alias crash="$CRASH -i ~/.crash"
crash_dir=/var/crash
alias c0="$CRASH -i /root/.crash $crash_dir/vmcore.0 $linux_dir/vmlinux"
alias c1="$CRASH -i /root/.crash $crash_dir/vmcore.1 $linux_dir/vmlinux"
alias c2="$CRASH -i /root/.crash $crash_dir/vmcore.2 $linux_dir/vmlinux"
alias c3="$CRASH -i /root/.crash $crash_dir/vmcore.3 $linux_dir/vmlinux"
alias c4="$CRASH -i /root/.crash $crash_dir/vmcore.4 $linux_dir/vmlinux"
alias c5="$CRASH -i /root/.crash $crash_dir/vmcore.5 $linux_dir/vmlinux"
alias c6="$CRASH -i /root/.crash $crash_dir/vmcore.6 $linux_dir/vmlinux"

alias cc0="$CRASH $crash_dir/vmcore.0 /usr/lib/debug/lib/modules/$(uname -r)/vmlinux"
alias cc1="$CRASH -i /root/.crash $crash_dir/vmcore.1 /usr/lib/debug/lib/modules/$(uname -r)/vmlinux"
alias cc0="$CRASH -i /root/.crash /usr/lib/debug/lib/modules/$(uname -r)/vmlinux"

if (( old == 1 )); then
	alias c=cc0
fi

alias sw='vsconfig-sw; restart-ovs'
alias hw='vsconfig-hw; restart-ovs'

alias fsdump5="mlxdump -d $pci fsdump --type FT --gvmi=0 --no_zero=1"
alias fsdump52="mlxdump -d $pci2 fsdump --type FT --gvmi=1 --no_zero=1"

function fsdump
{
	fsdump5 > /root/1.txt
	fsdump52 > /root/2.txt
}

alias fsdump4lx='mlxdump -d 03:00.0 fsdump --type FT --gvmi=0 --no_zero=1'
alias fsdump4='mlxdump -d 03:00.0 fsdump --type FT --gvmi=0 --no_zero=1'
alias gc='grub-customizer'

alias vm1="ssh root@$vm1_ip"
alias vm2="ssh root@$vm2_ip"
alias vm3="ssh root@$vm3_ip"

alias con='virsh console'
alias con1='virsh console vm1'
alias con2='virsh console vm2'
alias con3='virsh console vm3'
alias con4='virsh console vm4'
alias con5='virsh console vm5'
alias con6='virsh console vm6'
alias con7='virsh console vm7'
alias con8='virsh console vm8'


alias s1='ssh root@192.168.122.10'
alias s2='ssh root@192.168.122.2'
alias s3='ssh root@192.168.122.3'
alias s4='ssh root@192.168.122.4'
alias s5='ssh root@192.168.122.5'
alias s6='ssh root@192.168.122.6'
alias s7='ssh root@192.168.122.7'
alias s8='ssh root@192.168.122.8'

alias s11='ssh root@192.168.122.11'
alias s12='ssh root@192.168.122.12'
alias s13='ssh root@192.168.122.13'
alias s14='ssh root@192.168.122.14'
alias s15='ssh root@192.168.122.15'
alias s16='ssh root@192.168.122.16'
alias s17='ssh root@192.168.122.17'
alias s18='ssh root@192.168.122.18'

alias start1='virsh start vm1'
alias start1c='virsh start vm1 --console'
alias restart1='virsh reboot vm1'
alias start2='virsh start vm2'
alias restart2='virsh reboot vm2'
alias start3='virsh start vm3'
alias restart3='virsh reboot vm3'
alias reboot='sudo reboot'

alias stop1='virsh shutdown vm1'
alias stop2='virsh shutdown vm2'
alias stop3='virsh shutdown vm3'

alias reset1='virsh reset vm1'
alias reset2='virsh reset vm2'

alias dud='du -h -d 1'

alias sect='git bisect'
alias slog='git slog'
alias slog1='git slog -1'
alias slog2='git slog -2'
alias slog3='git slog -3'
alias slog4='git slog -4'
alias slog10='git slog -10'
alias git1='git slog v4.11.. drivers/net/ethernet/mellanox/mlx5/core/'
alias gita='git log --author="chrism@mellanox.com"'

# for legacy

alias debug-esw='debugm 8; debug-file drivers/net/ethernet/mellanox/mlx5/core/eswitch.c'
alias debug-esw='debugm 8; debug-file drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c'
alias rx='rxdump -d 03:00.0 -s 0'
alias rx2='rxdump -d 03:00.0 -s 0 -m'
alias sx='sxdump -d 03:00.0 -s 0'

alias iperf=iperf3
alias or='ssh root@10.209.32.230'
alias t="tcpdump -enn -i $link"
alias t1="tcpdump -enn -v -i $link"
alias t2="tcpdump -enn -vv -i $link"
alias t4="tcpdump -enn -vvvv -i $link"
alias ti='tcpdump -enn -i'
alias tvf="ip netns exec n0 tcpdump -enn -i $vf1"
alias tvf2="ip netns exec n1 tcpdump -en -i $vf2"
alias trep="tcpdump -en -i $rep1"
alias mount-mswg='sudo mount 10.4.0.102:/vol/mswg/mswg /mswg/'

alias tvf1="tcpdump ip src host 1.1.1.14 -e -xxx -i $vf1"
alias tvf2="tcpdump ip src host 1.1.1.14 -e -xxx -i $vf2"
alias tvx="tcpdump ip dst host 1.1.13.2 -e -xxx -i $vx"

alias up="mlxlink -d $pci -p 1 -a UP"
alias down="mlxlink -d $pci -p 1 -a DN"
alias m1="mlxlink -d $pci"

alias modv='modprobe --dump-modversions'
alias 154='ssh mishuang@10.12.66.154'
alias ctl=systemctl
# alias dmesg='dmesg -T'

alias 13c='ssh root@10.12.206.25'
alias 14c='ssh root@10.12.206.26'

alias switch='ssh admin@10.12.67.39'

# alias t="ti $vf1"
alias r=restart

alias slave='lnst-slave'
alias classic='rpyc_classic.py'	# used to update mac address
alias lv='lnst-ctl -d --pools=dev13_14 run recipes/ovs_offload/03-vlan_in_host.xml'
alias lh='lnst-ctl -d --pools=dev13_14 run recipes/ovs_offload/header_rewrite.xml'
alias iso='cd /mnt/d/software/iso'

# alias uperf="$nfs_dir/uperf-1.0.5/src/uperf"

function vmcore
{
	[[ $# != 1 ]] && return
	$nfs_dir/crash/crash -i ~chrism/.crash $1 $linux_dir/vmlinux
}

alias chown1="sudo chown -R chrism.mtl $linux_dir"
alias sb='tmux save-buffer'

alias sm2='cd /home1/chrism'
alias sm3='cd /home1/chrism/iproute2'
alias sm1="cd $linux_dir"
alias smm='cd /home1/chrism/mlnx-ofa_kernel-4.0'
alias cd-test="cd $linux_dir/tools/testing/selftests/tc-testing/"
alias vi-action="vi $linux_dir/tools/testing/selftests/tc-testing/tc-tests/actions//tests.json"
alias vi-filter="vi $linux_dir/tools/testing/selftests/tc-testing/tc-tests/filters//tests.json"
alias ovs="cd $nfs_dir/ovs/openvswitch"
alias ovs="cd /home1/chrism/openvswitch"
alias smo="cd /home1/chrism/openvswitch"
alias cfo="cd /home1/chrism/openvswitch; cscope -d"
alias ovs2="cd $nfs_dir/ovs/test/ovs-tests"
alias ipa='ip a'
alias ipl='ip l'
alias ipal='ip a l'
alias smd='cd /usr/src/debug/kernel-3.10.0-327.el7/linux-3.10.0-327.el7.x86_64'
alias rmswp='sm1; find . -name *.swp -exec rm {} \;'
alias rmswp1='find . -name *.swp -exec rm {} \;'

alias mount-fedora="mount /dev/mapper/fedora-root /mnt"
alias cfl='cd /mnt/home1/chrism/linux; cscope -d'

alias sm="cd $nfs_dir"
alias smc="cd $nfs_dir/crash; vi net.c"
alias smi='cd /var/lib/libvirt/images'
alias smi2='cd /etc/libvirt/qemu'

alias smn='cd /etc/sysconfig/network-scripts/'

alias vs='ovs-vsctl'
alias of='ovs-ofctl'
alias dp='ovs-dpctl'
alias app='ovs-appctl'
alias app1='ovs-appctl dpctl/dump-flows'
alias appn='ovs-appctl dpctl/dump-flows --names'
# systemctl start openvswitch.service

alias p2='n0 ping 1.1.1.2'
alias p9='n0 ping 1.1.1.19'
alias p="ping $link_remote_ip"
alias px="ping $link_remote_ip"
alias p11='n0 ping 1.1.1.11'
alias p5='n0 ping 1.1.1.5'
alias p3='n0 ping 1.1.1.3'

alias tcs="tc filter show dev $link protocol ip parent ffff:"
alias tcss="tc -stats filter show dev $link protocol ip parent ffff:"
alias tcss="tc -stats filter show dev $link ingress"
alias tcs2="tc filter show dev $link protocol arp parent ffff:"
alias tcs3="tc filter show dev $link protocol 802.1Q parent ffff:"

alias tcss-rep2="tc -stats filter show dev $rep2 parent ffff:"
alias tcss-rep2-ip="tc -stats filter show dev $rep2  protocol ip parent ffff:"
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

alias tcss-vxlan="tc -stats filter show dev $vx_rep  protocol ip parent ffff:"
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
alias e=exit
alias 160='ssh root@10.200.0.160'
alias ka=killall
alias vnc2='ssh chrism@10.7.2.14'
alias vnc='ssh chrism@10.12.68.111'
alias netstat1='netstat -ntlp'

alias 18='ssh -X root@10.200.0.168'
alias 19='ssh -X root@10.200.0.169'
alias 19c='ssh -X chrism@10.200.0.169'
alias 13='ssh -X root@10.12.205.13'
alias 14='ssh -X root@10.12.205.14'
alias 15='ssh -X root@10.12.205.15'
alias 16='ssh -X root@10.12.205.16'

alias b3=' lspci -d 15b3: -nn'

alias ..='cd ..'
alias ...='cd ../..'

alias lc='ls --color'
alias l='ls -lh'
alias ll='ls -lh'
alias df='df -h'

alias vi='vim'
alias vipr='vi ~/.profile'
alias virc='vi ~/.bashrc'
alias virca='vi ~/.bashrc*'
alias visc='vi ~/.screenrc'
alias vv='vi ~/.vimrc'
alias rc='. ~/.bashrc'
alias vis='vi ~/.ssh/known_hosts'
alias vin='vi ~/Documents/notes.txt'
alias vi1='vi ~/Documents/ovs.txt'
alias vi2='vi ~/Documents/mirror.txt'
alias vib='vi ~/Documents/bug.txt'
alias vip='vi ~/Documents/private.txt'
alias vig='sudo vi /boot/grub2/grub.cfg'
alias vig2='sudo vi /etc/default/grub'
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
alias x=x.py
if (( old == 1 )); then
	alias cf="sm1; cscope -d"
else
	alias cf="cd $linux_dir; cscope -d"
fi
alias cf2='cd /auto/mtbcswgwork/chrism/iproute2; cscope -d'
alias cf3='sm3; cscope -d'

alias cd-download='cd /cygdrive/c/Users/chrism/Downloads'
alias cd-doc='cd /cygdrive/c/Users/chrism/Documents'
alias cdr="cd /lib/modules/$(uname -r)"

alias nc-server='nc -l -p 80 < /dev/zero'
alias nc-client='nc 1.1.1.19 80 > /dev/null'

# password is windows password
alias mount-setup='mkdir -p /mnt/setup; mount  -o username=chrism //10.200.0.25/Setup /mnt/setup'

alias qlog='less /var/log/libvirt/qemu/vm1.log'
alias vd='virsh dumpxml vm1'
alias simx='/opt/simx/bin/manage_vm_simx_support.py -n vm2'

alias vfs="mlxconfig -d $pci set SRIOV_EN=1 NUM_OF_VFS=127"
alias vfs="mlxconfig -d $pci set SRIOV_EN=1 NUM_OF_VFS=16"
alias vfq="mlxconfig -d $pci q"
alias vfq2="mlxconfig -d $pci2 q"
alias vfsm="mlxconfig -d $linik_bdf set NUM_VF_MSIX=6"

alias tune1="ethtool -C $link adaptive-rx off rx-usecs 64 rx-frames 128 tx-usecs 64 tx-frames 32"
alias tune2="ethtool -C $link adaptive-rx on"
alias tune3="ethtool -c $link"

alias ovs-enable-debug="ovs-appctl vlog/set tc:file:DBG netdev_tc_offloads:file:DBG"
alias a=ovs-arp-responder.sh

alias restart-virt='systemctl restart libvirtd.service'

export PATH=$PATH:~/bin
export EDITOR=vim
export TERM=xterm
unset PROMPT_COMMAND

n_time=20
m_msg=64000
alias np1="netperf -H 1.1.1.13 -t TCP_STREAM -l $n_time -- m $m_msg -p 12865 &"
alias np3="ip netns exec n1 netperf -H 1.1.1.13 -t TCP_STREAM -l $n_time -- m $m_msg -p 12865 &"
alias np4="ip netns exec n1 netperf -H 1.1.1.13 -t TCP_STREAM -l $n_time -- m $m_msg -p 12866 &"
alias np5="ip netns exec n1 netperf -H 1.1.1.13 -t TCP_STREAM -l $n_time -- m $m_msg -p 12867 &"

alias sshcopy='ssh-copy-id -i ~/.ssh/id_rsa.pub'

# ================================================================================

function core
{
        ulimit -c unlimited
        echo "/tmp/core-%e-%p" > /proc/sys/kernel/core_pattern
}

function enable-core
{
	mkdir -p /tmp/cores
	chmod a+rwx /tmp/cores
	echo "/tmp/cores/core.%e.%p.%h.%t" > /proc/sys/kernel/core_pattern
}

function vlan
{
        [[ $# != 3 ]] && return
        local link=$1 vid=$2 ip=$3 vlan=vlan$vid

        modprobe 8021q
	ifconfig $link 0
        ip link add link $link name $vlan type vlan id $vid
        ip link set dev $vlan up
        ip addr add $ip/16 brd + dev $vlan
        ip addr add $link_ipv6/64 dev $vlan
}
alias v1="vlan $link $vid $link_ip_vlan"
alias v2="ip link del vlan$vid"

function call
{
set -x
# 	/bin/rm -f cscope.out > /dev/null;
# 	/bin/rm -f tags > /dev/null;
# 	cscope -R -b -k -q &
# 	cscope -R -b -k &
# 	ctags -R

	make tags ARCH=x86
	make cscope ARCH=x86
set +x
}

function cone
{
set -x
# 	/bin/rm -f cscope.out > /dev/null;
# 	/bin/rm -f tags > /dev/null;
# 	cscope -R -b -k -q &
	cscope -R -b &
	ctags -R
set +x
}

alias cu='time cscope -R -b -k'

function greps
{
	[[ $# != 1 ]] && return
	sm1
	grep include -Rn -e "struct $1 {" | sed 's/:/\t/'
}

function profile
{
	local host=$1
	who=root
	[[ $# != 1 ]] && return
	scp ~/.bashrc $who@$host:~
	scp ~/.virc $who@$host:~
	scp ~/.vim $who@$host:~
	scp ~/.screenrc $who@$host:~
	scp ~/.tmux.conf $who@$host:~
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
function set_mac
{
	[[ $# != 1 ]] && return

	local vf=$1
	local mac_vf=$((vf+5))
	ip link set $link vf $vf mac $mac_prefix:$mac_vf
}

alias on_sriov="echo $numvfs > /sys/class/net/$link/device/sriov_numvfs"

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

function unbind_all
{
	local l=$1
	echo
	echo "start unbind_all /sys/bus/pci/drivers/mlx5_core/unbind"
	for (( i = 0; i < numvfs; i++)); do
		vf_bdf=$(basename `readlink /sys/class/net/$l/device/virtfn$i`)
		echo "vf${i} $bdf"
		echo $vf_bdf > /sys/bus/pci/drivers/mlx5_core/unbind
	done
	echo "end unbind_all"
}

function off_all
{
	local l
# 	for l in $link $link2; do
	for l in $link; do
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
# 	del-reps
	if (( old == 1)); then
		echo legacy > /sys/kernel/debug/mlx5/$pci/compat/mode 2 > /dev/null || echo "legacy"
	fi
}

alias off=off_all

function switchdev
{
	bdf=$(basename `readlink /sys/class/net/$link/device`)
	echo $bdf
	if [[ $# == 0 ]]; then
		devlink dev eswitch set pci/$bdf mode switchdev
	fi
	if [[ $# == 1 && "$1" == "off" ]]; then
		devlink dev eswitch set pci/$bdf mode legacy
	fi
}

function inline-mode
{
set -x
	bdf=$(basename `readlink /sys/class/net/$link/device`)
# 	devlink dev eswitch show pci/$bdf mode
# 	devlink dev eswitch show pci/$bdf inline-mode
	devlink dev eswitch set pci/$bdf inline-mode transport
set +x
}

function enable_tc
{
	ethtool -K $link hw-tc-offload on
	ethtool -K ${link}_0 hw-tc-offload on
	ethtool -K ${link}_1 hw-tc-offload on
}

function ovs_setup
{
	systemctl start openvswitch.service
	ovs-vsctl set Open_vSwitch . other_config:hw-offload=true
	ovs-vsctl add-br $br

	ovs-vsctl add-port $br $link
	ovs-vsctl add-port $br ${link}_0 # tag=52
	ovs-vsctl add-port $br ${link}_1 # tag=52

	ip link set dev $link up
	ip link set dev ${link}_0 up
	ip link set dev ${link}_1 up

	ovs-dpctl show 
	ovs-dpctl dump-flows
}

# function tcq
# {
# 	tc qdisc add dev $link ingress
# 	tc qdisc add dev ${link}_0 ingress
# 	tc qdisc add dev ${link}_1 ingress
# }

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

alias ofd="ovs-ofctl dump-flows $br"
alias drop3="ovs-ofctl add-flow $br 'nw_dst=1.1.1.14 action=drop'"
alias del3="ovs-ofctl del-flows $br 'nw_dst=1.1.1.14'"

alias drop1="ovs-ofctl add-flow $br 'nw_src=192.168.1.1 action=drop'"
alias normal1="ovs-ofctl add-flow $br 'nw_src=192.168.1.1 action=normal'"

alias drop2="ovs-ofctl add-flow $br 'nw_src=192.168.1.2 action=drop'"
alias normal2="ovs-ofctl add-flow $br 'nw_src=192.168.1.3 action=normal'"

alias dropm="ovs-ofctl add-flow $br 'dl_dst=24:8a:07:88:27:9a  table=0,priority=1,action=drop'"
alias normalm="ovs-ofctl add-flow $br 'dl_dst=24:8a:07:88:27:9a  action=normal'"
alias normalm="ovs-ofctl add-flow $br 'dl_dst=24:8a:07:88:27:9a  table=0,priority=10,action=normal'"
alias delm="ovs-ofctl del-flows $br dl_dst=24:8a:07:88:27:9a"

alias make_core='make M=drivers/net/ethernet/mellanox/mlx5/core'

if (( old == 1)); then
	stap_str="-d act_gact -d cls_flower -d act_mirred -d /usr/sbin/ethtool -d udp_tunnel -d sch_ingress -d 8021q -d /usr/sbin/ip -d /usr/sbin/ifconfig -d /usr/sbin/tc -d devlink -d mlx5_core -d tun -d kernel -d openvswitch -d vport_vxlan -d vxlan -d /usr/sbin/ovs-vswitchd -d /usr/bin/bash -d /usr/lib64/libc-2.17.so"
else
	stap_str="-d act_gact -d cls_flower -d act_mirred -d /usr/sbin/ethtool -d udp_tunnel -d sch_ingress -d 8021q -d /usr/sbin/ip -d /usr/sbin/ifconfig -d /usr/sbin/tc -d devlink -d mlx5_core -d tun -d kernel -d openvswitch -d vport_vxlan -d vxlan -d /usr/sbin/ovs-vswitchd -d /usr/bin/bash -d /usr/lib64/libc-2.26.so -d /usr/lib64/libpthread-2.26.so -d /home1/chrism/iproute2/tc/tc"
fi

# make oldconfig
# make prepare

STAP="/usr/bin/stap -v"
STAP="/usr/local/bin/stap -v"

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
#!/usr/local/bin/stap -v
global start
function timestamp:long() { return gettimeofday_us() - start }
probe begin { start = gettimeofday_us() }

global i=0;
probe module("$module").function("$function")
{
        print_backtrace()
        printf("parms: %s\n", \$\$parms);
        printf("execname: %s\n", execname());
        printf("ts: %d\n", timestamp() / 1000000);
        print_ubacktrace()
        printf("%d\n", i++);
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
#!/usr/local/bin/stap -v
/* global start */
/* function timestamp:long() { return gettimeofday_us() - start } */
/* probe begin { start = gettimeofday_us() } */

/* global i=0; */
probe module("$module").function("$function").return
{
/* 	print_backtrace() */
/* 	printf("execname: %s\n", execname()); */
/* 	printf("ts: %d\n", timestamp() / 1000000); */
/* 	print_ubacktrace() */
/* 	printf("%d\n", i++); */
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
#!/usr/local/bin/stap -v

global start
function timestamp:long() { return gettimeofday_us() - start }
probe begin { start = gettimeofday_us() }

probe kernel.function("$1")
{
	print_backtrace()
	printf("parms: %s\n", \$\$parms);
	printf("execname: %s\n", execname());
	printf("ts: %d\n", timestamp()/1000000);
	print_ubacktrace()
	printf("\n");
}
EOF
	else
		cat << EOF > $file
#!/usr/local/bin/stap -v

global start
function timestamp:long() { return gettimeofday_us() - start }
probe begin { start = gettimeofday_us() }

probe module("$mod").function("$1")
{
	print_backtrace()
	printf("parms: %s\n", \$\$parms);
	printf("execname: %s\n", execname());
	printf("ts: %d\n", timestamp()/1000000);
	print_ubacktrace()
	printf("\n");
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
#!/usr/local/bin/stap -v

global start
function timestamp:long() { return gettimeofday_us() - start }
probe begin { start = gettimeofday_us() }

probe kernel.function("$fun").return
{
	print_backtrace()
	printf("%x\t%d\n", \$return, \$return);
	printf("ts: %d\n", timestamp()/1000000);
}
EOF
	else
		cat << EOF > $file
#!/usr/local/bin/stap -v
 
global start
function timestamp:long() { return gettimeofday_us() - start }
probe begin { start = gettimeofday_us() }

probe module("$mod").function("$fun").return
{
	print_backtrace()
	printf("%x\t%d\n", \$return, \$return);
	printf("ts: %d\n", timestamp()/1000000);
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

mybuild () 
{
set -x; 
	module=mlx5_core;
	driver_dir=drivers/net/ethernet/mellanox/mlx5/core
	cd $linux_dir;
	make M=$driver_dir -j 32 || return
	src_dir=$linux_dir/$driver_dir
	sudo /bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/$driver_dir
# 	make modules_install -j 32

	sudo modprobe -r mlx5_ib
	sudo modprobe -r mlx5_core
	sudo modprobe -v mlx5_core

# 	cd $src_dir;
# 	make CONFIG_MLX5_CORE=m -C $linux_dir M=$src_dir modules -j 32;
# 	/bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/drivers/net/ethernet/mellanox/mlx5/core
# 	sudo rmmod mlx5_ib
# 	sudo rmmod $module;
# 	sudo modprobe mlx5_ib
# 	sudo modprobe $module;
set +x
}

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

if (( old == 1 )); then
	alias b=mybuild_old
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
alias b_gact="tc2; mybuild1 act_gact"
alias b_mirred="tc2; mybuild1 act_mirred"
alias b_vlan="tc2; mybuild1 act_vlan"
alias b_pedit="tc2; mybuild1 act_pedit"

mybuild1 ()
{
set -x;
        [[ $# == 0 ]] && return
        module=$1;
        driver_dir=net/sched
        cd $linux_dir;
        make M=$driver_dir -j 32 || return
        src_dir=$linux_dir/$driver_dir
        sudo /bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/$driver_dir

        sudo modprobe -r $1
        sudo modprobe -v $1

set +x
}

mybuild2 ()
{
set -x;
        module=openvswitch
        driver_dir=net/openvswitch
        cd $linux_dir;
        make M=$driver_dir -j 32 || return
        src_dir=$linux_dir/$driver_dir
        sudo /bin/cp -f $src_dir/$module.ko /lib/modules/$(uname -r)/kernel/$driver_dir

        sudo modprobe -r $module
        sudo modprobe -v $module

set +x
}

function reprobe
{
	sudo modprobe -r mlx5_ib
	sudo modprobe -r mlx5_core
	sudo modprobe -v mlx5_core
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

# need to install /auto/mtbcswgwork/chrism/libcap-ng-0.7.8 first
function install-ovs
{
set -x
	./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc
	make -j 32
	sudo make install -j 32
set +x
}

function io
{
set -x
	ovs
	make -j 32
	sudo make install
	sudo systemctl restart openvswitch.service
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
	git fetch origin net
	git checkout FETCH_HEAD
	git checkout -b net
set +x
}

function vxlan0
{
	ovs-vsctl add-port br0 vxlan0 -- set interface vxlan0 type=vxlan options:remote_ip=1.1.1.19 options:key=98
}

function dev
{
	pci_dev=$(basename `readlink /sys/class/net/$link/device`)
	echo $pci_dev
# 	devlink dev eswitch  set pci/$pci_dev mode legacy
	devlink dev eswitch  set pci/$pci_dev mode switchdev
}

function leg
{
	pci_dev=$(basename `readlink /sys/class/net/$link/device`)
	echo $pci_dev
	devlink dev eswitch  set pci/$pci_dev mode legacy
}

function tct
{
	tc filter add dev p2p1 protocol ip parent ffff: \
	  flower \
	  ip_proto 1 \
	  action pedit munge ip ttl add 0xff pipe \
	  action csum ip
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
CC = gcc
EXEC = $p
OBJS = $p.o
FILE = $p.c

all: \$(EXEC)
	\$(CC) -g \$(FILE) -o \$(EXEC)
# 	\$(CC) -Wall -Werror -ansi -pedantic-errors -g \$(FILE) -o \$(EXEC)

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
	printk(KERN_ALERT "$p enter\n");
	return 0;
}

static void ${p}_exit(void)
{
	printk(KERN_ALERT "$p exit\n");
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
KERNEL_SRC :=/home1/chrism/linux

KVERSION = \$(shell uname -r)
obj-m = ${p}.o

all:
	make -C /lib/modules/\$(KVERSION)/build M=\$(PWD) modules
clean:
	make -C /lib/modules/\$(KVERSION)/build M=\$(PWD) clean
	-sudo rmmod ${p}
	-sudo dmesg -C

run:
	-sudo insmod ./${p}.ko
	-sudo dmesg
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

alias make-all='[[ $UID == 0 ]] && break; sm1; make olddefconfig; make -j 32; sudo make modules_install -j 32; sudo make install'
alias make-all2='sm1; make olddefconfig; make -j 16; sudo make modules_install; sudo make install'
alias m=make-all
alias m2=make-all2
alias make-local='./configure; make -j 32; sudo make install'
alias ml=make-local
alias make-usr='./configure --prefix=/usr; make -j 32; sudo make install'
alias mu=make-usr
alias mi='make; sudo make install'

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

function ttl1
{
set -x
	cd /home1/chrism/tc-scripts
	p2p1
	ethtool -K p2p1 hw-tc-offload on
# 	ethtool -K p2p1 hw-tc-offload off
	./tc qdisc add dev  p2p1  ingress
	./tc filter add dev p2p1 protocol ip parent ffff: flower skip_sw ip_proto 1 action pedit munge ip ttl set 0x10
# 	./tc filter add dev p2p1 protocol ip parent ffff: prio 30 flower skip_sw ip_proto udp dst_port 7000 action pedit munge eth dst set aa:bb:cc:dd:ee:ff
set +x
}

function ttl2
{
set -x
	cd /home1/chrism/tc-scripts
	./tc qdisc del dev p2p1 ingress
set +x
}

alias config="egrep \"UPROBE|MODVERSION|STRICT_DEVMEM|CLS_FLOWER|CONFIG_NET_ACT_VLAN|CONFIG_NET_ACT_MIRRED|CONFIG_NET_UDP_TUNNEL|CONFIG_NET_ACT_TUNNEL_KEY\" .config"

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
#         killall -KILL $IPERF;

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
#         killall -KILL $IPERF;

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
# 	for link in p2p1 $rep1 $rep2 $vx_rep; do
	for l in $link $rep1 $rep2 $rep3 $vx_rep, $vx; do
		ip link show $l > /dev/null 2>&1 || continue
		tc qdisc show dev $l ingress | grep ffff > /dev/null 2>&1
		if (( $? == 0 )); then
			sudo /bin/time -f %e tc qdisc del dev $l ingress
			echo $l
		fi
	done
	tc action flush action gact
}

function tc-vxlan
{
set -x
	offload=skip_sw
        [[ $# == 1 ]] && offload=$1
        [[ "$offload" == "sw" ]] && offload="skip_hw"

	TC=tc
	local link=$link
	local rep=$rep1
	local vx=$vx_rep
	local vni=$vni
	port=4789

	$TC qdisc del dev $link ingress
	$TC qdisc del dev $rep ingress

	if [[ "$offload" == "skip_sw" ]]; then
		ethtool -K $link hw-tc-offload on 
		ethtool -K $rep   hw-tc-offload on 
	fi
	if [[ "$offload" == "skip_hw" ]]; then
		ethtool -K $link hw-tc-offload off
		ethtool -K $rep   hw-tc-offload off
	fi

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $rep ingress 
	$TC qdisc add dev $vx ingress 

	src_ip=192.168.1.18
	dst_ip=192.168.1.19
	src_mac=02:25:d0:e2:18:50
	dst_mac=02:25:d0:e2:19:50
	$TC filter add dev $rep protocol ip  parent ffff: flower $offload	\
		    dst_mac $dst_mac		\
		    src_mac $src_mac		\
                    action tunnel_key set	\
                    src_ip $src_ip		\
                    dst_ip $dst_ip		\
                    dst_port $port		\
                    id $vni			\
                    action mirred egress redirect dev $vx

	src_ip=192.168.1.19
	dst_ip=192.168.1.18
	src_mac=02:25:d0:e2:19:50
	dst_mac=02:25:d0:e2:18:50
        $TC filter add dev $vx protocol 0x806 parent ffff: flower $offload	\
		    dst_mac $dst_mac		\
		    src_mac $src_mac		\
		    enc_src_ip $src_ip		\
		    enc_dst_ip $dst_ip		\
		    enc_dst_port $port		\
		    enc_key_id $vni		\
		    action tunnel_key unset	\
                    action mirred egress redirect dev $rep
}

function tc-pf
{
set -x
	offload=skip_sw
        [[ $# == 1 ]] && offload=$1
        [[ "$offload" == "sw" ]] && offload="skip_hw"

	TC=/home1/chrism/tc-scripts/tc
	TC=tc
	TC=/home1/chrism/iproute2/tc/tc

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
	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $link
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $link
	$TC filter add dev $rep2 prio 3 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $link
	src_mac=$remote_mac
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $link prio 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $link prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $link prio 3 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
set +x
}

function tc-mirror-pf
{
set -x
	offload=skip_sw
        [[ $# == 1 ]] && offload=$1
        [[ "$offload" == "sw" ]] && offload="skip_hw"

	TC=/home1/chrism/tc-scripts/tc
	TC=tc
	TC=/home1/chrism/iproute2/tc/tc

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
	offload=skip_sw
        [[ $# == 1 ]] && offload=$1
        [[ "$offload" == "sw" ]] && offload="skip_hw"

	TC=/home1/chrism/tc-scripts/tc
	TC=tc
	TC=/home1/chrism/iproute2/tc/tc

	$TC qdisc del dev $rep2 ingress
	$TC qdisc del dev $rep3 ingress

	ethtool -K $rep2 hw-tc-offload on 
	ethtool -K $rep3 hw-tc-offload on 

	$TC qdisc add dev $rep2 ingress 
	$TC qdisc add dev $rep3 ingress 

	src_mac=02:25:d0:$host_num:01:02
	dst_mac=02:25:d0:$host_num:01:03
	$TC filter add dev $rep2 prio 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
		action mirred egress mirror dev $mirror \
	$TC filter add dev $rep2 prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep3
	$TC filter add dev $rep2 prio 3 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep3
	src_mac=02:25:d0:$host_num:01:03
	dst_mac=02:25:d0:$host_num:01:02
	$TC filter add dev $rep3 prio 1 protocol ip  parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 2 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $dst_mac action mirred egress redirect dev $rep2
	$TC filter add dev $rep3 prio 3 protocol arp parent ffff: flower skip_hw  src_mac $src_mac dst_mac $brd_mac action mirred egress redirect dev $rep2
set +x
}

function tc-mirror-vf
{
set -x
	offload="skip_sw"

	redirect=$rep2
	mirror=$rep1
	dest=$rep3

	TC=tc
	TC=/home1/chrism/iproute2/tc/tc

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

alias tmv=tc-mirror-vf
alias tmp=tc-mirror-pf


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

	TC=/home1/chrism/iproute2/tc/tc
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
	offload="skip_hw"

	[[ "$1" == "hw" ]] && offload="skip_sw"

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
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp parent ffff: flower skip_hw src_mac $src_mac dst_mac $dst_mac	\
		action vlan push id $vid		\
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp parent ffff: flower skip_hw src_mac $src_mac dst_mac $brd_mac	\
		action vlan push id $vid		\
		action mirred egress redirect dev $link

	src_mac=$remote_mac			# remote vm mac
	dst_mac=02:25:d0:$host_num:01:02	# local vm mac
	$TC filter add dev $link protocol 802.1Q parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac vlan_ethtype 0x800 vlan_id $vid vlan_prio 0	\
		action vlan pop				\
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol 802.1Q parent ffff: flower skip_hw src_mac $src_mac dst_mac $dst_mac vlan_ethtype 0x806 vlan_id $vid vlan_prio 0	\
		action vlan pop				\
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol 802.1Q parent ffff: flower skip_hw src_mac $src_mac dst_mac $brd_mac vlan_ethtype 0x806 vlan_id $vid vlan_prio 0	\
		action vlan pop				\
		action mirred egress redirect dev $redirect

set +x
}

alias tcv=tc-mirror-vlan-without
function tc-mirror-vlan-with
{
set -x
	offload="skip_hw"

	[[ "$1" == "hw" ]] && offload="skip_sw"

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

function tc-mirror-vlan-without
{
set -x
	offload="skip_hw"

	[[ "$1" == "hw" ]] && offload="skip_sw"

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
	$TC filter add dev $link protocol 802.1Q parent ffff: flower $offload src_mac $src_mac dst_mac $dst_mac vlan_ethtype 0x800 vlan_id $vid vlan_prio 0	\
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
	offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"
	offload="skip_sw"

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
	ethtool -K $vx  hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $mirror promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:$host_num:01:02
	remote_vm_mac=$vxlan_mac

	$TC filter add dev $redirect protocol ip  parent ffff: prio 1 flower skip_sw \
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
		action tunnel_key set	\
		src_ip $link_ip		\
		dst_ip $link_remote_ip	\
		dst_port $vxlan_port	\
		id $vni			\
		action mirred egress redirect dev $vx

	$TC filter add dev $vx protocol ip  parent ffff: prio 3 flower skip_hw \
		src_mac $remote_vm_mac \
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
		action mirred egress redirect dev $redirect
set +x
}

function tcx2
{
set -x
	offload="skip_hw"
	[[ "$1" == "hw" ]] && offload="skip_sw"

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
	ethtool -K $vx  hw-tc-offload on 

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $redirect ingress 
	$TC qdisc add dev $vx ingress 

	ip link set $link promisc on
	ip link set $redirect promisc on
	ip link set $mirror promisc on
	ip link set $vx promisc on

	local_vm_mac=02:25:d0:13:01:02
	remote_vm_mac=$vxlan_mac

	$TC filter add dev $redirect protocol ip  parent ffff: prio 1 flower skip_hw \
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

	$TC filter add dev $vx protocol ip  parent ffff: prio 3 flower $offload \
		src_mac $remote_vm_mac \
		enc_src_ip $link_remote_ip	\
		enc_dst_ip $link_ip		\
		enc_dst_port $vxlan_port	\
		enc_key_id $vni			\
		action tunnel_key unset		\
		action mirred egress redirect dev $redirect
	$TC filter add dev $vx protocol arp parent ffff: prio 4 flower skip_hw	\
		src_mac $remote_vm_mac \
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
	if (( old == 1 )); then
		echo "eth$1"
	else
		echo "${link}_$1"
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

alias set-mirror="ovs-vsctl -- --id=@p get port $rep1 -- --id=@m create mirror name=m0 select-all=true output-port=@p -- set bridge $br mirrors=@m"
alias set-mirror-dst="ovs-vsctl -- --id=@p get port $rep1 -- --id=@p2 get port $rep2  -- --id=@m create mirror name=m0 select-dst-port=@p2 output-port=@p -- set bridge $br mirrors=@m"
alias set-mirror-src="ovs-vsctl -- --id=@p get port $rep1 -- --id=@p2 get port $rep2  -- --id=@m create mirror name=m0 select-src-port=@p2 output-port=@p -- set bridge $br mirrors=@m"
alias set-mirror-all="ovs-vsctl -- --id=@p get port $rep1 -- --id=@p2 get port $rep2  -- --id=@m create mirror name=m0 select-dst-port=@p2 select-src-port=@p2 output-port=@p -- set bridge $br mirrors=@m"
alias set-mirror-vlan="ovs-vsctl -- --id=@p get port $rep1 -- --id=@p2 get port $rep2  -- --id=@m create mirror name=m0 select-dst-port=@p2 select-src-port=@p2 output-port=@p output-vlan=5 -- set bridge $br mirrors=@m"
alias clear-mirror="ovs-vsctl clear bridge $br mirrors"

alias set-mirror3="ovs-vsctl -- --id=@p get port $rep3 -- --id=@m create mirror name=m0 select-all=true output-port=@p -- set bridge $br mirrors=@m"

function mirror-br
{
set -x
	local rep
	ovs-vsctl add-br $br
# 	ovs-vsctl add-port $br $vx -- set interface $vx type=vxlan options:remote_ip=$link_remote_ip options:key=$vni

	ip link set $rep1 up
	ovs-vsctl add-port $br $rep1	\
	    -- --id=@p get port $rep1	\
	    -- --id=@m create mirror name=m0 select-all=true output-port=@p \
	    -- set bridge $br mirrors=@m

	for (( i = 1; i < numvfs; i++)); do
		rep=$(get_rep $i)
# 		vs add-port $br $rep tag=$vid
		vs add-port $br $rep
		ip link set $rep up
	done
	vs add-port $br $link

# 	ovs-vsctl add-port $br $rep1 tag=$vid\
# set +x
# 	return

# 	ovs-ofctl add-flow $br 'nw_dst=1.1.1.14 action=drop'
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
#  	ovs-vsctl add-port $br $rep1 tag=$vid\
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

alias brv='create-br vlan'
alias br='create-br nomal'
alias brx='create-br vxlan'

function create-br
{
set -x
	[[ $# != 1 ]] && return
	local rep
	vs del-br $br
	vs add-br $br
	[[ "$1" == "vxlan" ]] && vxlan1 || vs add-port $br $link
	[[ "$1" == "vlan" ]] && tag="tag=$vid" || tag=""
	for (( i = 1; i < numvfs; i++)); do
		rep=$(get_rep $i)
		vs add-port $br $rep $tag
		ip link set $rep up
	done
        vs add-port $br $rep1 $tag
#         vs add-port $br $rep1 $tag
set +x
}

# rep=$(eval echo '$'rep"$i")
function del-br
{
set -x
	for (( i = 0; i < numvfs; i++)); do
		rep=$(get_rep $i)
		rep=${link}_$i
		vs del-port $rep
	done

	vs del-br $br
	vs del-port $link
	ip l d $vx_rep
	ip l d dummy0 > /dev/null 2>&1
set +x
}

function del_ovs2
{
set -x
	vs del-port $br vnet1
	vs del-port $br vnet3
	vs del-br $br

	brctl delif virbr0 vnet1
	brctl delif virbr0 vnet3
set +x
}

function start_ovs2
{
set -x
	vs add-br $br

	vs add-port $br vnet1
	vs add-port $br vnet3
set +x
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

function get_vfname
{
	local l
	local n
	local p
	local linkp
	l=$1
	n=$2
	p=$3
	local m=8
	linkp=$(echo $l | cut -d '0' -f 1)

	# for one port cx5 card
	if (( host_num == 13 )); then
		if (( p == 1 )); then
			if (( n >= 0 && n <= 5)); then
				echo ${linkp}0f$((n+2))
				return
			fi
			s=$(((n+2)/m))
			f=$(((n+2)%m))
			if (( f != 0 )); then
				echo ${linkp}${s}f$f
			else
				echo ${linkp}${s}
			fi
		fi
	fi

	# for one port cx4lx card
	if (( host_num == 14 )); then
		if (( p == 1 )); then
			if (( n >= 0 && n <= 5)); then
				echo ${linkp}0f$((n+1))
				return
			fi
			s=$(((n+2)/m))
			f=$(((n+1)%m))
			if (( f != 0 )); then
				echo ${linkp}${s}f$f
			else
				echo ${linkp}${s}
			fi
		fi
	fi

	if (( host_num == 13 )); then
		local delta=1
	elif (( host_num == 14 )); then
		local delta=2
	fi
	if (( p == 2 )); then
# 		for max_vf = 127
		s=$(((n+1)/m+16))
		f=$(((n+1)%m))

#		for max_vf = 16, ecmp
# 		s=$(((n+1)/m+delta))
# 		f=$(((n+1)%m+1))
		if (( f != 0 )); then
			echo ${linkp}${s}f$f
		else
			echo ${linkp}${s}
		fi
	fi
}

alias vf-test="for (( i = 0; i < 50; i++)); do echo -n $i; echo -n \" \"; vf $i; done"
alias vf-test2="for (( i = 0; i < 4; i++)); do echo -n $i; echo -n \" \"; vf $i; done"

# 1472
function netns
{
	local n=$1 link=$2 ip=$3
	ip netns del $n 2>/dev/null
	ip netns add $n
	ip link set dev $link netns $n
	ip netns exec $n ifconfig $link mtu 1450
	ip netns exec $n ip link set dev $link up
	ip netns exec $n ip addr add $ip/24 brd + dev $link
# 	ip netns exec $n ip r a 2.2.2.0/24 nexthop via 1.1.1.1 dev $link
}

# rep=$(eval echo '$'rep"$i")
function set_netns_all
{
	local vfn
	local ip
	local i
	local p=$1
	local start

	echo
	echo "start set_netns_all"
	if (( p == 1 )); then
		ns_ip=1.1.$host_num
		ns_ip=1.1.1
		start=21
	elif (( p == 2 )); then
		ns_ip=1.1.$((host_num+10))
		ns_ip=1.1.1
		start=121
	fi

	for (( i = 1; i < numvfs; i++)); do
		ip=${ns_ip}.$((i+start))
		vfn=$(get_vfname $l $i $p)
		echo "vf${i} name: $vfn, ip: $ip"
		netns n${p}${i} $vfn $ip
	done
	echo "end set_netns_all"
}

function up_all_reps
{
	local rep
	for (( i = 0; i < numvfs; i++)); do
		rep=${link}_$i
		ifconfig $rep up
		if (( ecmp == 1 )); then
			ovs-vsctl add-port br-vxlan $rep
		fi
	done
}

function hw_tc_all
{
	local rep
	ethtool -K $link hw-tc-offload on
	for (( i = 0; i < numvfs; i++)); do
		rep=${link}_$i
		ethtool -K $rep hw-tc-offload on
	done
}

function start_vm_all
{
	n=$numvfs
	[[ $# == 1 ]] && n=$1

	for (( i = 1; i <= n ; i++)); do
		virsh start vm$i
	done
}

alias ns1="netns n1 $vf1 $ns_ip1"
alias ns2="netns n2 $vf2 $ns_ip2"

alias exe=' ip netns exec'
alias n0='exe n0'
alias n1='exe n1'
alias n2='exe n2'
alias n3='exe n3'
alias n4='exe n4'

alias n='exe link2 bash'

alias n0='exe n10'
alias n1='exe n11'
alias n2='exe n12'

alias n20='exe n20'
alias n21='exe n21'

alias leg='start-switchdev legacy'
alias start='start-switchdev vm'
alias start='start-switchdev-all'
alias start-vm='start-switchdev 1 vm'
alias start-vf='start-switchdev vf'
alias start-bind='start-switchdev bind'
alias restart='off; start'
alias mystart=start-switchdev-all
function start-switchdev
{
	local p=$1
	echo "=========== port $p =========="
	local l
	local pci_addr
	if (( p == 1 )); then
		l=$link
		pci_addr=$pci
		mac_prefix="02:25:d0:$host_num:$p"
	elif (( p == 2 )); then
		l=$link2
		pci_addr=$pci2
		mac_prefix="02:25:d0:$host_num:$p"
	fi
	echo "link: $l"
	mac_vf=1
	mode=switchdev
	link_mode=transport

	echo $numvfs > /sys/class/net/$l/device/sriov_numvfs

	# echo "Set mac: "
	for vf in `ip link show $l | grep "vf " | awk {'print $2'}`; do
		local mac_addr=$mac_prefix:$mac_vf
		echo "vf${vf} mac address: $mac_addr"
		ip link set $l vf $vf mac $mac_addr
		((mac_vf=mac_vf+1))
	done

	unbind_all $l
	if [[ "$1" != "legacy" ]]; then
		echo "enable switchdev mode for: $pci_addr"
		if (( old == 0 )); then
			devlink dev eswitch set pci/$pci_addr mode switchdev
			devlink dev eswitch set pci/$pci_addr inline-mode transport;
			devlink dev eswitch set pci/$pci_addr encap enable
		else
			echo switchdev >  /sys/kernel/debug/mlx5/$pci_addr/compat/mode || echo "switchdev failed"
			echo transport >  /sys/kernel/debug/mlx5/$pci_addr/compat/inline 2>/dev/null|| echo "transport failed"
			echo basic >  /sys/kernel/debug/mlx5/$pci_addr/compat/encap || echo "baisc failed"
		fi

		ip1
# 	else
# 		return
	fi

	if (( old == 0 )); then
		up_all_reps
		hw_tc_all
	fi

	if [[ "$1" == "vf" ]]; then
		set +x
		return
	fi

	if [[ "$1" == "bind" ]]; then
		bind_all
		ifconfig $vf1 1.1.1.2/16 up
		ifconfig $vf2 up
		set +x
		return
	fi

	if [[ "$2" == "vm" ]]; then
		del-br
		start1
		start2
# 		ifconfig $rep1 1.1.1.2/24 up
# 		start_vm_all 1
		set +x
		return
	fi

	bind_all $l
	set_netns_all $p

	ifconfig $vf1 up

	iptables -F
	iptables -Z
	iptables -X

# 	ifconfig $rep1 1.1.1.5/24 up

	return
}

function start-switchdev-all
{
# 	enable-multipath
	for i in 1; do
		start-switchdev $i
	done
# 	brx
# 	add-reps
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
# 	echo 0 > /sys/class/net/$link/device/sriov_numvfs
}

function grub
{
set -x
	[[ $# == 0 ]] && kernel=0 || kernel=$1
	file=/etc/default/grub
	sudo sed -i '/GRUB_DEFAULT/d' $file
# 	sudo echo "GRUB_DEFAULT=\"CentOS Linux ($kernel) 7 (Core)\"" >> $file
	sudo echo "GRUB_DEFAULT=$kernel" >> $file

	sudo grub2-mkconfig -o /boot/grub2/grub.cfg

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
# export PS1="$__first_color\u$GREEN@\h $RED_BOLD\W $BLUE\$(parse_git_branch)\$(parse_svn_branch)$BLUE\\$ \${?##0} $BLACK"
# unset __first_color
# export PS1="$GREEN\u@\h $RED_BOLD\W $BLUE\$(parse_git_branch)\$(parse_svn_branch)$BLACK\$ "

# export PROMPT_COMMAND=__prompt_command

function __prompt_command() {
    local EXIT="$?"
    if [ "$EXIT" = 0 ]; then
        EXIT=""
    fi

    PS1="$__first_color\u$GREEN@\h $RED_BOLD\W $BLUE\$(parse_git_branch)\$(parse_svn_branch)$BLUE\\$ $EXIT $BLACK"
}

(( "$UID" == 0 )) && PS1="[\u@\h \W]# "
(( "$UID" == 0 )) && PS1="\e[0;31m[\u@\h \W]# \e[0m"      # set background=light
(( "$UID" == 0 )) && PS1="\e[1;31m[\u@\h \W]# \e[0m"      # set background=dark
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

function tc-show
{
	[[ $# == 0 ]] && local link=$link || local link=$1
	tc -s filter show dev $link ingress
}

function tc-insert
{
	[[ $# == 0 ]] && return
	local dir=$1
	local link=$link
	cd /root/tc
	TC=tc
	$TC qdisc del dev $link ingress
	$TC qdisc add dev $link ingress

set -x
	time for file in $dir/*; do
		$TC -b $file
	done
set +x
}

function scp1
{
	[[ $# == 0 ]] && return
	if [[ $# == 1 ]]; then
		d1=$1
		d2=/labhome/chrism
	fi
	if [[ $# == 2 ]]; then
		d1=$1
		d2=$2
	fi
set -x
	scp -r $d1 chrism@localhost:$d2
set +x
}

function scp2
{
	[[ $# != 1 ]] && return
set -x
	scp -r chrism@10.12.68.111:$1 .
set +x
}

function grepm
{
	[[ $# == 0 ]] && return
	sm1
	git grep "$1" drivers/net/ethernet/mellanox/mlx5/core
}

function grepm2
{
	[[ $# == 0 ]] && return
	sm1
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
		$cmd new -d -n n1 -s $session
		$cmd neww -n n2
		$cmd neww -n linux
		$cmd neww -n build
		$cmd neww -n patch
		$cmd neww -n live
		$cmd neww -n stm
		$cmd neww -n bash
		$cmd neww -n bash	# 8
	fi

	$cmd att -t $session
}

function lns
{
	ln -s ~chrism/.vim
	ln -s ~chrism/.virc
	ln -s ~chrism/.screenrc
	ln -s ~chrism/.tmux.conf
}

function tc-start
{
	tc qdisc add dev $link ingress
	ethtool -K $link hw-tc-offload on
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
	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
	TC=/home1/chrism/iproute2/tc/tc
	TC=tc
# 	tc filter change  dev $link prio 1 protocol ip handle 1 parent ffff: flower skip_hw src_mac e4:11:0:0:0:4 dst_mac e4:12:0:0:0:4 action drop
	$TC filter change dev $link prio 1 protocol ip handle 1 parent ffff: flower skip_hw src_mac e4:11:00:00:00:04 dst_mac e4:12:00:00:00:04 action drop
}

function tcm
{
# 	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
# 	tc2
	TC=tc
	tc qdisc delete dev $link ingress > /dev/null 2>&1
	sudo $TC qdisc add dev $link ingress
	sudo $TC filter add  dev $link prio 1 protocol ip handle 0x80000001 parent ffff: flower skip_hw src_mac e4:11:0:0:0:2 dst_mac e4:12:0:0:0:2 action drop
# 	sudo $TC filter add  dev $link prio 1 protocol ip handle 0x4 parent ffff: flower skip_hw src_mac e4:11:0:0:0:4 dst_mac e4:12:0:0:0:4 action drop
# 	sudo tc filter add  dev $link prio 1 protocol ip handle 2 parent ffff: flower skip_hw src_mac e4:11:0:0:0:2 dst_mac e4:12:0:0:0:2 action drop
	sudo $TC filter show dev $link parent ffff:
}

function tcm2
{
# 	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
# 	tc2
	TC=tc
	sudo $TC qdisc add dev $link ingress
	sudo $TC filter add  dev $link prio 1 protocol ip handle 0x4 parent ffff: flower skip_hw src_mac e4:11:0:0:0:4 dst_mac e4:12:0:0:0:4 action drop
# 	sudo tc filter add  dev $link prio 1 protocol ip handle 2 parent ffff: flower skip_hw src_mac e4:11:0:0:0:2 dst_mac e4:12:0:0:0:2 action drop
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

alias kn='killall noodle'

function tc-setup
{
	tc qdisc add dev $link ingress
	ethtool -K $link hw-tc-offload on
}

function tc-setup2
{
	ns=n1
	ip netns add $ns
	ip link set dev $link netns $ns
	ip netns exec $ns tc qdisc add dev $link ingress
	ip netns exec $ns ethtool -K $link hw-tc-offload on
	ip netns exec $ns ip l
	time ip netns exec $ns tc -b /root/tc_batch.txt
	time ip netns exec $ns tc qdisc del dev $link ingress
	ip netns del $ns
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

function tca1
{
set -x
	TC=tc
	TC=/home1/chrism/iproute2/tc/tc
	time $TC action add action ok index 1 action ok index 2 action ok index 3
	$TC action ls action gact
	$TC actions flush action gact
set +x
}

function tca3
{
set -x
	TC=/home1/chrism/iproute2/tc/tc
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
# 	sudo tc filter add  dev $link prio 1 protocol ip handle 2 parent ffff: flower skip_hw src_mac e4:11:0:0:0:2 dst_mac e4:12:0:0:0:2 action drop
set +x
}

# change action
function tcca
{
	tc filter change  dev $link prio 1 protocol ip handle 1 parent ffff: flower skip_hw src_mac e4:11:0:0:0:0 dst_mac e4:12:0:0:0:0 action pass
}

function tca
{
set -x
	[[ $# == 0 ]] && n=1 || n=$1

	file=/tmp/a.txt

	TC=tc.orig
	tc=tc
	TC=/home1/chrism/iproute2/tc/tc

# 	$linux_dir/tools/testing/selftests/tc-testing/tdc_batch.py -n $n $link $file

	sudo ~chrism/bin/tdc_batch_act.py -n $n $file
	time $TC -b $file
# 	$TC action ls action gact
	$TC actions flush action gact
set +x
}

function tca2
{
set -x
	TC=tc.orig
	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
	TC=/home1/chrism/iproute2/tc/tc

	$TC actions flush action gact
	$TC actions add action pass index 1
	$TC actions list action gact
	$TC actions get action gact index 1
# 	$TC actions del action gact index 1
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

	TC=/home1/chrism/iproute2/tc/tc
	TC=tc

# 	$linux_dir/tools/testing/selftests/tc-testing/tdc_batch.py -n $n $link $file

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
	TC=/home1/chrism/iproute2/tc/tc
	TC=tc

	sudo $TC qdisc del dev $link ingress > /dev/null 2>&1
	sudo $TC qdisc add dev $link ingress
	sudo ethtool -K $link hw-tc-offload on
# 	$linux_dir/tools/testing/selftests/tc-testing/tdc_batch.py -n $n $link $file
# 	sudo ~chrism/bin/tdc_batch.py -s -n $n $link $file	# for software only
	sudo ~chrism/bin/tdc_batch.py -o -n $n $link $file
	time $TC -b $file
# 	sudo $TC filter show dev $link parent ffff:
set +x
}

function tcd
{
set -x
	[[ $# == 0 ]] && n=1 || n=$1

	file=/tmp/d.txt

	TC=tc
	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
	TC=/home1/chrism/iproute2/tc/tc

# 	$linux_dir/tools/testing/selftests/tc-testing/tdc_batch.py -n $n $link $file
# 	sudo ~chrism/bin/tdc_batch.py -s -n $n $link $file
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
	TC=/home1/chrism/iproute2/tc/tc

	sudo $TC qdisc del dev $link ingress > /dev/null 2>&1
# 	sudo $TC qdisc add dev $link ingress
# 	$linux_dir/tools/testing/selftests/tc-testing/tdc_batch.py -n $n $link $file
# 	sudo ~chrism/bin/tdc_batch.py -s -n $n $link $file
	time $TC -b $file
# 	sudo $TC filter show dev $link parent ffff:
set +x
}



# [root@bjglab-18 ~]# dp dump-flows system@ovs-system
# in_port(1),eth(src=02:25:d0:e2:18:50,dst=0a:5e:73:d8:72:45),eth_type(0x0800), packets:26, bytes:3848, used:0.180s, actions:set(tunnel(tun_id=0x1,dst=192.168.1.19,tp_dst=4789,flags(key))),2
# in_port(1),eth(src=02:25:d0:e2:18:50,dst=0a:5e:73:d8:72:45),eth_type(0x0806), packets:0, bytes:0, used:5.300s, actions:set(tunnel(tun_id=0x1,dst=192.168.1.19,tp_dst=4789,flags(key))),2
# tunnel(tun_id=0x1,src=192.168.1.19,dst=192.168.1.18,flags(+key)),in_port(2),eth(src=0a:5e:73:d8:72:45,dst=02:25:d0:e2:18:50),eth_type(0x0800), packets:27, bytes:2646, used:0.180s, actions:1
# tunnel(tun_id=0x1,src=192.168.1.19,dst=192.168.1.18,flags(+key)),in_port(2),eth(src=0a:5e:73:d8:72:45,dst=02:25:d0:e2:18:50),eth_type(0x0806), packets:0, bytes:0, used:5.300s, actions:1

# ovs-dpctl add-dp dp1
# ovs-dpctl del-dp dp1

dp=system@ovs-system
dp=system@dp1
function dp-test
{
set -x
	ovs-dpctl add-flow $dp \
		"in_port(1),eth(),eth_type(0x800),\
		ipv4(src=1.1.1.1,dst=2.2.2.2)" 2
	ovs-dpctl dump-flows $dp
# 	ovs-dpctl del-flow $dp \
# 		"in_port(1),eth(),eth_type(0x800),\
# 		ipv4(src=1.1.1.1,dst=2.2.2.2)j
# 	ovs-dpctl dump-flows $dp
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
	local bin=$1
# 	gdb -batch $(which $bin) $(pgrep $bin) -x ~chrism/g.txt
	$GDB $(which $bin) $(pgrep $bin)
}

alias g='gdb1 ovs-vswitchd'

function vsconfig0
{
	ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"
	ovs-vsctl set Open_vSwitch . other_config:tc-policy=skip_hw
# 	ovs-vsctl set Open_vSwitch . other_config:max-idle=600000 # (10 minutes) 
	sudo systemctl restart openvswitch.service
	vsconfig
}

function vsconfig1
{
	ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"
	ovs-vsctl set Open_vSwitch . other_config:tc-policy=skip_sw
# 	ovs-vsctl set Open_vSwitch . other_config:max-idle=600000 # (10 minutes) 
	sudo systemctl restart openvswitch.service
	vsconfig
}

function vsconfig2
{
	ovs-vsctl remove Open_vSwitch . other_config hw-offload
	ovs-vsctl remove Open_vSwitch . other_config tc-policy
	ovs-vsctl remove Open_vSwitch . other_config max-idle
	sudo systemctl restart openvswitch.service
	vsconfig
}

function burn5
{
set -x
	version=fw-4119-rel-16_21_2030
	version=last_revision
	mkdir -p /mswg/
	sudo mount 10.4.0.102:/vol/mswg/mswg /mswg/
	yes | sudo mlxburn -d $pci -fw /mswg/release/fw-4119/$version/fw-ConnectX5.mlx -conf_dir /mswg/release/fw-4119/$version
	sudo mlxfwreset -d $pci reset
set +x
}

function burn4
{
set -x
	version=fw-4117-rel-14_22_1034
	version=last_revision
	mkdir -p /mswg/
	sudo mount 10.4.0.102:/vol/mswg/mswg /mswg/
	yes | sudo mlxburn -d $pci -fw /mswg/release/fw-4117/$version/fw-ConnectX4Lx.mlx -conf_dir /mswg/release/fw-4117/$version
	sudo mlxfwreset -d $pci reset
set +x
}



function git-patch
{
	[[ $# != 2 ]] && return
	local dir=$1
	local n=$2
	mkdir -p $dir
	git format-patch -o $dir -$n HEAD
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
patch_dir=~/batch/review12
alias smp="cd $patch_dir"
alias smp2="cd $patch_dir2"

# Jamal Hadi Salim <jhs@mojatatu.com>
# Lucas Bates <lucasb@mojatatu.com>

function git-format-patch
{
	[[ $# != 1 ]] && return
# 	git format-patch --cover-letter --subject-prefix="INTERNAL RFC net-next v9" -o $patch_dir -$1
# 	git format-patch --cover-letter --subject-prefix="patch net-next" -o $patch_dir -$1
# 	git format-patch --cover-letter --subject-prefix="patch net-next internal v11" -o $patch_dir -$1
# 	git format-patch --cover-letter --subject-prefix="patch net internal" -o $patch_dir -$1
	git format-patch --cover-letter --subject-prefix="patch iproute2 v10" -o $patch_dir -$1
}

#
# please make sure the subject is correct, patch net-next 0/3...
#
function git-send-email
{
# 	file=~/idr/m/4.txt
	file=/labhome/chrism/net/email.txt
	script=~/bin/send.sh

	echo "#!/bin/bash" > $script
	echo >> $script
	echo "git send-email $patch_dir/* --to=netdev@vger.kernel.org \\" >> $script

	cat $file | while read line; do
		echo "    --cc=$line \\" >> $script
	done

	echo "    --suppress-cc=all" >> $script
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

	echo "    --cc=mi.shuang@qq.com \\" >> $script
# 	cat $file | while read line; do
# 		echo "    --cc=$line \\" >> $script
# 	done

	echo "    --suppress-cc=all" >> $script
	chmod +x $script
}



function panic
{
	echo 1 > /proc/sys/kernel/sysrq
	echo c > /proc/sysrq-trigger
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
# 	ovs-add-flow "in_port(2),eth_type(0x800),eth(src=11:22:33:44:55:66)"
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
	ip link add name $vx type vxlan id $vni dev $link  remote $link_remote_ip dstport 4789
	ifconfig $vx $link_ip_vxlan/16 up
	ip link set $vx address $vxlan_mac

# 	ip link set vxlan0 up
# 	ip addr add 1.1.1.2/16 dev vxlan0
# 	ip addr add fc00:0:0:0::2/64 dev vxlan0
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

# 	ip link set vxlan0 up
# 	ip addr add 1.1.1.2/16 dev vxlan0
# 	ip addr add fc00:0:0:0::2/64 dev vxlan0
set +x
}

function peer2
{
set -x
	ip netns exec link2 ip link set $link2 netns 1
# 	ip link del $vx > /dev/null 2>&1
set +x
}



alias e1="enable-tcp-offload $link"
alias d1="disable-tcp-offload $link"

function restart-of
{
	ovs-ofctl del-flows $br
	systemctl restart openvswitch.service
}

function rule2
{
set -x
	ovs-ofctl add-flow $br in_port=10,dl_src=02:25:d0:e2:14:51,dl_dst=02:25:d0:e2:14:50,action=9
set +x
}

function rule
{
set -x
	rep1_port=6
	rep2_port=7
	br_port=3

	vf1_mac=02:25:d0:e2:14:00
	vf2_mac=02:25:d0:e2:14:01

	pf_mac=24:8a:07:88:27:ca

	ovs-ofctl del-flows $br
	restart-ovs
	ovs-ofctl add-flow $br in_port=$br_port,dl_src=$pf_mac,dl_dst=$vf1_mac,action=$rep1_port
	ovs-ofctl add-flow $br in_port=$br_port,dl_src=$pf_mac,dl_dst=$vf2_mac,action=$rep2_port
	ovs-ofctl dump-flows $br
set +x
}

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
set -x
	sm1
	cd ./samples/pktgen
	./pktgen_sample01_simple.sh -i $link -s 1 -m 02:25:d0:e2:14:00 -d 1.1.1.1 -t 1 -n 0
set +x
}

function pktgen1
{
set -x
	sm1
	cd ./samples/pktgen
	./pktgen_sample02_multiqueue.sh -i $link -s 1 -m 02:25:d0:e2:14:50 -d 1.1.1.1 -t 2 -n 0
set +x
}

function pktgen2
{
set -x
	sm1
	cd ./samples/pktgen
	./pktgen_sample02_multiqueue2.sh -i $link -s 1 -m 02:25:d0:e2:14:01 -d 1.1.1.2 -t 1 -n 0
set +x
}

# virsh net-edit default

#       <host mac='52:54:00:13:01:01' name='vm1' ip='192.168.122.11'/>
#       <host mac='52:54:00:13:01:02' name='vm2' ip='192.168.122.12'/>

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
set -x
	for ((i = 0; i < n; i++)); do
		commit=$(git slog -2 | cut -d ' ' -f 1  | sed -n '2p')
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

dir1=~/1
function save
{
	sm1
	/bin/cp -f include/net/act_api.h $dir1
	/bin/cp -f net/sched/act_api.c $dir1
}

function restore
{
	sm1
	/bin/cp -f $dir1/act_api.h include/net/act_api.h
	/bin/cp -f $dir1/act_api.c net/sched/act_api.c
}

function install-libevent
{
	version=2.1.8-stable
	libevent=libevent-$version
	sm
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

function install-tmux
{
	sm
	cd tmux
	CFLAGS="-I/usr/local/include/libevent" LDFLAGS="-L/usr/local/lib64/libevent" ./configure --prefix=/usr/local/tmux/2.0
	make
	sudo make install
	sudo alternatives --install /usr/local/bin/tmux tmux /usr/local/tmux/2.0/bin/tmux 10600
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
# 	/mswg/release/mft/latest/install.sh
	/mswg/release/mft/mftinstall
}

function mlxconfig-enable-sriov
{
	[[ $# != 1 ]] && return
	mlxconfig -d $1 set SRIOV_EN=1 NUM_OF_VFS=8
# 	mlxconfig -d $1 set SRIOV_EN=1 NUM_OF_VFS=8 LINK_TYPE_P1=2 LINK_TYPE_P2=2
}

alias krestart='systemctl restart kdump'
alias kstatus='systemctl status kdump'
alias kstop='systemctl stop kdump'
alias kstart='systemctl start kdump'
function kexec1
{
	ver=$(uname -r)
	/sbin/kexec -p "--command-line=BOOT_IMAGE=/vmlinuz-${ver}							\
		root=/dev/mapper/centos-root ro rd.lvm.lv=centos/root rd.lvm.lv=centos/swap intel_iommu=on irqpoll	\
		nr_cpus=1 reset_devices cgroup_disable=memory mce=off numa=off udev.children-max=2 panic=10		\
		rootflags=nofail acpi_no_memhotplug transparent_hugepage=never disable_cpu_apicid=0"			\
		--initrd=/boot/initramfs-${ver}kdump.img /boot/vmlinuz-$ver
}

# kexec -l kernel.img --reuse-initrd --reuse-cmdline

function fast-reboot
{
	pgrep vim && return
	ver=$(uname -r)
	if [[ $# == 1 ]]; then
		ver=$1
	fi
	echo "kexec -l /boot/vmlinuz-${ver} --append="$(cat /proc/cmdline)" --initrd=/boot/initramfs-${ver}.img"
	sudo kexec -l /boot/vmlinuz-${ver} --append="$(cat /proc/cmdline)" --initrd=/boot/initramfs-${ver}.img
	sudo kexec -e
}

function fast-reboot-dry
{
	ver=$(uname -r)
	if [[ $# == 1 ]]; then
		ver=$1
	fi
	echo "kexec -l /boot/vmlinuz-${ver} --append="$(cat /proc/cmdline)" --initrd=/boot/initramfs-${ver}.img"
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

function udev
{
	local file=/etc/udev/rules.d/82-net-setup-link.rules
	local id=$(ip -d link show $link | grep switchid | awk '{print $NF}')
	if [[ -z $id ]]; then
		echo "Please enable switchdev mode"
		return
	fi
# 	echo $id
	cat << EOF > $file
SUBSYSTEM=="net", ACTION=="add", ATTR{phys_switch_id}=="$id", \
ATTR{phys_port_name}!="", NAME="${link}_\$attr{phys_port_name}"
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
# 		(( i == 13 )) && continue
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
# 		(( i == 13 )) && continue
		$mac_ns ip link delete link dev $newlink
	done
}

function ping-all
{
	for ((i = mac_start; i <= mac_end; i++)); do
		ping 1.1.1.$i &
	done
}

function brctl-virbr
{
	for (( i = 0; i < 2; i++)); do
		brctl delif br2 vnet$i
	done
	for (( i = 0; i < 2; i++)); do
		brctl addif br0 vnet$i
	done
}

function vcpu
{
	[[ $# != 1 ]] && return
	n=$1

	for (( i = 0; i < n; i++)); do
		echo "    <vcpupin vcpu='$i' cpuset='$((i*2))'/>"
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

function natan
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
		-hda /var/lib/libvirt/images/vm1-1.qcow2	\
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

# ip r replace 8.2.10.0/24 nexthop via 7.1.10.1 dev $link nexthop via 7.2.10.1  dev $link2
# ip r replace 7.1.10.0/24 nexthop via 8.2.10.1 dev $link
# ip r replace 7.2.10.0/24 nexthop via 8.2.10.1 dev $link

function enable-multipath
{
	if (( old == 0 )); then
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

HOST1_TUN_NET=`getnet $HOST1_TUN/24`
HOST2_TUN_NET=`getnet $HOST2_TUN/24`

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

function add-reps
{
	for rep in enp4s0f0_0 enp4s0f0_1  enp4s0f1_0 enp4s0f1_1; do
		ifconfig $rep up
		ovs-vsctl add-port br-vxlan $rep
	done

	systemctl restart openvswitch.service
}

function add-reps2
{
	for rep in enp4s0f0_0 enp4s0f0_1 enp4s0f0_2; do
		ifconfig $rep up
		ovs-vsctl add-port br-vxlan $rep
	done

	for rep in enp4s0f1_0 enp4s0f1_1 enp4s0f1_2; do
		ifconfig $rep up
		ovs-vsctl add-port br-vxlan2 $rep
	done

	systemctl restart openvswitch.service
}

function del-reps2
{
	for rep in enp4s0f0_0 enp4s0f0_1 enp4s0f0_2; do
		ifconfig $rep up
		ovs-vsctl del-port br-vxlan $rep
	done

	for rep in enp4s0f1_0 enp4s0f1_1 enp4s0f1_2; do
		ifconfig $rep up
		ovs-vsctl del-port br-vxlan2 $rep
	done

	systemctl restart openvswitch.service
}

function del-reps
{
	for rep in enp4s0f0_0 enp4s0f0_1  enp4s0f1_0 enp4s0f1_1; do
		ovs-vsctl del-port br-vxlan $rep
	done

	systemctl restart openvswitch.service
}

alias lag="cat /sys/kernel/debug/mlx5/$pci/lag_affinity"
alias lag0="echo 0 > /sys/kernel/debug/mlx5/$pci/lag_affinity"
alias lag1="echo 1 > /sys/kernel/debug/mlx5/$pci/lag_affinity"
alias lag2="echo 2 > /sys/kernel/debug/mlx5/$pci/lag_affinity"

alias show-links="ip link show dev $link; ip link show dev $link2"

function r0
{
	cmd_on $HOST1 "ip r d $HOST2_TUN_NET"
	cmd_on $HOST1 "ip r a $HOST2_TUN_NET nexthop via $R1_P2_IP dev $HOST1_P2 weight 1 nexthop via $R1_P1_IP dev $HOST1_P1 weight 1"
}

function r1
{
	cmd_on $HOST1 "ip r d $HOST2_TUN_NET"
	cmd_on $HOST1 "ip r a $HOST2_TUN_NET nexthop via $R1_P1_IP dev $HOST1_P1 weight 1"
}

function r2
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

function unbind1
{
	echo 0000:04:00.2 >  /sys/bus/pci/drivers/mlx5_core/unbind
	echo 0000:04:00.3 >  /sys/bus/pci/drivers/mlx5_core/unbind
}
function bind1
{
	echo 0000:04:00.2 >  /sys/bus/pci/drivers/mlx5_core/bind
	echo 0000:04:00.3 >  /sys/bus/pci/drivers/mlx5_core/bind
}
function on1
{
	echo 2 > /sys/class/net/$link/device/sriov_numvfs
}
function dev1
{
	echo switchdev > /sys/kernel/debug/mlx5/$pci/compat/mode
}
#         echo legacy > /sys/kernel/debug/mlx5/$pci/compat/mode
#         echo switchdev > /sys/kernel/debug/mlx5/$pci/compat/mode
#         echo legacy > /sys/kernel/debug/mlx5/$pci/compat/mode


function test2
{
	echo "Turn ON SR-IOV on the PF devic."
        echo 2 > /sys/class/net/$link/device/sriov_numvfs

	echo "Restart Open vSwtich service."
        service openvswitch restart

	echo "Create an OVS instance (here we name it ovs-sriov)."
        ovs-vsctl set Open_vSwitch . other_config:hw-offload=true
        ovs-vsctl -- add-br ovs-sriov                            

	echo "Unbind the VFs."
        echo 0000:04:00.2 >  /sys/bus/pci/drivers/mlx5_core/unbind
        echo 0000:04:00.3 >  /sys/bus/pci/drivers/mlx5_core/unbind

	echo "Change the e-switch mode from legacy to OVS offloads on the PF device."
        echo switchdev > /sys/kernel/debug/mlx5/$pci/compat/mode
	echo "Change the e-switch mode to legacy on the PF device."
        echo legacy > /sys/kernel/debug/mlx5/$pci/compat/mode
}

function add-br2
{
	vs add-br br-port2
	vs add-port br-port2 enp4s0f1_0
	vs add-port br-port2 enp4s0f1_1
	vs add-port br-port2 enp4s0f1_2
	restart-ovs
}

alias centos="cd /root/rpmbuild/BUILD/kernel-3.10.0-327.36.3.el7/linux-3.10.0-327.36.3.el7.x86_64; cscope -d"
alias n1p23='n1 ping 1.1.1.23'

function restart-arp
{
	restart-ovs
	/root/bin/ovs-arp-responder.sh
}

function grepf
{
	[[ $# != 1 ]] && return
	id=`echo $1 | sed "s/0x//"`
	echo $id
	grep -i $id /root/syndrome_list.log
}

function grep4
{
	[[ $# != 1 ]] && return
	id=`echo $1 | sed "s/0x//"`
	echo $id
	grep -i $id /root/cx4lx-syndrome_list.log
}
