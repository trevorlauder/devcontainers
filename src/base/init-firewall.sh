#!/bin/bash
set -euo pipefail

collect_range() {
    local range="${1}" context="${2}"
    local ip_regex='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(/[0-9]{1,2})?$'

    if [[ ! "${range}" =~ ${ip_regex} ]]; then
        echo "ERROR: Invalid range from ${context}: ${range}"
        exit 1
    fi

    ranges+="${range}"$'\n'
}

resolve_domain() {
    local domain="${1}"
    local ips

    echo "Resolving ${domain}..."
    ips=$(dig +noall +answer A "${domain}" | awk '$4 == "A" {print $5}')

    if [ -z "${ips}" ]; then
        echo "ERROR: Failed to resolve ${domain}"
        exit 1
    fi

    while read -r ip; do
        collect_range "${ip}" "DNS for ${domain}"
    done <<< "${ips}"
}

verify_blocked() {
    if curl --connect-timeout 5 "${1}" >/dev/null 2>&1; then
        echo "ERROR: ${1} should be blocked but is reachable"
        exit 1
    fi
    echo "OK: ${1} is blocked"
}

verify_allowed() {
    if ! curl --connect-timeout 5 "${1}" >/dev/null 2>&1; then
        echo "ERROR: ${1} is not reachable"
        exit 1
    fi
    echo "OK: ${1} is reachable"
}

docker_dns_rules=$(iptables-save -t nat | grep "127\.0\.0\.11" || true)
host_ip=$(ip route | grep default | cut -d" " -f3)
host_network="${host_ip%.*}.0/24"
ranges=""

if [ -z "${host_ip}" ]; then
    echo "ERROR: Failed to detect host IP"
    exit 1
fi

ip6tables -P INPUT   DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT  DROP

iptables -F
iptables -X
iptables -t nat    -F
iptables -t nat    -X
iptables -t mangle -F
iptables -t mangle -X

ipset destroy allowed-domains 2>/dev/null || true
ipset create allowed-domains hash:net
iptables -A OUTPUT -m set --match-set allowed-domains dst -j ACCEPT

if [ -n "${docker_dns_rules}" ]; then
    echo "Restoring Docker DNS rules..."
    iptables -t nat -N DOCKER_OUTPUT      2>/dev/null || true
    iptables -t nat -N DOCKER_POSTROUTING 2>/dev/null || true
    echo "${docker_dns_rules}" | xargs -L 1 iptables -t nat --
else
    echo "No Docker DNS rules to restore"
fi


iptables -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT  -p tcp --dport 22 -j ACCEPT

iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

echo "Host network detected as: ${host_network}"

iptables -A INPUT  -s "${host_network}" -j ACCEPT
iptables -A OUTPUT -d "${host_network}" -j ACCEPT

if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "Fetching GitHub IP ranges..."
    github_ranges=$(curl -s https://api.github.com/meta)
else
    echo "Fetching GitHub IP ranges with authentication..."
    github_ranges=$(curl -s -H "Authorization: Bearer ${GITHUB_TOKEN}" https://api.github.com/meta)
fi

if [ -z "${github_ranges}" ]; then
    echo "ERROR: Failed to fetch GitHub IP ranges"
    exit 1
fi

if ! echo "${github_ranges}" | jq -e '.web and .api and .git' >/dev/null; then
    echo "ERROR: GitHub API response missing required fields"
    exit 1
fi

echo "Processing GitHub IPs..."
while read -r cidr; do
    collect_range "${cidr}" "GitHub meta"
done < <(echo "${github_ranges}" | jq -r '(.web + .api + .git)[]')

echo "Processing FQDNs..."
while read -r domain; do
    resolve_domain "${domain}"
done < <(grep -shvE '^([[:space:]]*#|[[:space:]]*$)' \
    /usr/local/etc/firewall-fqdns.txt \
    /usr/local/etc/firewall-extra-fqdns.txt 2>/dev/null || true)

echo "Adding aggregated ranges..."
while read -r range; do
    echo "Adding ${range}"
    ipset add allowed-domains "${range}"
done < <(echo "${ranges}" | aggregate -q)

iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited

iptables -P INPUT   DROP
iptables -P FORWARD DROP
iptables -P OUTPUT  DROP

echo "Verifying firewall rules..."
verify_blocked https://example.com
verify_allowed https://api.github.com/zen
