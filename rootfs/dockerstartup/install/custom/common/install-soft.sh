#!/usr/bin/env bash
set -ex

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

curl -fsSL https://pkgs.netbird.io/install.sh | sh

curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb >./google-chrome-stable_current_amd64.deb
apt -y install ./google-chrome-stable_current_amd64.deb
rm -f ./google-chrome-stable_current_amd64.deb
