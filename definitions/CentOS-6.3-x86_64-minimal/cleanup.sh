yum -y clean all
#rm -rf /etc/yum.repos.d/{puppetlabs,epel}.repo
rm -rf /etc/yum.repos.d/{puppetlabs}.repo
rm -rf VBoxGuestAdditions_*.iso

service iptables stop
chkconfig iptables off
sed -i "s/SELINUX=.*/SELINUX=disabled/" /etc/selinux/config
echo 0 >/selinux/enforce

