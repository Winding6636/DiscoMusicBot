FROM python:3.7-alpine
LABEL maintainer="Winding"

# Const_pkg
RUN apk update \
&& apk add --no-cache \
  ca-certificates \
  ffmpeg \
  opus \
  python3 \
  libsodium-dev \
  bash \
  git \
  wget \
  curl \
  patch \
\
# Build-deps_pkg
&& apk add --no-cache --virtual .build-deps \
  gcc \
  g++ \
  libc-dev \
  libffi-dev \
  make \
  musl-dev \
  python3-dev

#Scripts
WORKDIR /usr/src/musicbot
RUN  git clone https://github.com/Winding6636/DiscoMusicBot.git /usr/src/musicbot \
&&git checkout modified&&git pull --tags
# pip依存関係をインストールする
RUN pip3 install --upgrade pip \
&& pip3 install --no-cache-dir -r requirements.txt
# nndownloadインスヨール
RUN git clone https://github.com/AlexAplin/nndownload.git /tmp/nndownload \
    && pip install -r /tmp/nndownload/requirements.txt \
    && pip install /tmp/nndownload && rm -rf /tmp/nndownload
ADD config /usr/src/musicbot/config
ADD .netrc /root/.netrc
RUN chmod og-rw /root/.netrc

# Patchs
#ADD ./env/ytdl_patch.sh /usr/src/musicbot
RUN sh ./env/ytdl_patch.sh

#Cleanup
RUN apk del .build-deps

# 構成をマッピングするためのボリュームを作成します
VOLUME /usr/src/musicbot/config
ENV APP_ENV=docker
ENTRYPOINT ["python3", "dockerentry.py"]
