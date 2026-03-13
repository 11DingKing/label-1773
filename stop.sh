#!/bin/bash
# ======================================================================
# WebRTC 项目停止脚本 (适用于 macOS 和 Linux)
# ======================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 显示帮助信息
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "WebRTC 项目停止脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -y, --yes      非交互模式，停止服务但保留数据卷"
    echo "  -v, --volumes  非交互模式，停止服务并删除数据卷"
    echo "  -h, --help     显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0            交互模式停止"
    echo "  $0 -y         非交互模式停止，保留数据"
    echo "  $0 -v         非交互模式停止，删除数据"
    exit 0
fi

# 检查是否为非交互模式
NON_INTERACTIVE=0
CLEAR_DATA="N"
if [ "$1" = "-y" ] || [ "$1" = "--yes" ]; then
    NON_INTERACTIVE=1
    CLEAR_DATA="N"
elif [ "$1" = "-v" ] || [ "$1" = "--volumes" ]; then
    NON_INTERACTIVE=1
    CLEAR_DATA="Y"
fi

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    WebRTC 项目停止脚本                         ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

if [ $NON_INTERACTIVE -eq 0 ]; then
    read -p "是否同时删除数据卷? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        CLEAR_DATA="Y"
    fi
fi

if [ "$CLEAR_DATA" = "Y" ]; then
    echo -e "${YELLOW}⏳ 正在停止服务并删除数据卷...${NC}"
    docker compose down -v --remove-orphans
    echo -e "${GREEN}✅ 服务已停止，数据卷已删除${NC}"
else
    echo -e "${YELLOW}⏳ 正在停止服务...${NC}"
    docker compose down --remove-orphans
    echo -e "${GREEN}✅ 服务已停止${NC}"
fi
