#!/usr/bin/make

.PHONY: all
all: install

.PHONY: install
install:
	if [ ! -f /usr/bin/python3 ]; then sudo apt install python3; fi;
	# Installing through pip instead of brew upon advice of
	# https://docs.ansible.com/ansible/latest/reference_appendices/python_3_support.html
	if [ ! -f ~/.local/bin/pipenv ]; then pip3 install pipenv; fi;
	if [ ! $$(find ~/.local/share/virtualenvs/ -name "dev_setup*") ]; then pipenv --three install; fi;
	if [ ! -d ~/.ansible/roles/gantsign.visual-studio-code ]; then pipenv run ansible-galaxy install gantsign.visual-studio-code; fi;

.PHONY: clean
clean:
	rm -rf $$(find ~/.local/share/virtualenvs/ -name "dev_setup*")
	rm -rf ~/.ansible/roles/gantsign.visual-studio-code

.PHONY: test
test:
	pipenv run ansible-lint -c .ansible-lint *.yml

.PHONY: run
run: test
	pipenv run ansible-playbook --vault-id .vault_pass -i inventory main.yml --ask-become-pass

.PHONY: secret
secret:
	if [ -f ./files/secrets.yml ]; then pipenv run ansible-vault edit ./files/secrets.yml; else pipenv run ansible-vault create ./files/secrets.yml; fi;
