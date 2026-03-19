#!/bin/bash
# This is a script to prepare a Rocky Linux Minimal with the required prerequisites.

set -euo pipefail

color() {
    STARTCOLOR="\e[$2"
    ENDCOLOR="\e[0m"
    export "$1"="$STARTCOLOR%b$ENDCOLOR"
}

color info 96m
color success 92m
color warning 93m
color danger 91m

if [[ $EUID -ne 0 ]]; then
    printf "$danger" "This script must be run as root, for example: sudo ./rocky-setup.sh\n"
    exit 1
fi

printf "$info" "\nRocky Linux prerequisite setup for TAK Server\n"
printf "$warning" "This will install required tools and Docker Engine.\n"

printf "$info" "\n[1/5] Installing required base packages...\n"
dnf install -y \
    dnf-plugins-core \
    git \
    net-tools \
    unzip \
    zip \
    vim \
    ca-certificates \
    curl \
    java-17-openjdk \
    java-17-openjdk-devel

printf "$info" "\n[2/5] Removing potentially conflicting container packages...\n"
dnf remove -y \
    docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine \
    podman \
    runc || true

printf "$info" "\n[3/5] Adding Docker CE repository...\n"
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

printf "$info" "\n[4/5] Installing Docker Engine and plugins...\n"
dnf install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

printf "$info" "\n[5/5] Enabling and starting Docker...\n"
systemctl enable --now docker

printf "$info" "\nVerifying installation...\n"
docker --version
docker compose version
java -version

printf "$success" "\nSetup complete. Docker and Java 17 are installed.\n"
printf "$warning" "Tip: add your user to the docker group if you want to run Docker without sudo.\n"
printf "$warning" "Command: sudo usermod -aG docker <username>\n"
printf "$warning" "Log out and back in again after doing that.\n"
