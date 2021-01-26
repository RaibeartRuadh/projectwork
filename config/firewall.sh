echo "net.ipv4.conf.all.forwarding=1" >> /etc/sysctl.d/01-forwarding.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/01-forwarding.conf
iptables -t nat -A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
sysctl -p /etc/sysctl.d/01-forwarding.conf
