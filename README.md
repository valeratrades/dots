## Copy
```bash
#!/bin/sh
dots() {
    current_dir=$(pwd)
    cd /tmp
    rm -rf ./dots
    git clone --depth=1 https://github.com/Valera6/dots
    cd dots
    ./main.sh load
    cd ..
    rm -rf ./dots
    cd $current_dir
}
```
## Configure
To overwrite or add functionality, edit
```bash
${HOME}/.local.sh
```

#### btw
i use arch btw
