#!/bin/bash

BORG_DATA_DIR=/backup
chown borg /hombe/borg/prune.sh

# Parse environment
if [ ! -z "${BORG_PRUNE_CRON}" ] ; then
	BORG_PRUNE_CRON="0 12 * * *"
fi
if [ -z "${BORG_PRUNE_OPTIONS}" ] ; then
        BORG_PRUNE_OPTIONS="--keep-daily=7 --keep-weekly=4 --keep-monthly=6"
fi

echo "########################################################"

echo " * Starting Repository-Password import..."

echo "BORG_PRUNE_OPTIONS='"$BORG_PRUNE_OPTIONS"'" > /home/borg/repokeys.sh
chmod +x /home/borg/repokeys.sh
i=1
for key in $(env); do
	if [[ $key == "BORG_REPOKEY_"* ]]; then
		echo "REPOKEY[$i]="$(echo $key | cut -f2 -d=) >> /home/borg/repokeys.sh
	fi
	if [[ $key == "BORG_REPONAME_"* ]]; then
		echo "REPONAME[$i]="$(echo $key | cut -f2 -d=) >> /home/borg/repokeys.sh
	fi
	let i++
done

echo -e "${BORG_PRUNE_CRON} borg /home/borg/prune.sh >> /var/log/cron.log 2>&1\n" > /etc/cron.d/borg
cat /dev/null > /var/log/cron.log
chown borg /var/log/cron.log

echo " * Init done!"
echo "########################################################"
echo " * Starting CRON-Daemon"

/usr/sbin/cron
tail -f /var/log/cron.log
