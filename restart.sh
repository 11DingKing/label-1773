#!/bin/bash
# ======================================================================
# WebRTC 项目重启脚本 (适用于 macOS 和 Linux)
# ======================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 显示帮助信息
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "WebRTC 项目重启脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -y, --yes    非交互模式"
    echo "  -h, --help   显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0          交互模式重启"
    echo "  $0 -y       非交互模式重启"
    exit 0
fi

# 检查是否为非交互模式
NON_INTERACTIVE=0
if [ "$1" = "-y" ] || [ "$1" = "--yes" ]; then
    NON_INTERACTIVE=1
fi

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    WebRTC 项目重启脚本                         ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}⏳ 正在停止服务...${NC}"
docker compose stop

echo -e "${YELLOW}🔨 正在重新构建（如有变更）...${NC}"
docker compose build

echo -e "${YELLOW}🚀 正在启动服务...${NC}"
docker compose up -d

echo -e "${GREEN}✅ 服务已重启!${NC}"
echo ""
echo -e "${BLUE}📊 服务状态:${NC}"
docker compose ps
