# Base Development Environment (base)

Base devcontainer image layer

## Example Usage

```json
"features": {
    "ghcr.io/trevorlauder/devcontainers/base:1": {}
}
```

## Options

| Options Id     | Description                                                                                                   | Type   | Default Value    |
| -------------- | ------------------------------------------------------------------------------------------------------------- | ------ | ---------------- |
| timezone       | Container timezone                                                                                            | string | America/Edmonton |
| chezmoiVersion | chezmoi version to install                                                                                    | string | 2.70.0           |
| username       | Username to create and use as the container user.                                                             | string | vscode           |
| homeDirs       | Comma-separated list of directories relative to $HOME to create as the container user (e.g. '.foo,.bar/baz'). | string | -                |

## Customizations

### VS Code Extensions

- `anthropic.claude-code`
- `eamodio.gitlens`
- `github.vscode-pull-request-github`
- `ms-azuretools.vscode-containers`
- `ms-python.python`

# Base Development Environment Feature

Provides a foundational devcontainer layer with zsh, mise (version management), chezmoi (dotfiles), and a restrictive allowlist-based firewall.

## Required Configuration

### Run Args

The firewall requires `NET_ADMIN` and `NET_RAW` capabilities:

```json
"runArgs": ["--cap-add=NET_ADMIN", "--cap-add=NET_RAW"]
```

### Mounts

Four mounts are recommended. The first two are named volumes scoped to the container so that shell history and Claude Code configuration survive rebuilds. The third is a shared mise cache so tool installs are not repeated across containers. The fourth is a bind mount for a per-project file that lets you add domains to the firewall allowlist.

```json
"mounts": [
  "source=shell-history-${localWorkspaceFolderBasename},target=/commandhistory,type=volume",
  "source=claude-code-config-${devcontainerId},target=/home/vscode/.claude,type=volume",
  "source=mise-cache,target=/home/vscode/.local/share/mise,type=volume",
  "source=${localWorkspaceFolder}/.devcontainer/firewall-extra-fqdns.txt,target=/usr/local/etc/firewall-extra-fqdns.d/extra-fqdns.txt,type=bind,consistency=cached"
]
```

## Firewall

The container starts an allowlist-based firewall that blocks all outbound traffic except to approved domains. GitHub IP ranges are fetched from the GitHub API at startup so they stay current without any manual updates.

The built-in allowlist is defined in `src/base/firewall-fqdns.txt`.

To allow additional domains, create `.devcontainer/firewall-extra-fqdns.txt` in your project with one domain per line and bind mount it into `/usr/local/etc/firewall-extra-fqdns.d/` as shown above. The firewall reads all files in that directory at startup, so other features or bind mounts can each contribute their own list of domains.

## Full Example

```json
{
  "name": "My Devcontainer Name",
  "image": "mcr.microsoft.com/devcontainers/base:trixie",
  "features": {
    "ghcr.io/trevorlauder/devcontainers/base:1": {}
  },
  "runArgs": ["--cap-add=NET_ADMIN", "--cap-add=NET_RAW"],
  "customizations": {
    "vscode": {
      "extensions": [],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "zsh",
        "terminal.integrated.profiles.linux": {
          "zsh": {
            "path": "zsh",
            "args": ["-l"]
          }
        }
      }
    }
  },
  "remoteUser": "vscode",
  "mounts": [
    "source=shell-history-${localWorkspaceFolderBasename},target=/commandhistory,type=volume",
    "source=claude-code-config-${devcontainerId},target=/home/vscode/.claude,type=volume",
    "source=mise-cache,target=/home/vscode/.local/share/mise,type=volume",
    "source=${localWorkspaceFolder}/.devcontainer/firewall-extra-fqdns.txt,target=/usr/local/etc/firewall-extra-fqdns.d/extra-fqdns.txt,type=bind,consistency=cached"
  ],
  "containerEnv": {
    "CLAUDE_CONFIG_DIR": "/home/vscode/.claude"
  },
  "remoteEnv": {
    "GITHUB_TOKEN": "${localEnv:GITHUB_TOKEN}"
  },
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind,consistency=delegated",
  "workspaceFolder": "/workspace",
  "postStartCommand": "/usr/local/bin/init-container.sh",
  "waitFor": "postStartCommand"
}
```

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/trevorlauder/devcontainers/blob/main/src/base/devcontainer-feature.json). Add additional notes to a `NOTES.md`._
