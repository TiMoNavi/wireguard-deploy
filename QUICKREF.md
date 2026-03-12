# 快速参考卡片

## 🚀 一键部署命令

### 本地服务器
```bash
cd local && sudo bash deploy.sh
git add ../config/local.conf && git commit -m "Add local" && git push
```

### 云端服务器
```bash
git clone https://github.com/TiMoNavi/wireguard-deploy.git
cd wireguard-deploy/remote && sudo bash deploy.sh
git add ../config/remote.conf && git commit -m "Add remote" && git push
```

### 本地连接
```bash
git pull && cd local && sudo bash connect.sh
```

---

## 🔧 端口转发

```bash
# 转发指定端口
bash forward-ports.sh 8000 8080 9528

# 自动转发所有端口
sudo bash /home/cw/port-mapper.sh
```

---

## ✅ 测试命令

```bash
# 测试 VPN
ping 10.7.0.1

# 测试 SSH
ssh -p 2222 cw@81.70.52.75

# 测试 Web
curl http://81.70.52.75:8000
```

---

## ⚠️ 腾讯云安全组

**必须配置：**
- UDP 51820
- 所有 TCP 端口
