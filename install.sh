#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# GitHub repository URL
REPO_URL="https://github.com/MohamedElashri/txm-bash"

# Check if Bash is installed
if ! command -v bash &> /dev/null
then
    echo -e "${RED}Error: Bash is not installed. Please install Bash before proceeding.${NC}"
    exit 1
fi

# Check if tmux is installed
if ! command -v tmux &> /dev/null
then
    echo -e "${YELLOW}Warning: tmux is not installed. Installing tmux...${NC}"
    sudo apt-get update
    sudo apt-get install -y tmux
fi

# Check if txm is already installed
if command -v txm &> /dev/null
then
    read -p "txm is already installed. Do you want to overwrite the existing installation? [y/N]: " overwrite
    overwrite=${overwrite:-N}
    if [[ $overwrite =~ ^[Yy]$ ]]
    then
        sudo rm -f /usr/local/bin/txm
    else
        echo -e "${YELLOW}Skipping installation. Exiting.${NC}"
        exit 0
    fi
fi

# Create a temporary directory for installation
temp_dir=$(mktemp -d)

# Download the txm script and man page from the GitHub repository
echo -e "${GREEN}Downloading txm script and man page...${NC}"
curl -sSL "$REPO_URL/raw/main/txm.sh" -o "$temp_dir/txm"
curl -sSL "$REPO_URL/raw/main/txm.1" -o "$temp_dir/txm.1"

# Check if the downloads were successful
if [[ $? -ne 0 ]]
then
    echo -e "${RED}Error: Failed to download txm script and/or man page. Please check your internet connection and try again.${NC}"
    rm -rf "$temp_dir"
    exit 1
fi

# Copy the txm script to /usr/local/bin
echo -e "${GREEN}Installing txm script...${NC}"
sudo cp "$temp_dir/txm" /usr/local/bin/
sudo chmod +x /usr/local/bin/txm

# Create the necessary configuration directories
mkdir -p "$HOME/.txm/layouts"

# Check if the man page directory exists
man_dir="/usr/local/share/man/man1"
if [[ ! -d "$man_dir" ]]
then
    echo -e "${YELLOW}Warning: Man page directory does not exist. Creating...${NC}"
    sudo mkdir -p "$man_dir"
fi

# Copy the man page to the appropriate location
echo -e "${GREEN}Installing man page...${NC}"
sudo cp "$temp_dir/txm.1" "$man_dir/"

# Update the man page index
echo -e "${GREEN}Updating man page index...${NC}"
sudo mandb

# Clean up the temporary directory
rm -rf "$temp_dir"

echo -e "${GREEN}Installation complete. Please source your shell's configuration file or start a new shell session for the changes to take effect.${NC}"
