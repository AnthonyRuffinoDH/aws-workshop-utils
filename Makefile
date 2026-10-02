.PHONY: all init probe ssh gh git-init git-nuke help

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

## help: Show available targets
help:
	@echo "Usage: make [target]"
	@echo ""
	@sed -n 's/^##//p' $(MAKEFILE_LIST)
