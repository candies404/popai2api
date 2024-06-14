# 使用多阶段构建
FROM python:alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装必要的依赖工具
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    curl \
    chromium \
    chromium-chromedriver

# 复制并安装 Python 依赖
COPY ./requirements.txt .
RUN pip install --no-cache-dir -U -r requirements.txt

# 最终镜像
FROM python:alpine

# 设置工作目录
WORKDIR /app

# 安装运行时必要的依赖工具
RUN apk add --no-cache \
    libstdc++ \
    chromium

# 复制 Python 环境和依赖
COPY --from=builder /usr/local /usr/local

# 创建 drivers 目录并复制 ChromeDriver
RUN mkdir -p /app/drivers
COPY --from=builder /usr/bin/chromedriver /drivers/chromedriver

# 复制应用程序代码
COPY . /app

# 暴露端口
EXPOSE 3000

# 入口点
ENTRYPOINT ["python", "./main.py"]
