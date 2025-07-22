# AppUp

> The command that can save you typing 15 characters or more, each time!

This is a fork of [Cloudstek/zsh-plugin-appup](https://github.com/Cloudstek/zsh-plugin-appup) with added support for Docker Compose V2.

[![CircleCI](https://circleci.com/gh/nguyenvinhloc1997/zsh-plugin-appup-dockerv2.svg?style=svg)](https://circleci.com/gh/nguyenvinhloc1997/zsh-plugin-appup-dockerv2)

This plugin adds `start`, `restart`, `stop`, `up` and `down` commands when it detects a docker-compose or Vagrant file
in the current directory (e.g. your application). Just run `up` and get coding! This saves you typing `docker compose` (V2)
or `docker-compose` (V1) or `vagrant` every time or aliasing them. Also gives you one set of commands that work for both environments.

### Docker

The plugin supports both Docker Compose V2 (`docker compose`) and V1 (`docker-compose`), defaulting to V2 when available. 
By default, running `up <name>` will use only the environment-specific compose file (e.g., `up dev` uses `docker-compose.dev.yml`). 
If you want to extend your configuration, set `APPUP_MERGE_COMPOSE=true` and running `up <name>` will use both `docker-compose.yml` and `docker-compose.<name>.yml`. 
For more on extending please see the [official docker documentation](https://docs.docker.com/compose/extends). Additional arguments
will be directly supplied to Docker Compose.

### Vagrant

Vagrant doesn't have a `down`, `restart`, `start` or `stop` commands natively but don't worry, that's been taken care of
and running those commands will actually run vagrant's equivalent commands. Additional arguments will be directly
supplied to vagrant.

### Command mapping

| Command | Vagrant command                                            | Docker command                                                |
|---------|------------------------------------------------------------|---------------------------------------------------------------|
| up      | [up](https://www.vagrantup.com/docs/cli/up.html)           | [up](https://docs.docker.com/compose/reference/up/)           |
| upd     |                                                            | [up -d](https://docs.docker.com/compose/reference/up/) (detached mode) |
| upbd    |                                                            | [up --build -d](https://docs.docker.com/compose/reference/up/) (build and run detached) |
| down    | [destroy](https://www.vagrantup.com/docs/cli/destroy.html) | [down](https://docs.docker.com/compose/reference/down/)       |
| downv   |                                                            | [down -v](https://docs.docker.com/compose/reference/down/) (remove volumes) |
| start   | [up](https://www.vagrantup.com/docs/cli/up.html)           | [start](https://docs.docker.com/compose/reference/start/)     |
| restart | [reload](https://www.vagrantup.com/docs/cli/reload.html)   | [restart](https://docs.docker.com/compose/reference/restart/) |
| stop    | [halt](https://www.vagrantup.com/docs/cli/halt.html)       | [stop](https://docs.docker.com/compose/reference/stop/)       |
| enter   |                                                            | [exec](https://docs.docker.com/compose/reference/exec/) /bin/bash -l (or custom command/shell, e.g. with `enter /bin/sh`)      |

## Migrating from Original Plugin

If you have the original appup plugin installed, follow these steps to migrate to this fork:

### oh-my-zsh users
1. Remove the existing plugin directory:
   ```bash
   rm -rf "$ZSH_CUSTOM/plugins/appup"
   ```

2. Install this fork (see Installation section below)

3. Restart your terminal or run:
   ```bash
   source ~/.zshrc
   ```

### Plain ZSH users
1. Remove the source line from your `~/.zshrc` that points to the old plugin
2. Delete the old plugin directory (wherever you cloned it)
3. Follow the Plain ZSH installation steps below
4. Restart your terminal or run:
   ```bash
   source ~/.zshrc
   ```

Note: Your existing configuration options in `~/.zshrc` (like `APPUP_CHECK_STARTED`, `APPUP_DOCKER_MACHINE`, etc.) will continue to work with this fork.

## Installation

### oh-my-zsh

1. Clone this repository in `$ZSH_CUSTOM/plugins/appup`:

   ```bash
   git clone https://github.com/nguyenvinhloc1997/zsh-plugin-appup-dockerv2.git "$ZSH_CUSTOM/plugins/appup"
   ```
2. Edit `~/.zshrc` and add `appup` to the list of plugins

### Plain ZSH

1. Clone this repository somewhere

2. Edit your `~/.zshrc` and add this line near the bottom of the file:

   ```bash
   source path/to/the/repository/appup.plugin.zsh
   ```

## Updating

1. Go to the directory where you cloned the plugin repository
2. Run `git pull origin master`

## Configuration options

AppUp has a few configuration options to customise its behaviour. Please make sure you define these in `~/.zshrc`
*before* you load any plugins.

Currently these options only affect docker.

| Name                    | Values     | Default | Description                                                                                                                                       |
|------------------------|------------|---------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| APPUP_CHECK_STARTED    | true/false | true    | Enable/disable checking if docker is running completely.                                                                                          |
| APPUP_DOCKER_MACHINE   | true/false | true    | If both docker (e.g. Docker Desktop) and docker-machine are installed, check if docker-machine (when `true`) or docker (when `false`) is running. |
| APPUP_LOAD_ENVS        | true/false | true    | When true, load .env, .env.local, .env.docker and .env.docker.local if they exist with `docker compose --env-file`.                             |
| APPUP_PREFER_COMPOSE_V2| true/false | true    | When true, prefer Docker Compose V2 (`docker compose`) over V1 (`docker-compose`) when both are available.                                       |
| APPUP_MERGE_COMPOSE    | true/false | false   | When true, merges base compose file with environment-specific file (e.g., `up dev` uses both `docker-compose.yml` and `docker-compose.dev.yml`). When false, uses only the environment-specific file if provided. | 

