# WireGuard 内网穿透一键部署指南

## 🎯 功能说明

通过 WireGuard VPN + iptables 端口转发，实现完整的内网穿透：
- 云端可以访问本地所有端口
- 从公网访问云端端口 = 访问本地服务
- 支持 HTTP、HTTPS、SSH 等所有 TCP 协议

---

## 📋 部署流程（3 步）

### 步骤 1：本地服务器初始化

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

---

### 步骤 2：云端服务器部署

```bash
# SSH 登录云端服务器
ssh root@<云端IP>

# 克隆仓库
git clone https://github.com/TiMoNavi/wireguard-deploy.git
cd wireguard-deploy/remote

# 部署
sudo bash deploy.sh
```

**⚠️ 重要：配置腾讯云安全组**
1. 登录腾讯云控制台
2. 进入云服务器 → 安全组
3. 添加规则：
   - UDP 51820（WireGuard）
   - 所有 TCP 端口（或按需开放）

**提交配置：**
```bash
cd ..
git add config/remote.conf
git commit -m "Add remote config"
git push
```

---

### 步骤 3：本地服务器连接

```bash
git pull
cd local
sudo bash connect.sh
```

**验证连接：**
```bash
ping 10.7.0.1
ssh -p 2222 cw@<云端IP>
```

---

## 🔧 端口转发配置

### 方法 1：手动配置指定端口

```bash
cd local
bash forward-ports.sh 8000 8080 9528
```

### 方法 2：自动扫描并转发所有端口

```bash
sudo bash /home/cw/port-mapper.sh
```

---

## ✅ 验证部署

### 测试 SSH 访问
```bash
# 访问云端 SSH
ssh root@<云端IP>

# 访问本地 SSH（通过云端）
ssh -p 2222 cw@<云端IP>
```

### 测试 Web 服务
```bash
# 假设本地有服务运行在 8000 端口
curl http://<云端IP>:8000
```

---

## 📊 当前配置

**已实现的端口转发：**
- 2222 → 本地 SSH (22)
- 8000 → 本地服务
- 8001 → 本地服务
- 8080 → 本地服务
- 9528 → 本地服务（HTTPS）

---

## 🔑 重要信息

**云端服务器：**
- IP: 81.70.52.75
- SSH: root@81.70.52.75:22
- 密码: @navi1001

**本地服务器：**
- VPN IP: 10.7.0.2
- SSH: cw@<云端IP>:2222
- 密码: 123

**WireGuard VPN：**
- 云端: 10.7.0.1
- 本地: 10.7.0.2
- 端口: UDP 51820

---

## 📚 相关文件

- `local/deploy.sh` - 本地初始化
- `local/connect.sh` - 本地连接
- `local/forward-ports.sh` - 端口转发配置
- `remote/deploy.sh` - 云端部署
- `config/local.conf` - 本地配置
- `config/remote.conf` - 云端配置
