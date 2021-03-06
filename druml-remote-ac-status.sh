#!/bin/bash

# Get Druml dir.
SCRIPT_DIR=$1
shift

# Load includes.
source $SCRIPT_DIR/druml-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 2 || -n $PARAM_HELP ]]
then
  echo "usage: druml remote-ac-status [--config=<path>] [--docroot=<path>]"
  echo "                              [--jobs=<number>] [--delay=<seconds>]"
  echo "                              [--server=<number>]"
  echo "                              <environment> <task_id>"
  exit 1
fi

# Read parameters.
ENV=$(get_environment ${ARG[1]})
TASK=${ARG[2]}

# Set variables.
DRUSH=$(get_drush_command)
DRUSH_ALIAS=$(get_drush_alias $ENV)
SSH_ARGS=$(get_ssh_args $ENV $PARAM_SERVER)

# Check task status every 20 seconds during 10 minutes.
I=0;
while [ $I -lt 1200 ]; do

  # Sleep random amount of time from 18 to 22 seconds
  sleep 18;
  _MULTIPLIER=4; _RND=$RANDOM*$_MULTIPLIER/32767; _RND=$(echo "scale=5; $_RND" | bc); sleep $_RND

  OUTPUT=$(ssh -Tn $SSH_ARGS "$DRUSH $DRUSH_ALIAS ac-task-info $TASK" 2>&1)
  RESULT="$?"

  while read -r LINE; do
    KEY=$(echo $LINE | awk '{print $1}')
    VAL=$(echo $LINE | awk '{print $3}')
    STATE=""

    if [[ "$KEY" = "state" ]]; then
        STATE=$VAL
        if [[ "$STATE" = "done" ]]; then
          echo "Task completed."
          exit 0
        fi
        if [ "$STATE" != "waiting" -a "$STATE" != "started" -a "$STATE" != "received" ]; then
          echo "Task failed, state: $STATE."
          exit 1
        fi
    fi
  done <<< "$OUTPUT"
  let I=$I+20;
done

echo "Task failed beause of timeout, last state: $STATE."
exit 1
