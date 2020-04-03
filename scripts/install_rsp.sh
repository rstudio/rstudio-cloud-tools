#!/bin/bash

set -xe

export DEBIAN_FRONTEND=noninteractive

if [[ -z "${RSP_VERSION}" ]]; then
    RSP_VERSION=1.2.5033-1
fi

# Use the first version of R and Python on the list as the default ones
for R_VER in ${R_VERSION}
do
    break;
done

# Use the first version of R and Python on the list as the default ones
for PYTHON_VER in ${PYTHON_VERSION}
do
    break;
done

# Install RSP
apt-get update
apt-get install -y gdebi-core
curl -O

curl -o /tmp/rstudio-server-pro-${RSP_VERSION}-amd64.deb https://download2.rstudio.org/server/trusty/amd64/rstudio-server-pro-${RSP_VERSION}-amd64.deb
gdebi --non-interactive /tmp/rstudio-server-pro-${RSP_VERSION}-amd64.deb
rm /tmp/rstudio-server-pro-${RSP_VERSION}-amd64.deb

# Set global R and python version
cat >/etc/profile.d/rstudio.sh <<EOL
export SHELL=/bin/bash
export PATH=/opt/R/${R_VER}/bin:/opt/python/${PYTHON_VER}/bin:$PATH
EOL

# Config RSP and Launcher -----------------------------------------------------

cat >/etc/rstudio/rserver.conf <<EOL
# Server Configuration File

www-port=80

server-project-sharing=0
server-health-check-enabled=1
admin-enabled=1
admin-group=rstudio-team

# Launcher Config
launcher-address=127.0.0.1
launcher-port=5559
launcher-sessions-enabled=1
launcher-default-cluster=Local
launcher-sessions-callback-address=http://127.0.0.1:80
EOL

cat >/etc/rstudio/launcher.conf <<EOL
[server]
address=127.0.0.1
port=5559
server-user=rstudio-server
admin-group=rstudio-server
authorization-enabled=1
thread-pool-size=4
enable-debug-logging=1

[cluster]
name=Local
type=Local
EOL

cat >/etc/rstudio/jupyter.conf <<EOL
jupyter-exe=/opt/python/jupyter/bin/jupyter
notebooks-enabled=1
labs-enabled=1

default-session-cluster=Local
EOL

cat >/etc/rstudio/rsession.conf <<EOL
#default-rsconnect-server=RSC_SERVER_ADDRESS
EOL

cat >/etc/rstudio/repos.conf <<EOL
#CRAN=RSPM_SERVER_ADDRESS
EOL

cat >/etc/rstudio/launcher-env <<EOL
JobType: any
Environment: PATH=/opt/R/${R_VER}/bin:/opt/python/${PYTHON_VER}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
EOL

# Create RSP user
adduser --disabled-password --gecos "" $USERNAME

# Set password
echo "$USERNAME:$PASSWORD" | chpasswd
groupadd rstudio-team
usermod -aG rstudio-team $USERNAME
# add default user to sudoers with no password
echo "$USERNAME ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

# enable and start services
systemctl enable rstudio-server
systemctl enable rstudio-launcher
systemctl start rstudio-server
systemctl start rstudio-launcher