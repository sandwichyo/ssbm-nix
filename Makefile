SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c

.PHONY: prefetch-url update update-slippi

# Auto-bump version *and* hash for the Slippi packages straight from their
# upstream GitHub releases. No more manual version/hash editing.
# Override the package set with PKGS="slippi-launcher slippi-netplay".
PKGS ?= slippi-launcher slippi-netplay slippi-playback

update update-slippi:
	@for pkg in $(PKGS); do \
		echo ">> nix-update $$pkg"; \
		nix run nixpkgs#nix-update -- --flake "$$pkg"; \
	done

# https://github.com/project-slippi/Ishiiruka-Playback/releases/download/v3.5.1/playback-3.5.1-Linux.zip
prefetch-url:
	@url="$${URL:-}"; \
	if [[ -z "$$url" ]]; then \
	  read -rp "Enter URL to prefetch: " url; \
	fi; \
	if [[ -z "$$url" ]]; then \
		echo "No URL provided." >&2; exit 1; \
	fi; \
	nix store prefetch-file "$$url"
