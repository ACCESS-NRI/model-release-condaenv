### Update stable if necessary
CURRENT_STABLE=$( get_aliased_module "${MODULE_NAME}" "${MODULE_PATH}" )
NEXT_STABLE="${ENVIRONMENT}-${STABLE_VERSION}"

if ! [[ "${CURRENT_STABLE}" == "${MODULE_NAME}/${STABLE_VERSION}" ]]; then
    echo "Updating stable environment to ${NEXT_STABLE}"
    write_modulerc_stable "${STABLE_VERSION}" "${ENVIRONMENT}" "${CONDA_MODULE_PATH}" "${MODULE_NAME}"
    symlink_atomic_update "${CONDA_INSTALLATION_PATH}"/envs/"${ENVIRONMENT}" "${NEXT_STABLE}"
    symlink_atomic_update "${CONDA_SCRIPT_PATH}"/"${ENVIRONMENT}".d "${NEXT_STABLE}".d
fi