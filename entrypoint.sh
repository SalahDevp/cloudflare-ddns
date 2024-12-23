#!/bin/bash

if [ -z "$CRON_SCHEDULE" ]; then
  CRON_SCHEDULE="* * * * *" # default every minute
fi

echo "$CRON_SCHEDULE /bin/bash /cf_ddns.sh" >> /etc/crontabs/root

crond -f
