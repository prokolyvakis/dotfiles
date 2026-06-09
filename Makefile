.DEFAULT_GOAL := help

.PHONY: help install apply dotfiles system lint docker-test

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

install:  ## Install prerequisites (ansible collections + chezmoi)
	cd ansible && ansible-galaxy collection install -r requirements.yml
	@command -v chezmoi >/dev/null || sh -c "$$(curl -fsLS get.chezmoi.io)"

apply: system dotfiles  ## Full setup (ansible + chezmoi)

dotfiles:  ## Apply dotfiles only (chezmoi)
	chezmoi apply --source=home/

system:  ## Run system provisioning only (ansible)
	cd ansible && ansible-playbook playbook.yml --diff

lint:  ## Lint ansible + yaml
	yamllint -c .yamllint.yml ansible/
	cd ansible && ansible-lint playbook.yml

docker-test:  ## Run full setup in a clean Ubuntu container
	./scripts/docker-test.sh
