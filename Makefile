#!/usr/bin/make

.PHONY: all
all: install

.PHONY: install
install:
	if [ ! -f /usr/bin/python3 ]; then sudo apt install -y python3; fi;
	if [ ! -f /usr/local/bin/pip3 ]; then sudo apt install -y python3-pip; fi;
	if [ ! -f ~/.local/bin/pipenv ]; then pip3 install pipenv; fi;
	if [ ! -d ~/.local/share/virtualenvs ]; then mkdir -p ~/.local/share/virtualenvs/; fi;
	if [ ! $$(find ~/.local/share/virtualenvs/ -name "dev_setup*") ]; then ~/.local/bin/pipenv install --python /usr/bin/python3; fi;
	if [ ! -d ~/.ansible/roles/gantsign.visual-studio-code ]; then ~/.local/bin/pipenv run ansible-galaxy install gantsign.visual-studio-code; fi;
	if [ ! -d ~/.ansible/roles/artis3n.bitwarden_app ]; then ~/.local/bin/pipenv run ansible-galaxy install artis3n.bitwarden_app; fi;

.PHONY: clean
clean:
	~/.local/bin/pipenv --rm
	rm -rf ~/.ansible/roles/

.PHONY: lint
lint:
	~/.local/bin/pipenv run ansible-lint -c .ansible-lint *.yml

.PHONY: provision
provision:
	~/.local/bin/pipenv run ansible-playbook --vault-id .vault_pass -i inventory main.yml --ask-become-pass --skip-tags keybase

.PHONY: secret
secret:
	if [ -f ./files/secrets.yml ]; then ~/.local/bin/pipenv run ansible-vault edit ./files/secrets.yml; else ~/.local/bin/pipenv run ansible-vault create ./files/secrets.yml; fi;

.PHONY: reset-run
reset-run: clean install run
