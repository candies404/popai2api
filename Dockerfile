# 基于 Python 的 Alpine 镜像构建环境
FROM python:3.12-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制 requirements.txt 并安装依赖
COPY ./requirements.txt .
RUN pip install --no-cache-dir -U -r requirements.txt

# 下载 ChromeDriver 的依赖包
RUN apk add --no-cache \
    wget \
    unzip \
    bash \
    chromium

# 下载并安装 ChromeDriver
ARG CHROMEDRIVER_VERSION=114.0.5735.90
RUN wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    mkdir -p /app/app/drivers && \
    unzip /tmp/chromedriver.zip -d /app/app/drivers/ && \
    rm /tmp/chromedriver.zip && \
    chmod +x /app/app/drivers/chromedriver

# 基于 Python 的 Alpine 运行环境
FROM python:3.12-alpine

# 设置工作目录
WORKDIR /app

# 复制构建环境中的依赖和 ChromeDriver
COPY --from=builder /usr/local /usr/local
COPY --from=builder /app/app/drivers /app/app/drivers

# 安装 Chromium 浏览器及其依赖
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ttf-freefont

# 设置环境变量，以便 ChromeDriver 可以找到 Chrome 浏览器
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/lib/chromium/

# 复制应用程序代码
COPY . /app

# 暴露端口
EXPOSE 3000

# 运行应用程序
ENTRYPOINT ["python", "./main.py"]
