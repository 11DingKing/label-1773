# 多阶段构建: 第一阶段 - 构建
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

# 复制pom.xml并下载依赖
COPY pom.xml .
RUN mvn dependency:go-offline -DskipTests

# 复制源代码并构建
COPY src ./src
RUN mvn package -DskipTests -Dmaven.test.skip=true

# 多阶段构建: 第二阶段 - 运行
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# 安装curl用于健康检查
RUN apt-get update && apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# 设置时区为Asia/Shanghai
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 复制构建好的jar文件
COPY --from=builder /app/target/*.jar app.jar

# 设置JVM参数
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# 暴露端口
EXPOSE 8080

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
