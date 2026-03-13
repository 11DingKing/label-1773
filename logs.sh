#!/bin/bash
# ======================================================================
# WebRTC 项目日志查看脚本 (适用于 macOS 和 Linux)
# ======================================================================

BLUE='\033[0;34m'
NC='\033[0m'

# 显示帮助信息
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "WebRTC 项目日志查看脚本"
    echo ""
    echo "用法: $0 [服务名] [--no-follow]"
    echo ""
    echo "选项:"
    echo "  --no-follow   不实时跟随日志"
    echo "  -h, --help    显示此帮助信息"
    echo ""
    echo "服务名可选: mysql, webrtc-service, webrtc-frontend"
    echo ""
    echo "示例:"
    echo "  $0                      查看所有服务日志（实时跟随）"
    echo "  $0 webrtc-service       查看后端服务日志（实时跟随）"
    echo "  $0 webrtc-frontend --no-follow  查看前端日志（不跟随）"
    exit 0
fi

if [ $# -eq 0 ]; then
    echo -e "${BLUE}📋 查看所有服务日志 (实时跟随)...${NC}"
    echo "   使用方法: $0 [服务名] [--no-follow]"
    echo "   服务名可选: mysql, webrtc-service, webrtc-frontend"
    echo ""
    docker compose logs -f --tail=100
else
    FOLLOW="-f"
    if [[ "$2" == "--no-follow" ]]; then
        FOLLOW=""
    fi
    docker compose logs $FOLLOW --tail=100 $1
fi
