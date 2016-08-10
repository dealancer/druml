#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-ac-codedeploy [--config=<path>] [--docroot=<path>]"
  echo "                                  <environment from> <environment to>"
  exit 1
fi

# Read parameters.
SUBSITE=$PARAM_SITE
ENV_FROM=$(get_environment ${ARG[1]})
ENV_TO=$(get_environment ${ARG[2]})
DRUSH=$(get_drush_command)
DRUSH_ALIAS_FROM=$(get_drush_alias $ENV_FROM)
DRUSH_ALIAS_TO=$(get_drush_alias $ENV_TO)
SSH_ARGS=$(get_ssh_args $ENV_FROM)

# Say Hello.
echo "=== Deploying code from $ENV_FROM to $ENV_TO"
echo ""

OUTPUT=$(ssh -Tn $SSH_ARGS "$DRUSH $DRUSH_ALIAS_FROM ac-code-deploy $ENV_TO" 2>&1)
RESULT="$?"
TASK=$(echo $OUTPUT | awk '{print $2}')

# Eixt upon an error.
if [[ $RESULT > 0 ]]; then
  echo "Error deploying code."
  exit 1
fi
echo "$OUTPUT"
echo "Code deployment scheduled."

# Check task status.
OUTPUT=$(run_script remote-ac-status $ENV_FROM $TASK 2>&1)
RESULT="$?"
echo "$OUTPUT"
if [[ $RESULT > 0 ]]; then
  echo "Code deployment failed!"
  exit 1
fi

echo "Code deployment completed!"
