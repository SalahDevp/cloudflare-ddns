FROM alpine:latest

RUN apk update && \
    apk add --no-cache curl bash openrc jq coreutils && \
    apk add --no-cache --virtual .build-deps curl

COPY entrypoint.sh /entrypoint.sh
COPY cf_ddns.sh /cf_ddns.sh

RUN chmod +x /cf_ddns.sh
RUN chmod +x /entrypoint.sh

ENV CRON_SCHEDULE="* * * * *"

ENTRYPOINT ["/entrypoint.sh"]
