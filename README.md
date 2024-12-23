# Cloudflare DDNS

A lightweight and efficient solution for Dynamic DNS (DDNS) updates using Cloudflare's API. This script checks your public IP address and updates your Cloudflare DNS record if it has changed.

## Features

- Updates Cloudflare DNS records dynamically based on public IP changes.
- Can be run as a standalone script or as a Dockerized cron job.

## Requirements

- A Cloudflare API token with permissions to manage DNS records.
- The `zone ID` and `record ID` of the DNS record you want to update.

## Usage

### 1. Run as a Standalone Bash Script

Clone the repository, ensure `curl`, `jq` are installed in your system and execute the script:

```bash
DOMAIN="your-domain.com" \
CF_API_TOKEN="your-cloudflare-api-token" \
CF_ZONE_ID="your-zone-id" \
CF_RECORD_ID="your-record-id" \
./cf_ddns.sh
```

### 2. Run as a Cron Job in Docker

Build the Docker image:

```bash
docker build -t cloudflare-ddns .
```

Run the container:

```bash
docker run -d \
    -e DOMAIN="your-domain.com" \
    -e CF_API_TOKEN="your-cloudflare-api-token" \
    -e CF_ZONE_ID="your-zone-id" \
    -e CF_RECORD_ID="your-record-id" \
    cloudflare-ddns
```

By default, the script runs as a cron job every minute. To modify the schedule, set the `CRON_SCHEDULE` environment variable.

Example:

```bash
docker run -d \
    -e DOMAIN="your-domain.com" \
    -e CF_API_TOKEN="your-cloudflare-api-token" \
    -e CF_ZONE_ID="your-zone-id" \
    -e CF_RECORD_ID="your-record-id" \
    -e CRON_SCHEDULE="*/5 * * * *" \
    cloudflare-ddns
```

This example runs the script every 5 minutes.

## Environment Variables

| Variable        | Description                                | Example                              |
| --------------- | ------------------------------------------ | ------------------------------------ |
| `DOMAIN`        | The Fully Qualified Domain Name (FQDN).    | `example.com`                        |
| `CF_API_TOKEN`  | Cloudflare API token with DNS permissions. | `your-api-token`                     |
| `CF_ZONE_ID`    | The Zone ID for your domain in Cloudflare. | `zone-id`                            |
| `CF_RECORD_ID`  | The DNS record ID to update.               | `record-id`                          |
| `CRON_SCHEDULE` | (Optional) Cron schedule for the job.      | `*/5 * * * *` (default: `* * * * *`) |

## License

This project is licensed under the MIT License.
