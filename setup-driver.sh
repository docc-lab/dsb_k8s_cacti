#!/bin/bash

set -x

# Preserve legacy main logfile location
ln -s /local/logs/setup.log /local/setup/setup-driver.log

ALLNODESCRIPTS="setup-ssh.sh setup-disk-space.sh"
HEADNODESCRIPTS_K8S="setup-nfs-server.sh setup-nginx.sh setup-ssl.sh setup-kubespray.sh setup-kubernetes-extra.sh setup-dsb-k8s.sh setup-end.sh"
HEADNODESCRIPTS_DOCKER="setup-nfs-server.sh setup-nginx.sh setup-ssl.sh setup-docker.sh setup-dsb-docker.sh setup-end.sh"
WORKERNODESCRIPTS="setup-nfs-client.sh"
#HEADNODESUDOS="setup-cacti.sh"

export SRC=`dirname $0`
cd $SRC
. $SRC/setup-lib.sh

chmod +x $SRC/setup-dsb-k8s.sh

# Don't run setup-driver.sh twice
if [ -f $OURDIR/setup-driver-done ]; then
    echo "setup-driver already ran; not running again"
    exit 0
fi
for script in $ALLNODESCRIPTS ; do
    cd $SRC
    $SRC/$script | tee - /local/logs/${script}.log 2>&1
    if [ ! $PIPESTATUS -eq 0 ]; then
	echo "ERROR: ${script} failed; aborting driver!"
	exit 1
    fi
done
if [ "$HOSTNAME" = "node-0" ]; then
  for script in $HEADNODESCRIPTS_$(cat /local/setup/app-type)
  do
	  cd $SRC
	  $SRC/$script | tee - /local/logs/${script}.log 2>&1
	  if [ ! $PIPESTATUS -eq 0 ]; then
	    echo "ERROR: ${script} failed; aborting driver!"
	    exit 1
	  fi
  done

  sudo su root -c "bash /local/repository/setup-cacti.sh"
else
    for script in $WORKERNODESCRIPTS ; do
	cd $SRC
	$SRC/$script | tee - /local/logs/${script}.log 2>&1
	if [ ! $PIPESTATUS -eq 0 ]; then
	    echo "ERROR: ${script} failed; aborting driver!"
	    exit 1
	fi
    done
fi

exit 0
