#!/bin/bash
# Prune repositories

BORG_DATA_DIR=/backup
export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes

/home/borg/repokeys.sh

echo "########################################################"
echo " * Start pruning ..."

for repo in $(ls $BORG_DATA_DIR/)
do
	found_repo=0
	for ((i=1; i<=${#REPONAME[@]}; i++))
	do
		if [[ ${REPONAME[$i]} == ${repo} ]]; then
			found_repo=1
			echo "  ** Pruning repository ${repo} using provided repokey-passphrase"
			BORG_PASSPHRASE=${REPOKEY[$i]} borg prune ${BORG_PRUNE_OPTIONS} ${BORG_DATA_DIR}/${repo}
		fi
	done

	if [ $found_repo -eq 0 ]; then
		echo "  ** Pruning repository ${repo} without a repokey-passphrase"
		borg prune ${BORG_PRUNE_OPTIONS} ${BORG_DATA_DIR}/${repo}
	fi
done

echo " * Pruning finished!"
echo "########################################################"
