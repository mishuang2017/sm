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

dpkg-query -L crash
