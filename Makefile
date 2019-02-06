
.PHONY: help submodules

help:
	@echo 'I still have not decided what the help is.'

ssh_keys:
	@if [ ! -f ssh_key/id_rsa ]; then ssh-keygen -b 2048 -t rsa -f ssh_key/id_rsa -N ''; fi

submodules:
	@helper_scripts/submodules.sh .submodules

init: ssh_keys submodules
