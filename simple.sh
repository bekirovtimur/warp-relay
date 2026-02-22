export TAG="WR_RULE"
export SRC_IP=$(curl -4s ifconfig.me)
export DST_IP=$(getent ahostsv4 engage.cloudflareclient.com | awk '{print $1; exit}')
export SRC_PORT=4500
export DST_PORT=4500

echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/ipv4-forwarding.conf
sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A PREROUTING \
  -d ${SRC_IP} -p udp --dport ${SRC_PORT} \
  -j DNAT --to-destination ${DST_IP}:${DST_PORT} \
  -m comment --comment "${TAG}"

iptables -t nat -A POSTROUTING \
  -p udp -d ${DST_IP} --dport ${DST_PORT} \
  -j MASQUERADE \
  -m comment --comment "${TAG}"

iptables -A FORWARD -p udp -d ${DST_IP} --dport ${DST_PORT} -j ACCEPT -m comment --comment "${TAG}"
iptables -A FORWARD -p udp -s ${DST_IP} --sport ${DST_PORT} -j ACCEPT -m comment --comment "${TAG}"

sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent
sudo netfilter-persistent save
