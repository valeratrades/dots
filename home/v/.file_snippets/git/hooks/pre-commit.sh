#!/bin/sh

config_filepath="${HOME}/.config/PROJECT_NAME_PLACEHOLDER.toml"
if [ -f "$config_filepath" ]; then
  echo "Copying project's toml config to examples/"
  mkdir examples >/dev/null 2>&1
  cp -f $config_filepath ./examples/config.toml

  git add examples/

  if [ $? -ne 0 ]; then
    echo "Failed to copy project's toml config to examples"
    exit 1
  fi
fi

if [ -f "Cargo.toml" ]; then
  cargo sort
fi

exit 0
