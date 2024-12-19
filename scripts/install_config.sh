### Settings to control installation path e.g. for test installs

# Environment that sets the base of paths for apps and modules directories
if [[ ! "${CONDA_BASE}" ]]; then
    echo "Error! CONDA_BASE must be defined"
    exit 1
fi
# Admin directory to store PBS logs and stage tar files of built environments
if [[ ! "${ADMIN_DIR}" ]]; then
    echo "Error! ADMIN_DIR must be defined"
    exit 1
fi

# Temporary path to build conda environments on PBS jobs
export CONDA_TEMP_PATH="${PBS_JOBFS:-${CONDA_TEMP_PATH}}"

# Script directory path that contains this repository, used to source and 
# copy across scripts and the base container image if built
export SCRIPT_DIR="${SCRIPT_DIR:-$PWD}"

# SCRIPT_SUBDIR contains the environment launcher scripts (for every file on 
# $PATH inside the squashfs environment) that launches a container and 
# runs commands inside the containerised environment
export CONDA_SCRIPTS_BASENAME="conda_scripts"
export SCRIPT_SUBDIR="apps/${CONDA_SCRIPTS_BASENAME}"
export MODULE_SUBDIR="modules"
export APPS_SUBDIR="apps"

# CONDA_INSTALL_BASENAME is a sub-directory in apps that contains the micromamba
# install and the envs sub-directory that contains a squashfs file for each
# environment and symlinks to in-container conda environment paths
export CONDA_INSTALL_BASENAME="base_conda" #TODO: Eventually replace with conda

# Modules are named $MODULE_NAME/$MODULE_VERSION where $MODULE_VERSION can
# be $ENVIRONMENT-$VERSION, (e.g. conda/analysis3-24.07)
# Note: this is currently over-ridden in the payu environment config
# so payu modules are named payu/$MODULE_VERSION (e.g. payu/1.1.5)
export MODULE_NAME="conda_container" # TODO: Eventually replace with conda

### Derived locations - extra '.' for arcane rsync magic
export CONDA_SCRIPT_PATH="${CONDA_BASE}"/./"${SCRIPT_SUBDIR}"
export CONDA_MODULE_PATH="${CONDA_BASE}"/./"${MODULE_SUBDIR}"/"${MODULE_NAME}"
export JOB_LOG_DIR="${ADMIN_DIR}"/logs
export BUILD_STAGE_DIR="${ADMIN_DIR}"/staging

### Groups
if [[ ! "${APPS_USERS_GROUP}" ]]; then
    echo "Error! APPS_USERS_GROUP must be defined"
    exit 1
fi
if [[ ! "${APPS_OWNER}" ]]; then
    echo "Error! APPS_OWNER must be defined"
    exit 1
fi

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

    # FULLENV is the name used for environment's launcher script subdirectory,
    # squashfs file name, and name of the environment inside of the container
    if [[ ! "${FULLENV}" ]]; then
        echo "Error! FULLENV must be defined in ${CONDA_ENVIRONMENT} config file"
        exit 1
    fi
    # MODULE_VERSION is the version name used for the modulefile
    if [[ ! "${MODULE_VERSION}" ]]; then
        echo "Error! MODULE_VERSION must be defined in ${CONDA_ENVIRONMENT} config file"
        exit 1
    fi
fi

### Define any undefined arrays
[[ -z ${rpms_to_remove+x} ]]              && declare -a rpms_to_remove=()              || true
[[ -z ${replace_from_apps+x} ]]           && declare -a replace_from_apps=()           || true
[[ -z ${outside_commands_to_include+x} ]] && declare -a outside_commands_to_include=() || true
[[ -z ${outside_files_to_copy+x} ]]       && declare -a outside_files_to_copy=()       || true
[[ -z ${replace_with_external+x} ]]       && declare -a replace_with_external=()       || true
