#!/bin/bash
# 端口转发配置脚本 - 为指定端口创建转发规则

REMOTE_HOST="81.70.52.75"
REMOTE_USER="root"
REMOTE_PASS="@navi1001"
LOCAL_VPN_IP="10.7.0.2"

# 要转发的端口列表（空格分隔）
PORTS="$@"

if [ -z "$PORTS" ]; then
    echo "用法: $0 <端口1> <端口2> ..."
    echo "示例: $0 8000 8080 9528"
    exit 1
fi

echo "=== 配置端口转发 ==="
echo ""

for port in $PORTS; do
    echo "配置端口 $port..."
    sshpass -p "$REMOTE_PASS" ssh $REMOTE_USER@$REMOTE_HOST << EOF
# 检查规则是否已存在
if ! iptables -t nat -C PREROUTING -p tcp --dport $port -j DNAT --to-destination $LOCAL_VPN_IP:$port 2>/dev/null; then
    iptables -t nat -A PREROUTING -p tcp --dport $port -j DNAT --to-destination $LOCAL_VPN_IP:$port
    iptables -t nat -A POSTROUTING -d $LOCAL_VPN_IP -p tcp --dport $port -j MASQUERADE
    echo "✅ 端口 $port 转发已配置"
else
    echo "⚠️  端口 $port 转发已存在"
fi
EOF
done

echo ""
echo "✅ 完成！"
echo ""
echo "测试访问: http://$REMOTE_HOST:<端口>"
