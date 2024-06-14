# 基于 Python 的 Alpine 镜像构建环境
FROM python:3.12-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制 requirements.txt 并安装依赖
COPY ./requirements.txt .
RUN pip install --no-cache-dir -U -r requirements.txt

# 安装 Chromium 和 chromedriver
RUN apk add --no-cache \
    chromium \
    chromium-chromedriver

# 基于 Python 的 Alpine 运行环境
FROM python:3.12-alpine

# 设置工作目录
WORKDIR /app

# 从构建环境复制 Python 依赖
COPY --from=builder /usr/local /usr/local

# 安装 Chromium 浏览器及其依赖和 chromedriver
RUN apk add --no-cache \
    chromium \
    chromium-chromedriver \
    nss \
    freetype \
    harfbuzz \
    ttf-freefont

# 设置环境变量，以便 ChromeDriver 可以找到 Chrome 浏览器
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROMEDRIVER_PATH=/usr/bin/chromedriver

# 复制应用程序代码
COPY . /app

# 暴露端口
EXPOSE 3000

# 运行应用程序
ENTRYPOINT ["python", "./main.py"]