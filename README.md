# Info
This image is based on Nold360/docker-borgserver. It has been modified to run a conrjob which will prune all repositories. this image can't be accessed from outside, it's only meant for pruning old archives.

**NOTE Repositories using a keyfile are not supported.**

# BorgServer - Docker image
Debian based container image, running cron-daemon only. Not accessable for storing backups via ssh. Backup-Repositories will be access via persistent storage, all config is saved in environment variables.

### Environment Variables

#### BORG_PRUNE_OPTIONS
This variable is passed to `borg prune`, see available options in [the borg docs](https://borgbackup.readthedocs.io/en/stable/usage/prune.html). The default value it you don't set this variable is `--keep-daily=7 --keep-weekly=4 --keep-monthly=6`. Don't use single quotes in the value for this variable, they would break the code.

#### BORG_PRUNE_CRON
Use this varible to control the intervall in which the prune-cronjob will be executed. The default value if you don't set this variable is `0 12 * * *`. Make sure to choose a timeframe in which your repositories are not locked because of running borg-jobs (e.g. running backups via `borg create`).

##### Example
```
docker run -rm -e BORG_PRUNE_OPTIONS="--stats --keep-last 30" -e BORG_PRUNE_CRON="0 20 * * *" (...) heavygale/borgserver:crontab
```

#### BORG_REPONAME_#
For each of your encrypted or authenticated repositories, using a repokey-passphrase, you need to set one BORG_REPOKEY_#-variable and a according BORG_REPOKEY_#-variable.
E.g. you have two repositoys in /backup, server_a and server_b, and both weren't created with `--encryption=none` and therefore a repokey-passphrase is needed for accessing them. In this case you need to set the variables like this:
* BORG_REPONAME_1 = "server_a"
* BORG_REPOKEY_1 = "verySecurePassword"
* BORG_REPONAME_2 = "server_b"
* BORG_REPOKEY_2 = "hunter2"

Note: Repositoy-names containing whitespaces mode are not supported.

#### BORG_REPOKEY_#
See description for BORG_REPONAME_#

Note: repokey-passphrases containing whitespaces mode are not supported.

### Persistent Storage /backup
We need a persistent storage directory containing all the client data. Every repository found in this direcotory will be pruned automatically.

## Example Setup
### docker-compose.yml
Here is a quick example, how to run borgserver using docker-compose:
```
services:
 borgserver:
  image: heavygale/borgserver:crontab
  volumes:
   - /backup:/backup
  environment:
   BORG_PRUNE_CRON: "0 20 * * *"
```
