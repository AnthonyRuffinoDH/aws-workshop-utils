.PHONY: all init probe ssh gh git-init git-nuke export-creds gen-docker-creds claude-docker help

all: init

## init: Full environment setup (probe + git-init)
init: probe git-init
	@echo "=================================================="
	@echo " WORKSPACE INITIALIZATION COMPLETE"
	@echo "=================================================="

## probe: Scan AWS identity, services, and environment capabilities
probe:
	@bash scripts/env_probe.sh

## git-init: Interactive Git + GitHub setup (identity, token, gh auth, cleanup)
git-init:
	@bash scripts/git_init.sh

## ssh: Generate or display SSH key for GitHub
ssh:
	@bash scripts/setup_ssh.sh

## gh: Check GitHub CLI auth status
gh:
	@bash scripts/setup_gh.sh

## git-nuke: Remove all git/GitHub credentials and reset identity
git-nuke:
	@bash scripts/git_nuke.sh

## export-creds: Print AWS + Claude env vars to paste into a local terminal
export-creds:
	@bash scripts/export_creds.sh

## gen-docker-creds: Print the make claude-docker command with creds baked in (run in cloud, paste locally)
gen-docker-creds:
	@bash scripts/gen_docker_creds.sh

## claude-docker: Launch a Docker container with Claude Code + AWS creds, current dir mounted
claude-docker:
	@AK=$(AK) SK=$(SK) ST=$(ST) bash scripts/claude_docker.sh

## help: Show available targets
help:
	@echo "Usage: make [target]"
	@echo ""
	@sed -n 's/^##//p' $(MAKEFILE_LIST)
