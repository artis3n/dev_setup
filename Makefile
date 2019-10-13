#!/usr/bin/make

.PHONY: all
all: install provision

.PHONY: install
install:
	if [ ! -f /usr/bin/python3 ]; then sudo apt install python3; fi;
	if [ ! -f ~/.local/bin/pipenv ]; then pip3 install pipenv; fi;
	if [ ! $$(find ~/.local/share/virtualenvs/ -name "dev_setup*") ]; then pipenv install; fi;
	if [ ! -d ~/.ansible/roles/gantsign.visual-studio-code ]; then pipenv run ansible-galaxy install gantsign.visual-studio-code; fi;
	if [ ! -d ~/.ansible/roles/artis3n.bitwarden_app ]; then pipenv run ansible-galaxy install artis3n.bitwarden_app; fi;
	pipenv run pre-commit autoupdate

.PHONY: clean
clean:
	pipenv --rm
	rm -rf ~/.ansible/roles/

.PHONY: lint
lint:
	pipenv run ansible-lint -c .ansible-lint *.yml

.PHONY: provision
provision:
	pipenv run ansible-playbook --vault-id .vault_pass -i inventory main.yml --ask-become-pass --skip-tags keybase

.PHONY: secret
secret:
	if [ -f ./files/secrets.yml ]; then pipenv run ansible-vault edit ./files/secrets.yml; else pipenv run ansible-vault create ./files/secrets.yml; fi;

.PHONY: reset-run
reset-run: clean install run
