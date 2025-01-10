# Switch payu-dev version

### Update payu-dev
DEV_ENV_ALIAS="${ENVIRONMENT}"-dev
NEXT_DEV_ENV="${ENVIRONMENT}-${VERSION_TO_MODIFY}"

echo "Updating dev environment to ${NEXT_DEV_ENV}"
write_modulerc_stable "${VERSION_TO_MODIFY}" "dev" "${CONDA_MODULE_PATH}" "${MODULE_NAME}"

### Remove old payu-dev versions
payu_dev_versions=$(ls "${CONDA_MODULE_PATH}" | grep -E '^dev-[0-9]{8}T[0-9]{6}Z-.*')
# Order module versions by date (versions format is dev-DATETIME-COMMIT),
# and remove the 2 latest versions (e.g. current and previous)
old_versions=$(echo "$payu_dev_versions" | sort -r | tail -n +3)

for old_version in $old_versions; do
    # Double check for empty strings to avoid deleting everything
    if [ -z "$old_version" ] || [ -z "${CONDA_MODULE_PATH}" ] || [ -z "${CONDA_SCRIPT_PATH}" ] || [ -z "${CONDA_INSTALLATION_PATH}" ]; then
        echo "Empty version or path variables, skipping removing environment"
        echo "  payu-dev version: $old_version"
        echo "  CONDA_MODULE_PATH: ${CONDA_MODULE_PATH}"
        echo "  CONDA_SCRIPT_PATH: ${CONDA_SCRIPT_PATH}"
        echo "  CONDA_INSTALLATION_PATH: ${CONDA_INSTALLATION_PATH}"
        continue
    fi

    # Remove modulefiles and module insert
    unlink "${CONDA_MODULE_PATH}"/"${old_version}"
    rm "${CONDA_MODULE_PATH}"/."${old_version}"
    # Remove launcher script directories
    rm -rf "${CONDA_SCRIPT_PATH}"/"${ENVIRONMENT}"-"${old_version}".d
    # Remove squashfs file
    rm "${CONDA_INSTALLATION_PATH}"/envs/"${ENVIRONMENT}"-"${old_version}".sqsh
    # Remove conda environment symlink
    unlink "${CONDA_INSTALLATION_PATH}"/envs/"${ENVIRONMENT}"-"${old_version}"

    echo "::notice::Removed payu/dev version: $old_version"
done
