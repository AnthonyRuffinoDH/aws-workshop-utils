# aws-workshop-utils

Umbrella repo for utilities, scripts, and experiments built during an AWS workshop session.

## Quick Start

```bash
make init    # full setup: probe environment, SSH key, GH auth
make probe   # just scan AWS capabilities
make ssh     # just generate/show SSH key
make gh      # just check GH CLI auth
make help    # list all targets
```

## Structure

- `scripts/` — Bootstrap and environment setup scripts
- `aws/` — AWS service helpers and experiments
- `tools/` — Tunnel utilities, MCP bridges, CLI tools
