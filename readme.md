# Wordpress installation script


## Quick start

- Copy this repository in the folder which will store your Wordpress
- Go to `_install` path
- Launch command `sh install.sh`


## Automated installation

- Create a copy of `_configuration.sample.sh` file named `configuration.sh` in the `_install` folder
- Edit `configuration.sh` file with right information
- Launch command `sh install.sh`

## Misc informations
- By default, Wordpress site will be installed in a `public` subfolder
- You can edit default options in the `include/configuration.default.sh` file
- `configuration.sh` file is ignored by git