#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
set -xe

export RSP_VERSION=${RSP_VERSION:-1.2.5042-1}
export RSP_USERNAME=${RSP_USERNAME:-rstudio-user}
export RSP_PASSWORD=${RSP_PASSWORD:-rstudio}
export RSP_DATA_DIR=${RSP_DATA_DIR:-/mnt/rstudio}
export R_VERSION=${R_VERSION:-3.6.3}
export PYTHON_VERSION=${PYTHON_VERSION:-3.8.1}
export ANACONDA_VERSION=${ANACONDA_VERSION:-Miniconda3-py38_4.8.2}
export DRIVERS_VERSION=${DRIVERS_VERSION:-1.6.1}
export RSPM_ADDRESS=${RSPM_ADDRESS}
export RSC_ADDRESS=${RSC_ADDRESS}


# Utility scripts
mv ./wait-for-it.sh /usr/local/bin/wait-for-it.sh
chmod +x /usr/local/bin/wait-for-it.sh

cat >/tmp/r_packages.txt <<EOL
tidyverse
rmarkdown
shiny
tidymodels
data.table
packrat
odbc
sparklyr
reticulate
rsconnect
devtools
RCurl
tensorflow
keras
EOL

cat >/tmp/python_packages.txt <<EOL
altair
beautifulsoup4
cloudpickle
cython
dash
dask
flask
gensim
ipykernel
jupyterlab
matplotlib
nltk
notebook
numpy
pandas
pillow
plotly
pyarrow
requests
scipy
scikit-image
scikit-learn
scrapy
seaborn
spacy
sqlalchemy
statsmodels
tensorflow
keras
xgboost
rsp-jupyter
rsconnect-python
rsconnect-jupyter
EOL

# Install
bash ./install_r.sh
bash ./install_python.sh
PREFIX_NAME=jupyter bash ./install_python.sh
bash ./install_drivers.sh
bash ./install_rsp.sh
DISK_MNT=${RSP_DATA_DIR} MNT_USER=${MNT_USER} MNT_GROUP=${MNT_GROUP} bash ./az_data_disk.sh
R_VERSIONS=${R_VERSION} PYTHON_VERSIONS=${PYTHON_VERSION} bash ./config_rsp.sh
bash ./rsp_start.sh
bash ./rsp_create_user.sh
