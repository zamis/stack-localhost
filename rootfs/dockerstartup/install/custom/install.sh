#!/usr/bin/env bash
set -ex

BASEDIR="$(dirname $(readlink -f $0))"
DEBIAN_FRONTEND=noninteractive
SKIP_CLEAN=false
KASM_RX_HOME=$STARTUPDIR/kasmrx
DONT_PROMPT_WSL_INSTALL="No_Prompt_please"
INST_DIR=$STARTUPDIR/install
INST_SCRIPTS="common/install-common.sh \
              common/install-soft.sh \
              certificates/install_ca_cert.sh \
              remmina/install_remmina.sh \
              docker/install-docker.sh \
              common/cleanup.sh"

for SCRIPT in $INST_SCRIPTS; do bash ${BASEDIR}/${SCRIPT} || exit 1; done
