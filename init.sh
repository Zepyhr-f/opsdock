#!/bin/bash
set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== OpsDock 初始化脚本 ===${NC}"

# 检查 .env 文件
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}未找到 .env 文件，正在复制模板...${NC}"
    cp .env.example .env
fi

# 加载环境变量
source .env

# 数据目录
DATA_DIR=${DATA_DIR:-/app/data}
echo -e "数据目录: ${DATA_DIR}"

# 创建数据目录
echo -e "${YELLOW}创建数据目录...${NC}"
mkdir -p ${DATA_DIR}/{mysql/{data,init},postgres/data,redis/data,nacos/{logs,data},prometheus/data,grafana/data}

# 检查并清理冲突的容器（通过 docker ps 检测）
echo -e "${YELLOW}检查冲突容器...${NC}"
CONTAINER_NAMES=("mysql-nacos" "pgsql" "redis" "nacos" "prometheus" "grafana" "node-exporter" "cadvisor")
for name in "${CONTAINER_NAMES[@]}"; do
    if docker ps -a --format '{{.Names}}' | grep -q "^${name}$"; then
        echo -e "${YELLOW}停止并删除容器: $name${NC}"
        docker stop "$name" 2>/dev/null || true
        docker rm "$name" 2>/dev/null || true
    fi
done

# 启动服务
echo -e "${GREEN}启动 Docker 服务...${NC}"
docker-compose up -d

# 等待 MySQL 就绪
echo -e "${YELLOW}等待 MySQL 启动...${NC}"
sleep 5
for i in {1..30}; do
    if docker exec mysql-nacos mysql -uroot -proot -e "SELECT 1" > /dev/null 2>&1; then
        echo -e "${GREEN}MySQL 已就绪${NC}"
        break
    fi
    echo -e "${YELLOW}MySQL 正在启动... ($i/30)${NC}"
    sleep 2
done

# 配置远程访问
echo -e "${YELLOW}配置 MySQL 远程访问...${NC}"
docker exec mysql-nacos mysql -uroot -proot -e "CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'root'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null || true

# 执行 MySQL 初始化脚本
echo -e "${YELLOW}执行 MySQL 初始化脚本...${NC}"
for sql_file in ./mysql/init/*.sql; do
    if [ -f "$sql_file" ]; then
        filename=$(basename "$sql_file")
        echo -e "  执行: $filename"
        docker exec -i mysql-nacos mysql -uroot -proot nacos_config < "$sql_file" 2>/dev/null || echo -e "  ${YELLOW}警告: $filename 执行可能有问题（表可能已存在）${NC}"
    fi
done

# 显示服务状态
echo -e "${GREEN}服务状态:${NC}"
docker-compose ps

echo ""
echo -e "${GREEN}=== 初始化完成 ===${NC}"
echo -e "访问地址:"
echo -e "  Nacos:      http://localhost:8848/nacos"
echo -e "  Grafana:    http://localhost:3000"
echo -e "  Prometheus: http://localhost:9090"
echo -e "  cAdvisor:   http://localhost:8080"
echo ""
echo -e "管理命令:"
echo -e "  make up     - 启动所有服务"
echo -e "  make down   - 停止所有服务"
echo -e "  make logs   - 查看日志"
