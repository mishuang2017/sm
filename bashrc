# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

numvfs=2
port=1
vni=200
vni=100
vid=50
vxlan_port=4789
vxlan_mac=24:25:d0:e2:00:00

# Append to history
shopt -s histappend
oldkernel=0
uname -r | grep 3.10 > /dev/null 2>&1 && oldkernel=1

if [[ "$UID" == "0" ]]; then
	dmidecode | grep "Red Hat" > /dev/null 2>&1
	rh=$?
fi

if [[ "$(hostname -s)" == "bjglab-18" ]]; then
	host_num=18
elif [[ "$(hostname -s)" == "bjglab-19.internal.tilera.com" ]]; then
	host_num=19
elif [[ "$(hostname -s)" == "bc-vnc02" ]]; then
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

export DISPLAY=MTBC-CHRISM:0.0
export DISPLAY=:0.0

nfs_dir='/auto/mtbcswgwork/chrism'

if (( host_num == 9 )); then
	link=ens9
fi
if (( host_num == 13 )); then
	if (( port == 1 )); then
		link=enp4s0f0
		link2=enp4s0f1
		link_ip=192.168.1.13
		link_ip_vlan=1.1.1.13
		link_ip_vxlan=1.1.1.13
		link_remote_ip=192.168.1.14

		br=br1
		vx=vxlan0
	fi
	if (( port == 2 )); then
		link=enp4s0f1
		link_ip=192.168.2.13
		link_remote_ip=192.168.2.14

		br=br2
		vx=vxlan1
	fi


	ns_ip1=1.1.1.3
	ns_ip2=1.1.1.4
	ns_ip=1.1.$host_num

	vf1=enp4s0f2
	vf2=enp4s0f3

	if (( oldkernel == 0 )); then
		rep1=${link}_0
		rep2=${link}_1
	else
		rep1=eth0
		rep2=eth1
	fi

	link_mac=24:8a:07:88:27:ca
	link_mac2=24:8a:07:88:27:cb

	linux_dir=/home1/chrism/linux
fi
if (( host_num == 14 )); then
	if (( port == 1 )); then
		link=enp4s0f0
		link_ip=192.168.1.14
		link_ip_vlan=1.1.1.14
		link_ip_vxlan=1.1.1.14
		link_remote_ip=192.168.1.13

		br=br1
		vx=vxlan0
	fi
	if (( port == 2 )); then
		link=enp4s0f1
		link_ip=192.168.2.14
		link_remote_ip=192.168.2.13

		br=br2
		vx=vxlan1
	fi

	link_mac=24:8a:07:88:27:9a
	link_mac2=24:8a:07:88:27:9b

	ns_ip1=1.1.1.5
	ns_ip2=1.1.1.6
	ns_ip=1.1.$host_num

	vf1=enp4s0f2
	vf2=enp4s0f3

	rep1=${link}_0
	rep2=${link}_1
	rep3=${link}_2

	linux_dir=/home1/chrism/linux
fi

if (( host_num == 18 )); then
	if (( port == 1 )); then
		link=enp3s0f0
		link_ip=192.168.1.18
		link_ip_vlan=1.1.1.18
		link_ip_vxlan=1.1.1.18
		link_remote_ip=192.168.1.19

		br=br1
		vx=vxlan0
	fi
	if (( port == 2 )); then
		link=enp3s0f1
		link_ip=192.168.2.18
		link_remote_ip=192.168.2.19

		br=br2
		vx=vxlan1
	fi

	link_mac=24:8a:07:88:27:ca
	link_mac2=24:8a:07:88:27:cb

	vf1=enp3s0f2
	vf2=enp3s0f3

	rep1=${link}_0
	rep2=${link}_1

	ns_ip1=1.1.1.3
	ns_ip2=1.1.1.4
	ns_ip=1.1.$host_num

	linux_dir=/home1/chrism/linux

fi
if (( host_num == 19 )); then
	link=p3p1	# connected to cx4
	link=p3p2	# connected to cx5
	link_ip=192.168.1.19
	link_ip_vlan=1.1.1.19

	link_remote_ip=192.168.1.18
	link_mac=24:8a:07:88:27:9b
	link_mac2=24:8a:07:88:27:ab

	linux_dir=/mnt/18/linux
fi
if (( host_num == 20 )); then
	linux_dir=/auto/mtbcswgwork/chrism/linux
fi

if (( host_num == 15 )); then
	link=ens9
	link_ip=1.1.1.13
	link_remote_ip=1.1.1.3
	linux_dir=/home1/chrism/linux
fi
if (( host_num == 16 )); then
	link=ens9
	link_ip=1.1.1.3
	link_remote_ip=1.1.1.13
	linux_dir=/home1/chrism/linux
fi

vm1_ip=192.168.122.11
vm2_ip=192.168.122.12

linkp=$(echo $link | cut -d '0' -f 1)

if (( oldkernel == 1 )); then
	vx_rep=dummy_vxlan0
else
	vx_rep=vxlan_sys_4789
fi

alias ssh='ssh -o "StrictHostKeyChecking no"'

if [[ -e /sys/class/net/$link/device ]]; then
	link_bdf=$(basename $(readlink /sys/class/net/$link/device))
fi

alias a1="ip l show $link | grep ether; ip link set dev $link address $link_mac;  ip l show $link | grep ether"
alias a2="ip l show $link | grep ether; ip link set dev $link address $link_mac2; ip l show $link | grep ether"

alias vxlan1="ovs-vsctl add-port $br $vx -- set interface $vx type=vxlan options:remote_ip=$link_remote_ip  options:key=$vni"
alias vxlan2="ovs-vsctl del-port $br $vx"
alias vx='vxlan2; vxlan1'

alias ip1="ifconfig $link 0; ip addr add dev $link $link_ip/24; ip link set $link up"
alias ip2="ifconfig $link 0; ip addr add dev $link $link_ip_vlan/16; ip link set $link up"

alias vsconfig='ovs-vsctl get Open_vSwitch . other_config'
alias vsconfig-idle='ovs-vsctl set Open_vSwitch . other_config:max-idle=30000'
alias vsconfig-hw='ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"'
alias vsconfig-sw='ovs-vsctl set Open_vSwitch . other_config:hw-offload="false"'
alias vsconfig-skip_sw='ovs-vsctl set Open_vSwitch . other_config:tc-policy=skip_sw'
alias vsconfig-skip_hw='ovs-vsctl set Open_vSwitch . other_config:tc-policy=skip_hw'
alias vsconfig-none='ovs-vsctl set Open_vSwitch . other_config:tc-policy=none'
alias ovs-log=' tail -f  /var/log/openvswitch/ovs-vswitchd.log'
alias ovs2-log=' tail -f /var/log/openvswitch/ovsdb-server.log'

alias crash1="$nfs_dir/crash/crash -i /root/.crash $linux_dir/vmlinux"
alias crash2="$nfs_dir/crash/crash -i /root/.crash //boot/vmlinux-$(uname -r).bz2"
alias c=crash1

alias crash='/auto/mtbcswgwork/chrism/crash/crash -i ~/.crash'

crash_dir=/var/crash
alias c0="$nfs_dir/crash/crash -i /root/.crash $crash_dir/vmcore.0 $linux_dir/vmlinux"
alias c1="$nfs_dir/crash/crash -i /root/.crash $crash_dir/vmcore.1 $linux_dir/vmlinux"
alias c2="$nfs_dir/crash/crash -i /root/.crash $crash_dir/vmcore.2 $linux_dir/vmlinux"
alias c3="$nfs_dir/crash/crash -i /root/.crash $crash_dir/vmcore.3 $linux_dir/vmlinux"
alias c4="$nfs_dir/crash/crash -i /root/.crash $crash_dir/vmcore.4 $linux_dir/vmlinux"
alias c5="$nfs_dir/crash/crash -i /root/.crash $crash_dir/vmcore.5 $linux_dir/vmlinux"
alias c6="$nfs_dir/crash/crash -i /root/.crash $crash_dir/vmcore.6 $linux_dir/vmlinux"

alias cc0="/bin/crash $crash_dir/vmcore.0 /usr/lib/debug/lib/modules/$(uname -r)/vmlinux"
alias cc0="$nfs_dir/crash/crash -i /root/.crash $crash_dir/vmcore.0 /usr/lib/debug/lib/modules/$(uname -r)/vmlinux"

alias sw='vsconfig-sw; restart-ovs'
alias hw='vsconfig-hw; restart-ovs'

alias fsdump5='mlxdump -d 04:00.0 fsdump --type FT --gvmi=0 --no_zero=1'
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

alias modv='modprobe --dump-modversions'
alias 154='ssh mishuang@10.12.66.154'
alias ctl=systemctl
# alias dmesg='dmesg -T'

alias 13c='ssh root@10.12.206.25'
alias 14c='ssh root@10.12.206.26'

alias slave='lnst-slave'
alias classic='rpyc_classic.py'
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
alias sm1="cd $linux_dir"
alias smm='cd /home1/chrism/mlnx-ofa_kernel-4.0'
alias cd-test="cd $linux_dir/tools/testing/selftests/tc-testing/"
alias vi-action="vi $linux_dir/tools/testing/selftests/tc-testing/tc-tests/actions//tests.json"
alias vi-filter="vi $linux_dir/tools/testing/selftests/tc-testing/tc-tests/filters//tests.json"
alias ovs="cd $nfs_dir/ovs/openvswitch"
alias ovs="cd /home1/chrism/openvswitch"
alias ovs2="cd $nfs_dir/ovs/test/ovs-tests"
alias ipa='ip a'
alias ipl='ip l'
alias ipal='ip a l'
alias smd='cd /usr/src/debug/kernel-3.10.0-327.el7/linux-3.10.0-327.el7.x86_64'
alias rmswp='sm1; find . -name *.swp -exec rm {} \;'

alias sm="cd $nfs_dir"
alias smc="cd $nfs_dir/crash; vi net.c"
alias sm3="cd $nfs_dir/ovs/openvswitch"
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
alias p4='n0 ping 1.1.1.4'
alias p6='n0 ping 1.1.1.6'
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

alias tcss-rep="tc -stats filter show dev $rep1 ingress"
alias tcss-rep-ip="tc -stats filter show dev $rep1 protocol ip parent ffff:"
alias tcss-rep-arp="tc -stats filter show dev $rep1 protocol arp parent ffff:"

alias tcss-link="tc -stats filter show dev $link parent ffff:"
alias tcss-link-ip="tc -stats filter show dev $link  protocol ip parent ffff:"
alias tcss-link-arp="tc -stats filter show dev $link  protocol arp parent ffff:"

alias tcss-vxlan-ip="tc -stats filter show dev $vx_rep  protocol ip parent ffff:"
alias tcss-vxlan-arp="tc -stats filter show dev $vx_rep  protocol arp parent ffff:"
alias tcss-vxlan="tc -stats filter show dev $vx_rep ingress"

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
alias vib='vi ~/Documents/bug.txt'
alias vip='vi ~/Documents/private.txt'
alias vig='sudo vi /boot/grub2/grub.cfg'
alias vig2='sudo vi /etc/default/grub'
alias viu="vi $nfs_dir/uperf-1.0.5/workloads/netperf.xml"
alias vit='vi ~/.tmux.conf'
alias vic='vi ~/.crash'
alias viu='vi /etc/udev/rules.d/82-net-setup-link.rules'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias ta='type -all'
# alias grep='grep --color=auto'
alias h='history'
alias screen='screen -h 1000'
alias path='echo -e ${PATH//:/\\n}'
alias x=x.py
alias cf="cd $linux_dir; cscope -d"
alias cf2='cd /home1/chrism/linux; cscope -d'

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

alias vfs="mlxconfig -d $linik_bdf set SRIOV_EN=1 NUM_OF_VFS=127"
alias vfq="mlxconfig -d $link_bdf q"
alias vfsm="mlxconfig -d $linik_bdf set NUM_VF_MSIX=6"

alias tune1="ethtool -C $link adaptive-rx off rx-usecs 64 rx-frames 128 tx-usecs 64 tx-frames 32"
alias tune2="ethtool -C $link adaptive-rx on"
alias tune3="ethtool -c $link"

alias restart-virt='systemctl restart libvirtd.service'

export PATH=$PATH:~/bin
export EDITOR=vim
export TERM=xterm
unset PROMPT_COMMAND

n_time=20
m_msg=64000
alias np1="netperf -H 1.1.1.3 -t TCP_STREAM -l $n_time -- m $m_msg -p 12865 &"
alias np3="ip netns exec n1 netperf -H 1.1.1.3 -t TCP_STREAM -l $n_time -- m $m_msg -p 12865 &"
alias np4="ip netns exec n1 netperf -H 1.1.1.3 -t TCP_STREAM -l $n_time -- m $m_msg -p 12866 &"
alias np5="ip netns exec n1 netperf -H 1.1.1.3 -t TCP_STREAM -l $n_time -- m $m_msg -p 12867 &"

alias sshcopy='ssh-copy-id -i ~/.ssh/id_rsa.pub'

function vlan
{
        [[ $# != 3 ]] && return
        typeset link=$1 vid=$2 ip=$3 vlan=vlan$vid

        modprobe 8021q
	ifconfig $link 0
        ip link add link $link name $vlan type vlan id $vid
        ip link set dev $vlan up
        ip addr add $ip/16 brd + dev $vlan
}
alias v1="vlan $link $vid $link_ip_vlan"
alias v2='ip link del vlan'

function call
{
set -x
# 	/bin/rm -f cscope.out > /dev/null;
# 	/bin/rm -f tags > /dev/null;
# 	cscope -R -b -k -q &
	cscope -R -b -k &
	ctags -R
set +x
}

alias cu='time cscope -R -b -k'

function profile
{
	typeset host=$1
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
alias vfs="cat /sys/class/net/$link/device/sriov_totalvfs"
mac_prefix="02:25:d0:e2:18"
function set_mac
{
	[[ $# != 1 ]] && return

	typeset vf=$1
	typeset mac_vf=$((vf+5))
	ip link set $link vf $vf mac $mac_prefix:$mac_vf
}
alias on_sriov="echo 2 > /sys/class/net/$link/device/sriov_numvfs"

function unbind_all
{
set -x
	for (( i = 0; i < numvfs; i++)); do
		bdf=$(basename `readlink /sys/class/net/$link/device/virtfn$i`)
		echo $bdf
		echo $bdf > /sys/bus/pci/drivers/mlx5_core/unbind
	done
set +x
}

function off_sriov
{
	unbind_all $numvfs
	echo 0 > /sys/class/net/$link/device/sriov_numvfs
}

alias off=off_sriov

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

alias drop="ovs-ofctl add-flow ovsbr 'nw_dst=192.168.1.3 action=drop'"
alias normal="ovs-ofctl add-flow ovsbr 'nw_dst=192.168.1.3 action=normal'"

alias drop1="ovs-ofctl add-flow ovsbr 'nw_src=192.168.1.1 action=drop'"
alias normal1="ovs-ofctl add-flow ovsbr 'nw_src=192.168.1.1 action=normal'"

alias drop2="ovs-ofctl add-flow ovsbr 'nw_src=192.168.1.2 action=drop'"
alias normal2="ovs-ofctl add-flow ovsbr 'nw_src=192.168.1.3 action=normal'"

alias dropm="ovs-ofctl add-flow ovsbr 'dl_dst=52:54:00:60:78:03 action=drop'"
alias normalm="ovs-ofctl add-flow ovsbr 'dl_dst=52:54:00:60:78:03 action=normal'"

alias make_core='make M=drivers/net/ethernet/mellanox/mlx5/core'

stap_str="-d act_gact -d cls_flower -d act_mirred -d /usr/sbin/ethtool -d udp_tunnel -d sch_ingress -d 8021q -d /usr/sbin/ip -d /usr/sbin/ifconfig -d /usr/sbin/tc -d devlink -d mlx5_core -d tun -d kernel -d openvswitch -d vport_vxlan -d vxlan -d /usr/sbin/ovs-vswitchd -d /usr/bin/bash -d /usr/lib64/libc-2.26.so"

# make oldconfig
# make prepare

STAP="/usr/local/bin/stap -v"
STAP="/usr/bin/stap -v"

alias sta="$STAP $stap_str"
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

alias b=mybuild
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

	typeset dir=~/prg/c p=$(basename $1)

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

all: \$(EXEC)

\$(EXEC): \$(OBJS)
	\$(CC) \$(LDFLAGS) -o \$@ \$^ \$(LDLIBS)

clean:
	rm -f \$(EXEC) *.elf *.gdb *.o core

run:
	./$p
EOF
}

function template-m
{
        (( $# == 0 )) && return

        typeset dir=~/prg/mod p=$(basename $1)

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

	typeset udp=0
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
                exec n1 $IPERF -c $ip -u -t $t -p 7000
        else
                for ((i = 0; i < $n; i++)); do
                        p=$((7000+i))
                        echo $i
                        exec n1 $IPERF -c $ip -u -t $t -p $p &
                done
        fi
set +x
}


# vlan offload testing
function tc1
{
set -x
	offload=skip_sw
        [[ $# == 1 ]] && offload=$1
        [[ "$offload" == "sw" ]] && offload="skip_hw"

	TC=tc
	TC=/home1/chrism/tc-scripts/tc
	TC=/home1/chrism/iproute2/tc/tc
	typeset link=$link
	rep=$rep1
	vid=52

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

	brd_mac=ff:ff:ff:ff:ff:ff

	dst_mac=24:8a:07:88:27:9b
	src_mac=02:25:d0:e2:18:50
# 	$TC filter add dev $rep protocol ip  parent ffff: flower $offload dst_mac $dst_mac src_mac $src_mac action mirred egress redirect dev $link
# 	$TC filter add dev $rep protocol arp parent ffff: flower skip_hw  dst_mac $dst_mac src_mac $src_mac action mirred egress redirect dev $link
# 	$TC filter add dev $rep protocol arp parent ffff: flower skip_hw  dst_mac $brd_mac src_mac $src_mac action mirred egress redirect dev $link
	$TC filter add dev $rep protocol ip  parent ffff: flower $offload dst_mac $dst_mac src_mac $src_mac action vlan push id $vid index 1 action mirred egress redirect dev $link index 1
	$TC filter add dev $rep protocol arp parent ffff: flower skip_hw  dst_mac $dst_mac src_mac $src_mac action vlan push id $vid index 1 action mirred egress redirect dev $link index 1
	$TC filter add dev $rep protocol arp parent ffff: flower skip_hw  dst_mac $brd_mac src_mac $src_mac action vlan push id $vid index 1 action mirred egress redirect dev $link index 1

	dst_mac=02:25:d0:e2:18:50
	src_mac=24:8a:07:88:27:9b
# 	$TC filter add dev $link protocol ip  parent ffff: flower $offload dst_mac $dst_mac src_mac $src_mac action mirred egress redirect dev $rep
# 	$TC filter add dev $link protocol arp parent ffff: flower skip_hw  dst_mac $dst_mac src_mac $src_mac action mirred egress redirect dev $rep
# 	$TC filter add dev $link protocol arp parent ffff: flower skip_hw  dst_mac $brd_mac src_mac $src_mac action mirred egress redirect dev $rep
	$TC filter add dev $link protocol 802.1Q parent ffff: flower $offload dst_mac $dst_mac src_mac $src_mac vlan_ethtype 0x800 vlan_id $vid vlan_prio 0 action vlan pop index 2 action mirred egress redirect dev $rep index 2
	$TC filter add dev $link protocol 802.1Q parent ffff: flower skip_hw  dst_mac $dst_mac src_mac $src_mac vlan_ethtype 0x806 vlan_id $vid vlan_prio 0 action vlan pop index 2 action mirred egress redirect dev $rep index 2
	$TC filter add dev $link protocol 802.1Q parent ffff: flower skip_hw  dst_mac $brd_mac src_mac $src_mac vlan_ethtype 0x806 vlan_id $vid vlan_prio 0 action vlan pop index 2 action mirred egress redirect dev $rep index 2


# 	dst_mac=02:25:d0:e2:19:50
# 	src_mac=02:25:d0:e2:18:50
# 	$TC filter add dev $rep protocol ip  parent ffff: flower $offload dst_mac $dst_mac src_mac $src_mac action vlan push id $vid action mirred egress redirect dev $link
# 	$TC filter add dev $rep protocol arp parent ffff: flower skip_hw  dst_mac $dst_mac src_mac $src_mac action vlan push id $vid action mirred egress redirect dev $link
# 	$TC filter add dev $rep protocol arp parent ffff: flower skip_hw  dst_mac $brd_mac src_mac $src_mac action vlan push id $vid action mirred egress redirect dev $link
# 	dst_mac=02:25:d0:e2:18:50
# 	src_mac=02:25:d0:e2:19:50
# 	$TC filter add dev $link protocol 802.1Q parent ffff: flower $offload dst_mac $dst_mac src_mac $src_mac vlan_ethtype 0x800 vlan_id $vid vlan_prio 0 action vlan pop action mirred egress redirect dev $rep
# 	$TC filter add dev $link protocol 802.1Q parent ffff: flower skip_hw dst_mac $dst_mac src_mac $src_mac vlan_ethtype 0x806 vlan_id $vid vlan_prio 0 action vlan pop action mirred egress redirect dev $rep
# 	$TC filter add dev $link protocol 802.1Q parent ffff: flower skip_hw dst_mac $brd_mac src_mac $src_mac vlan_ethtype 0x806 vlan_id $vid vlan_prio 0 action vlan pop action mirred egress redirect dev $rep
set +x
}

function tc2
{
	typeset l
# 	for link in p2p1 $rep1 $rep2 $vx_rep; do
	for l in $link $rep1 $rep2 $vx_rep, $vx; do
		ip link show $l > /dev/null 2>&1 || continue
		tc qdisc show dev $l ingress | grep ffff > /dev/null 2>&1
		if (( $? == 0 )); then
			sudo /bin/time -f %e tc qdisc del dev $l ingress
			echo $l
		fi
	done
}

function tc-vxlan
{
set -x
	offload=skip_sw
        [[ $# == 1 ]] && offload=$1
        [[ "$offload" == "sw" ]] && offload="skip_hw"

	TC=tc
	typeset link=$link
	typeset rep=$rep1
	typeset vx=$vx_rep
	typeset vni=$vni
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

function tc4
{
set -x
	offload=skip_sw
        [[ $# == 1 ]] && offload=$1
        [[ "$offload" == "sw" ]] && offload="skip_hw"

	TC=tc
	TC=/home1/chrism/tc-scripts/tc
	TC=/home1/chrism/iproute2/tc/tc
	typeset link=$link
	rep=$rep1
	vid=52

	$TC qdisc del dev $link ingress
	$TC qdisc del dev $rep ingress

	if [[ "$offload" == "skip_sw" ]]; then
		ethtool -K $link hw-tc-offload on 
		ethtool -K $rep  hw-tc-offload on 
	fi
	if [[ "$offload" == "skip_hw" ]]; then
		ethtool -K $link hw-tc-offload off
		ethtool -K $rep  hw-tc-offload off
	fi

	$TC qdisc add dev $link ingress 
	$TC qdisc add dev $rep ingress 

        brd_mac=ff:ff:ff:ff:ff:ff

	dst_mac=02:25:d0:e2:18:50
	src_mac=02:25:d0:e2:18:51
	$TC filter add dev $rep prio 3 protocol ip  parent ffff: flower $offload dst_mac $dst_mac src_mac $src_mac action mirred egress redirect dev $link
	$TC filter add dev $rep prio 2 protocol arp parent ffff: flower $offload dst_mac $dst_mac src_mac $src_mac action mirred egress redirect dev $link
	$TC filter add dev $rep prio 1 protocol arp parent ffff: flower $offload dst_mac $brd_mac src_mac $src_mac action mirred egress redirect dev $link
	dst_mac=02:25:d0:e2:18:51
	src_mac=02:25:d0:e2:18:50
	$TC filter add dev $link prio 3 protocol ip  parent ffff: flower $offload dst_mac $dst_mac src_mac $src_mac action mirred egress redirect dev $rep
	$TC filter add dev $link prio 2 protocol arp parent ffff: flower $offload dst_mac $dst_mac src_mac $src_mac action mirred egress redirect dev $rep
	$TC filter add dev $link prio 1 protocol arp parent ffff: flower $offload dst_mac $brd_mac src_mac $src_mac action mirred egress redirect dev $rep
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

	src_mac=02:25:d0:13:01:02
	$TC filter add dev $redirect protocol ip  parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress redirect dev $link

	src_mac=24:8a:07:88:27:9a
	$TC filter add dev $link protocol ip  parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol arp parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress redirect dev $redirect

set +x
}



function tc-mirror
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

	src_mac=02:25:d0:13:01:02
	$TC filter add dev $redirect protocol ip  parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $link

	src_mac=24:8a:07:88:27:9a
	$TC filter add dev $link protocol ip  parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol arp parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress mirror dev $mirror \
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

alias tcv=tc-mirror-vlan
function tc-mirror-vlan
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

	src_mac=02:25:d0:13:01:02	# local vm mac
	$TC filter add dev $redirect protocol ip  parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress mirror dev $mirror	\
		action vlan push id $vid		\
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress mirror dev $mirror	\
		action vlan push id $vid		\
		action mirred egress redirect dev $link

	src_mac=24:8a:07:88:27:9a	# remote vm mac
	$TC filter add dev $link protocol 802.1Q parent ffff: flower $offload src_mac $src_mac vlan_ethtype 0x800 vlan_id $vid vlan_prio 0	\
		action vlan pop				\
		action mirred egress mirror dev $mirror	\
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol 802.1Q parent ffff: flower $offload src_mac $src_mac vlan_ethtype 0x806 vlan_id $vid vlan_prio 0	\
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

function tc5
{
set -x
	offload=skip_sw
        [[ $# == 1 ]] && offload=$1
        [[ "$offload" == "sw" ]] && offload="skip_hw"

	TC=tc
	TC=/home1/chrism/tc-scripts/tc
	TC=/home1/chrism/iproute2/tc/tc
	typeset link=p4p1
	typeset rep=eth0
	typeset vx=$vx_rep
	vid=52
	typeset vni=$vni
	port=4789

	mac1=02:25:d0:e2:18:50
	mac2=22:99:1a:d5:c3:9b

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
	src_mac=$mac1
	dst_mac=$mac2
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
	src_mac=$mac2
	dst_mac=$mac1
        $TC filter add dev $vx protocol ip parent ffff: flower $offload	\
		    dst_mac $dst_mac		\
		    src_mac $src_mac		\
		    enc_src_ip $src_ip		\
		    enc_dst_ip $dst_ip		\
		    enc_dst_port $port		\
		    enc_key_id $vni		\
		    action tunnel_key unset	\
                    action mirred egress redirect dev $rep
}

alias vf00="ip link set dev  $link vf 0 vlan 0 qos 0"
alias vf052="ip link set dev $link vf 0 vlan 52 qos 0"

alias vf10="ip link set dev  $link vf 1 vlan 0 qos 0"
alias vf152="ip link set dev $link vf 1 vlan 52 qos 0"

function get_rep
{
	[[ $# != 1 ]] && return
	if (( oldkernel == 1 )); then
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

function mirror-br
{
set -x
	local rep
	ovs-vsctl add-br $br
	ovs-vsctl add-port $br $vx -- set interface $vx type=vxlan options:remote_ip=$link_remote_ip options:key=$vni
# 	vs add-port $br $link
	for (( i = 1; i < numvfs; i++)); do
		rep=$(get_rep $i)
# 		vs add-port $br $rep tag=$vid
		vs add-port $br $rep
		ip link set $rep up
	done

	ip link set $rep1 up
# 	ovs-vsctl add-port $br $rep1 tag=$vid\
# set +x
# 	return
	ovs-vsctl add-port $br $rep1	\
	    -- --id=@p get port $rep1	\
	    -- --id=@m create mirror name=m0 select-all=true output-port=@p \
	    -- set bridge $br mirrors=@m

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
# 	ovs-vsctl add-port $br $rep1 tag=$vid\
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

function create-br
{
set -x
	typeset rep

	vs add-br $br
	vxlan1
# 	vs add-port $br $link
	for (( i = 0; i < numvfs; i++)); do
		rep=$(get_rep $i)
		vs add-port $br $rep
		ip link set $rep up
	done
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
# 	vs del-port $link
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
	typeset link=$1
	vid=$2
	ip=$3
	n=$4
	vlan=${link}$vid
	modprobe 8021q
	ip netns del $n
	ip netns add $n

	ip link set dev $link netns $n
	exec $n vconfig add $link $vid
	exec $n ifconfig $link up
	exec $n ifconfig ${link}.$vid $ip/24 up
set +x
}
alias vn1="ifconfig $vf1 0; vlan-ns $vf1 52 1.1.1.11 n1"
alias vn2="ifconfig $vf2 0; vlan-ns $vf2 52 1.1.1.12 n2"

alias iperfc1='n1 iperf3 -c 1.1.1.11 -u -t 1000 -p 7000'
alias iperfc1='n1 iperf3 -c 1.1.1.11 -t 1000 -p 7000'
alias iperfs1='n1 iperf3 -s -p 7000'

function bind_all
{
set -x
	for (( i = 0; i < numvfs; i++)); do
		bdf=$(basename `readlink /sys/class/net/$link/device/virtfn$i`)
		echo $bdf
		echo $bdf > /sys/bus/pci/drivers/mlx5_core/bind
	done
set +x
}

function vf
{
	typeset n
        [[ $# != 1 ]] && return
	n=$1

	if (( port == 1 )); then
		if (( n >= 0 && n <= 5)); then
			echo ${linkp}0f$((n+2))
			return
		fi
		m=8
		s=$(((n+2)/m))
		f=$(((n+2)%m))
		if (( f != 0 )); then
			echo ${linkp}${s}f$f
		else
			echo ${linkp}${s}
		fi
	fi
	if (( port == 2 )); then
		m=8
		s=$(((n+1)/m+16))
		f=$(((n+1)%m))
		if (( f != 0 )); then
			echo ${linkp}${s}f$f
		else
			echo ${linkp}${s}
		fi
	fi
}

alias vf-test="for (( i = 0; i < 50; i++)); do echo -n $i; echo -n \" \"; vf $i; done"

# 1472
function netns
{
	typeset n=$1 link=$2 ip=$3
	ip netns del $n
	ip netns add $n
	ip link set dev $link netns $n
	ip netns exec $n ifconfig $link mtu 1450
	ip netns exec $n ip link set dev $link up
	ip netns exec $n ip addr add $ip/16 brd + dev $link
}

# rep=$(eval echo '$'rep"$i")
function ns_all
{
	typeset vfn
	typeset ip
	typeset i
	for (( i = 0; i < numvfs; i++)); do
		ip=${ns_ip}.$((i+1))
		echo "ip=$ip"
		vfn=$(vf i)
		echo "vfn=$vfn"
		netns n${port}${i} $vfn $ip
	done
}

function up_all
{
	typeset rep
	for (( i = 0; i < numvfs; i++)); do
		rep=${link}_$i
		ifconfig $rep up
	done
}

function hw_tc_all
{
	typeset rep
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

alias exec=' ip netns exec'
alias n0='exec n0'
alias n1='exec n1'
alias n2='exec n2'
alias n3='exec n3'
alias n4='exec n4'

alias n0='exec n10'
alias n1='exec n11'

alias n20='exec n20'
alias n21='exec n21'

alias nn1='exec host1_ns'
alias nn2='exec host2_ns'
alias nn3='exec host3_ns'

alias leg='start-switchdev legacy'
alias start='start-switchdev vm'
alias start='off; start-switchdev'
alias start-vm='start-switchdev vm'
alias start-vf='start-switchdev vf'
alias start-bind='start-switchdev bind'
alias restart='off; start'
function start-switchdev
{
set -x
	if (( port == 1 )); then
		mac_prefix="02:25:d0:$host_num:$port"
	fi
	if (( port == 2 )); then
		mac_prefix="02:25:d0:$host_num:$port"
	fi
	mac_vf=1
	mode=switchdev
	link_mode=transport

	chmod go+w /sys/class/net/$link/device/sriov_numvfs
	chmod go+w /sys/bus/pci/drivers/mlx5_core/unbind
	chmod go+w /sys/bus/pci/drivers/mlx5_core/bind

	echo $numvfs > /sys/class/net/$link/device/sriov_numvfs

	echo "Unbind the VFs from the NIC driver: "
	for i in `ls -1d  /sys/class/net/$link/device/virtfn*`; do
		pci_dev=$(basename `readlink $i`)
		echo "unbind $pci_dev"
		echo $pci_dev > /sys/bus/pci/drivers/mlx5_core/unbind
	done

	# echo "Set mac: "
	for vf in `ip link show $link | grep "vf " | awk {'print $2'}`; do
		ip link set $link vf $vf mac $mac_prefix:$mac_vf
		((mac_vf=mac_vf+1))
	done

	if [[ "$1" != "legacy" ]]; then
		echo $link_bdf
		if (( oldkernel == 0 )); then
			devlink dev eswitch set pci/$link_bdf mode switchdev
			devlink dev eswitch set pci/$link_bdf inline-mode transport;
			devlink dev eswitch set pci/$link_bdf encap enable
		else
			echo switchdev >  /sys/kernel/debug/mlx5/$link_bdf/compat/mode
			echo transport >  /sys/kernel/debug/mlx5/$link_bdf/compat/inline
			echo base >  /sys/kernel/debug/mlx5/$link_bdf/compat/encap
		fi

		ip1

# 		restart_ovs
	fi

	start-ovs
	up_all
	hw_tc_all

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

	if [[ "$1" == "vm" ]]; then
		start_vm_all $numvfs
		ifconfig $rep1 1.1.1.2/24 up
# 		start_vm_all 1
		set +x
		return
	fi

	bind_all

	ns_all

	iptables -F
	iptables -Z
	iptables -X

# 	ifconfig $rep1 1.1.1.5/24 up

set +x
	return
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
	[[ $# == 0 ]] && typeset link=$link || typeset link=$1
	tc -s filter show dev $link ingress
}

function tc-insert
{
	[[ $# == 0 ]] && return
	typeset dir=$1
	typeset link=$link
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
	typeset link=int0
	ip=1.1.1.11

	ovs-vsctl del-port $br $link
	ovs-vsctl add-port $br $link -- set interface $link type=internal
	ifconfig $link mtu 1450
	ifconfig $link $ip/24 up
}

function tm
{
	[[ $# == 0 ]] && return
	typeset session=$1
	typeset cmd=$(which tmux) # tmux path

	if [ -z $cmd ]; then
		echo "You need to install tmux."
		return
	fi

	$cmd has -t $session

	if [ $? != 0 ]; then
		$cmd new -d -n src -s $session
		$cmd neww -n linux
		$cmd neww -n virc
		$cmd neww -n vin
		$cmd neww -n live
		$cmd neww -n stm
		$cmd neww -n tc
		$cmd neww -n crash_src
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

function tcd
{
	typeset h
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
	typeset h
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
	tc filter change  dev $link prio 1 protocol ip handle 2 parent ffff: flower skip_hw src_mac e4:11:0:0:0:4 dst_mac e4:12:0:0:0:4 action drop
}

function tcm
{
	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
	tc2
	sudo $TC qdisc add dev $link ingress
	sudo $TC filter add  dev $link prio 1 protocol ip handle 0x80000001 parent ffff: flower skip_hw src_mac e4:11:0:0:0:2 dst_mac e4:12:0:0:0:2 action drop
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

function tcbnoodle
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
	TC=/auto/mtbcswgwork/chrism/iproute2/tc/tc
	tc2
	sudo $TC qdisc add dev $link ingress
set -x
	sudo $TC filter add dev $link prio 1 protocol 0x8100 parent ffff: flower skip_hw src_mac e4:11:1:1:1:1 dst_mac e4:12:1:1:1:1 vlan_ethtype ip action vlan pop action mirred egress redirect dev $rep1
set +x
}

function tca
{
set -x
	sudo time tc action add action ok index 1 action ok index 2 action ok index 3
	sudo tc action ls action gact
	sudo tc action delete action ok index 1 action ok index 2 action ok index 3
set +x
}

alias tca-add='tc action add action ok index 0'
alias tca-flush='tc actions flush action gact'
alias tca-ls='tc action ls action gact'

function tca-delete
{
	if [[ $# == 0 ]]; then
		n=1
	fi
	n=$1
	for ((i = 0; i <= n; i++)); do
		set -x
		tc action delete action ok index $i
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


function tcb
{
	[[ $# == 0 ]] && return

	TC=tc

	$TC qdisc del dev $link ingress
	$TC qdisc add dev $link ingress
	ethtool -K $link hw-tc-offload on

	time for file in $1/*.*; do
set -x
		$TC -b $file
set +x
	done
}

function tcb1
{
	[[ $# == 0 ]] && return

	TC=tc

	$TC qdisc del dev $link ingress
	$TC qdisc add dev $link ingress
	ethtool -K $link hw-tc-offload on

	$TC -b $1
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

	typeset bin=$1
# 	gdb -batch $(which $bin) $(pgrep $bin) -x ~chrism/g.txt
	gdb $(which $bin) $(pgrep $bin) -x ~chrism/g.txt
}

alias g1='gdb1 ovs-vswitchd'

function vsconfig1
{
	ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"
	ovs-vsctl set Open_vSwitch . other_config:tc-policy=skip_hw
# 	ovs-vsctl set Open_vSwitch . other_config:max-idle=600000 # (10 minutes) 
}

function vsconfig2
{
	ovs-vsctl remove Open_vSwitch . other_config hw-offload
	ovs-vsctl remove Open_vSwitch . other_config tc-policy
# 	ovs-vsctl remove Open_vSwitch . other_config max-idle
}

function burn5
{
set -x
	version=last_revision
	version=fw-4119-rel-16_21_0338
	mkdir -p /mswg/
	pci_dev=$(basename `readlink /sys/class/net/$link/device`);
	sudo mount 10.4.0.102:/vol/mswg/mswg /mswg/
	yes | sudo mlxburn -d $pci_dev -fw /mswg/release/fw-4119/$version/fw-ConnectX5.mlx -conf_dir /mswg/release/fw-4119/$version
	sudo mlxfwreset -d $pci_dev reset
set +x
}

function git-patch
{
	[[ $# != 2 ]] && return
	typeset dir=$1
	typeset n=$2
	mkdir -p $dir
	git format-patch -o $dir -$n HEAD
}

linux_file=~/idr/
function checkout
{
set -x
	typeset list=$linux_file/out.txt
	typeset new_dir=$linux_file/out
	typeset linux_full_name
	typeset new_full

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
	typeset list=$linux_file/$1
	typeset new_dir=$linux_file/2
	typeset linux_full_name
	typeset new_full

	while read line; do 
		echo $line
		linux_full_name=$linux_dir/$line
		new_full=$new_dir/$line
		/bin/cp -f $new_full $linux_full_name
	done < $list
set +x
}

patch_dir=~/net/r1
alias smp="cd $patch_dir"

# Jamal Hadi Salim <jhs@mojatatu.com>
# Lucas Bates <lucasb@mojatatu.com>

function git-format-patch
{
	[[ $# != 1 ]] && return
# 	git format-patch --cover-letter --subject-prefix="INTERNAL RFC net-next v9" -o $patch_dir -$1
# 	git format-patch --cover-letter --subject-prefix="patch net-next" -o $patch_dir -$1
# 	git format-patch --cover-letter --subject-prefix="patch net-next internal v11" -o $patch_dir -$1
	git format-patch --cover-letter --subject-prefix="patch net internal" -o $patch_dir -$1
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
	typeset link=$1
	typeset ip=$2
	typeset file=/etc/sysconfig/network-scripts/ifcfg-$link
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
	typeset link=$1
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
	typeset link=$1
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



function peer2
{
set -x
	ifconfig $link 0
	ip link del $vx > /dev/null 2>&1
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
	ip=1.1.2.11

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
	typeset start=$1
	typeset end=$2
	typeset cmd=$3
	typeset dir=$4

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
	typeset file=/etc/udev/rules.d/82-net-setup-link.rules
	typeset id=$(ip -d link show $link | grep switchid | awk '{print $NF}')
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
	typeset l=$link
	if [[ $# == 1 ]]; then
		l=$1
	fi
	for ((i = mac_start; i <= mac_end; i++)); do
# 		(( i == 13 )) && continue
		mf1=$(printf %x $i)
		typeset newlink=${l}.$i
		echo $newlink
		$mac_ns ip link add link $l address 00:11:11:11:11:$mf1 $newlink type macvlan
		$mac_ns ifconfig $newlink 1.1.11.$i/16 up
	done
}

function macvlan2
{
	typeset l=$link
	if [[ $# == 1 ]]; then
		l=$1
	fi
	for ((i = mac_start; i <= mac_end; i++)); do
		typeset newlink=${l}.$i
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

function watcht
{
	watch -d -n 1 "ethtool -S $link | grep \"tx[0-9]*_packets:\""
}

# yum --enablerepo=extras install epel-release
# yum install python-devel
# yum -y install pip
# pip install rpyc
# pip install netifaces
# yum install libvirt
 
function update
{
	lnst-slave &
	rpyc_classic.py &
	sleep 1
	cd /root/lnst-hw-offload-config
	./update-dev13_14.py
}

function run-lnst
{
	del_ovs
	vs del-br $br
	vs del-br t_br1
	vs del-br t_br2
	cd /root/lnst-hw-offload-config
	lnst-ctl -d --pools=dev13_14 run recipes/ovs_offload/1_virt_ovs_vxlan_flow_key.xml
}
alias f=key-flow
function key-flow
{
set -x
	ovs-vsctl del-br $br
	ovs-vsctl add-br $br
	ovs-vsctl add-port $br vxlan0 -- set Interface vxlan0 type=vxlan  option:remote_ip=$link_remote_ip option:key=flow option:dst_port=4789 ofport_request=10
	ovs-vsctl add-port $br enp4s0f0_0
	ovs-vsctl add-port $br enp4s0f0_1
	ovs-vsctl set Interface enp4s0f0_0 ofport_request=5
	ovs-vsctl set Interface enp4s0f0_1 ofport_request=6

	ovs-ofctl add-flow $br "table=2,dl_dst=e4:11:22:33:44:55,actions=drop"
	ovs-ofctl add-flow $br "table=2,priority=100,actions=drop"

	typeset vni=100
	typeset ofport=5
	ovs-ofctl add-flow $br "table=0, priority=1 actions=goto_table:1"
	ovs-ofctl add-flow $br "table=1, priority=1 actions=goto_table:2"
	ovs-ofctl add-flow $br "table=2,in_port=$ofport,actions=set_field:$vni->tun_id,output:10"
	ovs-ofctl add-flow $br "table=2,in_port=10,tun_id=$vni,actions=output:$ofport"

	typeset vni=200
	typeset ofport=6
	ovs-ofctl add-flow $br "table=0,in_port=$ofport,actions=set_field:$vni->tun_id,output:10"
	ovs-ofctl add-flow $br "table=0,in_port=10,tun_id=$vni,actions=output:$ofport"

	ip link set enp4s0f0_0 up
	ip link set enp4s0f0_1 up
	ip link set enp4s0f0 up
	ip link set $br up
	ifconfig $link 0
	ip addr add $link_ip/24 dev $link
	ip link set $br up

	ovs-ofctl dump-flows $br
set +x
}

function key-flow1
{
	ovs-ofctl add-flow $br 'table=0,in_port=5,actions=set_field:100->tun_id,output:10';
	ovs-ofctl add-flow $br 'table=0,in_port=10,tun_id=100,actions=output:5';
	ovs-ofctl add-flow $br 'table=0,priority=100,actions=drop';
}

function key-flow2
{
	ovs-ofctl add-flow $br 'table=0,in_port=5,actions=set_field:200->tun_id,output:10';
	ovs-ofctl add-flow $br 'table=0,in_port=10,tun_id=200,actions=output:5';
	ovs-ofctl add-flow $br 'table=0,priority=100,actions=drop';
}

function disable-ipv6
{
	sysctl -w net.ipv6.conf.all.disable_ipv6=1
	sysctl -w net.ipv6.conf.default.disable_ipv6=1
}

function enable-ipv6
{
	sysctl -w net.ipv6.conf.all.disable_ipv6=0
	sysctl -w net.ipv6.conf.default.disable_ipv6=0
}

# ovs-appctl vlog/list
alias ovs-vlog-list="ovs-appctl vlog/list"

function ovs-vlog-set
{
	[[ $# != 1 ]] && return

	m=$1
	ovs-appctl vlog/set $m:console:dbg
	ovs-appctl vlog/set $m:syslog:dbg
	ovs-appctl vlog/set $m:file:dbg
}

function install-python3
{
	sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
	sudo yum -y install python36u
	sudo ln -s /usr/bin/python3.6 /usr/bin/python3
}

function tc-batch
{
	n=1000000
	[[ $# != 0 ]] && n=$1
	file=b.txt
	TC=tc
	set -x
	$TC qdisc add dev $link ingress
	ethtool -K $link hw-tc-offload on
	time ~chrism/bin/tdc_batch.py $link $file -n $n -o --share_action
# 	time ~chrism/bin/tdc_batch.py $link $file -n $n -o
	time $TC -b $file
	time $TC qdisc del dev $link ingress
	/bin/rm $file
	set +x
}

function copy-kdump
{
set -x
	[[ $# != 1 ]] && return
	typeset host=$1
	
	typeset file=./file.txt
	rpm -ql kexec-tools > $file
        while read line; do
		scp $line root@$host:$line
        done < $file
set +x
}

function copy-kdump-local
{
set -x
	typeset dir=kdump
	mkdir -p $dir

	typeset file=./file.txt
	rpm -ql kexec-tools > $file
        while read line; do
		d=$(dirname $line)
		mkdir -p $dir/$d
		cp $line $dir/$line
        done < $file
set +x
}

function selinux
{
	typeset file=/etc/selinux/config
	sed -i 's/SELINUX=enforcing/SELINUX=disable/' $file;
	setenforce 0
}

function rm-gdm
{
set -x
	rmdir Videos/
	rmdir Templates/
	rmdir Pictures/
	rmdir Music/
	rmdir Documents/
	rmdir Downloads/
	rmdir Desktop/
	rmdir Public/
set +x
}

# commit 40b360a38a043b8e7ef6c8e273d2521929b37c54 (HEAD, origin/mlnx_ofed_4_2, origin/HEAD, mlnx_ofed_4_2)
# Author: Inbar Karmy <inbark@mellanox.com>
# Date:   Wed Sep 6 11:37:22 2017 +0300
# 
#     BACKPORTS: Fix the number of tx queues that are allocated
# 
#     Fix the number of tx queues that are allocated to depend on
#     TC number.
# 
#     Issue: 1121966
# 
#     Change-Id: I55f83a25768a9fe649e5e9df65d6330eded976dd
#     Signed-off-by: Inbar Karmy <inbark@mellanox.com>

# http://l-gerrit.mtl.labs.mlnx:8080/mlnx_ofed/mlnx-ofa_kernel-4.0
function install-ofed
{
	smm
	ln -s ofed_scripts/configure
	ln -s ofed_scripts/makefile
	ln -s ofed_scripts/Makefile
	./configure --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-ipoib-mod --with-mlx5-mod -j 32
#	./configure --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlx4-mod --with-mlx4_en-mod --with-ipoib-mod --with-srp-mod --with-rds-mod --with-iser-mod
	make -j 32
	sudo make install
}

function get_sw_id
{
    cat /sys/class/net/$1/phys_switch_id 2>/dev/null
    # also appear in: ip -d link show dev $1
}

function get_port_name
{
    cat /sys/class/net/$1/phys_port_name 2>/dev/null
    # also appear in: ip -d link show dev $1
}

function show_reps
{
	# get uplink switch id

	nic_id=`get_sw_id $link`

	[[ "$#" == 1 ]] && nic_id=`get_sw_id $1`

	if [ -z "$nic_id" ]; then
		echo "Cannot get switch id for $link"
		return
	fi

	# go over virtual net devices and find same switch id
	VIRTUAL="/sys/devices/virtual/net"

	for net in `ls -1 $VIRTUAL`; do
	    virt_id=`get_sw_id $net`
	    if [ "$nic_id" = "$virt_id" ]; then
		port_name=`get_port_name $net`
		echo "$NIC : $net -> VF$port_name"
	    fi
	done
}

function tcp1
{
	offload="skip_hw"
	TC=tc
	redirect=$rep2
	mirror=$rep1

	[[ "$1" == "hw" ]] && offload="skip_sw"

set -x
# 	$TC filter add dev $redirect protocol ip parent ffff: prio 30 flower $offload ip_proto icmp \

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
	ip link set $rep1 promisc on
	ip link set $rep2 promisc on

# 		action pedit ex munge ip dst set 1.1.1.14 pipe \
# 		action pedit ex munge eth dst set 11:22:33:44:55:66 \
# 		action pedit ex munge ip src set 1.1.1.1 pipe\
	src_mac=02:25:d0:13:01:02
	$TC filter add dev $redirect protocol ip  parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $link
	$TC filter add dev $redirect protocol arp parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $link

	src_mac=24:8a:07:88:27:9a
	$TC filter add dev $link protocol ip  parent ffff: flower $offload src_mac $src_mac	\
		action pedit ex munge eth dst set 11:22:33:44:55:66 pipe\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $redirect
	$TC filter add dev $link protocol arp parent ffff: flower $offload src_mac $src_mac	\
		action mirred egress mirror dev $mirror \
		action mirred egress redirect dev $redirect
set +x
}
