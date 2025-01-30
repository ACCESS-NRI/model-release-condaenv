## Update stable if necessary
CURRENT_STABLE=$( get_aliased_module "${MODULE_NAME}" "${MODULE_PATH}" )
NEXT_STABLE="${ENVIRONMENT}-${STABLE_VERSION}"

if ! [[ "${CURRENT_STABLE}" == "${MODULE_NAME}/${STABLE_VERSION}" ]]; then
    echo "Updating default environment to ${NEXT_STABLE}"
    write_modulerc_stable "${STABLE_VERSION}" "default" "${CONDA_MODULE_PATH}" "${MODULE_NAME}"
fi