# AWS Firewall FQDNs (firewall-aws)

Allows outbound traffic to AWS endpoints by generating FQDNs from botocore endpoint data for the firewall

## Example Usage

```json
"features": {
    "ghcr.io/trevorlauder/devcontainers/firewall-aws:1": {}
}
```

## Options

| Options Id | Description                                                                                                   | Type    | Default Value |
| ---------- | ------------------------------------------------------------------------------------------------------------- | ------- | ------------- |
| regions    | Comma-separated list of AWS regions to allow (e.g. 'us-east-1,us-west-2'). If empty, all regions are allowed. | string  | -             |
| fips       | Include FIPS endpoints (keys matching 'fips-_' or '_-fips').                                                  | boolean | false         |

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/trevorlauder/devcontainers/blob/main/src/firewall-aws/devcontainer-feature.json). Add additional notes to a `NOTES.md`._
