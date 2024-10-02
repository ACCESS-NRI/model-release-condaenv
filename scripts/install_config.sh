### Settings to control installation path e.g. for test installs
export CONDA_BASE="${CONDA_BASE:-/g/data/vk83/prerelease}" #TODO: Remove prerelease
export ADMIN_DIR="${ADMIN_DIR:-/g/data/vk83/admin/conda_concept}"
export CONDA_TEMP_PATH="${PBS_JOBFS:-${CONDA_TEMP_PATH}}"
export SCRIPT_DIR="${SCRIPT_DIR:-$PWD}"

export SCRIPT_SUBDIR="apps/conda_scripts"
export MODULE_SUBDIR="modules"
export APPS_SUBDIR="apps"
export CONDA_INSTALL_BASENAME="base_conda" #TODO: Replace with conda?
export MODULE_NAME="conda_concept" # TODO: Replace with conda?

### Derived locations - extra '.' for arcane rsync magic
export CONDA_SCRIPT_PATH="${CONDA_BASE}"/./"${SCRIPT_SUBDIR}"
export CONDA_MODULE_PATH="${CONDA_BASE}"/./"${MODULE_SUBDIR}"/"${MODULE_NAME}"
export JOB_LOG_DIR="${ADMIN_DIR}"/logs
export BUILD_STAGE_DIR="${ADMIN_DIR}"/staging

### Groups
# TODO: Replace tm70 with vk83? vk83_w?
export APPS_USERS_GROUP=tm70
export APPS_OWNERS_GROUP=tm70

### Other settings
export TEST_OUT_FILE=test_results.xml
export PYTHONNOUSERSITE=true
export CONTAINER_PATH="${SCRIPT_DIR}"/../container/base.sif
export SINGULARITY_BINARY_PATH="/opt/singularity/bin/singularity"

declare -a bind_dirs=( "/etc" "/half-root" "/local" "/ram" "/run" "/system" "/usr" "/var/lib/sss" "/var/lib/rpm" "/var/run/munge" "/sys/fs/cgroup" "/iointensive" )

if [[ "${CONDA_ENVIRONMENT}" ]]; then
    if [[ -e "${SCRIPT_DIR}"/../environments/"${CONDA_ENVIRONMENT}"/config.sh  ]]; then
        source "${SCRIPT_DIR}"/../environments/"${CONDA_ENVIRONMENT}"/config.sh
    else
        echo "ERROR! ${CONDA_ENVIRONMENT} config file missing!"
        exit 1
    fi
fi

### Define any undefined arrays
[[ -z ${rpms_to_remove+x} ]]              && declare -a rpms_to_remove=()              || true
[[ -z ${replace_from_apps+x} ]]           && declare -a replace_from_apps=()           || true
[[ -z ${outside_commands_to_include+x} ]] && declare -a outside_commands_to_include=() || true
[[ -z ${outside_files_to_copy+x} ]]       && declare -a outside_files_to_copy=()       || true
[[ -z ${replace_with_external+x} ]]       && declare -a replace_with_external=()       || true
