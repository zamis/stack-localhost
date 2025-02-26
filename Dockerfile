# syntax=docker/dockerfile:1.7-labs
FROM kasmweb/core-ubuntu-noble:1.18.0

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

# Copy install scripts
COPY /rootfs/dockerstartup/ /dockerstartup/
RUN bash /dockerstartup/install/custom/install.sh || exit 1;

RUN chown 1000:0 $HOME
RUN /dockerstartup/set_user_permission.sh $HOME

ENV USER=kasm-user
ENV HOME=/home/$USER
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
EXPOSE 6901
