FROM python:3.11-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        swig \
        git \
        patch \
        pkg-config \
        libssl-dev \
        libffi-dev \
        zlib1g-dev \
        libjpeg-dev \
        libmagic-dev \
    && rm -rf /var/lib/apt/lists/*

COPY patches /patches

RUN pip download --no-cache-dir http-parser==0.9.0 --no-deps --no-binary :all: -d /tmp/http-parser \
    && tar xzf /tmp/http-parser/http-parser-0.9.0.tar.gz -C /tmp/http-parser \
    && patch -p1 -d /tmp/http-parser < /patches/http-parser-py311.patch \
    && pip install --no-cache-dir --no-deps /tmp/http-parser/http-parser-0.9.0 \
    && rm -rf /tmp/http-parser

RUN pip install --no-cache-dir \
        git+https://github.com/n1nj4sec/pupy@nextgen

FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        libssl3 \
        libffi8 \
        libmagic1 \
        libjpeg62-turbo \
        ca-certificates \
        tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/pupysh /usr/local/bin/pupysh

COPY bin/pupygen /usr/local/bin/pupygen
RUN chmod +x /usr/local/bin/pupygen

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME /data
ENV PUPY_WORKDIR=/data \
    PUPY_LISTEN="ssl 0.0.0.0:443"

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]