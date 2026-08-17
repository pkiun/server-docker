FROM python:3.11-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        swig \
        git \
        pkg-config \
        libssl-dev \
        libffi-dev \
        zlib1g-dev \
        libjpeg-dev \
        libmagic-dev \
    && rm -rf /var/lib/apt/lists/*

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
COPY --from=builder /usr/local/bin/pupygen /usr/local/bin/pupygen

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME /data
ENV PUPY_WORKDIR=/data \
    PUPY_LISTEN="ssl 0.0.0.0:443"

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]