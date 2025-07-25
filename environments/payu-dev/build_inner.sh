### Custom install inner

# Fix shebang headers in payu entry points (issue with pip installed packages: https://github.com/ACCESS-NRI/MED-condaenv/issues/78)
for file in ${CONDA_INSTALLATION_PATH}/envs/${FULLENV}/bin/payu*; do
    # Using payu* to modify payu, payu-run, payu-collate, payu-sync files
    echo "Adding python header to $file"
    # Substitute the first line of file (e.g. 1s), if it starts with #! (regex ^#!/.*$),
    # with the python executable in the conda environment
    sed -i "1s|^#!/.*$|#!${CONDA_INSTALLATION_PATH}/envs/${FULLENV}/bin/python|" "$file"
done