FROM debian:bookworm AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    gperf \
    git \
    libssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git
WORKDIR /src/telegram-bot-api/build
RUN cmake -DCMAKE_BUILD_TYPE=Release .. \
    && cmake --build . --target install --parallel 2

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bin/telegram-bot-api /usr/local/bin/telegram-bot-api

WORKDIR /app
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/telegram-bot-api", "--local", "--http-ip-address=0.0.0.0", "--http-port=8080", "--dir=/data", "--files-dir=/data"]
