FROM debian:bookworm:slim

LABEL authors="danielpmc,luxxy"

RUN apt update \
    && apt upgrade -y \
    && apt -y install curl software-properties-common locales git \
    && apt-get -y install liblzma-dev \
    && apt-get -y install lzma \
    && adduser container \
    && apt-get update \ 
    && apt -y install cmake \
    && apt -y install wget

# Grant sudo permissions to container user for commands
RUN apt-get update && \
    apt-get -y install sudo
    
# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# NodeJS
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt -y install nodejs \
    && apt -y install ffmpeg \
    && apt -y install make \
    && apt -y install build-essential 
    
# Python 2 & 3
RUN apt update \
   && apt -y install zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev \
   && wget https://www.python.org/ftp/python/3.11.1/Python-3.11.1.tgz \
   && tar -xf Python-3.11.*.tgz \
   && cd Python-3.11.1 \
   && ./configure --enable-optimizations \
   && make -j $(nproc) \
   && make altinstall \
   && cd .. \
   && rm -rf Python-3.11.1 \
   && rm Python-3.11.*.tgz 
   
# Upgrade Pip
RUN apt -y install python python-pip python3-pip \
   && pip3 install --upgrade pip

# Golang
RUN curl -OL https://golang.org/dl/go1.19.5.linux-amd64.tar.gz \
   && tar -C /usr/local -xvf go1.19.5.linux-amd64.tar.gz   
ENV PATH=$PATH:/usr/local/go/bin
ENV GOROOT=/usr/local/go

#.NET Core Runtime and SDK
RUN wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
   && dpkg -i packages-microsoft-prod.deb \ 
   && rm packages-microsoft-prod.deb \
   && apt-get update \
   && apt-get install -y apt-transport-https \
   && apt-get update \
   && apt-get install -y aspnetcore-runtime-6.0 dotnet-sdk-6.0 

# Install the system dependencies required for puppeteer support
RUN apt-get install -y \
    fonts-liberation \
    gconf-service \
    libappindicator1 \
    libasound2 \
    libatk1.0-0 \
    libcairo2 \
    libcups2 \
    libfontconfig1 \
    libgbm-dev \
    libgdk-pixbuf2.0-0 \
    libgtk-3-0 \
    libicu-dev \
    libjpeg-dev \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpng-dev \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    xdg-utils

# Installing NodeJS dependencies for AIO.
RUN npm i -g yarn pm2 


USER container
ENV  USER container
ENV  HOME /home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]