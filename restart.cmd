@echo off
setlocal enabledelayedexpansion

REM 显示帮助信息
if "%1"=="-h" goto HELP
if "%1"=="--help" goto HELP

REM 检查是否为非交互模式
set NON_INTERACTIVE=0
if "%1"=="-y" set NON_INTERACTIVE=1
if "%1"=="--yes" set NON_INTERACTIVE=1

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                    WebRTC 项目重启脚本                         ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.

echo ⏳ 正在停止服务...
docker compose stop

echo 🔨 正在重新构建（如有变更）...
docker compose build

echo 🚀 正在启动服务...
docker compose up -d

echo ✅ 服务已重启!
echo.
echo 📊 服务状态:
docker compose ps

echo.
if !NON_INTERACTIVE! equ 0 (
    pause
)
exit /b 0

:HELP
echo WebRTC 项目重启脚本
echo.
echo 用法: %0 [选项]
echo.
echo 选项:
echo   -y, --yes    非交互模式
echo   -h, --help   显示此帮助信息
echo.
echo 示例:
echo   %0          交互模式重启
echo   %0 -y       非交互模式重启
exit /b 0
