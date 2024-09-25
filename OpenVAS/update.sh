#!/bin/bash

#--------------------------------------------------------------------------------------------------------------------
# 
# https://greenbone.github.io/docs/latest/22.4/source-build/workflows.html
#
# Updating to Newer Releases
#
# Stop the running services
# sudo systemctl stop gsad gvmd ospd-openvas openvasd
#
# Make sure the prerequisites are met and the Install prefix, the PATH and the env variables are set
# Uninstalling the old packages
# sudo python3 -m pip uninstall --break-system-packages ospd-openvas greenbone-feed-sync gvm-tools
#
# Updating the DB schema
# /usr/local/sbin/gvmd --migrate
#
# After all components are installed, restart the services
# sudo systemctl start gsad gvmd ospd-openvas openvasd
#
#---------------------------------------------------------------------------------------------------------------------


set -x

# Check if the current user is root
if [ "$(echo $USER)" == "root" ]; then
    echo "This script cannot be run as root."
    exit 1
else

	# Prerequisites
	sudo useradd -r -M -U -G sudo -s /usr/sbin/nologin gvm
	sudo usermod -aG gvm $USER
	#su $USER

	export INSTALL_PREFIX=/usr/local

	export PATH=$PATH:$INSTALL_PREFIX/sbin

	export SOURCE_DIR=$HOME/source
	mkdir -p $SOURCE_DIR

	export BUILD_DIR=$HOME/build
	mkdir -p $BUILD_DIR

	export INSTALL_DIR=$HOME/install
	mkdir -p $INSTALL_DIR

	sudo apt update
	sudo apt install --no-install-recommends --assume-yes \
	  build-essential \
	  curl \
	  cmake \
	  pkg-config \
	  python3 \
	  python3-pip \
	  gnupg

	curl -f -L https://www.greenbone.net/GBCommunitySigningKey.asc -o /tmp/GBCommunitySigningKey.asc
	gpg --import /tmp/GBCommunitySigningKey.asc

	echo "8AE4BE429B60A59B311C2E739823FAA60ED1E580:6:" | gpg --import-ownertrust

	# Uninstalling the old services
	sudo python3 -m pip uninstall --break-system-packages ospd-openvas greenbone-feed-sync gvm-tools

	# Updating DB Schema
	/usr/local/sbin/gvmd --migrate

	# Restarting all services
	sudo systemctl start gsad gvmd ospd-openvas openvasd

	######

	# Accessing the Web Interface Remotely
	# GSAD .service file
	cat << EOF > $BUILD_DIR/gsad.service
[Unit]
Description=Greenbone Security Assistant daemon (gsad)
Documentation=man:gsad(8) https://www.greenbone.net
After=network.target gvmd.service
Wants=gvmd.service

[Service]
Type=exec
User=gvm
RuntimeDirectory=gsad
RuntimeDirectoryMode=2775
PIDFile=/run/gsad/gsad.pid
ExecStart=/usr/local/sbin/gsad --foreground --listen=0.0.0.0 --port=9392 --http-only
Restart=always
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
Alias=greenbone-security-assistant.service
EOF

	# Installing the systemd service file for gsad
	sudo cp -v $BUILD_DIR/gsad.service /etc/systemd/system/

	# Must reload the services
	sudo systemctl daemon-reload

	# Restarting gsad
	sudo systemctl restart gsad

	# Verify if OpenVAS is running
	if curl -s http://127.0.0.1:9392/ | grep -q "Greenbone"; then
    	echo -e "\n\e[32m OpenVAS Updated http://localhost:9392/ \e[0m"
    	exit 1
    else
    	echo -e "\n\e[31mFailure: Greenbone not found\!\e[0m"
		exit 1
	fi
fi
