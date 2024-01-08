#!/bin/bash

# This script upgrade all the dependencies that use the project to the latest stable version available

pre-commit-by-latest-release() {
	local repo_owner repo_name latest current
	local repo="${1}"
	repo_owner=$(echo "${repo}" | sed -e 's#^[^/]*//[^/]*\(/.*\)$#\1#' | cut -d '/' -f 2)
	repo_name=$(echo "${repo}" | sed -e 's#^[^/]*//[^/]*\(/.*\)$#\1#' | cut -d '/' -f 3)
	local releases_api_repo="https://api.github.com/repos/${repo_owner}/${repo_name}/releases/latest"
	latest=$(curl -f "${releases_api_repo}" | jq -r '.tag_name')
	current=$(yq ".repos[] | select(.repo == \"${repo}\") | .rev" .pre-commit-config.yaml)
	if [ "${latest}" != "${current}" ]; then
		echo "Error: ${repo} repo is not up to date, the current version is ${current} but the latest is ${latest}"
		yq -i "(.repos[] | select(.repo == \"${repo}\") | .rev) = \"${latest}\"" .pre-commit-config.yaml
		return 1
	else
		echo "Successful verification: ${repo} repo is up to date (${latest})"
		return 0
	fi
}

pre-commit-by-compute-latest-tag() {
	local repo_owner repo_name latest current
	local repo="${1}"
	repo_owner=$(echo "${repo}" | sed -e 's#^[^/]*//[^/]*\(/.*\)$#\1#' | cut -d '/' -f 2)
	repo_name=$(echo "${repo}" | sed -e 's#^[^/]*//[^/]*\(/.*\)$#\1#' | cut -d '/' -f 3)
	local releases_api_repo="https://api.github.com/repos/${repo_owner}/${repo_name}/tags"
	latest=$(curl -f "${releases_api_repo}" | jq -r '.[].name' | sort | tail -1)
	current=$(yq ".repos[] | select(.repo == \"${repo}\") | .rev" .pre-commit-config.yaml)
	if [ "${latest}" != "${current}" ]; then
		echo "Error: ${repo} repo is not up to date, the current version is ${current} but the latest is ${latest}"
		yq -i "(.repos[] | select(.repo == \"${repo}\") | .rev) = \"${latest}\"" .pre-commit-config.yaml
		return 1
	else
		echo "Successful verification: ${repo} repo is up to date (${latest})"
		return 0
	fi
}

pre-commit-by-latest-release "https://github.com/pre-commit/pre-commit-hooks"
pre-commit-by-latest-release "https://github.com/antonbabenko/pre-commit-terraform"
pre-commit-by-compute-latest-tag "https://github.com/jumanjihouse/pre-commit-hooks"
