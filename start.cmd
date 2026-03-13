@echo off
setlocal enabledelayedexpansion

REM ======================================================================
REM WebRTC 项目启动脚本 (适用于 Windows)
REM 一站式傻瓜式启动脚本
REM ======================================================================

REM 显示帮助信息
if "%1"=="-h" goto HELP
if "%1"=="--help" goto HELP

REM 检查是否为非交互模式
set NON_INTERACTIVE=0
if "%1"=="-y" set NON_INTERACTIVE=1
if "%1"=="--yes" set NON_INTERACTIVE=1

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                    WebRTC 项目启动脚本                         ║
echo ║                     适用于 Windows                            ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.

REM 检查 Docker 是否已安装
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误: 未找到 Docker 命令
    echo.
    echo 📦 请先安装 Docker Desktop:
    echo    https://docs.docker.com/desktop/install/windows-install/
    echo.
    pause
    exit /b 1
)

REM 检查 Docker 是否已启动
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误: Docker 未运行
    echo.
    echo 🚀 请启动 Docker Desktop
    echo.
    pause
    exit /b 1
)

echo ✅ Docker 已安装并运行

REM 检查 docker compose
docker compose version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误: 未找到 docker compose 命令
    pause
    exit /b 1
)

echo ✅ Docker Compose 可用

REM 检查 .env 文件
if not exist ".env" (
    echo ⚠️  未找到 .env 文件，正在从 .env.example 创建...
    if exist ".env.example" (
        copy ".env.example" ".env"
        echo ✅ .env 文件已创建
    ) else (
        echo ❌ 错误: .env.example 文件不存在
        pause
        exit /b 1
    )
)

REM 读取配置
for /f "tokens=2 delims==" %%a in ('findstr /b "MYSQL_PORT=" .env') do set MYSQL_PORT=%%a
for /f "tokens=2 delims==" %%a in ('findstr /b "BACKEND_PORT=" .env') do set BACKEND_PORT=%%a
for /f "tokens=2 delims==" %%a in ('findstr /b "FRONTEND_PORT=" .env') do set FRONTEND_PORT=%%a
for /f "tokens=2 delims==" %%a in ('findstr /b "FRONTEND_MODE=" .env') do set FRONTEND_MODE=%%a

echo.
echo 🔧 配置项:
echo    - MySQL 端口:      !MYSQL_PORT!
echo    - 后端服务端口:    !BACKEND_PORT!
echo    - 前端端口:        !FRONTEND_PORT!
echo    - 前端运行模式:    !FRONTEND_MODE!

echo.
echo ⏳ 正在停止旧容器（如果有）...
docker compose down --remove-orphans 2>nul

echo.
if !NON_INTERACTIVE! equ 1 (
    echo 🗑️  非交互模式: 保留数据卷
) else (
    set /p CLEAR_DATA=🗑️  是否清除 MySQL 数据卷? (y/N): 
    if /i "!CLEAR_DATA!"=="y" (
        docker compose down -v --remove-orphans 2>nul
        echo ✅ 数据卷已清除
    )
)

echo.
echo 🔨 正在构建镜像...
docker compose build
if %errorlevel% neq 0 (
    echo ❌ 构建失败
    pause
    exit /b 1
)

echo.
echo 🚀 正在启动服务...
docker compose up -d
if %errorlevel% neq 0 (
    echo ❌ 启动失败
    pause
    exit /b 1
)

echo.
echo ⏳ 等待服务启动...
echo.

set MAX_RETRIES=30
set RETRY_COUNT=0

:WAIT_LOOP
if !RETRY_COUNT! lss !MAX_RETRIES! (
    cls
    echo 📊 服务状态 (尝试 !RETRY_COUNT!/!MAX_RETRIES!):
    echo.
    docker compose ps --format "table {{.Name}}\t{{.Service}}\t{{.Status}}\t{{.Ports}}"
    
    REM 简单等待
    timeout /t 2 /nobreak >nul
    set /a RETRY_COUNT+=1
    goto WAIT_LOOP
)

echo.
echo ═══════════════════════════════════════════════════════════════
echo                    🎉 启动成功! 🎉
echo ═══════════════════════════════════════════════════════════════
echo.
echo 🌐 访问地址:
echo    前端应用:     http://localhost:!FRONTEND_PORT!
echo    后端API:      http://localhost:!BACKEND_PORT!
echo    MySQL:        localhost:!MYSQL_PORT!
echo.
echo 🔧 常用命令:
echo    查看日志:     logs.cmd [服务名]
echo    停止服务:     stop.cmd
echo    重启服务:     restart.cmd
echo.
echo 📝 说明:
echo    - WebRTC 需要 HTTPS 或 localhost 才能访问摄像头
echo    - 如需公网部署，请配置 HTTPS 和 TURN 服务器
echo    - 当前使用 Google STUN 服务器，公网部署建议添加 TURN
echo.

if !NON_INTERACTIVE! equ 1 (
    echo 🌐 非交互模式: 自动打开浏览器
    start http://localhost:!FRONTEND_PORT!
) else (
    set /p OPEN_BROWSER=是否在浏览器中打开应用? (Y/n): 
    if /i not "!OPEN_BROWSER!"=="n" (
        start http://localhost:!FRONTEND_PORT!
    )
)

echo.
echo ✨ 按任意键退出...
if !NON_INTERACTIVE! equ 0 (
    pause >nul
)
exit /b 0

:HELP
echo WebRTC 项目启动脚本
echo.
echo 用法: %0 [选项]
echo.
echo 选项:
echo   -y, --yes    非交互模式，自动使用默认值
echo   -h, --help   显示此帮助信息
echo.
echo 示例:
echo   %0          交互模式启动
echo   %0 -y       非交互模式启动
exit /b 0
