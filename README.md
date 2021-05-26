# dev_setup

[![Build Status](https://github.com/artis3n/dev-setup/workflows/Ansible/badge.svg)](https://github.com/artis3n/dev-setup/workflows/Ansible/badge.svg)
![GitHub Pipenv locked Python version (branch)](https://img.shields.io/github/pipenv/locked/python-version/artis3n/dev-setup/main?label=python)

## Usage

```bash
make install
make preprovision
# Restart the computer
export TAILSCALE_AUTH_KEY="..."
make provision-oryx
# or
make provision-lemur
```
