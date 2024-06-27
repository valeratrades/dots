## Copy
```sh
dots() {
    current_dir=$(pwd)
    cd /tmp
    rm -rf ./dots
    git clone --depth=1 https://github.com/valeratrades/dots
    cd dots
    ./main.sh load
    cd ..
    rm -rf ./dots
    cd $current_dir
}
dots
```
Or without `git`:
```sh
curl -sL https://github.com/valeratrades/dots/tree/master/load_dots_script.sh | bash
```

## Configure
To overwrite or add functionality, edit
```bash
${HOME}/.local.sh
```

### Cli Philosophie
Target length for general aliases is 2 characters, if they are important enough.
One-letter cases are mostly reserved for custom scripts, local to the project, eg: commands initialized when I `cs` into a directory with `run.sh` in it.

#### btw
i use arch btw
