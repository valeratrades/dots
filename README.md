# Archived
All configuration are henceforth moved to Nix, and now reside [here](<https://github.com/valeratrades/nix>). This \`dots\` framework of mine was always a way to get some of the configurational power of nix (not knowing that was what I was searching for), so now it has outlived its purpose, as I see no reason to use anything but Nix for all of my machines and servers.

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
curl -sL https://github.com/valeratrades/dots/tree/master/load_dots.sh | bash
```

## Configure
Configuration is in `zsh`, so have to install it and run
```sh
chsh -s $(which zsh)
```
Then change [~/.zshrc] or/and [~/.config/zsh/]

### Cli Philosophie
Target length for general aliases is 2 characters, if they are important enough.
One-letter cases are mostly reserved for custom scripts, local to the project, eg: commands initialized when I `cs` into a directory with `run.sh` in it.

#### btw
i use arch btw
