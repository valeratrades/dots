#!/bin/sh

version=$(python ${HOME}s/help_scripts/bump_version.py $(pwd)/pyproject.toml)

rm -rf ./dist ./build
python -m build
twine upload ./dist/* -u __token__ -p $PYPI_KEY

push_git() {
	message="."
	if [ -n "$1" ]; then
		message="$@"
	fi
	git add -A && git commit -m "$message" && git tag "v${version}" && git push --follow-tags
}
push_git
