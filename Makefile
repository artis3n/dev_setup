#!/usr/bin/make

.PHONY: all
all: install

.PHONY: install
install:
	if [ ! -f /usr/bin/python3 ]; then sudo apt install python3; fi;
	# Installing through pip instead of brew upon advice of
	# https://docs.ansible.com/ansible/latest/reference_appendices/python_3_support.html
	if [ ! -f ~/.local/bin/virtualenv ]; then pip3 install virtualenv; fi;
	if [ ! -d ./venv/ ]; then virtualenv -p python3 venv/ && venv/bin/pip3 install -r requirements.txt; fi;

.PHONY: clean
clean:
	rm -rf ./venv/

.PHONY: test
test:
	ansible-lint *.yml
