# OpsDock - Docker 服务快速部署工具

在 Ubuntu 上快速部署和启动 Docker 服务的工具箱。

## 目录

- [部署步骤](#部署步骤)
- [服务列表](#服务列表)
- [常用命令](#常用命令)
- [配置说明](#配置说明)
- [数据存储](#数据存储)
- [访问地址](#访问地址)

---

## 部署步骤

### 1. 克隆项目

```bash
git clone <your-repo-url>
cd opsdock
```

### 2. 一键初始化启动

```bash
# 方式一：使用一键初始化脚本（推荐）
chmod +x init.sh
./init.sh
```

脚本会自动：
- 复制 `.env.example` 到 `.env`（如果不存在）
- 创建数据目录
- 检查端口占用
- 启动所有 Docker 服务
- 配置 MySQL 远程访问

```bash
# 方式二：手动部署
cp .env.example .env
make mkdir
make up
```

---

## 服务列表

| 服务 | 端口 | 默认账号 | 说明 |
|------|------|----------|------|
| MySQL | 3306 | root/root | 数据库，nacos 依赖 |
| PostgreSQL | 5432 | postgres/postgres | 轻量数据库 |
| Redis | 6379 | 无认证 | 缓存服务 |
| Nacos | 8848 | nacos/nacos | 配置中心 |
| Prometheus | 9090 | 无认证 | 监控系统 |
| Grafana | 3000 | admin/admin | 可视化面板 |
| Node Exporter | 9100 | 无认证 | 服务器监控 |
| cAdvisor | 8080 | 无认证 | 容器监控 |

---

## 常用命令

```bash
# 启动所有服务
make up

# 停止所有服务
make down

# 重启所有服务
make restart

# 查看日志
make logs

# 查看服务状态
make ps

# 查看服务健康状态
make health

# 启动单个服务
make start-mysql
make start-redis

# 停止单个服务
make stop-mysql

# 查看单个服务日志
make logs-nacos

# 完全清理（删除数据目录）
make clean
```

---

## 配置说明

### 修改数据目录

编辑 `.env` 文件：

```bash
DATA_DIR=/your/custom/path
```

然后重新创建目录并启动：

```bash
make mkdir
make up
```

### MySQL 初始化脚本

将 SQL 脚本放入 `mysql/init/` 目录，容器首次启动时会自动执行：

```bash
# 示例：创建初始数据库和用户
echo "CREATE DATABASE myapp;" > mysql/init/02-myapp.sql
```

已内置的初始化脚本：

| 文件 | 说明 |
|------|------|
| `01-remote-access.sql` | 配置 MySQL root 用户远程访问 |
| `02-nacos-config.sql` | Nacos 配置中心所需的数据表 |

脚本执行顺序按文件名数字排序。

### Prometheus 配置

编辑 `prometheus/prometheus.yml` 来自定义监控目标。

---

## 数据存储

所有数据存储在 `${DATA_DIR}` 目录下（默认 `/app/data`）：

```
/app/data/
├── mysql/
│   ├── data/          # MySQL 数据文件
│   └── init/          # 初始化脚本（可选）
├── postgres/
│   └── data/          # PostgreSQL 数据文件
├── redis/
│   └── data/          # Redis 数据文件
├── nacos/
│   ├── logs/          # Nacos 日志
│   └── data/          # Nacos 数据
├── prometheus/
│   └── data/          # Prometheus 数据
└── grafana/
    └── data/          # Grafana 数据
```

> **注意**：这些目录由 Docker 管理，不需要提交到 Git。

---

## 访问地址

| 服务 | 地址 | 说明 |
|------|------|------|
| Nacos | http://localhost:8848/nacos | 配置中心 |
| Grafana | http://localhost:3000 | 监控面板 |
| Prometheus | http://localhost:9090 | 指标查询 |
| cAdvisor | http://localhost:8080 | 容器监控 |
| Node Exporter | http://localhost:9100 | 服务器指标 |

---

## 项目结构

```
opsdock/
├── docker-compose.yml    # Docker 服务配置
├── .env.example          # 环境变量模板
├── .env                  # 环境变量（需创建）
├── Makefile              # 快速命令入口
├── init.sh               # 一键初始化脚本
├── README.md             # 本文档
├── prometheus/
│   ├── prometheus.yml    # Prometheus 配置
│   └── rules/            # 告警规则（可选）
├── nacos/
│   └── nacos_config.sql  # Nacos 数据库表结构
└── mysql/
    └── init/
        ├── 01-remote-access.sql  # MySQL 远程访问配置
        └── 02-nacos-config.sql  # Nacos 表结构
```
