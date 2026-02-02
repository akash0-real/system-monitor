FROM alpine:3.19 AS base

RUN apk add --no-cache \
    bash \
    procps \
    coreutils \
    util-linux \
    tzdata

RUN addgroup -S monitor && adduser -S monitor -G monitor && \
    mkdir -p /monitor/data && \
    chown -R monitor:monitor /monitor

WORKDIR /monitor

COPY --chown=monitor:monitor monitor.sh /monitor/monitor.sh

RUN chmod +x /monitor/monitor.sh

USER monitor

ENV TZ=UTC

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD test -f /monitor/data/metrics.json || exit 1

CMD ["sh", "-c", "while true; do /monitor/monitor.sh; sleep 60; done"]
