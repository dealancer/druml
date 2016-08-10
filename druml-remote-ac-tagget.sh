#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1 || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-ac-tagget [--config=<path>] [--docroot=<path>]"
  echo "                              <environment>"
  exit 1
fi

# Read parameters.
ENV=$(get_environment ${ARG[1]})

# Set variables.
DRUSH=$(get_drush_command)
DRUSH_ALIAS=$(get_drush_alias $ENV)
SSH_ARGS=$(get_ssh_args $ENV)


# Get current tag/branch.
OUTPUT=$(ssh -Tn $SSH_ARGS "$DRUSH $DRUSH_ALIAS ac-environment-info" 2>&1)
RESULT="$?"

# Eixt upon an error.
if [[ $RESULT > 0 ]]; then
  exit 1
fi

# Serch for tag or branch
while read -r LINE; do
  KEY=$(echo $LINE | awk -F':' '{print $1}' | tr -d "\'")
  VAL=$(echo $LINE | awk -F':' '{print $2}' | tr -d "\'")
  if [[ $KEY = vcs_path* ]]; then
    # Output tag or branch
    echo $VAL | tr -d ' '
    exit
  fi
done <<< "$OUTPUT"

exit 1
