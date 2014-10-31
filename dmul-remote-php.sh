#!/bin/sh

# Save script dir.
SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)

# Load includes.
source $SCRIPT_DIR/dmul-inc-init.sh

# Display help.
if [[ ${#ARG[@]} -lt 1 || -z $PARAM_SITE || -z $PARAM_SOURCE || -n $PARAM_HELP ]]
then
  echo "usage: dmul remote-php [--config=<path>] [--delay=<seconds>]"
  echo "                       [--site=<subsite> | --list=<list>]"
  echo "                       --source=<path> [--output=<path>]"
  echo "                       <environment>"
  exit 1
fi

# Load config.
source $SCRIPT_DIR/dmul-inc-config.sh

# Read parameters.
SUBSITE=$PARAM_SITE
ENV=$(get_environment ${ARG[1]})
SSH_ARGS=$(get_ssh_args $ENV)
DRUSH_ALIAS=$(get_drush_alias $ENV)
SOURCE=$(get_config_dir)/$PARAM_SOURCE
if [[ -n $PARAM_OUTPUT ]]
then
  OUTPUT=$(get_config_dir)/$PARAM_OUTPUT
fi

# Read commands to execute.
echo "=== Execute php commands for '$SUBSITE' subsite on the '$ENV' environment"
echo "Commands to be executed:"

while read -r LINE
do
  CODE+=$LINE
  echo $LINE
done < $SOURCE
echo ""

# Execute php code.
echo "Results:"
RES=$(ssh $SSH_ARGS "drush $DRUSH_ALIAS -l $SUBSITE php-eval '$CODE'")
echo $RES

# Output results to the file.
if [[ -n $OUTPUT ]]
then
  echo $RES >> $OUTPUT
fi

echo ""
echo "Complete!"
echo ""