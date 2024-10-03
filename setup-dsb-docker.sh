#!/bin/bash

set -x

. "`dirname $0`/setup-lib.sh"

if [ -f $OURDIR/dsb-done ]; then
    exit 0
fi

logtstart "dsb"

# Variables
REPO_URL="https://github.com/docc-lab/DeathStarBench.git"
#DOCKER_IMAGE="deathstarbench/hotel-reservation"
#KUBERNETES_DIR="hotelReservation/kubernetes"  # Path to the Kubernetes directory within the repo

echo "setup deathstarbench in docker"

# Clone the repository
cd /local
git clone $REPO_URL

# Prepare workload generator
cd /local/DeathStarBench/wrk2
git submodule update --init --recursive ./deps/luajit/
sudo apt-get update
sudo apt-get install -y libssl-dev
sudo apt-get install -y libz-dev
sudo apt-get install -y luarocks
sudo luarocks install luasocket
sudo -H pip install asyncio
sudo -H pip install aiohttp

make all

# Pull hotelreservation docker images
#sudo docker pull $DOCKER_IMAGE

# Setup kubernetes cluster
#sudo kubectl apply -Rf /local/DeathStarBench/$KUBERNETES_DIR

echo "deathstarbench-docker setup complete"

logtend "dsb"

touch $OURDIR/dsb-done
exit 0