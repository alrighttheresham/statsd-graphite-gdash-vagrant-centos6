yum install -y tree mysql mysql-libs mysql-server net-snmp net-snmp-libs net-snmp-utils freeradius freeradius-utils freeradius-mysql openssh-clients cronie mlocate screen man ntp traceroute vim genisoimage x86info dmidecode pciutils hdparam expect telnet nc dejavu-lgc-sans-fonts xorg-x11-xauth git tcpdump

# from epel
yum install -y proftp monit lshw

# ensure ntp is setup for the VM
yum -y install ntp
ntpdate pool.ntp.org