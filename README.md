# Containerised Conda Environments

## Overview

This repository is forked from [CMS Containerised Conda environments](https://github.com/coecms/cms-conda-singularity) 
which is an approach to deploying and maintaining large conda environments 
while reducing inode usage and increasing performance. It takes advantage of 
`singularity`'s ability to manage overlay and SquashFS filesystems.
 Each conda environment is consolidated into its own SquashFS file, and then 
 one or more of these SquashFS environments are loaded using components 
 of the environment. For more information on the CMS containerised environments, 
 see the [Conda hh5 environment setup page on the CMS Wiki](https://coecms.github.io/cms-wiki/resources/resources-conda-setup.html).


## Conda Environments

There are currently two environments configured in this repository:
- payu
- payu-dev

### Environment Directory Structure

Each conda environment should have the following files under its subdirectory in `environments/`:

- **`environment.yml`**: The conda environment file

- **`config.sh`**: 
 This script sets up environment variables required for the build, test, and deploy scripts. It requires at least the following to be set:
  - `ENVIRONMENT` - Name of the environment, e.g. `payu`
  - `FULLENV` - Name of the SquashFS file and script directories related to an environment version, e.g. `payu-1.1.6`
  - `MODULE_VERSION` - By default the module name is `conda` and so if the `MODULE_VERSION` is `payu-1.1.6`, the module can be loaded by `module load conda/payu-1.1.6`. Note that for payu, existing modules are loaded using `module load payu/1.1.6`. To achieve this, `MODULE_VERSION` is set to `1.1.6`, and `CONDA_MODULE_PATH` overrides the default variable in `/scripts/install_config.sh`.

- **`build_inner.sh`** (optional):
 This script can modify environment files during the `Build` script before the environment is compressed into a Squashfs file.

- **`deploy.sh`** (optional):
 This script runs once the environment has been deployed. It is useful for updating module files to a stable alias or to set a new default version.

- **`testconfig.yml`**:
 This is a configuration file used in the `test` job. This file specifies modules to skip loading, ignore exceptions, and modules to preload before testing.

### Releasing a New `payu` Environment

1. Clone this repository and create and checkout a new branch.
2. Modify the payu version in the conda environment file - `environments/payu/environment.yml`. If payu version is not set, it'll use the latest version in `access-nri` conda channel.
3. Modify `VERSION_TO_MODIFY` and `STABLE_VERSION` in `environments/payu/config.sh`. `VERSION_TO_MODIFY` builds a payu environment with this version, and `STABLE_VERSION` is used in deployment to set the default version for the modulefile.
4. Add any new packages or versions to `environment.yml` required for the next release.
5. Push the changes and open a Pull Request to the `main` branch of this repository (not the upstream `coecms/cms-conda-singularity` repository).
6. Once a Pull Request is open, it will request a sign-off for a `Build` and `Test` job that runs on Gadi. These jobs are performed in temporary locations, and so will not affect the production environments. 
7. Once the jobs have been completed successfully and the Pull Request has also been approved, the branch can be merged, and then the `Deploy` job will run.
8. Once deployed, check loading the new module with:

```shell
$ module use /g/data/vk83/modules
$ module load payu/VERSION
```

### Updating the `payu-dev` Environment

Payu-dev is Payu development conda environment that has the latest changes on [payu-org/payu](https://github.com/payu-org/payu) main branch. The deploy payu-dev workflow runs every day to check if there have been any new commits to payu. 
The workflow can also be triggered manually to add updates to packages, or once a Pull Request is merged that modifies the `payu-dev` environment files.

If a package needs to be added or has a version constraint, open a Pull Request that modifies `environments/payu-dev/environment.yml`. Note leave `VERSION_TO_MODIFY=dev` in `environments/payu-dev/config.sh` unchanged as a version is generated at the time of deployment to include the date-time, and the latest payu commit (e.g. `dev-20250116T002805Z-20a8e76`). In the pull request, it will run `Build` and `Test` using the default version in the environment file. Once the tests pass and the Pull Request has been approved and merged, the custom deploy payu-dev job will run.

The `payu-dev` environment can be loaded via running,
```shell
$ module use /g/data/vk83/prerelease/modules
$ module load payu/dev
```



## Deployed Conda Environment Components

Given a base install directory, the structure of apps and modules deployed
would look something like the following for `payu/1.1.6`
```bash
├── apps
│   ├── base_conda
│   │   ├── bin
│   │   │   └── micromamba # Micromamba used to install environments in build scripts
│   │   ├── envs
│   │   │   ├── payu-1.1.6 -> /opt/conda/payu-1.1.6 # Symlink to conda environment path inside the container
│   │   │   ├── payu-1.1.6.sqsh # Squashfs file used an overlay
│   │   └── etc
│   │       └── base.sif # Base singularity image
│   └── conda_scripts 
│       ├── launcher_conf.sh
│       ├── launcher.sh
│       ├── overrides
│       └── payu-1.1.6.d
│           ├── bin
│           │   ├── payu -> launcher.sh
│           │   ├── python3 -> launcher.sh
│           │   ├── # Launcher script symlinks for every entry point in the environment
│           │   ├── launcher_conf.sh
│           │   ├── launcher.sh # Runs commands inside the containerised environment
│           └── overrides # Contains symlinks to overrides
│  
└── modules
 └── payu
 ├──.common_v3 # Common Environment Module file
 ├──.1.1.6 # Custom module insert 
 └──1.1.6 -> .common_v3 # payu/1.1.6 module file symlink
```

Running `module load payu/1.1.6` adds launcher scripts in `apps/conda_scripts/payu-1.1.6.d/bin` to the `$PATH`. It also sets up environment variables as if `micromamba activate` was run on the micromamba environment. `SINGULARITYENV_PREPEND_PATH` is set to `/opt/conda/payu-1.1.6/bin` which modifies `$PATH` only inside a singularity container.

If outside the container, running `payu setup` command calls the launcher script, which runs a `singularity exec` command that uses the base container in `/apps/base_conda/etc/base.sif` and adds the overlay of the SquashFS file `apps/base_conda/envs/payu-1.1.6.sqsh`. The SquashFS is a read-only file system that is mounted onto the container at runtime. This means all the files in `apps/base_conda/envs/payu/opt/conda/payu-1.1.6` are now accessible inside the container. The launcher script then runs `payu setup` command inside the container. 

If the `payu setup` launcher script is invoked inside the container, it would instead run `payu setup` command directly.

## Github Workflows Overview

## Build script (`scripts/build.sh`)
  - If the base conda environment does not exist, it will be created. 
  - Using the base container, a mounting `/g` directory to a temporary directory on `/jobfs/` so it does not affect the production environments. Inside the container, it:
    - builds the micromamba environment
    - creates all required launcher scripts
    - sets up the modulefiles
    - runs any custom environment `build_inner.sh` scripts
  - Creates a SquashFS file of the environment and stages this file.
  - Once the build is done, archives the apps and modules files created into a tar file and stages this file.

## Test Script (`scripts/test.sh`)
  - Launches the container with the built SquashFS overlay
  - Run pytests that attempt to import all accessible Python modules.

## Deploy Script (`scripts/deploy.sh`)
  - Unpacks the archived tar file of the built environment to a temporary location
  - Rsyncs the apps and modules directories, and move the SquashFS file to the deployed locations.
  - Stores the archived tar file in the admin directory.

### Pull Request

On a Pull Request to the `main` branch of this repository, it will check for any changes to any changes to conda environment configuration files (under `environments/`). If changes are detected, it will build a base conda conda container on a Github runner, and request a signoff to deployment to a Gadi Github environment. Once approved, it will rsyncs the repository down and the built base container to Gadi, runs the build and test scripts which are submitted as PBS jobs.

### Deploy 
Once PR is merged, it will request a sign-off to deploy to a Gadi Github environment. Once approved, it will run the deploy script on a login node. This workflow does not run for the Payu-Dev environment so it gets all the latest changes on the main branch and is deployed with a custom version.

### Custom Payu-Dev Deploy

This workflow is triggered either on:
- a merged Pull Request that modifies any `payu-dev` environment files
- if there have been recent commits to [`payu-org/payu` repository's](https://github.com/payu-org/payu) `master` branch 
- if the workflow has been triggered manually 

It will request signoff to `Gadi Prerelease` environment. Once approved, it will generate a version of format `dev-$DATETIME-$GIT_COMMIT_HASH` and modify `payu-dev` environment files before rsyncing to the repository down to Gadi. It will re-run the build and test scripts to ensure it has the latest commits of `payu` and files use the correct version. It'll then deploy all required files to the Prerelease location on NCI. It'll set `payu/dev` module version to point to the deployed module version. Finally, it'll delete all old versions of `payu/dev` files, except the recently deployed version, and the previous `payu/dev` version which could be actively used at the time of the deployment. 

## Github Configuration

There are currently two Github Environments for deployment called `Gadi` and `Gadi Prerelease`. Any build, test, or deploy workflows that need to run on NCI, currently require a sign-off.

Repository settings:
- `vars.PRERELEASE_ENVIRONMENTS`: Space-separate list of quoted environments to deploy to prerelease directories (E.g. `"payu-dev"`)

### Github Environment settings:

Secrets required for SSH:
- `secrets.HOST`: Hostname for the environment
- `secrets.HOST_DATA`: Hostname for the data mover
- `secrets.SSH_USER`: Username for the account used for deployment
- `secrets.SSH_KEY`: Private SSH key for the user

Variables required for Build/Test/Deploy scripts:
- `secrets.REPO_PATH`: Directory path to sync repository to and all build and deploy scripts are run from. **Note:** Directory can't be in the `/g/data` directory as this directory `/g` is mounted to a `/jobfs` directory during the build script so the repository would not be accessible.
- `vars.CONDA_BASE` - Base deployment directory that contains `apps/` and `modules/` subdirectories (e.g for `Gadi`: `/g/data/vk83` and for `Gadi Prerelease`: `/g/data/vk83/prerelease/`). Currently, the build scripts expect `CONDA_BASE` directory to be in `/g/data`.
- `vars.ADMIN_DIR`: Directory to store staging and log files, and tar files of deployed conda environments (e.g. `/g/data/vk83/admin/conda_containers/prerelease`)
- `vars.APPS_USERS_GROUP`: Permissions of read and execute for files installed to apps and modules (e.g. `vk83`)
- `vars.APPS_OWNER`: User with read, write, and execute permissions for installed files
- `vars.PROJECT`: Project code used for build and test PBS jobs (e.g. `tm70`)
- `vars.STORAGE`: Storage directives for building and test PBS jobs (e.g. `gdata/vk83`)
