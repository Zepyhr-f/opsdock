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

# 检查端口占用
echo -e "${YELLOW}检查必要端口...${NC}"
PORTS=(3306 5432 6379 8848 9090 3000 9100 8080)
for port in "${PORTS[@]}"; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${YELLOW}端口 $port 已被占用${NC}"
    else
        echo -e "端口 $port 可用"
    fi
done

# 启动服务
echo -e "${GREEN}启动 Docker 服务...${NC}"
docker-compose up -d

# 等待 MySQL 就绪
echo -e "${YELLOW}等待 MySQL 启动...${NC}"
sleep 5
until docker exec mysql-nacos mysql -uroot -proot -e "SELECT 1" > /dev/null 2>&1; do
    echo -e "${YELLOW}MySQL 正在启动...${NC}"
    sleep 3
done
echo -e "${GREEN}MySQL 已就绪${NC}"

# 检查远程访问
echo -e "${YELLOW}检查远程访问配置...${NC}"
RESULT=$(docker exec mysql-nacos mysql -uroot -proot -N -e "SELECT User,Host FROM mysql.user WHERE User='root' AND Host='%';" 2>/dev/null)
if [ -z "$RESULT" ]; then
    echo -e "${YELLOW}正在配置远程访问...${NC}"
    docker exec mysql-nacos mysql -uroot -proot -e "CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'root'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null
    echo -e "${GREEN}远程访问已配置${NC}"
else
    echo -e "${GREEN}远程访问已配置${NC}"
fi

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
echo -e ""
echo -e "管理命令:"
echo -e "  make up     - 启动所有服务"
echo -e "  make down   - 停止所有服务"
echo -e "  make logs   - 查看日志"
