#!/usr/bin/make

.PHONY: all
all: dev-install

.PHONY: install
install:
	if [ ! -f /usr/bin/python3 ]; then sudo apt update && sudo apt install -y python3; fi;
	if [ ! -f /usr/bin/pip3 ]; then sudo apt update && sudo apt install -y python3-pip; fi;
	if [ ! -f ~/.local/bin/pipenv ]; then pip3 install --user pipenv; fi;
	if [ ! -d ~/.local/share/virtualenvs ]; then mkdir -p ~/.local/share/virtualenvs/; fi;
	if [ ! $$(find ~/.local/share/virtualenvs/ -name "dev-setup*") ]; then ~/.local/bin/pipenv install; fi;
	if [ ! -d ~/.ansible/roles/gantsign.visual-studio-code ]; then ~/.local/bin/pipenv run ansible-galaxy install gantsign.visual-studio-code; fi;
	if [ ! -d ~/.ansible/roles/artis3n.bitwarden_app ]; then ~/.local/bin/pipenv run ansible-galaxy install artis3n.bitwarden_app; fi;
	if [ ! -d ~/.ansible/collections/ansible_collections/artis3n/github ]; then ~/.local/bin/pipenv run ansible-galaxy collection install artis3n.github; fi;

.PHONY: dev-install
dev-install: install
	pipenv install --dev;

.PHONY: clean
clean:
	-~/.local/bin/pipenv --rm
	rm -rf ~/.ansible/roles/
	rm -rf ~/.ansible/collections/ansible_collections/artis3n/github

.PHONY: lint
lint:
	~/.local/bin/pipenv run ansible-lint -c .ansible-lint *.yml

.PHONY: provision
provision:
	~/.local/bin/pipenv run ansible-playbook --vault-id .vault_pass -i inventory main.yml --ask-become-pass

.PHONY: secret
secret:
	if [ -f ./files/secrets.yml ]; then ~/.local/bin/pipenv run ansible-vault edit ./files/secrets.yml; else ~/.local/bin/pipenv run ansible-vault create ./files/secrets.yml; fi;

.PHONY: test
test:
	pipenv run molecule test

.PHONY: reset-run
reset-run: clean install run
