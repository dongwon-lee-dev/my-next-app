#!/bin/bash
sudo apt update
sudo apt install docker.io -y
sudo chmod 666 /var/run/docker.sock
sudo systemctl enable docker

