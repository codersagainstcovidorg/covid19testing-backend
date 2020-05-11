#!/bin/bash -eu
# Capture parameters
environment="${1:-"staging"}"; # if parameter is not received, defaults to 'staging'

###############################
#   Define color variables    #
###############################
BOLD=$'\e[1m';
UNDERLINE=$'\e[4m';
CYAN=$'\e[01;36m';
GREEN=$'\e[01;32m';
PURPLE=$'\e[01;35m';
RED=$'\e[01;31m';
YELLOW=$'\e[01;33m';
WHITE=$'\e[01;37m';
PLAIN=$'\e[00m';
RESET=$(tput sgr0);

###############################
#    Define business logic    #
###############################
# start the tunnel
echo "[${YELLOW}CAC${RESET}] Connecting to DB bastion";
./Users/jorge/code/codersagainstcovidorg/infra/start-tunnel.sh ${environment}

# start the tunnel
echo "[${YELLOW}CAC${RESET}] Connecting to DB bastion";
./Users/jorge/code/codersagainstcovidorg/infra/start-tunnel.sh ${environment}
