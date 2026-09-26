git-hooks:
	@echo ">>> checking nix linting rules ..."
	cp .config/git/hooks/pre-commit .git/hooks/pre-commit

nixfmt:
	@echo ">>> formatting nix files ..."
	find . -type f -name "*.nix" -print0 | xargs -0 nix fmt

nixfmt-check:
	@echo ">>> formatting nix files ..."
	find . -type f -name "*.nix" -print0 | xargs -0 nix fmt -- --ci

