### config.sh MUST provide the following:
### $FULLENV
###
### Arrays used by the build system (optional, can be empty)
### rpms_to_remove
### replace_from_apps
### outside_commands_to_include
### outside_files_to_copy

### Optional config for custom deploy script
export VERSION_TO_MODIFY=1.1.5
export STABLE_VERSION=1.1.5
export UNSTABLE_VERSION=1.1.5

### Version settings
export ENVIRONMENT=analysis3
export FULLENV="${ENVIRONMENT}-${VERSION_TO_MODIFY}"

declare -a rpms_to_remove=( "openssh-clients" "openssh-server" "openssh" )
declare -a replace_from_apps=( "ucx/1.15.0" )
declare -a outside_commands_to_include=( "pbs_tmrsh" "ssh" )
declare -a outside_files_to_copy=()
declare -a replace_with_external=()