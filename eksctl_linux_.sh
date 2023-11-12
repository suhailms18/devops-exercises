# Download the latest release of eksctl
curl -sLO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz"

# Extract the latest release of eksctl to tmp directory
tar -xzf eksctl_Linux_amd64.tar.gz -C /tmp

# Remove the zip file
rm eksctl_Linux_amd64.tar.gz

# Move the extracted binary to /usr/local/bin
sudo mv /tmp/eksctl /usr/local/bin

# Validating the installation
eksctl version
