#!/usr/bin/env bash
set -ex

BASEDIR="$(dirname $(readlink -f $0))"
DEBIAN_FRONTEND=noninteractive
SKIP_CLEAN=false
KASM_RX_HOME=$STARTUPDIR/kasmrx
DONT_PROMPT_WSL_INSTALL="No_Prompt_please"
INST_DIR=$STARTUPDIR/install

bash ${BASEDIR}/common/install.sh || exit 1;
bash ${BASEDIR}/certificates/install_ca_cert.sh || exit 1;
bash ${BASEDIR}/docker/install-docker.sh || exit 1;
bash ${BASEDIR}/common/cleanup.sh || exit 1;