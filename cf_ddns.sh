#!/bin/bash


# conf
RECORD_TYPE="A"

log() {
    local level="$1"
    shift
    local message="$@"
    echo "$(date +'%Y-%m-%d %H:%M:%S') [$level] $message"
}

check_env_vars() {
    local missing_vars=()
    
    if [ -z "$DOMAIN" ]; then
        missing_vars+=("DOMAIN")
    fi
    if [ -z "$CF_API_TOKEN" ]; then
        missing_vars+=("CF_API_TOKEN")
    fi
    
    if [ -z "$CF_ZONE_ID" ]; then
        missing_vars+=("CF_ZONE_ID")
    fi
    
    if [ -z "$CF_RECORD_ID" ]; then
        missing_vars+=("CF_RECORD_ID")
    fi
    
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        log "ERROR" "Missing required environment variables:"
        printf '%s
' "${missing_vars[@]}"
        log "INFO" "Please set the following environment variables:"
        log "INFO" "DOMAIN   - Your FQDN"
        log "INFO" "CF_API_TOKEN   - Your Cloudflare API token"
        log "INFO" "CF_ZONE_ID     - Your domain's zone ID"
        log "INFO" "CF_RECORD_ID   - The DNS record ID to update"
        exit 1
    fi
}

get_public_ip() {
    curl -s icanhazip.com
}

get_domain_ip() {
    local dns_ip=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$CF_RECORD_ID" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" \
        | jq -r '.result.content')
    echo "$dns_ip"
}

update_dns_record() {
    local new_ip=$1
    
    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$CF_RECORD_ID" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{
            \"type\":\"$RECORD_TYPE\",
            \"content\":\"$new_ip\",
            \"name\":\"$DOMAIN\"
        }" > /dev/null

    if [ $? -eq 0 ]; then
        log "INFO" "DNS record updated successfully to $new_ip"
    else
        log "ERROR" "Failed to update DNS record"
        exit 1
    fi
}

# Main 

check_env_vars

log "INFO" "Starting DNS update check"


CURRENT_IP=$(get_public_ip)

if [ -z "$CURRENT_IP" ]; then
    log "ERROR" "Failed to get current IP address"
    exit 1
fi

log "INFO" "Current public IP: $CURRENT_IP"

DOMAIN_IP=$(get_domain_ip)


if [ -z "$DOMAIN_IP" ]; then
    log "ERROR" "Failed to get DNS record IP"
    exit 1
fi

log "INFO" "Current DNS Record IP: $DOMAIN_IP"

if [ "$(printf '%s' "$CURRENT_IP")" != "$(printf '%s' "$DOMAIN_IP")" ]; then
    update_dns_record "$CURRENT_IP"
fi

log "INFO" "DNS update check completed"
