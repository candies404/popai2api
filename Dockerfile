# 使用多阶段构建
FROM python:3.9-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装必要的依赖工具
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    curl \
    wget \
    unzip && \
    apk add --no-cache \
    chromium && \
    CHROMEDRIVER_VERSION=$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE) && \
    wget -O /tmp/chromedriver.zip "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" && \
    unzip /tmp/chromedriver.zip -d /tmp/ && \
    mv /tmp/chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/chromedriver && \
    rm /tmp/chromedriver.zip && \
    pip install --no-cache-dir -r requirements.txt && \
    apk del .build-deps

# 最终镜像
FROM python:3.9-alpine

# 设置工作目录
WORKDIR /app

# 安装运行时必要的依赖工具
RUN apk add --no-cache \
    libstdc++ \
    chromium

# 复制 Python 环境和依赖
COPY --from=builder /usr/local /usr/local

# 创建 drivers 目录并复制 ChromeDriver
RUN mkdir -p /app/app/drivers && \
    cp /usr/local/bin/chromedriver /app/app/drivers/chromedriver && \
    chmod +x /app/app/drivers/chromedriver

# 复制应用程序代码
COPY . /app

# 暴露端口
EXPOSE 3000

# 切换到非 root 用户
#RUN adduser -D -u 1000 chromedriver && \
#    chown -R chromedriver:chromedriver /app
#USER chromedriver

# 入口点
ENTRYPOINT ["python", "./main.py"]
