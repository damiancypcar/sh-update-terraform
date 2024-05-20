#!/usr/bin/env bash
# ----------------------------------------------------------
# Author:          damiancypcar
# Modified:        2024-05-20
# Version:         1.0
# Desc:            Update Terraform to latest version
# ----------------------------------------------------------
set -e -o pipefail

TERRAFORM_NEW_VERSION=""
TERRAFORM_BIN_PATH="$HOME/AppData/Local/Programs/_bin"
# TERRAFORM_BIN_PATH="$PWD/bin"

function showHelp {
    echo -e "\nUpdate Terraform to latest version.\n\nUsage: $0\n\n-h --help\tshow this help\n"
}

function getTerraformVersion {
    if [ ! -f "$TERRAFORM_BIN_PATH/terraform.exe" ]; then
        echo "Terraform NOT found in $TERRAFORM_BIN_PATH"
        TERRAFORM_CURR_VERSION='-'
        TERRAFORM_NEW_VERSION='1.5.2'
        return
    fi

    local tfRawVersion
    local tfNewVersion
    tfRawVersion=$("$TERRAFORM_BIN_PATH/terraform" --version)
    # tfRawVersion="Terraform v1.5.2\non windows_amd64"
    tfRawVersion=($(echo "$tfRawVersion" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'))
    tfNewVersion=${tfRawVersion[1]}

    if [ -n "$tfNewVersion" ]; then
        TERRAFORM_NEW_VERSION="${tfNewVersion}"
        TERRAFORM_CURR_VERSION="${tfRawVersion[0]}"
    fi
}

function getTerraformBinary {
    echo
    echo "Downloading Terraform..."
    
    local tempDir
    tempDir=$(mktemp -d)
    # tempDir=$(mktemp -d -p "$PWD")
    cd "$tempDir"
    echo "Temp dir: $tempDir"
    
    dwnlURL="https://releases.hashicorp.com/terraform/${TERRAFORM_NEW_VERSION}/terraform_${TERRAFORM_NEW_VERSION}_windows_amd64.zip"
    outFile="terraform_${TERRAFORM_NEW_VERSION}_windows_amd64.zip"

    echo
    curl -o "$outFile" "$dwnlURL"
    unzip "$outFile" -d "$tempDir"
    
    echo
    echo "Copying to $TERRAFORM_BIN_PATH"
    if [ ! -d "$TERRAFORM_BIN_PATH" ]; then
        mkdir -p "$TERRAFORM_BIN_PATH"
    fi
    cp "$tempDir/terraform.exe" "$TERRAFORM_BIN_PATH/terraform.exe"
    cd - >/dev/null
}

function main {
    echo
    getTerraformVersion
    
    if [ -n "$TERRAFORM_NEW_VERSION" ]; then
        echo "Current version: $TERRAFORM_CURR_VERSION"
        echo "Update to $TERRAFORM_NEW_VERSION available."
        read -p "Are you sure you want to proceed (y/N)? " confirmation
        if [ "$confirmation" == "y" ]; then
            getTerraformBinary
            echo "Done"
        else
            echo "Exiting"
            return
        fi
    else
        echo "Terraform is up to date!"
    fi
}


case $1 in
	"-h"|"--help") showHelp ;;
	*) main ;;
esac
