#!/bin/bash

sudo ln -s /local/pythia/etc/systemd/system/pythia.service /etc/systemd/system/
sudo ln -s /local/pythia/etc/pythia /etc/
chmod -R g+rwX /etc/pythia
chmod -R o+rwX /etc/pythia

chmod -R 777 /local/pythia/workloads

touch /local/setup/setup-pythia-done

chown geniuser -R /local