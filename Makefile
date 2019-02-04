
.PHONY: help submodules

help:
	@echo 'I still have not decided what the help is.'

submodules:
	@helper_scripts/submodules.sh .submodules

init: submodules
