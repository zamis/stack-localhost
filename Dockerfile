# syntax=docker/dockerfile:1.7-labs
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
RUN apt install -y sudo apt-utils
RUN apt install -y libfuse2t64 dbus-user-session uidmap coreutils e2fsprogs cryptsetup kpartx dialog
RUN apt install -y curl gnupg ca-certificates openssl ssh git iputils-ping nmap socat encfs uidmap iproute2
RUN apt install -y htop mc thunar-archive-plugin
RUN apt install -y postgresql-client

RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
RUN curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o ./google-chrome.deb && apt -y install ./google-chrome.deb && rm ./google-chrome.deb
RUN curl -fsSL https://get.docker.com/ | bash

# RUN docker context create dind --description "DinD" --docker "host=tcp://dind-dev:2376,ca=/certs/client/ca.pem,cert=/certs/client/cert.pem,key=/certs/client/key.pem"
# RUN docker context create rootless --description "Rootless mode" --docker "host=unix:///home/kasm-user/.docker/run/docker.sock"
# RUN docker context use dind
# RUN docker context use default

RUN <<EOF
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
EOF

# Copy install scripts
COPY /rootfs/dockerstartup/ /dockerstartup/

RUN chown 1000:0 $HOME
RUN /dockerstartup/set_user_permission.sh $HOME

ENV USER=kasm-user
ENV HOME=/home/$USER
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
EXPOSE 6901
