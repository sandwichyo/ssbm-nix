SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c

.PHONY: prefetch-url

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
