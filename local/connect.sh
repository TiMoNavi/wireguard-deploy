#!/bin/bash
# 本地服务器连接脚本

set -e

echo "=== 连接到 WireGuard VPN ==="

# 检查配置
if [ ! -f "../config/local.conf" ] || [ ! -f "../config/remote.conf" ]; then
    echo "❌ 配置文件不完整"
    exit 1
fi

source ../config/local.conf
source ../config/remote.conf

# 创建 WireGuard 配置
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = $LOCAL_IP/24
PrivateKey = $LOCAL_PRIVATE_KEY

PostUp = ip route add $REMOTE_IP via $DEFAULT_GATEWAY dev $DEFAULT_INTERFACE
PostDown = ip route del $REMOTE_IP

[Peer]
PublicKey = $REMOTE_PUBLIC_KEY
Endpoint = $REMOTE_IP:$WIREGUARD_PORT
AllowedIPs = 10.7.0.0/24
PersistentKeepalive = 25
EOF

# 启动
wg-quick up wg0

echo "✅ 已连接到 VPN"
ping -c 3 10.7.0.1
