.PHONY: up down restart logs ps status clean mkdir help

# 创建数据目录
mkdir:
	@echo "Creating data directories in $${DATA_DIR:-/app/data}..."
	@mkdir -p $${DATA_DIR:-/app/data}/{mysql/{data,init},postgres/data,redis/data,nacos/{logs,data},prometheus/data,grafana/data}

up: mkdir

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f

ps:
	docker-compose ps

status: ps

# 查看所有服务健康状态
health:
	@echo "Checking service health..."
	@docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# 启动单个服务
start-%:
	docker-compose up -d $*

# 停止单个服务
stop-%:
	docker-compose stop $*

# 查看单个服务日志
logs-%:
	docker-compose logs -f $*

# 完全清理（删除数据卷）
clean: down
	@echo "WARNING: This will delete all data volumes!"
	docker-compose down -v

# 默认帮助
help:
	@echo "OpsDock - Docker Services Management"
	@echo ""
	@echo "Commands:"
	@echo "  make up           - Create dirs and start all services"
	@echo "  make mkdir        - Create data directories"
	@echo "  make down         - Stop all services"
	@echo "  make restart      - Restart all services"
	@echo "  make logs         - Follow all logs"
	@echo "  make ps           - Show service status"
	@echo "  make health       - Show service health status"
	@echo "  make start-<svc>  - Start specific service (e.g., make start-mysql)"
	@echo "  make stop-<svc>   - Stop specific service"
	@echo "  make logs-<svc>   - Follow specific service logs"
	@echo "  make clean        - Stop and delete data volumes"
	@echo "  make help         - Show this help"
