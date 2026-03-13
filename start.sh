#!/bin/bash
# ======================================================================
# WebRTC 项目启动脚本 (适用于 macOS 和 Linux)
# 一站式傻瓜式启动脚本
# ======================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "WebRTC 项目启动脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -y, --yes    非交互模式，自动使用默认值"
    echo "  -h, --help   显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0          交互模式启动"
    echo "  $0 -y       非交互模式启动"
    exit 0
fi

# 检查是否为非交互模式
NON_INTERACTIVE=0
if [ "$1" = "-y" ] || [ "$1" = "--yes" ]; then
    NON_INTERACTIVE=1
fi

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    WebRTC 项目启动脚本                         ║"
echo "║              适用于 macOS / Linux / Windows (Git Bash)        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ 错误: 未找到 Docker 命令${NC}"
    echo ""
    echo -e "${YELLOW}📦 请先安装 Docker Desktop:${NC}"
    echo "   - macOS:   brew install --cask docker 或 https://docs.docker.com/desktop/install/mac-install/"
    echo "   - Windows: https://docs.docker.com/desktop/install/windows-install/"
    echo "   - Linux:   https://docs.docker.com/desktop/install/linux-install/"
    echo ""
    exit 1
fi

# 检查 Docker 是否已启动
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ 错误: Docker 未运行${NC}"
    echo ""
    echo -e "${YELLOW}🚀 请启动 Docker Desktop${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker 已安装并运行${NC}"

# 检查 docker-compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ 错误: 未找到 docker compose 命令${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker Compose 可用${NC}"

# 检查 .env 文件
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  未找到 .env 文件，正在从 .env.example 创建...${NC}"
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ .env 文件已创建${NC}"
    else
        echo -e "${RED}❌ 错误: .env.example 文件不存在${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}🔧 配置项:${NC}"
echo "   - MySQL 端口:      $(grep '^MYSQL_PORT=' .env | cut -d'=' -f2)"
echo "   - 后端服务端口:    $(grep '^BACKEND_PORT=' .env | cut -d'=' -f2)"
echo "   - 前端端口:        $(grep '^FRONTEND_PORT=' .env | cut -d'=' -f2)"
echo "   - 前端运行模式:    $(grep '^FRONTEND_MODE=' .env | cut -d'=' -f2)"

echo ""
echo -e "${YELLOW}⏳ 正在停止旧容器（如果有）...${NC}"
docker compose down --remove-orphans 2>/dev/null || true

echo ""
echo -e "${YELLOW}🗑️  正在清理旧数据...${NC}"
if [ $NON_INTERACTIVE -eq 1 ]; then
    echo "   非交互模式: 保留数据卷"
else
    read -p "   是否清除 MySQL 数据卷? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose down -v --remove-orphans 2>/dev/null || true
        echo -e "${GREEN}✅ 数据卷已清除${NC}"
    fi
fi

echo ""
echo -e "${YELLOW}🔨 正在构建镜像...${NC}"
docker compose build

echo ""
echo -e "${YELLOW}🚀 正在启动服务...${NC}"
docker compose up -d

echo ""
echo -e "${YELLOW}⏳ 等待服务启动...${NC}"
echo ""

# 等待服务健康检查
MAX_RETRIES=30
RETRY_COUNT=0

echo -e "${BLUE}📊 服务状态:${NC}"
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    STATUS=$(docker compose ps --format "table {{.Name}}\t{{.Service}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || docker-compose ps)
    clear
    echo -e "${BLUE}📊 服务状态 (尝试 $((RETRY_COUNT+1))/$MAX_RETRIES):${NC}"
    echo "$STATUS"
    
    # 检查所有服务是否健康
    HEALTHY_COUNT=$(docker compose ps -q | xargs docker inspect -f '{{.State.Health.Status}}' 2>/dev/null | grep -c "healthy" || echo 0)
    TOTAL_SERVICES=$(docker compose config --services | wc -l | tr -d '[:space:]')
    
    if [ "$HEALTHY_COUNT" -eq "$TOTAL_SERVICES" ]; then
        echo ""
        echo -e "${GREEN}✅ 所有服务已启动并健康!${NC}"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT+1))
    sleep 2
done

if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo ""
    echo -e "${RED}⚠️  服务启动可能较慢，请检查日志${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}                   🎉 启动成功! 🎉${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}🌐 访问地址:${NC}"
echo "   前端应用:     http://localhost:$(grep '^FRONTEND_PORT=' .env | cut -d'=' -f2)"
echo "   后端API:      http://localhost:$(grep '^BACKEND_PORT=' .env | cut -d'=' -f2)"
echo "   MySQL:        localhost:$(grep '^MYSQL_PORT=' .env | cut -d'=' -f2)"
echo ""
echo -e "${BLUE}🔧 常用命令:${NC}"
echo "   查看日志:     ./logs.sh [服务名]"
echo "   停止服务:     ./stop.sh"
echo "   重启服务:     ./restart.sh"
echo "   进入容器:     docker compose exec [服务名] bash"
echo ""
echo -e "${BLUE}📝 说明:${NC}"
echo "   - WebRTC 需要 HTTPS 或 localhost 才能访问摄像头"
echo "   - 如需公网部署，请配置 HTTPS 和 TURN 服务器"
echo "   - 当前使用 Google STUN 服务器，公网部署建议添加 TURN"
echo ""

# 询问是否打开浏览器（非交互模式下自动打开）
if [ $NON_INTERACTIVE -eq 1 ]; then
    if command -v open &> /dev/null; then
        open "http://localhost:$(grep '^FRONTEND_PORT=' .env | cut -d'=' -f2)"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "http://localhost:$(grep '^FRONTEND_PORT=' .env | cut -d'=' -f2)"
    fi
else
    if command -v open &> /dev/null; then
        read -p "是否在浏览器中打开应用? (Y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            open "http://localhost:$(grep '^FRONTEND_PORT=' .env | cut -d'=' -f2)"
        fi
    elif command -v xdg-open &> /dev/null; then
        read -p "是否在浏览器中打开应用? (Y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            xdg-open "http://localhost:$(grep '^FRONTEND_PORT=' .env | cut -d'=' -f2)"
        fi
    fi
fi
