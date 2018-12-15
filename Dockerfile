############################################################
# Dockerfile to build borgbackup server images
# for pruning repositories via cronjob
# Based on Debian
############################################################
FROM debian:buster-slim

# Volume for borg repositories
VOLUME /backup

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y --no-install-recommends install \
		borgbackup cron && apt-get clean && \
		useradd -s /bin/bash -m borg && \
		rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

COPY ./data/run.sh /run.sh
COPY ./data/prune.sh /home/borg/prune.sh

ENTRYPOINT /run.sh
