#!/bin/bash
# 云端端口管理服务 - 监控云端端口并通知本地

LOCAL_VPN_IP="10.7.0.2"

# 获取当前监听的端口
get_listening_ports() {
    ss -tlnp | awk 'NR>1 {split($4,a,":"); print a[length(a)]}' | sort -u
}

# 获取已配置的转发规则
get_forwarded_ports() {
    iptables -t nat -L PREROUTING -n | grep "DNAT.*$LOCAL_VPN_IP" | \
        awk '{print $7}' | cut -d: -f2 | sort -u
}

echo "=== 云端端口监控服务 ==="
echo ""

while true; do
    echo "[$(date '+%H:%M:%S')] 监控端口状态..."

    listening=$(get_listening_ports)
    forwarded=$(get_forwarded_ports)

    echo "监听端口: $(echo $listening | wc -w)"
    echo "转发规则: $(echo $forwarded | wc -w)"

    sleep 30
done
