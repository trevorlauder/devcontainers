# AWS Feature (aws)

Configures AWS tooling and optionally allows outbound traffic to AWS endpoints for the firewall.

## Example Usage

```json
"features": {
    "ghcr.io/trevorlauder/devcontainers/aws:1": {}
}
```

## Options

| Options Id     | Description                                                                                                   | Type    | Default Value |
| -------------- | ------------------------------------------------------------------------------------------------------------- | ------- | ------------- |
| enableFirewall | Generate FQDN allow-list entries for AWS endpoints used by the firewall feature.                              | boolean | true          |
| regions        | Comma-separated list of AWS regions to allow (e.g. 'us-east-1,us-west-2'). If empty, all regions are allowed. | string  | -             |
| services       | Comma-separated list of AWS services to allow (e.g. 's3,ec2'). If empty, all services are allowed.            | string  | -             |
| fips           | Include FIPS endpoints (keys matching 'fips-_' or '_-fips').                                                  | boolean | false         |
| useGranted     | Install and setup Granted.                                                                                    | boolean | true          |
| username       | Username that owns created files and directories.                                                             | string  | vscode        |

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/trevorlauder/devcontainers/blob/main/src/aws/devcontainer-feature.json). Add additional notes to a `NOTES.md`._
