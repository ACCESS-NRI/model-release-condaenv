### config.sh MUST provide the following:
### $FULLENV $MODULE_VERSION
###
### Arrays used by the build system (optional, can be empty)
### rpms_to_remove
### replace_from_apps
### outside_commands_to_include
### outside_files_to_copy

### Optional config for custom deploy script
export VERSION_TO_MODIFY=1.1.6
export STABLE_VERSION=1.1.6

### Version settings
export ENVIRONMENT=payu
export FULLENV="${ENVIRONMENT}-${VERSION_TO_MODIFY}"
export MODULE_VERSION="${VERSION_TO_MODIFY}"

# Override general module path settings to name modulefiles payu/$VERSION
# in build scripts and custom deploy script
export MODULE_NAME="${ENVIRONMENT}"
export MODULE_PATH="${CONDA_BASE}"/./"${MODULE_SUBDIR}"
export CONDA_MODULE_PATH="${MODULE_PATH}"/"${MODULE_NAME}"

declare -a rpms_to_remove=()
declare -a replace_from_apps=()
declare -a outside_commands_to_include=( "pbs_tmrsh" )
declare -a outside_files_to_copy=()
declare -a replace_with_external=()
