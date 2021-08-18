# Wordpress installation script


## Quick start

- Go to the folder in which you want to install wordpress
- Execute command `git clone git@github.com:deljdlx/wp-installer.git _install`
- Go to `_install` path
- Launch command `sh install.sh`

### Exemple

```sh
cd /var/www/html
mkdir customwordpress
cd customwordpress
git clone git@github.com:deljdlx/wp-installer.git _install
cd _install
sh install.sh
```


## Automated installation

- Create a copy of `_configuration.sample.sh` file named `configuration.sh` in the `_install` folder
- Edit `configuration.sh` file with right information
- Launch command `sh install.sh`

## Misc informations
- By default, Wordpress site will be installed in a `public` subfolder
- You can edit default options in the `include/configuration.default.sh` file
- `configuration.sh` file is ignored by git