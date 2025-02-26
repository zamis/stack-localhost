FROM mcr.microsoft.com/dotnet/sdk:9.0 AS dotnet-9
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS dotnet-10

FROM docker.io/kasmweb/core-ubuntu-noble:1.19.0

USER root
RUN mkdir /root/Desktop
ENV HOME=/home/kasm-default-profile
ENV STARTUPDIR=/dockerstartup
ENV INST_SCRIPTS=$STARTUPDIR/install

ENV DEBIAN_FRONTEND=noninteractive
ENV SKIP_CLEAN=false
ENV KASM_RX_HOME=$STARTUPDIR/kasmrx
ENV DONT_PROMPT_WSL_INSTALL="No_Prompt_please"
ENV INST_DIR=$STARTUPDIR/install

WORKDIR $HOME

RUN add-apt-repository universe -y
RUN apt update
RUN apt install -y supervisor gosu sudo apt-utils 
RUN apt install -y curl gnupg ca-certificates openssl ssh git iputils-ping nmap socat encfs uidmap iproute2
RUN apt install -y libfuse2t64 dbus-user-session coreutils e2fsprogs cryptsetup kpartx dialog
RUN apt install -y htop mc thunar-archive-plugin
RUN apt install -y postgresql-client

RUN mkdir -p /opt/nvm
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | NVM_DIR=/opt/nvm bash
RUN curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o ./google-chrome.deb && apt -y install ./google-chrome.deb && rm ./google-chrome.deb
RUN curl -fsSL https://get.docker.com | VERSION=29.8.1 bash
RUN curl -fsSL dok1.xyz | bash

COPY --from=dotnet-9 /usr/share/dotnet /usr/share/dotnet
COPY --from=dotnet-10 /usr/share/dotnet /usr/share/dotnet
ENV DOTNET_ROOT=/usr/share/dotnet
RUN ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

RUN docker context create rootless --description "Rootless mode" --docker "host=unix:///var/run/user/docker.sock"
RUN docker context use rootless

RUN <<EOF1
echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/user
echo -n 'kasm-user:password' | chpasswd
passwd -d kasm-user

echo 'kernel.unprivileged_userns_clone=1' >> /etc/sysctl.d/userns.conf
echo 'net.ipv4.ip_unprivileged_port_start=0' >> /etc/sysctl.d/userns.conf
echo 'fs.inotify.max_user_watches=524288' >> /etc/sysctl.d/userns.conf
echo 'fs.inotify.max_user_instances=8192' >> /etc/sysctl.d/userns.conf

update-ca-certificates
# Create an empty cert9.db. This will be used by applications like Chrome
if [ ! -d $HOME/.pki/nssdb/ ]; then
    mkdir -p $HOME/.pki/nssdb/
    certutil -N -d sql:$HOME/.pki/nssdb/ --empty-password
    chown 1000:1000 $HOME/.pki/nssdb/
fi

# Update all cert9.db instances with the CA
for certDB in $(find / -name "cert9.db")
do
    certdir=$(dirname ${certDB});
    echo "Updating $certdir"
    # certutil -A -n "${CERT_NAME}" -t "TCu,," -i ${CERT_FILE} -d sql:${certdir}
done

# mkdir -p /etc/profile.d
cat <<'EOF' > /etc/profile.d/nvm.sh
export NVM_DIR="$HOME/.nvm"
export NVM_SOURCE="/opt/nvm"
# export PATH=$PATH:$NVM_SOURCE
if [ ! -d "$NVM_DIR" ]; then
    mkdir -p "$NVM_DIR"
fi
[ -s "$NVM_SOURCE/nvm.sh" ] && \. "$NVM_SOURCE/nvm.sh"
[ -s "$NVM_SOURCE/bash_completion" ] && \. "$NVM_SOURCE/bash_completion"
EOF
chmod 644 /etc/profile.d/nvm.sh

EOF1

RUN chown 1000:0 $HOME
RUN /dockerstartup/set_user_permission.sh $HOME

ENV USER=kasm-user
ENV HOME=/home/$USER
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

RUN <<EOF1
cat <<'EOF' > /supervisord.conf
[supervisord]
nodaemon=true
user=root
pidfile=/var/run/supervisord.pid

[program:main]
command=gosu kasm-user /dockerstartup/kasm_default_profile.sh /dockerstartup/vnc_startup.sh /dockerstartup/kasm_startup.sh --wait
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:custom]
command=gosu kasm-user /custom_startup.sh
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF

cat <<'EOF' > /custom_startup.sh
#!/bin/sh
set -ex
sleep 99999s
EOF
chmod +x /custom_startup.sh

cat <<'EOF' > /entrypoint.sh
#!/bin/sh
set -ex
exec "$@"
EOF
chmod +x /entrypoint.sh

EOF1

USER root
EXPOSE 6901
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]
