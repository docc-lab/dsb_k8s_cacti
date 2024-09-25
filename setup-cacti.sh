#!/bin/bash

set -x

DIRNAME=`dirname $0`

# Gotta know the rules!
if [ $EUID -ne 0 ] ; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Grab our libs
. "$DIRNAME/setup-lib.sh"

# Don't run setup-pythia.sh twice
if [ -f $OURDIR/setup-pythia-done ]; then
    echo "setup-pythia already ran; not running again"
    exit 0
fi

sudo apt-get pkg-config -y

# shellcheck disable=SC2045
for user in $(ls /users)
do
  su $user -c "bash /local/repository/setup-rust.sh"
done

# shellcheck disable=SC2164
cd /local
git clone https://github.com/docc-lab/cacti-dev.git pythia
chmod -R 777 /local/pythia
chown geniuser -R /local/pythia

mkdir dotfiles

echo "phase 0" >> cargo_phases.txt
su geniuser -c "cargo update --manifest-path /local/pythia/Cargo.toml -p lexical-core" > /local/lc0_out.txt 2> /local/lc0_err.txt
echo "phase 1" >> cargo_phases.txt
su geniuser -c "cargo update --manifest-path /local/pythia/pythia_server/Cargo.toml -p lexical-core" > /local/lc1_out.txt 2> /local/lc1_err.txt
echo "phase 2" >> cargo_phases.txt
su geniuser -c "cargo install --locked --path /local/pythia" > /local/pythia_out.txt 2> /local/pythia_err.txt
echo "phase 3" >> cargo_phases.txt
su geniuser -c "cargo install --locked --path /local/pythia/pythia_server" > /local/pythia_server_out.txt 2> /local/pythia_server_err.txt
echo "phase 4" >> cargo_phases.txt
sudo ln -s /users/geniuser/.cargo/bin/pythia_server /usr/local/bin/
sudo ln -s /users/geniuser/.cargo/bin/pythia /usr/bin/pythia
sudo ln -s /local/pythia /users/geniuser/
sudo ln -s /local/dotfiles /users/geniuser/

sudo ln -s /local/pythia/etc/systemd/system/pythia.service /etc/systemd/system/
sudo ln -s /local/pythia/etc/pythia /etc/
chmod -R g+rwX /etc/pythia
chmod -R o+rwX /etc/pythia

chmod -R 777 /local/pythia/workloads

sudo systemctl start pythia.service

touch $OURDIR/setup-pythia-done
logtend "pythia"

chown geniuser -R /local