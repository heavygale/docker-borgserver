#!/bin/bash
# Prune repositories

BORG_DATA_DIR=/backup
export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes

/home/borg/repokeys.sh

echo "########################################################"
echo " * Pruning ..."

for repo in $(ls $BORG_DATA_DIR/)
do
	for ((i=1; i<=${#REPONAME[@]}; i++))
	do
		if [[ ${REPONAME[$i]} == ${repo} ]]; then
			echo "  ** Pruning repository ${repo}"
			BORG_PASSPHRASE=${REPOKEY[$i]} borg prune ${BORG_PRUNE_OPTIONS} ${BORG_DATA_DIR}/${repo}
		fi
	done
done

echo " * Pruning finished!"
echo "########################################################"
