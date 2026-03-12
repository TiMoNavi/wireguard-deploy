#!/bin/bash
# 云端服务器部署脚本 - 自动安装并配置 WireGuard + 端口转发

set -e

echo "=== WireGuard 内网穿透 - 云端部署 v2 ==="
echo ""

# 检查配置文件
if [ ! -f "../config/local.conf" ]; then
    echo "❌ 未找到本地配置文件"
    echo "请先在本地运行 deploy.sh 并推送到 GitHub"
    exit 1
fi

# 读取本地配置
source ../config/local.conf

# 安装依赖
echo "📦 安装依赖..."
yum install -y git golang wireguard-tools iptables-services 2>/dev/null || \
apt install -y git golang wireguard-tools iptables-persistent 2>/dev/null

# 编译 wireguard-go
if [ ! -f /usr/bin/wireguard-go ]; then
    echo "🔧 编译 wireguard-go..."
    cd /tmp
    rm -rf wireguard-go
    git clone https://git.zx2c4.com/wireguard-go >/dev/null 2>&1
    cd wireguard-go
    export GOPROXY=https://goproxy.cn,direct
    make >/dev/null 2>&1
    cp wireguard-go /usr/bin/
    chmod +x /usr/bin/wireguard-go
fi

# 生成服务器密钥
echo "🔑 生成服务器密钥..."
SERVER_PRIVATE_KEY=$(wg genkey)
SERVER_PUBLIC_KEY=$(echo "$SERVER_PRIVATE_KEY" | wg pubkey)

# 获取公网 IP
PUBLIC_IP=$(curl -s ifconfig.me)

# 创建 WireGuard 配置
echo "📝 创建 WireGuard 配置..."
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = 10.7.0.1/24
PrivateKey = $SERVER_PRIVATE_KEY
ListenPort = 51820

[Peer]
PublicKey = $LOCAL_PUBLIC_KEY
AllowedIPs = 10.7.0.2/32
EOF

# 启动 WireGuard
echo "🚀 启动 WireGuard..."
WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick up wg0 >/dev/null 2>&1

# 配置基础端口转发（SSH）
echo "🔧 配置端口转发..."
iptables -t nat -A PREROUTING -p tcp --dport 2222 -j DNAT --to-destination 10.7.0.2:22
iptables -t nat -A POSTROUTING -d 10.7.0.2 -p tcp --dport 22 -j MASQUERADE

# 保存 iptables 规则
service iptables save 2>/dev/null || iptables-save > /etc/iptables/rules.v4 2>/dev/null

# 保存配置
cat > ../config/remote.conf <<EOF
# 云端服务器配置
REMOTE_IP=$PUBLIC_IP
REMOTE_PUBLIC_KEY=$SERVER_PUBLIC_KEY
WIREGUARD_PORT=51820
EOF

echo ""
echo "✅ 部署完成！"
echo ""
echo "📋 云端公钥: $SERVER_PUBLIC_KEY"
echo "📋 云端 IP: $PUBLIC_IP"
echo ""
echo "⚠️  重要：请在腾讯云控制台配置安全组"
echo "   - 开放 UDP 51820（WireGuard）"
echo "   - 开放所有 TCP 端口（或按需开放）"
echo ""
echo "下一步: 提交配置到 GitHub"
echo "  git add ../config/remote.conf"
echo "  git commit -m 'Add remote config'"
echo "  git push"
