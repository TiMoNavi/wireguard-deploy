#!/bin/bash
# 本地服务器部署脚本 - 生成配置并推送到 GitHub

set -e

echo "=== WireGuard 内网穿透 - 本地部署 ==="
echo ""

# 检查依赖
command -v wg >/dev/null 2>&1 || { echo "❌ 请先安装 WireGuard"; exit 1; }

# 生成密钥对
echo "🔑 生成密钥对..."
PRIVATE_KEY=$(wg genkey)
PUBLIC_KEY=$(echo "$PRIVATE_KEY" | wg pubkey)

# 获取网络信息
DEFAULT_GW=$(ip route | grep default | awk '{print $3}')
DEFAULT_IF=$(ip route | grep default | awk '{print $5}')

# 写入配置
cat > ../config/local.conf <<EOF
# 本地服务器配置
LOCAL_IP=10.7.0.2
LOCAL_PRIVATE_KEY=$PRIVATE_KEY
LOCAL_PUBLIC_KEY=$PUBLIC_KEY
DEFAULT_GATEWAY=$DEFAULT_GW
DEFAULT_INTERFACE=$DEFAULT_IF
EOF

echo ""
echo "✅ 配置已生成"
echo ""
echo "📋 本地公钥: $PUBLIC_KEY"
echo ""
echo "下一步: 提交到 GitHub"
echo "  cd .. && git add config/local.conf"
echo "  git commit -m 'Add local config'"
echo "  git push"
