#!/bin/bash
set -euo pipefail

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p /usr/local/etc/firewall-extra-fqdns.d

regions_array=$(echo "${REGIONS}" | tr ',' '\n' | jq -Rsc '[split("\n")[] | select(length > 0)]')

jq -r --argjson regions "${regions_array}" --argjson fips "${FIPS}" '
    .partitions[] | select(.partition == "aws") |
    . as $partition |
    .services | to_entries[] | . as $service |
    .value.endpoints | to_entries[] |
    .key as $region |
    (if .value.hostname then .value.hostname
     else "\($service.key).\($region).\($partition.dnsSuffix)"
     end) as $hostname |
    select($fips or ($hostname | test("fips"; "i") | not)) |
    select($regions | length == 0 or ($regions | contains([$region]))) |
    $hostname
' "${FEATURE_DIR}/botocore-endpoints.json" | sort -u \
    > /usr/local/etc/firewall-extra-fqdns.d/feature-firewall-aws-fqdns.txt
