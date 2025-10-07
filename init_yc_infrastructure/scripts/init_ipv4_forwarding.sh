echo net.ipv4.ip_forward = 1 | tee --append /etc/sysctl.conf
sysctl -p