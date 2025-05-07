#!/bin/bash
arg1=$1
LOCAL_BIN=/usr/local/bin

mkdir -p ${LOCAL_BIN}

if [ "$HOME" = "/home/vscode" ]; then
  # Local Devcontainer Environment
  TFENV_INSTALL_DIR="/home/vscode/.tfenv"
  TDOC="/home/vscode/.t-docs"
elif [ "$HOME" = "/home/vsts" ]; then
  # Azure pipelines Environment
  TFENV_INSTALL_DIR="/home/vsts/.tfenv"
  TDOC="/home/vsts/.t-docs"
else
  # Default Environment
  TFENV_INSTALL_DIR="${HOME}/.tfenv"
  TDOC="${HOME}/.t-docs"
fi

# Install tfenv
git clone --depth 1 https://github.com/tfutils/tfenv.git "${TFENV_INSTALL_DIR}"

sudo ln -s "${TFENV_INSTALL_DIR}/bin/tfenv" ${LOCAL_BIN}/tfenv
sudo ln -s "${TFENV_INSTALL_DIR}/bin/terraform" ${LOCAL_BIN}/terraform

# Install terraform
tfenv install $arg1
tfenv use $arg1

# Install tflint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | sudo bash

# Install tfsec
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | sudo bash

# Install terraform-docs
mkdir -p ${TDOC}
cd ${TDOC}
curl -Lo terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.20.0/terraform-docs-v0.20.0-linux-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
sudo mv terraform-docs ${LOCAL_BIN}
cd ../
rm -r ${TDOC}
