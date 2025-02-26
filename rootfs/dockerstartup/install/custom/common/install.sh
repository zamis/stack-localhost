#!/usr/bin/env bash
set -ex

add-apt-repository universe -y
apt-get update
apt-get install -y sudo apt-utils 
apt-get install -y libfuse2t64 dbus-user-session uidmap coreutils e2fsprogs cryptsetup kpartx dialog
apt-get install -y openssl iputils-ping nmap socat
apt-get install -y encfs ssh git htop mc thunar-archive-plugin
apt-get install -y postgresql-client

echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/user
echo -n 'kasm-user:password' | chpasswd
passwd -d kasm-user

echo 'kernel.unprivileged_userns_clone=1' >> /etc/sysctl.d/userns.conf
echo 'net.ipv4.ip_unprivileged_port_start=0' >> /etc/sysctl.d/userns.conf
echo 'fs.inotify.max_user_watches=524288' >> /etc/sysctl.d/userns.conf
echo 'fs.inotify.max_user_instances=8192' >> /etc/sysctl.d/userns.conf

echo "install additional soft"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb >./google-chrome-stable_current_amd64.deb
apt -y install ./google-chrome-stable_current_amd64.deb
rm -f ./google-chrome-stable_current_amd64.deb
