#!/bin/bash

set -x

cd /local

git clone https://github.com/docc-lab/cacti-dev.git pythia
sudo chmod -R 777 /local/pythia

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

source $HOME.cargo/env
rustup update stable

sudo chown geniuser -R /local/pythia

echo "phase 0" >> cargo_phases.txt
cargo update --manifest-path /local/pythia/Cargo.toml -p lexical-core > /local/lc0_out.txt 2> /local/lc0_err.txt
echo "phase 1" >> cargo_phases.txt
cargo update --manifest-path /local/pythia/pythia_server/Cargo.toml -p lexical-core > /local/lc1_out.txt 2> /local/lc1_err.txt
echo "phase 2" >> cargo_phases.txt
cargo install --locked --path /local/pythia > /local/pythia_out.txt 2> /local/pythia_err.txt
echo "phase 3" >> cargo_phases.txt
cargo install --locked --path /local/pythia/pythia_server > /local/pythia_server_out.txt 2> /local/pythia_server_err.txt
echo "phase 4" >> cargo_phases.txt

sudo ln -s /users/geniuser/.cargo/bin/pythia_server /usr/local/bin/
sudo ln -s /users/geniuser/.cargo/bin/pythia /usr/bin/pythia
sudo ln -s /local/pythia /users/geniuser/
sudo ln -s /local/dotfiles /users/geniuser/