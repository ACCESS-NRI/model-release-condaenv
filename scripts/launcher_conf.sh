### Subject to change
export SINGULARITY_BINARY_PATH="/opt/singularity/bin/singularity"
export CONTAINER_PATH="__CONDA_BASE__/__APPS_SUBDIR__/__CONDA_INSTALL_BASENAME__/etc/base.sif"
if [[ "${CONDA_EXE}" ]]; then
    export CONDA_BASE_ENV_PATH="${CONDA_EXE//\/bin\/micromamba/}"
else
    export CONDA_BASE_ENV_PATH="__CONDA_BASE__/__APPS_SUBDIR__/__CONDA_INSTALL_BASENAME__"
fi

declare -a bind_dirs=( "/etc" "/half-root" "/local" "/ram" "/run" "/system" "/usr" "/var/lib/sss" "/var/run/munge" "/sys/fs/cgroup" "/iointensive" )

# Set up the environment launcher script path - useful for scripts, such as payu,
# to know how launch the container directly
export ENV_LAUNCHER_SCRIPT_PATH="__CONDA_SCRIPT_PATH__/__FULLENV__.d/bin/launcher.sh"