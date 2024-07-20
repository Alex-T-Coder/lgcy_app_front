# lgcymatthewfe
# First of all install Pods and Ruby

## Ruby install

- Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

For more detailsl you can check https://docs.brew.sh/Installation

- Install rbenv
```bash
brew install rbenv
echo 'eval "$(rbenv init -)"' >> ~/.zshrc
source ~/.zshrc
```

- Install ruby version 3.3.3

```bash
rbenv install 3.3.3
rbenv global 3.3.3
```

- Check the version of ruby installed

```bash
ruby --version
```

## Pods install

- Install pod

```bash
sudo gem install cocoapods
```
