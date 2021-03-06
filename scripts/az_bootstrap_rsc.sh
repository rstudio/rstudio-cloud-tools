#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
set -xe

export RSC_VERSION=${RSC_VERSION:-1.8.2-10}
export RSC_USERNAME=${RSC_USERNAME:-admin}
export RSC_PASSWORD=${RSC_PASSWORD:-rstudio}
export RSC_DATA_DIR=${RSC_DATA_DIR:-/mnt/rstudio-connect}
export MNT_USER=${MNT_USER:-rstudio-connect}
export MNT_GROUP=${MNT_GROUP:-rstudio-connect}
export R_VERSION=${R_VERSION:-3.6.3}
export PYTHON_VERSION=${PYTHON_VERSION:-3.8.1}
export ANACONDA_VERSION=${ANACONDA_VERSION:-Miniconda3-py38_4.8.2}
export DRIVERS_VERSION=${DRIVERS_VERSION:-1.6.1}
export RSPM_ADDRESS=${RSPM_ADDRESS}


# Utility scripts
mv ./wait-for-it.sh /usr/local/bin/wait-for-it.sh
chmod +x /usr/local/bin/wait-for-it.sh

# Install
bash ./install_r.sh
bash ./install_python.sh
bash ./install_drivers.sh
bash ./install_rsc.sh
DISK_MNT=${RSC_DATA_DIR} MNT_USER=${MNT_USER} MNT_GROUP=${MNT_GROUP} bash ./az_data_disk.sh
R_VERSIONS=${R_VERSION} PYTHON_VERSIONS=${PYTHON_VERSION} bash ./config_rsc.sh
bash ./rsc_start.sh
bash ./rsc_create_user.sh
