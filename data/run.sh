#!/bin/bash

BORG_DATA_DIR=/backup
chown borg /home/borg/prune.sh

# Parse environment
if [ w-z "${BORG_PRUNE_CRON}" ] ; then
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
	if [[ $key == "BORG_REPONAME_"* ]]; then
		client_name=$(echo $key | cut -f2 -d=)
		echo "REPONAME[$i]="$client_name >> /home/borg/repokeys.sh

		key_num=${key:14}
		key_num=$(echo ${key_num} | cut -f1 -d=)
		key_val=BORG_REPOKEY_$key_num
		if [ ! -z ${!key_val} ]; then
			echo "  ** Importing repokey for ${BORG_DATA_DIR}/${client_name}"
			echo "REPOKEY[$i]="${!key_val} >> /home/borg/repokeys.sh
			let i++
		else
			echo "  ** Repokey for ${BORG_DATA_DIR}/${client_name} is missing, either drop BORG_REPONAME_${key_num} or add BORG_REPOKEY_${key_num}!"
		fi
	fi
done

echo -e "${BORG_PRUNE_CRON} borg /home/borg/prune.sh >> /var/log/cron.log 2>&1\n" > /etc/cron.d/borg
cat /dev/null > /var/log/cron.log
chown borg /var/log/cron.log

echo " * Init done!"
echo "########################################################"
echo " * Starting CRON-Daemon"

/usr/sbin/cron
tail -f /var/log/cron.log
