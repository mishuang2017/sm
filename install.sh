#!/bin/bash

set -x
for file in bashrc vimrc screenrc tmux.conf; do
	/bin/rm ~/.$file > /dev/null 2>&1
	/bin/cp $file ~/.$file
done

rpm -q libvirt-daemon || exit

dir=/etc/libvirt/qemu
mkdir -p $dir
/bin/cp qemu/centos-xml/*.xml $dir

for i in 1 2; do
	file=../vm$i.qcow2
	if [[ -f $file ]]; then
		/bin/cp $file /var/lib/libvirt/images
	fi
done

set +x
