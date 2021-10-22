#!/usr/bin/env make

.PHONY: all
all: dev-install

.PHONY: install
install:
	if [ ! -f /usr/bin/python3 ]; then sudo apt update && sudo apt install -y python3; fi;
	if [ ! -f /usr/bin/pip3 ]; then sudo apt update && sudo apt install -y python3-pip; fi;
	if [ ! -f ~/.local/bin/pipenv ]; then pip3 install --user pipenv; fi;
	if [ ! -d ~/.local/share/virtualenvs ]; then mkdir -p ~/.local/share/virtualenvs/; fi;
	if [ ! $$(find ~/.local/share/virtualenvs/ -name "dev_setup*") ]; then ~/.local/bin/pipenv install; fi;
	if [ ! -f /usr/bin/git ]; then sudo apt install -y git; fi;
	~/.local/bin/pipenv run ansible-galaxy role install --force --role-file requirements.yml
	~/.local/bin/pipenv run ansible-galaxy collection install --upgrade --requirements-file requirements.yml

.PHONY: dev-install
dev-install: install
	~/.local/bin/pipenv install --dev;
	-if [ ! -f .git/hooks/pre-commit ]; then ~/.local/bin/pipenv run pre-commit install; fi;

.PHONY: update
update:
	pipenv update --dev
	pipenv run pre-commit autoupdate

.PHONY: clean
clean:
	~/.local/bin/pipenv --rm

.PHONY: lint
lint:
	~/.local/bin/pipenv run ansible-lint -c .ansible-lint

.PHONY: preprovision
preprovision:
	~/.local/bin/pipenv run ansible-playbook --limit lemur -i inventory pre.yml --ask-become-pass --force-handlers

.PHONY: provision-oryx
provision-oryx:
	 ~/.local/bin/pipenv run ansible-playbook --limit oryx -i inventory --extra-vars "TAILSCALE_AUTH_KEY=$TAILSCALE_AUTH_KEY" main.yml --ask-become-pass --force-handlers

.PHONY: provision-lemur
provision-lemur:
	~/.local/bin/pipenv run ansible-playbook --limit lemur -i inventory --extra-vars "TAILSCALE_AUTH_KEY=$TAILSCALE_AUTH_KEY" main.yml --ask-become-pass --force-handlers

.PHONY: test
test:
	pipenv run molecule test
