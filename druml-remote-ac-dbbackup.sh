#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1 || -z $PARAM_SITE || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-ac-dbbackup [--config=<path>] [--docroot=<path>]"
  echo "                                [--jobs=<number>] [--delay=<seconds>]"
  echo "                                --site=<subsite> | --list=<list>"
  echo "                                [--server=<number>]"
  echo "                                <environment>"
  exit 1
fi

# Read parameters.
SUBSITE=$(get_site_alias $PARAM_SITE)
ENV=$(get_environment ${ARG[1]})

# Set variables.
DRUSH=$(get_drush_command)
DRUSH_ALIAS=$(get_drush_alias $ENV)
SSH_ARGS=$(get_ssh_args $ENV $PARAM_SERVER)
DRUSH_SUBSITE_ARGS=$(get_drush_subsite_args $SUBSITE)
PROXY_PARAM_SERVER=$(get_param_proxy "server")

# Say Hello.
echo "=== Backup '$SUBSITE' DB at the $ENV"
echo ""

OUTPUT=$(ssh -Tn $SSH_ARGS "$DRUSH $DRUSH_ALIAS $DRUSH_SUBSITE_ARGS ac-database-instance-backup $SUBSITE" 2>&1)
RESULT="$?"
TASK=$(echo $OUTPUT | awk '{print $2}')

# Eixt upon an error.
if [[ $RESULT > 0 ]]; then
  echo "Error backing up DB."
  exit 1
fi
echo "$OUTPUT"
echo "Database backup scheduled."

# Check task status.
run_script remote-ac-status $PROXY_PARAM_SERVER $ENV $TASK
if [[ $? > 0 ]]; then
  echo "Database backup failed!"
  exit 1
fi

echo "Database backup completed!"
