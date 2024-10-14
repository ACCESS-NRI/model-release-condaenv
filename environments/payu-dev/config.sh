### config.sh MUST provide the following:
### $FULLENV
###
### Arrays used by the build system (optional, can be empty)
### rpms_to_remove
### replace_from_apps
### outside_commands_to_include
### outside_files_to_copy

### Version settings
export ENVIRONMENT=payu-dev
export FULLENV="${ENVIRONMENT}"

declare -a rpms_to_remove=()
declare -a replace_from_apps=()
declare -a outside_commands_to_include=( "pbs_tmrsh" )
declare -a outside_files_to_copy=()
declare -a replace_with_external=()