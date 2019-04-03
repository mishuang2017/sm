apt-get -y install nis yp-tools autofs kexec-tools automake gcc flex bison ctags libmnl-dev
apt install linux-crashdump
dpkg-reconfigure kdump-tools

systemctl cat nis.service

systemctl enable autofs
systemctl start autofs

nfs-client.target
rpcbind

mkdir -p /labhome/chrism/
chown chrism.mtl /labhome/chrism/
mount 10.200.0.25:/vol/labhome/chrism /labhome/chrism/

# list installed files on a package
dpkg-query -L crash

# add a user to sudoer
usermod -aG sudo chrism

# edit /etc/vim/vimrc to uncomment autocmd to remember last position

# install broadcom wifi driver
sudo apt-get update
sudo apt-get install bcmwl-kernel-source
