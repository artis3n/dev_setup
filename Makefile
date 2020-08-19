#!/usr/bin/env make

.PHONY: all
all: dev-install

.PHONY: install
install:
	if [ ! -f /usr/bin/python3 ]; then sudo apt update && sudo apt install -y python3; fi;
	if [ ! -f /usr/bin/pip3 ]; then sudo apt update && sudo apt install -y python3-pip; fi;
	if [ ! -f ~/.local/bin/pipenv ]; then pip3 install --user pipenv; fi;
	if [ ! -d ~/.local/share/virtualenvs ]; then mkdir -p ~/.local/share/virtualenvs/; fi;
	if [ ! $$(find ~/.local/share/virtualenvs/ -name "dev-setup*") ]; then ~/.local/bin/pipenv install; fi;
	if [ ! -f /usr/bin/git ]; then sudo apt install -y git; fi;
	~/.local/bin/pipenv run ansible-galaxy install -r requirements.yml
	~/.local/bin/pipenv run ansible-galaxy collection install -r requirements.yml

.PHONY: dev-install
dev-install: install
	~/.local/bin/pipenv install --dev;
	-if [ ! -f .git/hooks/pre-commit ]; then ~/.local/bin/pipenv run pre-commit install; fi;

.PHONY: clean
clean:
	-~/.local/bin/pipenv --rm
	rm -rf ~/.ansible/roles/
	rm -rf ~/.ansible/collections/ansible_collections/artis3n/github

.PHONY: lint
lint:
	~/.local/bin/pipenv run ansible-lint

.PHONY: preprovision
preprovision:
	~/.local/bin/pipenv run ansible-playbook --limit lemur -i inventory pre.yml --ask-become-pass --force-handlers

.PHONY: provision-oryx
provision-oryx:
	 ~/.local/bin/pipenv run ansible-playbook --limit oryx --vault-id .vault_pass -i inventory main.yml --ask-become-pass --force-handlers

.PHONY: provision-lemur
provision-lemur:
	~/.local/bin/pipenv run ansible-playbook --limit lemur --vault-id .vault_pass -i inventory main.yml --ask-become-pass --force-handlers

.PHONY: test
test:
	pipenv run molecule test

.PHONY: reset-run
reset-run: clean install provision
