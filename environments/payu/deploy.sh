### Update stable if necessary
CURRENT_STABLE=$( get_aliased_module "${MODULE_NAME}"/payu "${CONDA_MODULE_PATH}" )
NEXT_STABLE="${ENVIRONMENT}-${STABLE_VERSION}"

if ! [[ "${CURRENT_STABLE}" == "${MODULE_NAME}/${NEXT_STABLE}" ]]; then
    echo "Updating stable environment to ${NEXT_STABLE}"
    write_modulerc_stable "${NEXT_STABLE}" "${ENVIRONMENT}" "${CONDA_MODULE_PATH}" "${MODULE_NAME}"
    symlink_atomic_update "${CONDA_INSTALLATION_PATH}"/envs/"${ENVIRONMENT}" "${NEXT_STABLE}"
    symlink_atomic_update "${CONDA_SCRIPT_PATH}"/"${ENVIRONMENT}".d "${NEXT_STABLE}".d
fi