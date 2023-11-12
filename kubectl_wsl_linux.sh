#!/bin/bash

# Download the latest release with the command
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl as root user
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install kubectl as normal user
# Grant the execute permission
chmod +x ./kubectl

# Move the binary to /usr/local/bin
sudo mv ./kubectl /usr/local/bin/kubectl

# Storing the user name to the variable
windowsUser=$1

# Creating a directory
mkdir -p ~/.kube

#Creating a sym link
ln -sf "/mnt/c/users/$windowsUser/.kube/config" ~/.kube/config

# Validating the installation
kubectl version
