#!/bin/sh
# File is source on `cs` into the project's root. Allows to define a set of project-specific commands and aliases.

#alias r="sc lrun -- start"
alias a="cargo add"
alias patch="cargo set-version --bump patch && gg && cargo publish"
