# 基于 Python 的 Debian 镜像构建环境
FROM python:3.12 AS builder

# 设置工作目录
WORKDIR /app

# 复制 requirements.txt 并安装依赖
COPY ./requirements.txt .
RUN pip install --no-cache-dir -U -r requirements.txt

# 安装 Chrome 和 ChromeDriver 的依赖包
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# 安装 Google Chrome 的前置步骤
RUN apt-get update && apt-get install -y wget gnupg2 --no-install-recommends \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list

# 安装 Google Chrome
RUN apt-get update && apt-get install -y google-chrome-stable --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# 下载并安装 ChromeDriver
ARG CHROMEDRIVER_VERSION=114.0.5735.90
RUN wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip \
    && unzip /tmp/chromedriver.zip -d /usr/local/bin/ \
    && rm /tmp/chromedriver.zip \
    && chmod +x /usr/local/bin/chromedriver

# 基于 Python 的 Debian 运行环境
FROM python:3.12

# 设置工作目录
WORKDIR /app

# 复制构建环境中的依赖、Chrome 和 ChromeDriver
COPY --from=builder /usr/local /usr/local
COPY --from=builder /usr/local/bin/chromedriver /usr/local/bin/chromedriver

# 安装 Google Chrome
RUN apt-get update && apt-get install -y \
    google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# 设置环境变量，以便 ChromeDriver 可以找到 Chrome 浏览器
ENV CHROME_BIN=/usr/bin/google-chrome
ENV CHROME_PATH=/usr/lib/google-chrome/

# 复制应用程序代码
COPY . /app

# 暴露端口
EXPOSE 3000

# 运行应用程序
ENTRYPOINT ["python", "./main.py"]