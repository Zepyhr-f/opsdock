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

### 2. 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑配置（可选，根据需要修改）
vim .env
```

主要配置项：

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `DATA_DIR` | `/app/data` | 数据存储目录 |
| `TZ` | `Asia/Shanghai` | 时区 |
| `MYSQL_ROOT_PASSWORD` | `root` | MySQL root 密码 |
| `POSTGRES_PASSWORD` | `postgres` | PostgreSQL 密码 |
| `GRAFANA_ADMIN_PASSWORD` | `admin` | Grafana 管理员密码 |

### 3. 创建数据目录

```bash
# 方式一：使用 Makefile 自动创建
make mkdir

# 方式二：手动创建
mkdir -p /app/data/{mysql/{data,init},postgres/data,redis/data,nacos/{logs,data},prometheus/data,grafana/data}
```

### 4. 启动服务

```bash
# 启动所有服务
make up

# 或单独启动指定服务
docker-compose up -d mysql redis
```

### 5. 验证服务

```bash
# 查看服务状态
make health

# 或
docker-compose ps
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

将 SQL 脚本放入 `mysql/init/` 目录，容器启动时会自动执行：

```bash
# 示例：创建初始数据库和用户
echo "CREATE DATABASE myapp;" > mysql/init/01-init.sql
```

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
├── README.md             # 本文档
├── prometheus/
│   ├── prometheus.yml    # Prometheus 配置
│   └── rules/            # 告警规则（可选）
└── mysql/
    └── init/             # MySQL 初始化脚本（可选）
```
