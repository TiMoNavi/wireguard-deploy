# WireGuard 内网穿透一键部署

## 🎯 功能

通过 WireGuard VPN 实现完整的内网穿透，云端服务器可以访问本地服务器的所有端口。

## 📋 使用流程

### 1. 本地服务器（首次）

```bash
cd local
sudo bash deploy.sh
```

**提交配置：**
```bash
cd ..
git add config/local.conf
git commit -m "Add local config"
git push
```

### 2. 云端服务器

```bash
# 克隆仓库
git clone https://github.com/TiMoNavi/wireguard-deploy.git
cd wireguard-deploy/remote

# 部署
sudo bash deploy.sh
```

**提交配置：**
```bash
cd ..
git add config/remote.conf
git commit -m "Add remote config"
git push
```

### 3. 本地服务器（连接）

```bash
git pull
cd local
sudo bash connect.sh
```

## ✅ 验证

**从云端访问本地：**
```bash
# 云端服务器执行
ping 10.7.0.2
ssh user@10.7.0.2
```

## 🔧 网络拓扑

```
本地服务器 (10.7.0.2)
    ↕ WireGuard VPN
云端服务器 (10.7.0.1)
```

## ⚠️ 重要提示

**云端服务器安全组配置：**
- 必须开放 UDP 51820 端口
- 腾讯云：安全组 → 添加规则 → UDP:51820

## 📚 文件说明

- `local/deploy.sh` - 本地初始化
- `local/connect.sh` - 本地连接
- `remote/deploy.sh` - 云端部署
- `config/local.conf` - 本地配置
- `config/remote.conf` - 云端配置
