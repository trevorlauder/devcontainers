# Python Feature (python)

Configures Python tooling and optionally allows outbound traffic to Python endpoints for the firewall.

## Example Usage

```json
"features": {
    "ghcr.io/trevorlauder/devcontainers/python:1": {}
}
```

## Options

| Options Id     | Description                                                                         | Type    | Default Value |
| -------------- | ----------------------------------------------------------------------------------- | ------- | ------------- |
| enableFirewall | Generate FQDN allow-list entries for Python endpoints used by the firewall feature. | boolean | true          |
| username       | Username that owns created files and directories.                                   | string  | vscode        |

## Customizations

### VS Code Extensions

- `charliermarsh.ruff`

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/trevorlauder/devcontainers/blob/main/src/python/devcontainer-feature.json). Add additional notes to a `NOTES.md`._
