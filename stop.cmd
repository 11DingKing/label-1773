@echo off
setlocal enabledelayedexpansion

REM 显示帮助信息
if "%1"=="-h" goto HELP
if "%1"=="--help" goto HELP

REM 检查是否为非交互模式
set NON_INTERACTIVE=0
set CLEAR_DATA=N
if "%1"=="-y" (
    set NON_INTERACTIVE=1
    set CLEAR_DATA=N
)
if "%1"=="--yes" (
    set NON_INTERACTIVE=1
    set CLEAR_DATA=N
)
if "%1"=="-v" (
    set NON_INTERACTIVE=1
    set CLEAR_DATA=Y
)
if "%1"=="--volumes" (
    set NON_INTERACTIVE=1
    set CLEAR_DATA=Y
)

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                    WebRTC 项目停止脚本                         ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.

if !NON_INTERACTIVE! equ 0 (
    set /p CLEAR_DATA=是否同时删除数据卷? (y/N): 
)

if /i "!CLEAR_DATA!"=="y" (
    echo ⏳ 正在停止服务并删除数据卷...
    docker compose down -v --remove-orphans
    echo ✅ 服务已停止，数据卷已删除
) else (
    echo ⏳ 正在停止服务...
    docker compose down --remove-orphans
    echo ✅ 服务已停止
)

echo.
if !NON_INTERACTIVE! equ 0 (
    pause
)
exit /b 0

:HELP
echo WebRTC 项目停止脚本
echo.
echo 用法: %0 [选项]
echo.
echo 选项:
echo   -y, --yes      非交互模式，停止服务但保留数据卷
echo   -v, --volumes  非交互模式，停止服务并删除数据卷
echo   -h, --help     显示此帮助信息
echo.
echo 示例:
echo   %0            交互模式停止
echo   %0 -y         非交互模式停止，保留数据
echo   %0 -v         非交互模式停止，删除数据
exit /b 0
