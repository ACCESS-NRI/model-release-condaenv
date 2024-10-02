### Custom install inner to build jupyter lab extensions

# set +u
# eval "$( ${MAMBA} shell hook --shell bash)"
# micromamba activate "${CONDA_INSTALLATION_PATH}/envs/${FULLENV}"
# set -u

# jupyter lab build

# Patch payu shebang header with outer python executable that launches a container when run.
# This means when payu submits qsub commands (e.g. payu run), it uses this python executable and launches a container on PBS job
sed -i "1s|^#!/.*$|#!${CONDA_SCRIPT_PATH}/${FULLENV}.d/bin/python|" "${CONDA_INSTALLATION_PATH}/envs/${FULLENV}/bin/payu"